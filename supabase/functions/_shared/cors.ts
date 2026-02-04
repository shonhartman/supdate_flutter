/**
 * CORS headers for Supabase Edge Function responses.
 * Allow the Flutter app origin and required methods/headers.
 */

const DEFAULT_ALLOW_ORIGIN = "*";

export function corsHeaders(origin?: string | null): Record<string, string> {
  return {
    "Access-Control-Allow-Origin": origin ?? DEFAULT_ALLOW_ORIGIN,
    "Access-Control-Allow-Methods": "POST, OPTIONS",
    "Access-Control-Allow-Headers":
      "Authorization, Content-Type, X-Client-Info",
    "Access-Control-Max-Age": "86400",
  };
}

export function respondCorsPreflight(): Response {
  return new Response(null, {
    status: 204,
    headers: corsHeaders(),
  });
}
