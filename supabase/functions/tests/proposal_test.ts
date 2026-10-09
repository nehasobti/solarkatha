import { assertEquals, assertThrows } from "jsr:@std/assert@1";

import {
  buildPdfPayload,
  bytesToBase64,
  parseWebhook,
  paymentAmount,
  paymentLinkBody,
  pdfServiceHeaders,
  proposalNumber,
  verifyRazorpaySignature,
} from "../_shared/proposal.ts";

async function hmac(secret: string, msg: string): Promise<string> {
  const key = await crypto.subtle.importKey(
    "raw",
    new TextEncoder().encode(secret),
    { name: "HMAC", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const sig = await crypto.subtle.sign(
    "HMAC",
    key,
    new TextEncoder().encode(msg),
  );
  return Array.from(new Uint8Array(sig), (b) => b.toString(16).padStart(2, "0"))
    .join("");
}

Deno.test("Razorpay signature: valid, tampered, wrong secret, missing", async () => {
  const body = '{"event":"payment_link.paid"}';
  const sig = await hmac("whsec", body);
  assertEquals(await verifyRazorpaySignature("whsec", body, sig), true);
  assertEquals(await verifyRazorpaySignature("whsec", body + " ", sig), false);
  assertEquals(await verifyRazorpaySignature("other", body, sig), false);
  assertEquals(await verifyRazorpaySignature("whsec", body, null), false);
  assertEquals(await verifyRazorpaySignature("", body, sig), false);
});

Deno.test("PDF service headers sign timestamp.body", async () => {
  const h = await pdfServiceHeaders("pdfsec", '{"a":1}', 1_800_000_000);
  assertEquals(h["x-solarkatha-timestamp"], "1800000000");
  assertEquals(
    h["x-solarkatha-signature"],
    await hmac("pdfsec", '1800000000.{"a":1}'),
  );
});

Deno.test("webhook events map to payment status", () => {
  const paid = parseWebhook({
    event: "payment_link.paid",
    payload: {
      payment_link: { entity: { id: "plink_1" } },
      payment: { entity: { id: "pay_9" } },
    },
  });
  assertEquals(paid, { linkId: "plink_1", status: "paid", paymentId: "pay_9" });
  assertEquals(
    parseWebhook({
      event: "payment_link.expired",
      payload: { payment_link: { entity: { id: "p" } } },
    })
      ?.status,
    "expired",
  );
  assertEquals(parseWebhook({ event: "payment.captured", payload: {} }), null);
  assertEquals(parseWebhook({ event: "payment_link.paid" }), null);
});

Deno.test("payment amount: advance %, typed amount, limits", () => {
  const base = { netPrice: 86400, advancePct: 20, alreadyPaid: 0 };
  assertEquals(paymentAmount({ ...base, kind: "advance" }), 17280);
  assertEquals(
    paymentAmount({ ...base, kind: "advance", requested: 10000 }),
    10000,
  );
  assertEquals(
    paymentAmount({ ...base, kind: "balance", alreadyPaid: 17280 }),
    69120,
  );
  assertThrows(() => paymentAmount({ ...base, kind: "advance", requested: 0 }));
  assertThrows(() =>
    paymentAmount({ ...base, kind: "advance", requested: 90000 })
  );
  assertThrows(() =>
    paymentAmount({ ...base, kind: "balance", alreadyPaid: 86400 })
  );
});

Deno.test("payment link body: paise, +91 contact, reference id", () => {
  const b = paymentLinkBody({
    paymentId: "3f9a2c11-0000-4000-8000-000000000001",
    amountRupees: 17280,
    description: "Advance",
    customerName: "Ramesh Gupta",
    customerPhone: "98765 43210",
    proposalId: "p1",
    companyId: "c1",
  });
  assertEquals(b.amount, 1728000);
  assertEquals(b.currency, "INR");
  assertEquals((b.customer as { contact: string }).contact, "+919876543210");
  assertEquals(b.reference_id, "3f9a2c11000040008000000000000001");
  const noPhone = paymentLinkBody({
    paymentId: "x",
    amountRupees: 1,
    description: "d",
    customerName: "n",
    customerPhone: null,
    proposalId: "p",
    companyId: "c",
  });
  assertEquals("contact" in (noPhone.customer as object), false);
});

Deno.test("proposal number", () => {
  assertEquals(
    proposalNumber(
      "3f9a2c11-aaaa-4000-8000-000000000001",
      "2026-10-08T05:00:00Z",
      1,
    ),
    "SK-2610-3F9A2C",
  );
  assertEquals(
    proposalNumber(
      "3f9a2c11-aaaa-4000-8000-000000000001",
      "2026-10-08T05:00:00Z",
      2,
    ),
    "SK-2610-3F9A2C-v2",
  );
});

Deno.test("PDF payload from database rows", () => {
  const payload = buildPdfPayload({
    proposal: {
      id: "3f9a2c11-aaaa-4000-8000-000000000001",
      version: 1,
      language: "hi",
      created_at: "2026-10-08T05:00:00Z",
      system_kw: "3.24",
      panel_count: 6,
      gross_price: "194400",
      central_subsidy: 78000,
      state_subsidy: 30000,
      net_price: 86400,
      loan: { bank: "SBI", amount: 86400, rate: 7, years: 10, emi: 1003 },
      est_generation: { monthly: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12] },
      annual_savings: 28400,
      signature_png: null,
    },
    lead: {
      name: "Ramesh",
      phone: "9876543210",
      address: "12 Vikas Nagar",
      district: "Lucknow",
      pincode: null,
    },
    company: { name: "Demo Solar", brand_color: "#E07B00" },
    panel: {
      brand: "Waaree",
      model: "540",
      watt_peak: 540,
      warranty_years: 25,
      is_dcr: true,
      almm_listed: true,
    },
    inverter: null,
    validDays: 15,
    lifetimeYears: 25,
  });
  const p = payload.proposal as Record<string, unknown>;
  assertEquals(payload.language, "hi");
  assertEquals(p.system_kw, 3.24);
  assertEquals(p.gross_price, 194400);
  assertEquals(p.valid_until, "2026-10-23T05:00:00.000Z");
  assertEquals((p.monthly_generation as number[]).length, 12);
  assertEquals(
    (payload.customer as Record<string, unknown>).phone,
    "+91 9876543210",
  );
  assertEquals(
    (payload.customer as Record<string, unknown>).address,
    "12 Vikas Nagar, Lucknow",
  );
  assertEquals((p.panel as Record<string, unknown>).count, 6);
  assertEquals(p.inverter, null);
});

Deno.test("missing generation becomes 12 zeros", () => {
  const payload = buildPdfPayload({
    proposal: { id: "x", created_at: "bad-date", est_generation: null },
    lead: { name: "A" },
    company: { name: "B" },
    validDays: 15,
    lifetimeYears: 25,
  });
  assertEquals(
    (payload.proposal as Record<string, unknown>).monthly_generation,
    new Array(12).fill(0),
  );
});

Deno.test("bytesToBase64 matches btoa and handles large arrays", () => {
  assertEquals(
    bytesToBase64(new TextEncoder().encode("SolarKatha")),
    btoa("SolarKatha"),
  );
  const big = new Uint8Array(200_000).fill(65);
  assertEquals(bytesToBase64(big).length, Math.ceil(200_000 / 3) * 4);
});

Deno.test("roof layout is passed to the PDF payload", () => {
  const payload = buildPdfPayload({
    proposal: { id: "x", created_at: "2026-10-08T00:00:00Z" },
    lead: { name: "A" },
    company: { name: "B" },
    validDays: 15,
    lifetimeYears: 25,
    roofLayoutPng: "data:image/png;base64,AAAA",
  });
  assertEquals(payload.roof_layout_png, "data:image/png;base64,AAAA");
});
