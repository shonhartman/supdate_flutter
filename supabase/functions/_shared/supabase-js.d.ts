/** Type declaration for remote Deno import; matches usage in auth.ts. */
declare module "https://esm.sh/@supabase/supabase-js@2" {
  export function createClient(
    url: string,
    key: string,
    options?: { global?: { headers?: Record<string, string> } }
  ): {
    auth: {
      getUser(
        token: string
      ): Promise<{
        data: { user: { id: string } | null };
        error: { message?: string } | null;
      }>;
    };
  };
}
