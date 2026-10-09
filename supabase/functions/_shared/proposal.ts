// Pure helpers for proposal PDFs and Razorpay payment links (unit-tested).

export interface Row {
  [k: string]: unknown;
}

const n = (v: unknown, fallback = 0): number => {
  const x = typeof v === "number" ? v : Number(v);
  return Number.isFinite(x) ? x : fallback;
};
const s = (v: unknown): string | null =>
  typeof v === "string" && v.trim() !== "" ? v : null;

/** Human-friendly proposal number, e.g. SK-2610-3F9A2C. */
export function proposalNumber(
  id: string,
  createdAt: string,
  version: number,
): string {
  const d = new Date(createdAt);
  const yymm = Number.isNaN(d.getTime())
    ? "0000"
    : `${String(d.getUTCFullYear()).slice(2)}${
      String(d.getUTCMonth() + 1).padStart(2, "0")
    }`;
  return `SK-${yymm}-${id.replace(/-/g, "").slice(0, 6).toUpperCase()}${
    version > 1 ? `-v${version}` : ""
  }`;
}

export function addDays(iso: string, days: number): string {
  const d = new Date(iso);
  if (Number.isNaN(d.getTime())) {
    return new Date(Date.now() + days * 864e5).toISOString();
  }
  d.setUTCDate(d.getUTCDate() + days);
  return d.toISOString();
}

/** Builds the PDF service payload from database rows. */
export function buildPdfPayload(input: {
  proposal: Row;
  lead: Row;
  company: Row;
  panel?: Row | null;
  inverter?: Row | null;
  validDays: number;
  lifetimeYears: number;
  /** PNG data URL of the surveyed roof layout, if any. */
  roofLayoutPng?: string | null;
}): Record<string, unknown> {
  const { proposal: p, lead, company, panel, inverter } = input;
  const gen = (p.est_generation as { monthly?: unknown[] } | null)?.monthly;
  const monthly = Array.isArray(gen) && gen.length === 12
    ? gen.map((v) => n(v))
    : new Array(12).fill(0);
  const loan = p.loan as Row | null;
  const createdRaw = s(p.created_at);
  const created = createdRaw && !Number.isNaN(new Date(createdRaw).getTime())
    ? createdRaw
    : new Date().toISOString();
  return {
    language: p.language === "hi" ? "hi" : "en",
    company: {
      name: s(company.name) ?? "",
      address: s(company.address),
      phone: s(company.phone),
      gstin: s(company.gstin),
      brand_color: s(company.brand_color),
      mnre_vendor_id: s(company.mnre_vendor_id),
    },
    customer: {
      name: s(lead.name) ?? "",
      phone: s(lead.phone) ? `+91 ${lead.phone}` : null,
      address:
        [lead.address, lead.district, lead.pincode].filter((x) => s(x)).join(
          ", ",
        ) || null,
    },
    proposal: {
      number: proposalNumber(String(p.id), created, n(p.version, 1)),
      version: n(p.version, 1),
      date: created,
      valid_until: addDays(created, input.validDays),
      system_kw: n(p.system_kw),
      panel: panel
        ? {
          brand: s(panel.brand) ?? "",
          model: s(panel.model) ?? "",
          watt_peak: panel.watt_peak == null ? null : n(panel.watt_peak),
          count: p.panel_count == null ? null : n(p.panel_count),
          warranty_years: panel.warranty_years == null
            ? null
            : n(panel.warranty_years),
          is_dcr: panel.is_dcr === true,
          almm_listed: panel.almm_listed === true,
        }
        : null,
      inverter: inverter
        ? {
          brand: s(inverter.brand) ?? "",
          model: s(inverter.model) ?? "",
          warranty_years: inverter.warranty_years == null
            ? null
            : n(inverter.warranty_years),
        }
        : null,
      gross_price: n(p.gross_price),
      central_subsidy: n(p.central_subsidy),
      state_subsidy: n(p.state_subsidy),
      net_price: n(p.net_price),
      loan: loan
        ? {
          bank: s(loan.bank),
          amount: n(loan.amount),
          rate: n(loan.rate),
          years: n(loan.years),
          emi: n(loan.emi),
        }
        : null,
      current_monthly_bill: p.current_monthly_bill == null
        ? null
        : n(p.current_monthly_bill),
      monthly_generation: monthly,
      annual_savings: p.annual_savings == null ? null : n(p.annual_savings),
      payback_years: p.payback_years == null ? null : n(p.payback_years),
      lifetime_savings: p.lifetime_savings == null
        ? null
        : n(p.lifetime_savings),
      lifetime_years: input.lifetimeYears,
    },
    signature_png: s(p.signature_png),
    signed_at: s(p.signed_at),
    roof_layout_png: input.roofLayoutPng ?? null,
  };
}

// ---------------------------------------------------------------------------
// HMAC (WebCrypto)
// ---------------------------------------------------------------------------

async function hmacHex(secret: string, message: string): Promise<string> {
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
    new TextEncoder().encode(message),
  );
  return Array.from(new Uint8Array(sig), (b) => b.toString(16).padStart(2, "0"))
    .join("");
}

function safeEqual(a: string, b: string): boolean {
  if (a.length !== b.length) return false;
  let diff = 0;
  for (let i = 0; i < a.length; i++) diff |= a.charCodeAt(i) ^ b.charCodeAt(i);
  return diff === 0;
}

/** Headers for a request to the PDF service. */
export async function pdfServiceHeaders(
  secret: string,
  body: string,
  nowSeconds = Math.floor(Date.now() / 1000),
): Promise<Record<string, string>> {
  const ts = String(nowSeconds);
  return {
    "Content-Type": "application/json",
    "x-solarkatha-timestamp": ts,
    "x-solarkatha-signature": await hmacHex(secret, `${ts}.${body}`),
  };
}

/** Razorpay webhook: X-Razorpay-Signature = hex HMAC-SHA256(raw body). */
export async function verifyRazorpaySignature(
  secret: string,
  body: string,
  signature: string | null,
): Promise<boolean> {
  if (!secret || !signature) return false;
  return safeEqual(await hmacHex(secret, body), signature);
}

// ---------------------------------------------------------------------------
// Payment links
// ---------------------------------------------------------------------------

/** Amount in rupees to request: advance % of net price, or what the rep typed. */
export function paymentAmount(opts: {
  kind: "advance" | "balance";
  netPrice: number;
  advancePct: number;
  alreadyPaid: number;
  requested?: number | null;
}): number {
  const remaining = Math.max(0, Math.round(opts.netPrice - opts.alreadyPaid));
  const fallback = opts.kind === "advance"
    ? Math.round((opts.netPrice * opts.advancePct) / 100)
    : remaining;
  const amount = opts.requested != null && Number.isFinite(opts.requested)
    ? Math.round(opts.requested)
    : fallback;
  if (amount < 1) throw new Error("Amount must be at least ₹1");
  if (amount > remaining) {
    throw new Error("Amount is more than what is still due");
  }
  return amount;
}

/** Body for POST https://api.razorpay.com/v1/payment_links. */
export function paymentLinkBody(opts: {
  paymentId: string;
  amountRupees: number;
  description: string;
  customerName: string;
  customerPhone: string | null;
  proposalId: string;
  companyId: string;
  expireByUnix?: number;
}): Record<string, unknown> {
  const digits = (opts.customerPhone ?? "").replace(/\D/g, "");
  return {
    amount: Math.round(opts.amountRupees * 100), // paise
    currency: "INR",
    accept_partial: false,
    description: opts.description.slice(0, 2048),
    reference_id: opts.paymentId.replace(/-/g, "").slice(0, 40),
    customer: {
      name: opts.customerName.slice(0, 80),
      ...(digits.length >= 10 ? { contact: `+91${digits.slice(-10)}` } : {}),
    },
    notify: { sms: false, email: false },
    reminder_enable: false,
    notes: {
      proposal_id: opts.proposalId,
      company_id: opts.companyId,
      payment_id: opts.paymentId,
    },
    ...(opts.expireByUnix ? { expire_by: opts.expireByUnix } : {}),
  };
}

export interface WebhookUpdate {
  linkId: string;
  status: "paid" | "expired" | "cancelled";
  paymentId?: string;
}

/** Maps a Razorpay webhook event to a payment status change (or null). */
export function parseWebhook(event: unknown): WebhookUpdate | null {
  const e = event as {
    event?: string;
    payload?: {
      payment_link?: { entity?: { id?: string } };
      payment?: { entity?: { id?: string } };
    };
  };
  const linkId = e?.payload?.payment_link?.entity?.id;
  if (!linkId) return null;
  switch (e.event) {
    case "payment_link.paid":
      return {
        linkId,
        status: "paid",
        paymentId: e.payload?.payment?.entity?.id,
      };
    case "payment_link.expired":
      return { linkId, status: "expired" };
    case "payment_link.cancelled":
      return { linkId, status: "cancelled" };
    default:
      return null;
  }
}

/** Base64 for large byte arrays (chunked to avoid call-stack limits). */
export function bytesToBase64(bytes: Uint8Array): string {
  let binary = "";
  const chunk = 0x8000;
  for (let i = 0; i < bytes.length; i += chunk) {
    binary += String.fromCharCode(...bytes.subarray(i, i + chunk));
  }
  return btoa(binary);
}
