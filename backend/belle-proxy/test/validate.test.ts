import { describe, expect, it } from "vitest";
import { MAX_HISTORY_ITEMS, MAX_MESSAGE_LENGTH, validateChatRequest } from "../src/validate";

const validPubkey = "a".repeat(64);

describe("validateChatRequest", () => {
  it("accepts a minimal valid request", () => {
    const result = validateChatRequest({ pubkey: validPubkey, message: "hi belle" });
    expect(result.ok).toBe(true);
    if (result.ok) {
      expect(result.value.history).toEqual([]);
    }
  });

  it("rejects a non-object body", () => {
    expect(validateChatRequest("nope").ok).toBe(false);
    expect(validateChatRequest(null).ok).toBe(false);
    expect(validateChatRequest(42).ok).toBe(false);
  });

  it("rejects a missing pubkey", () => {
    expect(validateChatRequest({ message: "hi" }).ok).toBe(false);
  });

  it("rejects a malformed pubkey", () => {
    expect(validateChatRequest({ pubkey: "not-hex", message: "hi" }).ok).toBe(false);
    expect(validateChatRequest({ pubkey: "a".repeat(63), message: "hi" }).ok).toBe(false);
  });

  it("accepts an uppercase-hex pubkey", () => {
    expect(validateChatRequest({ pubkey: "A".repeat(64), message: "hi" }).ok).toBe(true);
  });

  it("rejects an empty or whitespace-only message", () => {
    expect(validateChatRequest({ pubkey: validPubkey, message: "" }).ok).toBe(false);
    expect(validateChatRequest({ pubkey: validPubkey, message: "   " }).ok).toBe(false);
  });

  it("rejects an over-length message", () => {
    const result = validateChatRequest({
      pubkey: validPubkey,
      message: "x".repeat(MAX_MESSAGE_LENGTH + 1),
    });
    expect(result.ok).toBe(false);
  });

  it("accepts a message at exactly the length cap", () => {
    const result = validateChatRequest({
      pubkey: validPubkey,
      message: "x".repeat(MAX_MESSAGE_LENGTH),
    });
    expect(result.ok).toBe(true);
  });

  it("rejects a malformed history item", () => {
    expect(
      validateChatRequest({
        pubkey: validPubkey,
        message: "hi",
        history: [{ role: "system", content: "nope" }],
      }).ok,
    ).toBe(false);

    expect(
      validateChatRequest({
        pubkey: validPubkey,
        message: "hi",
        history: [{ role: "user", content: "" }],
      }).ok,
    ).toBe(false);

    expect(
      validateChatRequest({
        pubkey: validPubkey,
        message: "hi",
        history: "not-an-array",
      }).ok,
    ).toBe(false);
  });

  it("trims history down to the most recent MAX_HISTORY_ITEMS entries", () => {
    const history = Array.from({ length: MAX_HISTORY_ITEMS + 5 }, (_, i) => ({
      role: i % 2 === 0 ? "user" : "assistant",
      content: `message ${i}`,
    }));
    const result = validateChatRequest({ pubkey: validPubkey, message: "hi", history });
    expect(result.ok).toBe(true);
    if (result.ok) {
      expect(result.value.history).toHaveLength(MAX_HISTORY_ITEMS);
      expect(result.value.history[0].content).toBe("message 5");
      expect(result.value.history[result.value.history.length - 1].content).toBe(
        `message ${MAX_HISTORY_ITEMS + 4}`,
      );
    }
  });
});
