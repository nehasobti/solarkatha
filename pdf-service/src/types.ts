/** Data the `proposal-pdf-request` Edge Function sends to the renderer. */
export interface ProposalPdfData {
  language: "en" | "hi";
  company: {
    name: string;
    address?: string | null;
    phone?: string | null;
    gstin?: string | null;
    brand_color?: string | null;
    mnre_vendor_id?: string | null;
  };
  customer: {
    name: string;
    phone?: string | null;
    address?: string | null;
  };
  proposal: {
    number: string;
    version: number;
    date: string; // ISO date
    valid_until?: string | null;
    system_kw: number;
    panel?: {
      brand: string;
      model: string;
      watt_peak?: number | null;
      count?: number | null;
      warranty_years?: number | null;
      is_dcr: boolean;
      almm_listed: boolean;
    } | null;
    inverter?: {
      brand: string;
      model: string;
      warranty_years?: number | null;
    } | null;
    gross_price: number;
    central_subsidy: number;
    state_subsidy: number;
    net_price: number;
    loan?: {
      bank?: string | null;
      amount: number;
      rate: number;
      years: number;
      emi: number;
    } | null;
    current_monthly_bill?: number | null;
    monthly_generation: number[]; // 12 values, Jan..Dec
    annual_savings?: number | null;
    payback_years?: number | null;
    lifetime_savings?: number | null;
    lifetime_years?: number | null;
  };
  /** PNG data URL of the customer's signature, once signed. */
  signature_png?: string | null;
  signed_at?: string | null;
  /** Roof layout image (data URL) from the survey, when available. */
  roof_layout_png?: string | null;
}
