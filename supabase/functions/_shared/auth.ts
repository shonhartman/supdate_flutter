/**
 * Auth helpers for Edge Functions: validate JWT and return user id for rate limiting.
 */

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

export async function getUserIdFromRequest(
  req: Request
): Promise<{ userId: string } | { error: Response }> {
  const authHeader = req.headers.get("Authorization");
  if (!authHeader?.startsWith("Bearer ")) {
    return {
      error: new Response(
        JSON.stringify({ error: "Missing or invalid Authorization header" }),
        { status: 401, headers: { "Content-Type": "application/json" } }
      ),
    };
  }

  const token = authHeader.slice(7);
  const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
  const supabaseAnonKey = Deno.env.get("SUPABASE_ANON_KEY")!;
  const client = createClient(supabaseUrl, supabaseAnonKey, {
    global: { headers: { Authorization: authHeader } },
  });

  const {
    data: { user },
    error,
  } = await client.auth.getUser(token);

  if (error || !user) {
    return {
      error: new Response(
        JSON.stringify({ error: "Unauthorized", detail: error?.message }),
        { status: 401, headers: { "Content-Type": "application/json" } }
      ),
    };
  }

  return { userId: user.id };
}
