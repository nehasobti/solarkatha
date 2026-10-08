import { assertEquals, assertThrows } from "jsr:@std/assert@1";

import {
  geminiText,
  monthlyUnitsThisBill,
  normalizeDiscom,
  summarise,
  validateExtraction,
} from "../_shared/bill.ts";

// A typical model response for a UP (MVVNL) bill with a printed history.
const sample = {
  discom: "Madhyanchal Vidyut Vitran Nigam Ltd.",
  consumer_number: "1234-567-890",
  customer_name: "  Ramesh   Gupta ",
  tariff_category: "LMV-1",
  sanctioned_load_kw: 3,
  billing_period: "01-Aug-2026 to 31-Aug-2026",
  billing_days: 31,
  units_this_bill: 342,
  units_history: [
    { month: "2026-07", units: 360 },
    { month: "2026-06", units: 410 },
    { month: "2026-05", units: 380 },
    { month: "2026-13", units: 1 }, // invalid month
    { month: "2026-06", units: 999 }, // duplicate
  ],
  bill_amount: "2,450",
  confidence: {
    discom: "high",
    consumer_number: "medium",
    sanctioned_load_kw: "low",
    bill_amount: "high",
    units_this_bill: "certain", // invalid → dropped
  },
};

Deno.test("validates and cleans a typical response", () => {
  const e = validateExtraction(sample);
  assertEquals(e.discom, "MVVNL");
  assertEquals(e.consumer_number, "1234567890");
  assertEquals(e.customer_name, "Ramesh Gupta");
  assertEquals(e.sanctioned_load_kw, 3);
  assertEquals(e.bill_amount, 2450);
  assertEquals(e.units_history.map((h) => h.month), [
    "2026-07",
    "2026-06",
    "2026-05",
  ]);
  assertEquals(e.units_history[1].units, 410);
  assertEquals(e.confidence.consumer_number, "medium");
  assertEquals(e.confidence.units_this_bill, undefined);
});

Deno.test("average uses the printed history", () => {
  const r = summarise(validateExtraction(sample));
  assertEquals(r.avg_monthly_units, Math.round((360 + 410 + 380) / 3));
  assertEquals(r.units_monthly["2026-07"], 360);
});

Deno.test("without history the average is this bill, bi-monthly halved", () => {
  const monthly = validateExtraction({ ...sample, units_history: [] });
  assertEquals(summarise(monthly).avg_monthly_units, 342);

  const biMonthly = validateExtraction({
    ...sample,
    units_history: [],
    units_this_bill: 600,
    billing_days: 60,
  });
  assertEquals(monthlyUnitsThisBill(biMonthly), 300);
  assertEquals(summarise(biMonthly).avg_monthly_units, 300);
});

Deno.test("nulls stay null; out-of-range values are rejected", () => {
  const e = validateExtraction({
    discom: null,
    consumer_number: "12",
    sanctioned_load_kw: 5000,
    units_this_bill: -5,
    bill_amount: "abc",
    units_history: "not an array",
    confidence: null,
  });
  assertEquals(e.discom, null);
  assertEquals(e.consumer_number, null, "too short to be real");
  assertEquals(e.sanctioned_load_kw, null);
  assertEquals(e.units_this_bill, null);
  assertEquals(e.bill_amount, null);
  assertEquals(e.units_history, []);
  assertEquals(summarise(e).avg_monthly_units, null);
});

Deno.test("rejects non-object responses", () => {
  assertThrows(() => validateExtraction(null));
  assertThrows(() => validateExtraction([1, 2]));
  assertThrows(() => validateExtraction("text"));
});

Deno.test("DISCOM names normalise to short codes", () => {
  assertEquals(normalizeDiscom("PVVNL"), "PVVNL");
  assertEquals(
    normalizeDiscom("Purvanchal Vidyut Vitran Nigam Limited"),
    "PUVVNL",
  );
  assertEquals(normalizeDiscom("पश्चिमांचल विद्युत वितरण निगम लि."), "PVVNL");
  assertEquals(normalizeDiscom("BSES Rajdhani Power Ltd"), "BRPL");
  assertEquals(normalizeDiscom("Tata Power-DDL"), "TPDDL");
  assertEquals(normalizeDiscom("MAHAVITARAN"), "MSEDCL");
  assertEquals(normalizeDiscom("Some Unknown Co-op"), "Some Unknown Co-op");
});

Deno.test("reads text out of a Gemini response", () => {
  const text = geminiText({
    candidates: [{ content: { parts: [{ text: '{"a":' }, { text: "1}" }] } }],
  });
  assertEquals(JSON.parse(text), { a: 1 });
  assertThrows(() => geminiText({ candidates: [] }));
});
