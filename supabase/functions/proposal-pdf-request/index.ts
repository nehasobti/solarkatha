// proposal-pdf-request: builds the proposal PDF via the PDF service, stores it
// in the private `documents` bucket and returns a signed URL.
//
// POST { "proposal_id": "<uuid>" } → { "url": "...", "path": "...", "expires_in": 604800 }
// Secrets: PDF_SERVICE_URL, PDF_SERVICE_SECRET.

import { loadProposalForMember } from "../_shared/access.ts";
import { configValue, requireMember } from "../_shared/auth.ts";
import {
  handler,
  HttpError,
  json,
  readJson,
  requireEnv,
} from "../_shared/http.ts";
import { buildPdfPayload, pdfServiceHeaders } from "../_shared/proposal.ts";

const BUCKET = "documents";
/** Signed link lifetime: long enough for the customer to open it from WhatsApp. */
const LINK_SECONDS = 7 * 24 * 60 * 60;

Deno.serve(handler(async (req) => {
  const member = await requireMember(req);
  const { admin, companyId } = member;
  const body = await readJson(req);
  const { proposal, lead } = await loadProposalForMember(
    admin,
    member,
    body.proposal_id,
  );

  const [{ data: company }, panelRes, inverterRes] = await Promise.all([
    admin.from("companies").select("*").eq("id", companyId).single(),
    proposal.panel_product_id
      ? admin.from("products").select("*").eq("id", proposal.panel_product_id)
        .maybeSingle()
      : Promise.resolve({ data: null }),
    proposal.inverter_product_id
      ? admin.from("products").select("*").eq(
        "id",
        proposal.inverter_product_id,
      ).maybeSingle()
      : Promise.resolve({ data: null }),
  ]);
  const payload = buildPdfPayload({
    proposal,
    lead,
    company: company ?? {},
    panel: panelRes.data,
    inverter: inverterRes.data,
    validDays: await configValue<number>(
      admin,
      companyId,
      "proposal_valid_days",
      15,
    ),
    lifetimeYears: await configValue<number>(
      admin,
      companyId,
      "lifetime_years",
      25,
    ),
  });

  const text = JSON.stringify(payload);
  const res = await fetch(
    `${requireEnv("PDF_SERVICE_URL").replace(/\/$/, "")}/api/render`,
    {
      method: "POST",
      headers: await pdfServiceHeaders(requireEnv("PDF_SERVICE_SECRET"), text),
      body: text,
      signal: AbortSignal.timeout(55_000),
    },
  );
  if (!res.ok) {
    console.error("PDF service", res.status, await res.text());
    throw new HttpError(
      502,
      "pdf_failed",
      "Could not create the PDF. Try again.",
    );
  }
  const pdf = new Uint8Array(await res.arrayBuffer());

  const path =
    `company/${companyId}/proposals/${proposal.id}/v${proposal.version}.pdf`;
  const { error: upErr } = await admin.storage.from(BUCKET).upload(path, pdf, {
    contentType: "application/pdf",
    upsert: true,
  });
  if (upErr) throw new HttpError(500, "storage_failed", upErr.message);

  await admin
    .from("proposals")
    .update({ pdf_path: path, pdf_generated_at: new Date().toISOString() })
    .eq("id", proposal.id);

  const { data: signed, error: signErr } = await admin.storage
    .from(BUCKET)
    .createSignedUrl(path, LINK_SECONDS);
  if (signErr || !signed) {
    throw new HttpError(500, "storage_failed", "Could not create a link");
  }
  return json({ url: signed.signedUrl, path, expires_in: LINK_SECONDS });
}));
