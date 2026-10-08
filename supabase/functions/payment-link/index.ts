// payment-link: creates a Razorpay Payment Link (UPI, cards, netbanking) for
// an advance or balance payment on a proposal.
//
// POST { "proposal_id": "<uuid>", "kind"?: "advance" | "balance", "amount"?: rupees }
// → { "payment_id", "short_url", "amount" }
// Secrets: RAZORPAY_KEY_ID, RAZORPAY_KEY_SECRET (test mode keys).

import { loadProposalForMember } from "../_shared/access.ts";
import { configValue, requireMember } from "../_shared/auth.ts";
import {
  handler,
  HttpError,
  json,
  readJson,
  requireEnv,
} from "../_shared/http.ts";
import { paymentAmount, paymentLinkBody } from "../_shared/proposal.ts";

Deno.serve(handler(async (req) => {
  const member = await requireMember(req);
  const { admin, companyId } = member;
  const body = await readJson(req);
  const { proposal, lead } = await loadProposalForMember(
    admin,
    member,
    body.proposal_id,
  );
  const kind = body.kind === "balance" ? "balance" : "advance";

  const { data: paid } = await admin
    .from("payments")
    .select("amount")
    .eq("proposal_id", proposal.id)
    .eq("status", "paid");
  const alreadyPaid = (paid ?? []).reduce((a, r) => a + Number(r.amount), 0);

  let amount: number;
  try {
    amount = paymentAmount({
      kind,
      netPrice: Number(proposal.net_price),
      advancePct: await configValue<number>(
        admin,
        companyId,
        "advance_pct",
        20,
      ),
      alreadyPaid,
      requested: typeof body.amount === "number" ? body.amount : null,
    });
  } catch (e) {
    throw new HttpError(400, "bad_amount", (e as Error).message);
  }

  const { data: company } = await admin.from("companies").select("name").eq(
    "id",
    companyId,
  ).single();
  const paymentId = crypto.randomUUID();
  const linkBody = paymentLinkBody({
    paymentId,
    amountRupees: amount,
    description: `${
      kind === "advance" ? "Advance" : "Balance"
    } for ${proposal.system_kw} kW rooftop solar – ${company?.name ?? ""}`,
    customerName: String(lead.name ?? ""),
    customerPhone: (lead.phone as string | null) ?? null,
    proposalId: String(proposal.id),
    companyId,
  });

  const auth = btoa(
    `${requireEnv("RAZORPAY_KEY_ID")}:${requireEnv("RAZORPAY_KEY_SECRET")}`,
  );
  const res = await fetch("https://api.razorpay.com/v1/payment_links", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Basic ${auth}`,
    },
    body: JSON.stringify(linkBody),
    signal: AbortSignal.timeout(20_000),
  });
  const result = await res.json().catch(() => ({}));
  if (!res.ok || !result.id || !result.short_url) {
    console.error("Razorpay", res.status, JSON.stringify(result));
    const reason = result?.error?.description ?? `HTTP ${res.status}`;
    throw new HttpError(
      502,
      "payment_failed",
      `Could not create the payment link (${reason}).`,
    );
  }

  const { error } = await admin.from("payments").insert({
    id: paymentId,
    company_id: companyId,
    lead_id: lead.id,
    proposal_id: proposal.id,
    kind,
    amount,
    razorpay_link_id: result.id,
    short_url: result.short_url,
    status: "created",
    created_by: member.userId,
  });
  if (error) throw new HttpError(500, "db_failed", error.message);

  return json({ payment_id: paymentId, short_url: result.short_url, amount });
}));
