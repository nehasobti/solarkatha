// POST /api/render — accepts proposal JSON signed with PDF_SERVICE_SECRET and
// returns the PDF. Called only by the `proposal-pdf-request` Edge Function.
//
// Headers: x-solarkatha-timestamp (unix seconds),
//          x-solarkatha-signature (hex HMAC-SHA256 of "<timestamp>.<body>").

import { renderPdf } from "../src/render.js";
import { verifySignature } from "../src/sign.js";
import type { ProposalPdfData } from "../src/types.js";

export async function POST(request: Request): Promise<Response> {
  const body = await request.text();
  const ok = verifySignature({
    secret: process.env.PDF_SERVICE_SECRET ?? "",
    timestamp: request.headers.get("x-solarkatha-timestamp"),
    signature: request.headers.get("x-solarkatha-signature"),
    body,
  });
  if (!ok) return Response.json({ error: "unauthorized" }, { status: 401 });

  let data: ProposalPdfData;
  try {
    data = JSON.parse(body) as ProposalPdfData;
    if (
      !data?.proposal ||
      !data.company?.name ||
      !data.customer?.name ||
      !Array.isArray(data.proposal.monthly_generation) ||
      data.proposal.monthly_generation.length !== 12 ||
      (data.language !== "en" && data.language !== "hi")
    ) {
      throw new Error("invalid");
    }
  } catch {
    return Response.json({ error: "bad_request" }, { status: 400 });
  }

  try {
    const pdf = await renderPdf(data);
    return new Response(Buffer.from(pdf), {
      headers: {
        "Content-Type": "application/pdf",
        "Cache-Control": "no-store",
      },
    });
  } catch (e) {
    console.error("render failed", e);
    return Response.json({ error: "render_failed" }, { status: 500 });
  }
}
