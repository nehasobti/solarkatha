// bill-scan: reads an electricity bill photo with Gemini and returns the
// extracted fields for the rep to confirm. Nothing is saved here; the app
// saves the bill only after the rep confirms.
//
// POST { "path": "company/<company_id>/lead-photos/<id>.jpg" }
// Secrets: GEMINI_API_KEY (required), GEMINI_MODEL (optional).

import { configValue, requireMember } from "../_shared/auth.ts";
import {
  billPrompt,
  billResponseSchema,
  geminiText,
  summarise,
  validateExtraction,
} from "../_shared/bill.ts";
import { handler, HttpError, json, readJson, requireEnv } from "../_shared/http.ts";

const BUCKET = "site-photos";
const MAX_BYTES = 10 * 1024 * 1024;

function startOfTodayIst(): string {
  const istOffsetMs = 5.5 * 60 * 60 * 1000;
  const nowIst = new Date(Date.now() + istOffsetMs);
  nowIst.setUTCHours(0, 0, 0, 0);
  return new Date(nowIst.getTime() - istOffsetMs).toISOString();
}

function toBase64(bytes: Uint8Array): string {
  let binary = "";
  const chunk = 0x8000;
  for (let i = 0; i < bytes.length; i += chunk) {
    binary += String.fromCharCode(...bytes.subarray(i, i + chunk));
  }
  return btoa(binary);
}

Deno.serve(handler(async (req) => {
  const member = await requireMember(req);
  const { admin, companyId } = member;
  const body = await readJson(req);

  const path = typeof body.path === "string" ? body.path : "";
  if (!path.startsWith(`company/${companyId}/`) || path.includes("..")) {
    throw new HttpError(403, "forbidden", "Photo is not in your company folder");
  }

  // Daily limit per company.
  const limit = await configValue<number>(admin, companyId, "bill_scan_daily_limit", 50);
  const { count } = await admin
    .from("ai_usage")
    .select("id", { count: "exact", head: true })
    .eq("company_id", companyId)
    .eq("kind", "bill_scan")
    .gte("created_at", startOfTodayIst());
  if ((count ?? 0) >= limit) {
    throw new HttpError(
      429,
      "limit_reached",
      `Daily bill-scan limit (${limit}) reached. Enter the values by hand.`,
    );
  }

  const { data: file, error: dlError } = await admin.storage.from(BUCKET).download(path);
  if (dlError || !file) {
    throw new HttpError(404, "photo_not_found", "Bill photo is not uploaded yet");
  }
  if (file.size > MAX_BYTES) {
    throw new HttpError(413, "too_large", "Bill photo is larger than 10 MB");
  }
  const bytes = new Uint8Array(await file.arrayBuffer());

  const model = Deno.env.get("GEMINI_MODEL") || "gemini-flash-latest";
  const apiKey = requireEnv("GEMINI_API_KEY");
  let ok = false;
  try {
    const res = await fetch(
      `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent`,
      {
        method: "POST",
        headers: { "Content-Type": "application/json", "x-goog-api-key": apiKey },
        signal: AbortSignal.timeout(45_000),
        body: JSON.stringify({
          contents: [{
            role: "user",
            parts: [
              { text: billPrompt },
              { inline_data: { mime_type: file.type || "image/jpeg", data: toBase64(bytes) } },
            ],
          }],
          generationConfig: {
            temperature: 0,
            responseMimeType: "application/json",
            responseSchema: billResponseSchema,
          },
        }),
      },
    );
    if (!res.ok) {
      const text = await res.text();
      console.error("Gemini error", res.status, text);
      let reason = "";
      try {
        reason = (JSON.parse(text) as { error?: { message?: string } }).error?.message ?? "";
      } catch {
        // not JSON
      }
      throw new HttpError(
        502,
        "ai_failed",
        `Could not read the bill (AI error ${res.status}${reason ? `: ${reason.slice(0, 200)}` : ""}). Enter the values by hand.`,
      );
    }
    const extraction = validateExtraction(JSON.parse(geminiText(await res.json())));
    ok = true;
    return json(summarise(extraction));
  } catch (e) {
    if (e instanceof HttpError) throw e;
    console.error("bill-scan", e);
    throw new HttpError(502, "ai_failed", "Could not read the bill. Enter the values by hand.");
  } finally {
    await admin.from("ai_usage").insert({
      company_id: companyId,
      actor_id: member.userId,
      kind: "bill_scan",
      ok,
    });
  }
}));
