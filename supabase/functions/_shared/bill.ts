// Pure helpers for the bill-scan function (no network, unit-tested).

export type Confidence = "high" | "medium" | "low";

export const BILL_FIELDS = [
  "discom",
  "consumer_number",
  "customer_name",
  "tariff_category",
  "sanctioned_load_kw",
  "billing_period",
  "billing_days",
  "units_this_bill",
  "units_history",
  "bill_amount",
] as const;
export type BillField = (typeof BILL_FIELDS)[number];

export interface BillExtraction {
  discom: string | null;
  consumer_number: string | null;
  customer_name: string | null;
  tariff_category: string | null;
  sanctioned_load_kw: number | null;
  billing_period: string | null;
  billing_days: number | null;
  units_this_bill: number | null;
  units_history: { month: string; units: number }[];
  bill_amount: number | null;
  confidence: Partial<Record<BillField, Confidence>>;
}

export interface BillScanResult {
  extraction: BillExtraction;
  /** Month (YYYY-MM) → units, monthly-normalised. */
  units_monthly: Record<string, number>;
  avg_monthly_units: number | null;
}

/** Gemini `responseSchema` (OpenAPI subset). */
export const billResponseSchema = {
  type: "OBJECT",
  properties: {
    discom: { type: "STRING", nullable: true },
    consumer_number: { type: "STRING", nullable: true },
    customer_name: { type: "STRING", nullable: true },
    tariff_category: { type: "STRING", nullable: true },
    sanctioned_load_kw: { type: "NUMBER", nullable: true },
    billing_period: { type: "STRING", nullable: true },
    billing_days: { type: "NUMBER", nullable: true },
    units_this_bill: { type: "NUMBER", nullable: true },
    units_history: {
      type: "ARRAY",
      items: {
        type: "OBJECT",
        properties: {
          month: { type: "STRING" },
          units: { type: "NUMBER" },
        },
        required: ["month", "units"],
      },
    },
    bill_amount: { type: "NUMBER", nullable: true },
    confidence: {
      type: "OBJECT",
      properties: Object.fromEntries(
        BILL_FIELDS.map((f) => [
          f,
          { type: "STRING", enum: ["high", "medium", "low"] },
        ]),
      ),
    },
  },
  required: ["units_history", "confidence"],
};

export const billPrompt = `You read Indian electricity bills (Hindi or English, any DISCOM layout, photographed on a phone).
Extract the fields in the JSON schema. Rules:
- Return null for anything you cannot read clearly. Never guess.
- discom: the distribution company name or its short code as printed (e.g. PVVNL, MVVNL, BSES Rajdhani, MSEDCL).
- consumer_number: the consumer / account / connection number (not the meter or bill number). Digits and letters only.
- tariff_category: as printed (e.g. LMV-1, Domestic, DS-II).
- sanctioned_load_kw: sanctioned / contracted load in kW (convert from W or kVA at face value).
- billing_period: as printed; billing_days: number of days the bill covers.
- units_this_bill: kWh consumed in this bill's period (current reading minus previous reading if not printed).
- units_history: up to 12 previous months if a consumption history table/graph is printed, month as YYYY-MM.
- bill_amount: the total amount payable in rupees for this bill.
- confidence: high / medium / low for each field you return.`;

const ranges: Partial<Record<BillField, [number, number]>> = {
  sanctioned_load_kw: [0.1, 200],
  billing_days: [1, 400],
  units_this_bill: [0, 100000],
  bill_amount: [0, 10000000],
};

function num(v: unknown, field: BillField): number | null {
  if (v === null || v === undefined || v === "") return null;
  const n = typeof v === "number" ? v : Number(String(v).replace(/[,₹\s]/g, ""));
  if (!Number.isFinite(n)) return null;
  const [min, max] = ranges[field] ?? [-Infinity, Infinity];
  return n < min || n > max ? null : n;
}

function str(v: unknown, max = 120): string | null {
  if (typeof v !== "string") return null;
  const s = v.replace(/\s+/g, " ").trim();
  return s.length === 0 ? null : s.slice(0, max);
}

const confidences = new Set(["high", "medium", "low"]);

/**
 * Validates and cleans the model's JSON. Out-of-range or malformed values
 * become null rather than being trusted.
 */
export function validateExtraction(raw: unknown): BillExtraction {
  if (!raw || typeof raw !== "object" || Array.isArray(raw)) {
    throw new Error("Model response is not a JSON object");
  }
  const r = raw as Record<string, unknown>;

  const history: { month: string; units: number }[] = [];
  if (Array.isArray(r.units_history)) {
    for (const item of r.units_history) {
      if (!item || typeof item !== "object") continue;
      const m = str((item as Record<string, unknown>).month, 7);
      const u = num((item as Record<string, unknown>).units, "units_this_bill");
      if (m && /^\d{4}-(0[1-9]|1[0-2])$/.test(m) && u !== null) {
        if (!history.some((h) => h.month === m)) history.push({ month: m, units: u });
      }
    }
  }
  history.sort((a, b) => b.month.localeCompare(a.month));

  const confidence: Partial<Record<BillField, Confidence>> = {};
  if (r.confidence && typeof r.confidence === "object") {
    for (const f of BILL_FIELDS) {
      const c = (r.confidence as Record<string, unknown>)[f];
      if (typeof c === "string" && confidences.has(c)) confidence[f] = c as Confidence;
    }
  }

  const consumer = str(r.consumer_number, 30)?.replace(/[^0-9A-Za-z]/g, "") ?? null;
  const discom = str(r.discom, 80);
  return {
    discom: discom ? normalizeDiscom(discom) : null,
    consumer_number: consumer && consumer.length >= 4 ? consumer : null,
    customer_name: str(r.customer_name, 80),
    tariff_category: str(r.tariff_category, 40),
    sanctioned_load_kw: num(r.sanctioned_load_kw, "sanctioned_load_kw"),
    billing_period: str(r.billing_period, 60),
    billing_days: num(r.billing_days, "billing_days"),
    units_this_bill: num(r.units_this_bill, "units_this_bill"),
    units_history: history.slice(0, 12),
    bill_amount: num(r.bill_amount, "bill_amount"),
    confidence,
  };
}

/** Monthly units from this bill, adjusting bi-monthly bills to 30 days. */
export function monthlyUnitsThisBill(e: BillExtraction): number | null {
  if (e.units_this_bill === null) return null;
  if (e.billing_days && e.billing_days > 40) {
    return Math.round((e.units_this_bill * 30) / e.billing_days);
  }
  return e.units_this_bill;
}

/** Average monthly units: printed history if any, else this bill. */
export function summarise(e: BillExtraction): BillScanResult {
  const units: Record<string, number> = {};
  for (const h of e.units_history) units[h.month] = h.units;
  const values = Object.values(units);
  const thisBill = monthlyUnitsThisBill(e);
  let avg: number | null = null;
  if (values.length > 0) {
    avg = Math.round(values.reduce((a, b) => a + b, 0) / values.length);
  } else if (thisBill !== null) {
    avg = thisBill;
  }
  return { extraction: e, units_monthly: units, avg_monthly_units: avg };
}

// ---------------------------------------------------------------------------
// DISCOM names
// ---------------------------------------------------------------------------

/** Canonical short code → aliases as they appear on bills. */
const discoms: Record<string, string[]> = {
  PVVNL: ["Paschimanchal Vidyut Vitran Nigam", "पश्चिमांचल विद्युत वितरण निगम"],
  MVVNL: ["Madhyanchal Vidyut Vitran Nigam", "मध्यांचल विद्युत वितरण निगम"],
  DVVNL: ["Dakshinanchal Vidyut Vitran Nigam", "दक्षिणांचल विद्युत वितरण निगम"],
  PUVVNL: ["Purvanchal Vidyut Vitran Nigam", "पूर्वांचल विद्युत वितरण निगम"],
  KESCO: ["Kanpur Electricity Supply Company"],
  BRPL: ["BSES Rajdhani", "BSES Rajdhani Power"],
  BYPL: ["BSES Yamuna", "BSES Yamuna Power"],
  TPDDL: ["Tata Power-DDL", "Tata Power Delhi Distribution", "NDPL"],
  MSEDCL: ["Mahavitaran", "Maharashtra State Electricity Distribution"],
  AEML: ["Adani Electricity Mumbai"],
  BEST: ["Brihanmumbai Electric Supply"],
  UGVCL: ["Uttar Gujarat Vij"],
  MGVCL: ["Madhya Gujarat Vij"],
  DGVCL: ["Dakshin Gujarat Vij"],
  PGVCL: ["Paschim Gujarat Vij"],
  TORRENT: ["Torrent Power"],
  JVVNL: ["Jaipur Vidyut Vitran Nigam"],
  AVVNL: ["Ajmer Vidyut Vitran Nigam"],
  JDVVNL: ["Jodhpur Vidyut Vitran Nigam"],
  SBPDCL: ["South Bihar Power Distribution"],
  NBPDCL: ["North Bihar Power Distribution"],
  UHBVN: ["Uttar Haryana Bijli Vitran Nigam"],
  DHBVN: ["Dakshin Haryana Bijli Vitran Nigam"],
  PSPCL: ["Punjab State Power Corporation"],
  BESCOM: ["Bangalore Electricity Supply"],
  TANGEDCO: ["Tamil Nadu Generation and Distribution", "TNPDCL"],
  TSSPDCL: ["Southern Power Distribution Company of Telangana", "TGSPDCL"],
  KSEB: ["Kerala State Electricity Board"],
  WBSEDCL: ["West Bengal State Electricity Distribution"],
  CESC: ["Calcutta Electric Supply"],
  JBVNL: ["Jharkhand Bijli Vitran Nigam"],
  CSPDCL: ["Chhattisgarh State Power Distribution"],
  UPCL: ["Uttarakhand Power Corporation"],
  MPMKVVCL: ["Madhya Pradesh Madhya Kshetra Vidyut Vitaran"],
  MPPKVVCL: ["Madhya Pradesh Poorv Kshetra Vidyut Vitaran"],
  MPWZ: ["Madhya Pradesh Paschim Kshetra Vidyut Vitaran"],
};

const squash = (s: string) => s.toUpperCase().replace(/[^A-Z0-9ऀ-ॿ]/g, "");

/** Maps a printed DISCOM name to its short code; unknown names pass through. */
export function normalizeDiscom(name: string): string {
  const key = squash(name);
  if (!key) return name.trim();
  for (const [code, aliases] of Object.entries(discoms)) {
    if (key === code || key.startsWith(code)) return code;
    for (const a of aliases) {
      const ak = squash(a);
      if (key.includes(ak) || (ak.length > 6 && ak.includes(key))) return code;
    }
  }
  return name.trim();
}

/** Extracts the JSON text from a Gemini generateContent response. */
export function geminiText(response: unknown): string {
  const r = response as {
    candidates?: { content?: { parts?: { text?: string }[] } }[];
  };
  const text = r?.candidates?.[0]?.content?.parts
    ?.map((p) => p.text ?? "")
    .join("");
  if (!text) throw new Error("Empty model response");
  return text;
}
