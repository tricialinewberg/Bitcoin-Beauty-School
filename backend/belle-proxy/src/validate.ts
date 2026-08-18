export interface ChatMessage {
  role: "user" | "assistant";
  content: string;
}

export interface ChatRequest {
  pubkey: string;
  message: string;
  history: ChatMessage[];
}

export const MAX_MESSAGE_LENGTH = 4000;

// Older turns are dropped, not rejected — a client that sends a longer
// history than this still gets a valid response, just with less context,
// rather than an error over something the app itself controls.
export const MAX_HISTORY_ITEMS = 12;

const PUBKEY_RE = /^[0-9a-f]{64}$/i;

export type ValidationResult =
  | { ok: true; value: ChatRequest }
  | { ok: false; error: string };

function isValidHistoryItem(item: unknown): item is ChatMessage {
  if (typeof item !== "object" || item === null) return false;
  const { role, content } = item as Record<string, unknown>;
  return (
    (role === "user" || role === "assistant") &&
    typeof content === "string" &&
    content.length > 0 &&
    content.length <= MAX_MESSAGE_LENGTH
  );
}

/**
 * Validates and normalizes an untyped JSON body into a {@link ChatRequest}.
 * Rejects malformed/oversized input outright; history that's merely too
 * long is trimmed to the most recent {@link MAX_HISTORY_ITEMS} entries
 * rather than rejected.
 */
export function validateChatRequest(body: unknown): ValidationResult {
  if (typeof body !== "object" || body === null) {
    return { ok: false, error: "Request body must be a JSON object." };
  }
  const b = body as Record<string, unknown>;

  if (typeof b.pubkey !== "string" || !PUBKEY_RE.test(b.pubkey)) {
    return { ok: false, error: "pubkey must be a 64-character hex string." };
  }

  if (typeof b.message !== "string" || b.message.trim().length === 0) {
    return { ok: false, error: "message must be a non-empty string." };
  }
  if (b.message.length > MAX_MESSAGE_LENGTH) {
    return {
      ok: false,
      error: `message must be at most ${MAX_MESSAGE_LENGTH} characters.`,
    };
  }

  let history: ChatMessage[] = [];
  if (b.history !== undefined) {
    if (!Array.isArray(b.history)) {
      return { ok: false, error: "history must be an array." };
    }
    for (const item of b.history) {
      if (!isValidHistoryItem(item)) {
        return {
          ok: false,
          error:
            "Each history item must be { role: 'user' | 'assistant', " +
            `content: string } with content 1-${MAX_MESSAGE_LENGTH} characters.`,
        };
      }
      history.push(item);
    }
    if (history.length > MAX_HISTORY_ITEMS) {
      history = history.slice(history.length - MAX_HISTORY_ITEMS);
    }
  }

  return { ok: true, value: { pubkey: b.pubkey, message: b.message, history } };
}
