import { describe, expect, it } from "vitest";
import { checkAndIncrement, type RateLimitStore } from "../src/ratelimit";

function createMemoryStore(): RateLimitStore {
  const map = new Map<string, string>();
  return {
    async get(key) {
      return map.get(key) ?? null;
    },
    async put(key, value) {
      map.set(key, value);
    },
  };
}

describe("checkAndIncrement", () => {
  it("allows requests under the limit and reports remaining correctly", async () => {
    const store = createMemoryStore();
    const r1 = await checkAndIncrement(store, "k", 3, 60);
    const r2 = await checkAndIncrement(store, "k", 3, 60);
    const r3 = await checkAndIncrement(store, "k", 3, 60);
    expect(r1).toEqual({ allowed: true, remaining: 2 });
    expect(r2).toEqual({ allowed: true, remaining: 1 });
    expect(r3).toEqual({ allowed: true, remaining: 0 });
  });

  it("blocks once the limit is reached", async () => {
    const store = createMemoryStore();
    await checkAndIncrement(store, "k", 2, 60);
    await checkAndIncrement(store, "k", 2, 60);
    const r3 = await checkAndIncrement(store, "k", 2, 60);
    expect(r3.allowed).toBe(false);
    expect(r3.remaining).toBe(0);
  });

  it("keeps blocking on subsequent calls within the same window", async () => {
    const store = createMemoryStore();
    await checkAndIncrement(store, "k", 1, 60);
    await checkAndIncrement(store, "k", 1, 60);
    const r3 = await checkAndIncrement(store, "k", 1, 60);
    expect(r3.allowed).toBe(false);
  });

  it("tracks separate keys independently", async () => {
    const store = createMemoryStore();
    await checkAndIncrement(store, "a", 1, 60);
    const blockedA = await checkAndIncrement(store, "a", 1, 60);
    const allowedB = await checkAndIncrement(store, "b", 1, 60);
    expect(blockedA.allowed).toBe(false);
    expect(allowedB.allowed).toBe(true);
  });

  it("a limit of 0 blocks immediately", async () => {
    const store = createMemoryStore();
    const r = await checkAndIncrement(store, "k", 0, 60);
    expect(r.allowed).toBe(false);
  });
});
