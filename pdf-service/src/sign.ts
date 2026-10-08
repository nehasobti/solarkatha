import { createHmac, timingSafeEqual } from "node:crypto";

/** Requests older than this are rejected (replay protection). */
export const MAX_SKEW_SECONDS = 300;

/** HMAC-SHA256 hex of `${timestamp}.${body}` with the shared secret. */
export function signBody(secret: string, timestamp: string, body: string): string {
  return createHmac("sha256", secret).update(`${timestamp}.${body}`).digest("hex");
}

export function verifySignature(opts: {
  secret: string;
  timestamp: string | null;
  signature: string | null;
  body: string;
  nowSeconds?: number;
}): boolean {
  const { secret, timestamp, signature, body } = opts;
  if (!secret || !timestamp || !signature) return false;
  const ts = Number(timestamp);
  const now = opts.nowSeconds ?? Math.floor(Date.now() / 1000);
  if (!Number.isFinite(ts) || Math.abs(now - ts) > MAX_SKEW_SECONDS) return false;
  const expected = Buffer.from(signBody(secret, timestamp, body), "hex");
  const given = Buffer.from(signature, "hex");
  return given.length === expected.length && timingSafeEqual(given, expected);
}
