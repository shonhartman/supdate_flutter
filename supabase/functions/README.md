# Supabase Edge Functions

## recommend-photo

Accepts 2–10 base64 images in the request body, calls Gemini 2.5 Flash (Vision), and returns the recommended photo index plus caption and vibe.

### Request

- **Method**: `POST`
- **Headers**: `Authorization: Bearer <supabase_jwt>`, `Content-Type: application/json`
- **Body**: `{ "images": [ { "base64": "<base64 string>", "mimeType": "image/jpeg" }, ... ] }`
- **Limits**: 2–10 images; ~5MB per image; 20 requests per user per hour (rate limited)

### Response

- **200**: `{ "recommendedIndex": number, "caption": string, "vibe": string }`
- **4xx/5xx**: `{ "error": string, "detail"?: string }`

### Secrets

Set the Gemini API key in Supabase (Dashboard → Edge Functions → Secrets, or Use the Supabase CLI):

```bash
supabase secrets set GEMINI_API_KEY=your_gemini_api_key
```

### Local development

From the project root:

```bash
supabase functions serve recommend-photo
```

Invoke with a valid Supabase anon key and user JWT in the `Authorization` header.
