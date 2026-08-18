import { combinedSystemPrompt } from "./content";
import type { ChatMessage } from "./validate";

export class UpstreamError extends Error {}

export interface AnthropicCallParams {
  apiKey: string;
  model: string;
  maxTokens: number;
  history: ChatMessage[];
  message: string;
}

interface AnthropicResponse {
  content: Array<{ type: string; text?: string }>;
}

/**
 * Calls the Anthropic Messages API directly via fetch rather than the
 * official SDK — the SDK is a fine choice generally, but for a single Worker
 * endpoint that makes one kind of call, a raw fetch keeps the bundle small
 * and the request shape fully visible in one place, with no SDK version to
 * track. Revisit if this proxy grows to use more of the API surface.
 */
export async function callBelle(params: AnthropicCallParams): Promise<string> {
  const { apiKey, model, maxTokens, history, message } = params;

  const messages = [
    ...history.map((m) => ({ role: m.role, content: m.content })),
    { role: "user" as const, content: message },
  ];

  const response = await fetch("https://api.anthropic.com/v1/messages", {
    method: "POST",
    headers: {
      "content-type": "application/json",
      "x-api-key": apiKey,
      "anthropic-version": "2023-06-01",
    },
    body: JSON.stringify({
      model,
      max_tokens: maxTokens,
      // cache_control on the system block lets Anthropic cache Belle's
      // ~13K-token system prompt (persona + knowledge base) across
      // requests within its TTL, instead of billing and re-processing the
      // full thing on every single message — it's identical every call, so
      // this is close to a pure win at this app's request volume.
      system: [
        {
          type: "text",
          text: combinedSystemPrompt,
          cache_control: { type: "ephemeral" },
        },
      ],
      messages,
    }),
  });

  if (!response.ok) {
    const detail = await response.text();
    throw new UpstreamError(`Anthropic API returned ${response.status}: ${detail}`);
  }

  const data = (await response.json()) as AnthropicResponse;
  const text = data.content
    .filter((block) => block.type === "text" && typeof block.text === "string")
    .map((block) => block.text)
    .join("");

  if (!text) {
    throw new UpstreamError("Anthropic API returned no text content.");
  }

  return text;
}
