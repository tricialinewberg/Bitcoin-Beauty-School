// Narrowed to just the two KV operations actually used, so this logic can
// be unit-tested against a plain in-memory fake instead of needing the real
// Workers runtime (see test/ratelimit.test.ts). Cloudflare's KVNamespace
// type satisfies this structurally, no adapter needed.
export interface RateLimitStore {
  get(key: string): Promise<string | null>;
  put(key: string, value: string, opts: { expirationTtl: number }): Promise<void>;
}

export interface RateLimitResult {
  allowed: boolean;
  remaining: number;
}

/**
 * Fixed-window request counter: one KV read + (on the request that
 * consumes the last slot before rejecting, and every request under the
 * limit) one KV write per call.
 *
 * This is not a precise sliding window — a caller could in theory get up
 * to ~2x the stated limit by timing requests around a window boundary —
 * but that imprecision is an acceptable trade for the simplicity of a
 * single counter key, and is plenty to deter casual/accidental abuse
 * (a buggy retry loop, someone spamming the endpoint by hand) at this
 * app's scale. It is not a defense against a determined attacker; see the
 * README's "Abuse protection" section for that caveat in full, including
 * why per-pubkey limiting alone doesn't stop someone willing to fabricate
 * new pubkeys per request.
 */
export async function checkAndIncrement(
  store: RateLimitStore,
  key: string,
  limit: number,
  windowSeconds: number,
): Promise<RateLimitResult> {
  const windowStart = Math.floor(Date.now() / 1000 / windowSeconds) * windowSeconds;
  const storageKey = `${key}:${windowStart}`;

  const current = await store.get(storageKey);
  const count = current ? parseInt(current, 10) : 0;

  if (count >= limit) {
    return { allowed: false, remaining: 0 };
  }

  // TTL padded past the window itself so a slow/retried write can't leave
  // a stale key alive into the *next* window and undercount it.
  await store.put(storageKey, String(count + 1), { expirationTtl: windowSeconds + 60 });
  return { allowed: true, remaining: limit - count - 1 };
}
