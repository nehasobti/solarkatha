// razorpay-webhook: Razorpay calls this when a payment link is paid,
// expired or cancelled. The signature is verified before anything changes.
// Deployed with --no-verify-jwt (Razorpay has no Supabase token).
//
// Secret: RAZORPAY_WEBHOOK_SECRET (same value as in the Razorpay dashboard).

import { createClient } from "npm:@supabase/supabase-js@2";

import { corsHeaders, json, requireEnv } from "../_shared/http.ts";
import { parseWebhook, verifyRazorpaySignature } from "../_shared/proposal.ts";

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }
  if (req.method !== "POST") return json({ error: "method_not_allowed" }, 405);

  const body = await req.text();
  const ok = await verifyRazorpaySignature(
    Deno.env.get("RAZORPAY_WEBHOOK_SECRET") ?? "",
    body,
    req.headers.get("x-razorpay-signature"),
  );
  if (!ok) return json({ error: "invalid_signature" }, 401);

  let update;
  try {
    update = parseWebhook(JSON.parse(body));
  } catch {
    return json({ error: "bad_request" }, 400);
  }
  if (!update) return json({ ok: true, ignored: true });

  const admin = createClient(
    requireEnv("SUPABASE_URL"),
    requireEnv("SUPABASE_SERVICE_ROLE_KEY"),
    {
      auth: { persistSession: false },
    },
  );
  const changes: Record<string, unknown> = { status: update.status };
  if (update.status === "paid") {
    changes.paid_at = new Date().toISOString();
    changes.razorpay_payment_id = update.paymentId ?? null;
  }
  // Idempotent: a paid payment is never changed again.
  const { data: rows, error } = await admin
    .from("payments")
    .update(changes)
    .eq("razorpay_link_id", update.linkId)
    .neq("status", "paid")
    .select("id, company_id, proposal_id, amount");
  if (error) {
    console.error(error);
    return json({ error: "db_failed" }, 500);
  }
  for (const r of rows ?? []) {
    await admin.from("activity_log").insert({
      company_id: r.company_id,
      entity: "payment",
      entity_id: r.id,
      action: `payment_${update.status}`,
      data: {
        proposal_id: r.proposal_id,
        amount: r.amount,
        razorpay_payment_id: update.paymentId ?? null,
      },
    });
  }
  return json({ ok: true, updated: rows?.length ?? 0 });
});
