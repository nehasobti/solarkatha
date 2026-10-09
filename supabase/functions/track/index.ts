// track: public customer tracking (no login). Deployed with --no-verify-jwt.
//
// POST { "token": "<share_token>" }                       → project status
// POST { "token": "...", "action": "sign", "signature_png": "data:image/png;base64,..." }
//
// Returns only the customer's first name, system size, price, stages and a
// pay link. Rate limited per client; revoked tokens return 404.

import { createClient } from "npm:@supabase/supabase-js@2";

import { configValue } from "../_shared/auth.ts";
import { corsHeaders, json, requireEnv } from "../_shared/http.ts";
import {
  buildTrackResponse,
  clientHash,
  isValidSignature,
  isValidToken,
} from "../_shared/track.ts";

const notFound = () => json({ error: "not_found" }, 404);

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }
  if (req.method !== "POST") return json({ error: "method_not_allowed" }, 405);

  let body: Record<string, unknown>;
  try {
    body = await req.json();
  } catch {
    return json({ error: "bad_request" }, 400);
  }
  if (!isValidToken(body.token)) return notFound();

  const admin = createClient(
    requireEnv("SUPABASE_URL"),
    requireEnv("SUPABASE_SERVICE_ROLE_KEY"),
    { auth: { persistSession: false } },
  );

  // Rate limit per client (hashed IP), per minute.
  const ip = req.headers.get("x-forwarded-for")?.split(",")[0]?.trim() ??
    "unknown";
  const hash = await clientHash(ip, requireEnv("SUPABASE_URL"));
  const since = new Date(Date.now() - 60_000).toISOString();
  const { count } = await admin
    .from("track_hits")
    .select("id", { count: "exact", head: true })
    .eq("client_hash", hash)
    .gte("created_at", since);
  const { data: proposal } = await admin
    .from("proposals")
    .select("*")
    .eq("share_token", body.token)
    .is("deleted_at", null)
    .is("share_revoked_at", null)
    .maybeSingle();
  const limit = proposal
    ? await configValue<number>(
      admin,
      proposal.company_id,
      "track_rate_limit_per_minute",
      30,
    )
    : 30;
  if ((count ?? 0) >= limit) return json({ error: "rate_limited" }, 429);
  await admin.from("track_hits").insert({ client_hash: hash });
  if (!proposal) return notFound();

  if (body.action === "sign") {
    if (!isValidSignature(body.signature_png)) {
      return json({ error: "bad_signature" }, 400);
    }
    if (proposal.status === "signed" || proposal.signature_png) {
      return json({ error: "already_signed" }, 409);
    }
    const now = new Date().toISOString();
    const { error } = await admin
      .from("proposals")
      .update({
        signature_png: body.signature_png,
        signed_at: now,
        status: "signed",
        sent_at: proposal.sent_at ?? now,
      })
      .eq("id", proposal.id);
    if (error) return json({ error: "db_failed" }, 500);
    await admin.from("activity_log").insert({
      company_id: proposal.company_id,
      entity: "proposal",
      entity_id: proposal.id,
      action: "signed_by_customer",
      data: { via: "tracking_page" },
    });
    proposal.status = "signed";
    proposal.signature_png = body.signature_png;
    proposal.signed_at = now;
  }

  const [{ data: lead }, { data: company }, { data: project }, {
    data: payment,
  }] = await Promise.all([
    admin.from("leads").select("name").eq("id", proposal.lead_id).single(),
    admin.from("companies").select("name, phone, brand_color").eq(
      "id",
      proposal.company_id,
    ).single(),
    admin.from("projects").select("id, current_stage").eq(
      "proposal_id",
      proposal.id,
    ).maybeSingle(),
    admin.from("payments").select("amount, status, short_url").eq(
      "proposal_id",
      proposal.id,
    ).order("created_at", { ascending: false }).limit(1).maybeSingle(),
  ]);
  const { data: stages } = project
    ? await admin.from("project_stages").select(
      "stage, position, status, done_at, due_date",
    ).eq("project_id", project.id)
    : { data: [] };
  let pdfUrl: string | null = null;
  if (proposal.pdf_path) {
    const { data } = await admin.storage.from("documents").createSignedUrl(
      proposal.pdf_path,
      3600,
    );
    pdfUrl = data?.signedUrl ?? null;
  }

  return json(buildTrackResponse({
    proposal,
    lead: lead ?? {},
    company: company ?? {},
    project,
    stages: stages ?? [],
    payment,
    pdfUrl,
  }));
});
