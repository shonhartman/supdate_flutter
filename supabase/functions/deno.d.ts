/**
 * Minimal Deno global types for Supabase Edge Functions.
 * Edge Functions run on Deno; the IDE needs this to resolve Deno.env and Deno.serve.
 */
declare const Deno: {
  env: {
    get(key: string): string | undefined;
  };
  serve: (handler: (req: Request) => Response | Promise<Response>) => void;
};
