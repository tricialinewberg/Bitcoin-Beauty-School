import { validateChatRequest } from "./validate";
import { checkAndIncrement } from "./ratelimit";
import { callBelle, UpstreamError } from "./anthropic";

export interface Env {
  ANTHROPIC_API_KEY: string;
  ANTHROPIC_MODEL: string;
  MAX_OUTPUT_TOKENS: number;
  PER_PUBKEY_LIMIT: number;
  PER_PUBKEY_WINDOW_SECONDS: number;
  PER_IP_LIMIT: number;
  PER_IP_WINDOW_SECONDS: number;
  GLOBAL_DAILY_LIMIT: number;
  RATE_LIMIT_KV: KVNamespace;
}

// First line of defense before we even try to parse JSON — generous
// headroom over MAX_MESSAGE_LENGTH * (1 + MAX_HISTORY_ITEMS) so a
// legitimate max-size request never trips it, but a multi-megabyte body
// gets rejected without ever being parsed.
const MAX_BODY_BYTES = 80_000;

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      "content-type": "application/json",
      // The proxy is called from the Flutter app's native HTTP client, not
      // a browser page, so CORS isn't strictly load-bearing — but it's
      // harmless to include, and keeps curl/browser-based manual testing
      // (see README) and a possible future Flutter Web build unblocked.
      "access-control-allow-origin": "*",
    },
  });
}

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    const url = new URL(request.url);

    if (request.method === "OPTIONS") {
      return new Response(null, {
        status: 204,
        headers: {
          "access-control-allow-origin": "*",
          "access-control-allow-methods": "POST, OPTIONS",
          "access-control-allow-headers": "content-type",
        },
      });
    }

    // Zero-cost liveness check — confirms the Worker is deployed and
    // reachable without spending anything on the Anthropic API. Check this
    // first when verifying a fresh deploy (see README).
    if (request.method === "GET" && url.pathname === "/health") {
      return json({ status: "ok" });
    }

    if (url.pathname !== "/chat") {
      return json({ error: "Not found." }, 404);
    }
    if (request.method !== "POST") {
      return json({ error: "Only POST is supported." }, 405);
    }

    const contentLength = request.headers.get("content-length");
    if (contentLength && Number(contentLength) > MAX_BODY_BYTES) {
      return json({ error: "Request body too large." }, 413);
    }

    let rawBody: unknown;
    try {
      rawBody = await request.json();
    } catch {
      return json({ error: "Request body must be valid JSON." }, 400);
    }

    const validation = validateChatRequest(rawBody);
    if (!validation.ok) {
      return json({ error: validation.error }, 400);
    }
    const { pubkey, message, history } = validation.value;

    // Three independent counters, cheapest/most-durable first:
    //  1. global daily cap — a hard backstop on total spend regardless of
    //     who's asking or how they're identified (see the pubkey caveat
    //     below and in README's "Abuse protection" section).
    //  2. per-pubkey — the app's own stable per-install identifier.
    //  3. per-IP — catches a single spammer hitting the endpoint directly
    //     without bothering to send a plausible pubkey at all.
    // None of this is signature-verified (the endpoint never checks that
    // the caller actually controls the private key for `pubkey`), so a
    // motivated attacker can bypass #2 by rotating fabricated pubkeys —
    // #1 and #3 are what actually bound the damage in that case. Real
    // protection against that would mean requiring a signed challenge,
    // which is a real feature, not "basic" abuse protection — flagged in
    // README as a deliberate scope cut, not an oversight.
    const globalCheck = await checkAndIncrement(
      env.RATE_LIMIT_KV,
      "rl:global",
      Number(env.GLOBAL_DAILY_LIMIT),
      24 * 3600,
    );
    if (!globalCheck.allowed) {
      return json(
        { error: "Belle is getting more messages than expected right now — please try again later." },
        429,
      );
    }

    const pubkeyCheck = await checkAndIncrement(
      env.RATE_LIMIT_KV,
      `rl:pk:${pubkey}`,
      Number(env.PER_PUBKEY_LIMIT),
      Number(env.PER_PUBKEY_WINDOW_SECONDS),
    );
    if (!pubkeyCheck.allowed) {
      return json(
        { error: "You're sending messages a bit too fast — take a short break and try again." },
        429,
      );
    }

    const ip = request.headers.get("cf-connecting-ip") ?? "unknown";
    const ipCheck = await checkAndIncrement(
      env.RATE_LIMIT_KV,
      `rl:ip:${ip}`,
      Number(env.PER_IP_LIMIT),
      Number(env.PER_IP_WINDOW_SECONDS),
    );
    if (!ipCheck.allowed) {
      return json({ error: "Too many requests from this network — please try again later." }, 429);
    }

    try {
      const reply = await callBelle({
        apiKey: env.ANTHROPIC_API_KEY,
        model: env.ANTHROPIC_MODEL,
        maxTokens: Number(env.MAX_OUTPUT_TOKENS),
        history,
        message,
      });
      return json({ reply });
    } catch (err) {
      console.error("Belle proxy upstream error:", err);
      const status = err instanceof UpstreamError ? 502 : 500;
      return json({ error: "Belle couldn't respond right now — please try again." }, status);
    }
  },
};
