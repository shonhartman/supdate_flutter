/**
 * recommend-photo: Supabase Edge Function
 * Accepts 2–10 base64 images, calls Gemini 1.5 Flash (Vision), returns
 * { recommendedIndex, caption, vibe }. Requires Authorization header for rate limiting.
 */

import { corsHeaders } from "../_shared/cors.ts";
import { getUserIdFromRequest } from "../_shared/auth.ts";
import { checkRateLimit } from "../_shared/rateLimit.ts";

const MIN_IMAGES = 2;
const MAX_IMAGES = 10;
const MAX_BASE64_BYTES_PER_IMAGE = 5 * 1024 * 1024; // 5MB sanity check
// gemini-1.5-flash is deprecated; use stable gemini-2.5-flash (supports images + generateContent).
const GEMINI_MODEL = "gemini-2.5-flash";
const GEMINI_BASE = "https://generativelanguage.googleapis.com/v1beta";

const SYSTEM_INSTRUCTION =
  'You are an expert social media editor. Analyze the provided images and select the single best one for an engaging social post. Return ONLY a JSON object: { "recommendedIndex": number, "caption": "string", "vibe": "string" }.';

interface ImagePart {
  base64: string;
  mimeType: string;
}

interface RequestBody {
  images: ImagePart[];
}

interface CuratorResponse {
  recommendedIndex: number;
  caption: string;
  vibe: string;
}

function jsonResponse(
  data: unknown,
  status: number,
  origin: string | null
): Response {
  return new Response(JSON.stringify(data), {
    status,
    headers: {
      "Content-Type": "application/json",
      ...corsHeaders(origin),
    },
  });
}

async function parseBody(req: Request): Promise<RequestBody | { error: string }> {
  try {
    const body = (await req.json()) as unknown;
    if (!body || typeof body !== "object" || !Array.isArray((body as RequestBody).images)) {
      return { error: "Body must be { images: [ { base64, mimeType } ] }" };
    }
    const { images } = body as RequestBody;
    if (images.length < MIN_IMAGES || images.length > MAX_IMAGES) {
      return {
        error: `images must contain between ${MIN_IMAGES} and ${MAX_IMAGES} items`,
      };
    }
    for (let i = 0; i < images.length; i++) {
      const img = images[i];
      if (!img || typeof img.base64 !== "string" || typeof img.mimeType !== "string") {
        return { error: `images[${i}] must have base64 and mimeType strings` };
      }
      const approxBytes = (img.base64.length * 3) / 4;
      if (approxBytes > MAX_BASE64_BYTES_PER_IMAGE) {
        return { error: `images[${i}] exceeds max size (5MB)` };
      }
    }
    return { images };
  } catch {
    return { error: "Invalid JSON body" };
  }
}

function buildGeminiParts(images: ImagePart[]): Record<string, unknown>[] {
  const parts: Record<string, unknown>[] = images.map((img) => ({
    inlineData: {
      mimeType: img.mimeType,
      data: img.base64,
    },
  }));
  parts.push({
    text: "Analyze these images and select the single best one for an engaging social post. Reply with the JSON only.",
  });
  return parts;
}

async function callGemini(images: ImagePart[]): Promise<CuratorResponse> {
  const apiKey = Deno.env.get("GEMINI_API_KEY");
  if (!apiKey) {
    throw new Error("GEMINI_API_KEY is not set");
  }

  const url = `${GEMINI_BASE}/models/${GEMINI_MODEL}:generateContent?key=${apiKey}`;
  const body = {
    contents: [
      {
        role: "user",
        parts: buildGeminiParts(images),
      },
    ],
    systemInstruction: {
      parts: [{ text: SYSTEM_INSTRUCTION }],
    },
    generationConfig: {
      responseMimeType: "application/json",
    },
  };

  const res = await fetch(url, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(body),
  });

  if (!res.ok) {
    const errText = await res.text();
    throw new Error(`Gemini API error ${res.status}: ${errText}`);
  }

  const data = (await res.json()) as {
    candidates?: Array<{
      content?: { parts?: Array<{ text?: string }> };
    }>;
  };
  const text =
    data.candidates?.[0]?.content?.parts?.[0]?.text?.trim();
  if (!text) {
    throw new Error("Gemini returned no text");
  }

  const parsed = JSON.parse(text) as CuratorResponse;
  if (
    typeof parsed.recommendedIndex !== "number" ||
    typeof parsed.caption !== "string" ||
    typeof parsed.vibe !== "string"
  ) {
    throw new Error("Gemini response missing recommendedIndex, caption, or vibe");
  }
  if (
    parsed.recommendedIndex < 0 ||
    parsed.recommendedIndex >= images.length
  ) {
    throw new Error("recommendedIndex out of range");
  }
  return parsed;
}

Deno.serve(async (req: Request) => {
  const origin = req.headers.get("Origin");

  if (req.method === "OPTIONS") {
    return new Response(null, { status: 204, headers: corsHeaders(origin) });
  }

  if (req.method !== "POST") {
    return jsonResponse(
      { error: "Method not allowed" },
      405,
      origin
    );
  }

  const authResult = await getUserIdFromRequest(req);
  if ("error" in authResult) {
    return authResult.error;
  }
  const { userId } = authResult;

  const rateLimit = checkRateLimit(userId);
  if (!rateLimit.allowed) {
    const headers = { ...corsHeaders(origin) };
    if (rateLimit.retryAfter != null) {
      headers["Retry-After"] = String(rateLimit.retryAfter);
    }
    return new Response(
      JSON.stringify({ error: "Too many requests", retryAfter: rateLimit.retryAfter }),
      { status: 429, headers: { "Content-Type": "application/json", ...headers } }
    );
  }

  const bodyResult = await parseBody(req);
  if ("error" in bodyResult) {
    return jsonResponse({ error: bodyResult.error }, 400, origin);
  }
  const { images } = bodyResult;

  try {
    const result = await callGemini(images);
    return jsonResponse(result, 200, origin);
  } catch (e) {
    const message = e instanceof Error ? e.message : String(e);
    return jsonResponse(
      { error: "Curator failed", detail: message },
      502,
      origin
    );
  }
});
