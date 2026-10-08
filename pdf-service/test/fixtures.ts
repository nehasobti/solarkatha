import type { ProposalPdfData } from "../src/types.js";

export function sampleProposal(language: "en" | "hi" = "hi"): ProposalPdfData {
  return {
    language,
    company: {
      name: "Demo Solar Solutions",
      address: "Gomti Nagar, Lucknow, Uttar Pradesh 226010",
      phone: "+91 99999 00001",
      gstin: "09ABCDE1234F1Z5",
      brand_color: "#E07B00",
    },
    customer: {
      name: language === "hi" ? "रमेश गुप्ता" : "Ramesh Gupta",
      phone: "+91 98765 43210",
      address: "12 Vikas Nagar, Lucknow",
    },
    proposal: {
      number: "SK-2610-0001",
      version: 1,
      date: "2026-10-08",
      valid_until: "2026-10-23",
      system_kw: 3.24,
      panel: {
        brand: "Waaree",
        model: "Bi-55-540 DCR Mono PERC",
        watt_peak: 540,
        count: 6,
        warranty_years: 25,
        is_dcr: true,
        almm_listed: true,
      },
      inverter: { brand: "Polycab", model: "3 kW On-grid PSIS-3K", warranty_years: 8 },
      gross_price: 194400,
      central_subsidy: 78000,
      state_subsidy: 30000,
      net_price: 86400,
      loan: { bank: "SBI Surya Ghar", amount: 86400, rate: 7, years: 10, emi: 1003 },
      current_monthly_bill: 2450,
      monthly_generation: [467, 457, 520, 494, 471, 377, 290, 312, 352, 454, 454, 462],
      annual_savings: 28400,
      payback_years: 3.1,
      lifetime_savings: 960000,
      lifetime_years: 25,
    },
    signature_png: null,
    signed_at: null,
  };
}
