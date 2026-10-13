// assistant: public Q&A about SolarKatha for the landing page (no login).
//
// POST { "messages": [{ "role": "user" | "model", "text": "..." }], "lang": "en" | "hi" }
// → { "reply": "..." }
//
// Answers from a fixed fact sheet only. Rate-limited per hashed IP and with a
// daily cap across everyone, so the Gemini key can't be drained.
// Deployed with --no-verify-jwt. Secrets: GEMINI_API_KEY, GEMINI_MODEL (optional).

import { createClient } from "npm:@supabase/supabase-js@2";

import { cleanTurns, geminiBody } from "../_shared/assistant.ts";
import { geminiText } from "../_shared/bill.ts";
import { corsHeaders, json, requireEnv } from "../_shared/http.ts";
import { clientHash } from "../_shared/track.ts";

const PER_IP_PER_HOUR = 30;
const PER_DAY_TOTAL = 1000;

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }
  if (req.method !== "POST") return json({ error: "method_not_allowed" }, 405);

  let body: { messages?: unknown; lang?: unknown };
  try {
    body = await req.json();
  } catch {
    return json({ error: "bad_request" }, 400);
  }
  const turns = cleanTurns(body.messages);
  if (!turns) return json({ error: "bad_request" }, 400);
  const lang = body.lang === "hi" ? "hi" : "en";

  const admin = createClient(
    requireEnv("SUPABASE_URL"),
    requireEnv("SUPABASE_SERVICE_ROLE_KEY"),
    { auth: { persistSession: false } },
  );
  const ip = req.headers.get("x-forwarded-for")?.split(",")[0]?.trim() ?? "unknown";
  const hash = await clientHash(ip, requireEnv("SUPABASE_URL"));
  const hourAgo = new Date(Date.now() - 3_600_000).toISOString();
  const dayAgo = new Date(Date.now() - 86_400_000).toISOString();
  const [{ count: mine }, { count: all }] = await Promise.all([
    admin.from("assistant_hits").select("id", { count: "exact", head: true })
      .eq("client_hash", hash).gte("created_at", hourAgo),
    admin.from("assistant_hits").select("id", { count: "exact", head: true })
      .gte("created_at", dayAgo),
  ]);
  if ((mine ?? 0) >= PER_IP_PER_HOUR || (all ?? 0) >= PER_DAY_TOTAL) {
    return json({ error: "rate_limited" }, 429);
  }
  await admin.from("assistant_hits").insert({ client_hash: hash });

  const model = Deno.env.get("GEMINI_MODEL") || "gemini-flash-latest";
  const res = await fetch(
    `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent`,
    {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "x-goog-api-key": requireEnv("GEMINI_API_KEY"),
      },
      signal: AbortSignal.timeout(30_000),
      body: JSON.stringify(geminiBody(turns, lang)),
    },
  );
  if (!res.ok) {
    console.error("gemini", res.status, await res.text());
    return json({ error: "upstream" }, 502);
  }
  try {
    return json({ reply: geminiText(await res.json()).trim() });
  } catch {
    return json({ error: "upstream" }, 502);
  }
});
