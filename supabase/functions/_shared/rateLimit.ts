/**
 * In-memory rate limiter per user. Resets on cold start.
 * Limits: MAX_REQUESTS per user per WINDOW_MS.
 */

const MAX_REQUESTS = 20;
const WINDOW_MS = 60 * 60 * 1000; // 1 hour

const requestTimestamps = new Map<string, number[]>();

export function checkRateLimit(userId: string): { allowed: boolean; retryAfter?: number } {
  const now = Date.now();
  const cutoff = now - WINDOW_MS;
  let timestamps = requestTimestamps.get(userId) ?? [];
  timestamps = timestamps.filter((t) => t > cutoff);

  if (timestamps.length >= MAX_REQUESTS) {
    const oldestInWindow = Math.min(...timestamps);
    return { allowed: false, retryAfter: Math.ceil((oldestInWindow + WINDOW_MS - now) / 1000) };
  }

  timestamps.push(now);
  requestTimestamps.set(userId, timestamps);
  return { allowed: true };
}
