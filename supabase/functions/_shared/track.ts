// Pure helpers for the public tracking endpoint (unit-tested).

/** Only the customer's first name leaves the server. */
export function firstName(name: unknown): string {
  return typeof name === "string" ? name.trim().split(/\s+/)[0] ?? "" : "";
}

/** Share tokens are 32 random bytes, base64url (43 chars). */
export function isValidToken(token: unknown): token is string {
  return typeof token === "string" && /^[A-Za-z0-9_-]{40,64}$/.test(token);
}

/** A PNG data URL under 300 KB. */
export function isValidSignature(png: unknown): png is string {
  return typeof png === "string" &&
    png.length < 400_000 &&
    /^data:image\/png;base64,[A-Za-z0-9+/=]+$/.test(png);
}

export async function clientHash(ip: string, salt: string): Promise<string> {
  const data = new TextEncoder().encode(`${salt}:${ip}`);
  const digest = await crypto.subtle.digest("SHA-256", data);
  return Array.from(
    new Uint8Array(digest).slice(0, 12),
    (b) => b.toString(16).padStart(2, "0"),
  )
    .join("");
}

export interface TrackRows {
  proposal: Record<string, unknown>;
  lead: Record<string, unknown>;
  company: Record<string, unknown>;
  project?: Record<string, unknown> | null;
  stages?: Record<string, unknown>[];
  payment?: Record<string, unknown> | null;
  pdfUrl?: string | null;
}

/**
 * The minimum the customer needs: no phone numbers, addresses, team names
 * or internal notes.
 */
export function buildTrackResponse(r: TrackRows): Record<string, unknown> {
  const n = (v: unknown) => (v == null ? null : Number(v));
  const p = r.proposal;
  return {
    company: {
      name: r.company.name ?? "",
      phone: r.company.phone ?? null,
      brand_color: r.company.brand_color ?? null,
    },
    customer_first_name: firstName(r.lead.name),
    language: p.language === "hi" ? "hi" : "en",
    system_kw: n(p.system_kw),
    net_price: n(p.net_price),
    subsidy: (n(p.central_subsidy) ?? 0) + (n(p.state_subsidy) ?? 0),
    status: p.status,
    signed: p.status === "signed" || p.signature_png != null,
    signed_at: p.signed_at ?? null,
    pdf_url: r.pdfUrl ?? null,
    current_stage: r.project?.current_stage ?? null,
    stages: (r.stages ?? [])
      .slice()
      .sort((a, b) => Number(a.position) - Number(b.position))
      .map((s) => ({
        stage: s.stage,
        status: s.status,
        done_at: s.done_at ?? null,
        due_date: s.due_date ?? null,
      })),
    payment: r.payment
      ? {
        amount: n(r.payment.amount),
        status: r.payment.status,
        // A pay link only while it is still payable.
        url: r.payment.status === "created"
          ? r.payment.short_url ?? null
          : null,
      }
      : null,
  };
}
