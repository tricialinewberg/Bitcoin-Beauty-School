# Belle Proxy

> **⚠️ Not currently in use.** Belle was redesigned to answer from a scripted, offline, keyword-matched response system (see [`content/belle/belle_scripted_responses.json`](../../content/belle/belle_scripted_responses.json) and `lib/services/belle_response_matcher.dart`) instead of a live LLM — no ongoing API cost, no network dependency, nothing to rate-limit or secure. This Worker is **not deployed and the app does not call it.** The code below is preserved as-is in case that decision is revisited (e.g. if scripted responses turn out too limited for some future need) — it was fully built, unit-tested, and verified locally (see "Verifying it actually works" below) before the direction changed, so it's ready to pick back up rather than rebuild from scratch. Don't deploy it or wire the app to it without re-confirming the cost/complexity trade-off still makes sense at that point.

A small Cloudflare Worker that mediates every call to Claude on Belle's behalf, so the Anthropic API key never has to exist inside the Flutter app binary or any client-side code.

```
Flutter app → POST /chat → this Worker → Anthropic Messages API
                              ↑
                     content/belle/*.md
                (system prompt + knowledge base,
                 bundled in at build time)
```

## Why Cloudflare Workers

This needed to be _something_ server-side — an LLM API key genuinely can't live on a device, unlike the rest of this app's data layer, which deliberately avoids a traditional backend. Given that one exception is unavoidable, the choice was between a few small serverless platforms:

- **Cloudflare Workers (chosen)**: free tier covers this app's expected scale many times over (100K requests/day, no time limit on trial), secrets are one `wrangler secret put` command, KV (used here for rate limiting) is in the same free tier, and `wrangler dev` gives a fully local dev loop with no account needed to iterate. No cold-start-heavy container runtime — Workers are designed to run this exact shape of workload (a small stateless HTTP function) cheaply at low volume.
- **Vercel Edge Functions**: comparable model, but more naturally reached for when the surrounding project is already a Vercel-hosted frontend, which this isn't.
- **Google Cloud Functions**: viable, but pulls in the broader GCP console/IAM surface for what's a single function, and sits closer to the "big-tech-dependent backend" this project has otherwise deliberately avoided (see the README's Nostr/self-custody design notes). Since this function is an unavoidable exception to that philosophy, not an extension of it, there's no reason to also take on GCP's heavier operational surface for it. Firebase specifically was ruled out for the same reason, plus it's the wrong shape of product for "one HTTP endpoint."

Cloudflare Workers gives the smallest operational footprint for the smallest possible exception to this project's no-traditional-backend design.

## Context management: full file, no retrieval (for now)

`content/belle/knowledge_base.md` is ~40KB (~10K tokens) today. That's sent in full as part of the system prompt on every request — see [`src/content.ts`](src/content.ts). At this app's expected request volume, that's cheap and comfortably inside Claude's context window; building topic-based retrieval or chunking now would be solving a problem this project doesn't have yet. The two files are imported directly from `content/belle/` (via a wrangler "Text" module rule — see `wrangler.toml`) rather than copied into this directory, so there's exactly one copy of Belle's content and no sync step to forget.

Prompt caching (`cache_control: { type: "ephemeral" }` on the system block in [`src/anthropic.ts`](src/anthropic.ts)) means repeat requests within the cache TTL don't pay full price to reprocess that ~10K-token block every time — a close-to-free win given the content is identical on every call.

**Revisit later, not now:** if `knowledge_base.md` keeps growing well past its current size, or request volume grows enough that full-file cost adds up, that's the point to introduce per-topic or per-tier retrieval instead of sending the whole file — flagged for a future pass, not a problem today.

## API contract

### `POST /chat`

Request:

```json
{
  "pubkey": "64-character hex Nostr pubkey",
  "message": "the user's latest message",
  "history": [
    { "role": "user", "content": "..." },
    { "role": "assistant", "content": "..." }
  ]
}
```

- `pubkey` — required, must be exactly 64 hex characters. This is the app's existing per-install Nostr identity (see `lib/services/nostr_keys.dart`), reused here purely as a rate-limit bucket key — **it is not cryptographically verified** (see "Abuse protection" below).
- `message` — required, non-empty, up to 4000 characters.
- `history` — optional. Only the most recent 12 entries are used server-side; older ones are silently dropped rather than rejected, so a client that sends more than it needs still gets a valid response. Each entry needs `role` (`"user"` or `"assistant"`) and `content` (1–4000 characters).

Response (200):

```json
{ "reply": "Belle's response text" }
```

Error responses (400/404/405/413/429/500/502) are `{ "error": "human-readable reason" }`. The app should treat any non-200 as "Belle couldn't respond right now," matching the tone `system_prompt.md` already establishes for gaps/failures — no need to surface raw error bodies to the user.

### `GET /health`

Returns `{ "status": "ok" }`. Costs nothing (never touches Anthropic) — use this first when checking a fresh deploy.

## Abuse protection

Three independent, cheapest-first checks per request, all backed by the `RATE_LIMIT_KV` namespace (see [`src/ratelimit.ts`](src/ratelimit.ts)):

1. **Global daily cap** (`GLOBAL_DAILY_LIMIT`, default 2000/day) — a hard backstop on total spend, regardless of who's asking.
2. **Per-pubkey** (`PER_PUBKEY_LIMIT`, default 30/hour) — keyed on the app's own stable identifier.
3. **Per-IP** (`PER_IP_LIMIT`, default 60/hour) — via `CF-Connecting-IP`, catches a spammer hitting the endpoint directly without bothering to send a plausible request at all.

All three are simple fixed-window counters (documented in `ratelimit.ts`), not sliding windows — good enough to deter casual/accidental abuse, not precision rate limiting.

**Known limitation, deliberately not fixed here:** `pubkey` is client-supplied and never signature-verified — the endpoint doesn't check that the caller actually holds the private key for it. A motivated attacker could bypass the per-pubkey limit by fabricating a new one on every request. The global and per-IP caps are what actually bound the damage in that scenario. Closing this properly would mean requiring a signed challenge (proving key ownership) on each request — a real feature with real design decisions of its own, not "basic" abuse protection, so it's out of scope here. Worth building if this ever needs to survive a targeted attacker rather than casual/accidental abuse.

`MAX_OUTPUT_TOKENS` (default 700, set server-side in `wrangler.toml`, never client-controlled) caps the cost of any single response regardless of the above.

## Setup (one-time, on your Cloudflare account)

You'll need to do this part yourself — I don't have access to your Cloudflare or Anthropic accounts.

1. **Cloudflare account**: sign up at [dash.cloudflare.com](https://dash.cloudflare.com) if you don't have one (free tier is enough).
2. **Anthropic API key**: create one at [console.anthropic.com](https://console.anthropic.com) → Settings → API Keys. Put a small spending limit on it while testing.
3. Install dependencies and log in:
   ```bash
   cd backend/belle-proxy
   npm install
   npx wrangler login
   ```
   This opens a browser to authorize Wrangler against your Cloudflare account.
4. **Create the KV namespace** used for rate limiting:
   ```bash
   npx wrangler kv namespace create RATE_LIMIT_KV
   ```
   This prints an `id`. Copy it into `wrangler.toml`, replacing `REPLACE_WITH_YOUR_KV_NAMESPACE_ID`.
5. **Set the Anthropic API key as a Worker secret** (never goes in `wrangler.toml`, never gets committed):
   ```bash
   npx wrangler secret put ANTHROPIC_API_KEY
   ```
   Paste your key at the prompt. Wrangler stores it encrypted on Cloudflare's side; it's not written to any file in this repo.
6. **Deploy**:
   ```bash
   npm run deploy
   ```
   Wrangler prints the deployed URL (`https://belle-proxy.<your-subdomain>.workers.dev`).

## Local development

```bash
cp .dev.vars.example .dev.vars   # then edit in your real key — this file is gitignored
npm run dev
```

`wrangler dev` runs the Worker locally (Miniflare) with a local, disposable KV store — no Cloudflare account traffic, no cost, and it doesn't touch the real rate-limit counters. `.dev.vars` is only for this local loop; the deployed Worker always uses the `wrangler secret` from step 5 above, not this file.

## Verifying it actually works

Local (no cost, no account needed beyond what setup already required):

```bash
npm test          # unit tests for validation + rate limiting
npm run typecheck
npm run dev        # in one terminal
curl http://127.0.0.1:8787/health   # in another — expect {"status":"ok"}
```

Once deployed, confirm the real thing end-to-end (this part only you can do, since it needs your live URL and spends a small amount of real API credit):

```bash
# 1. Liveness — free, no Anthropic call
curl https://belle-proxy.<your-subdomain>.workers.dev/health

# 2. A real Belle reply — this one costs a few cents' worth of tokens
curl -X POST https://belle-proxy.<your-subdomain>.workers.dev/chat \
  -H "content-type: application/json" \
  -d '{
    "pubkey": "'"$(printf 'a%.0s' {1..64})"'",
    "message": "What is a satoshi?"
  }'
```

Expect a 200 with `{"reply": "..."}` in Belle's voice. If you get a 502, double-check the secret was set correctly (`npx wrangler secret list` shows names, not values) and that your Anthropic account has available credit.

This was already verified locally during development (validation, routing, and the full request path up through a real call attempt to the Anthropic API all confirmed working via `wrangler dev` with a dummy key) — what's left is the one live call above, against your real deployed Worker and real key, which needs your account and isn't something that could be done on your behalf.

## Wiring up the Flutter app

Not done as part of this task — the app doesn't call this endpoint yet. When that's built, it needs the deployed Worker's URL (probably as a build-time config value, not hardcoded, since it'll differ between your dev/staging Worker and production if you ever split those) and should send the existing Nostr pubkey ([`lib/services/nostr_keys.dart`](../../lib/services/nostr_keys.dart)) plus a trimmed slice of recent chat history per the contract above.
