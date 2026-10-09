import { assertEquals, assertNotEquals } from "jsr:@std/assert@1";

import {
  buildTrackResponse,
  clientHash,
  firstName,
  isValidSignature,
  isValidToken,
} from "../_shared/track.ts";

Deno.test("token rules", () => {
  assertEquals(isValidToken("A".repeat(43)), true);
  assertEquals(isValidToken("abc_-DEF123".repeat(4)), true);
  assertEquals(isValidToken("short"), false);
  assertEquals(isValidToken("x".repeat(43) + "'; drop table"), false);
  assertEquals(isValidToken(null), false);
  assertEquals(isValidToken(12345), false);
});

Deno.test("signature must be a small PNG data URL", () => {
  assertEquals(isValidSignature("data:image/png;base64,iVBORw0KGgo="), true);
  assertEquals(isValidSignature("data:image/jpeg;base64,AAAA"), false);
  assertEquals(isValidSignature("https://evil.example/s.png"), false);
  assertEquals(
    isValidSignature("data:image/png;base64," + "A".repeat(400_000)),
    false,
  );
});

Deno.test("only the first name is shared", () => {
  assertEquals(firstName("  Ramesh Kumar Gupta "), "Ramesh");
  assertEquals(firstName("रमेश गुप्ता"), "रमेश");
  assertEquals(firstName(null), "");
});

Deno.test("client hash is stable and salted", async () => {
  assertEquals(
    await clientHash("1.2.3.4", "s"),
    await clientHash("1.2.3.4", "s"),
  );
  assertNotEquals(
    await clientHash("1.2.3.4", "s"),
    await clientHash("1.2.3.5", "s"),
  );
  assertNotEquals(
    await clientHash("1.2.3.4", "s"),
    await clientHash("1.2.3.4", "t"),
  );
});

Deno.test("response has no personal data beyond the first name", () => {
  const r = buildTrackResponse({
    proposal: {
      language: "hi",
      system_kw: "3.24",
      net_price: 86400,
      central_subsidy: 78000,
      state_subsidy: 30000,
      status: "signed",
      signed_at: "2026-10-08T05:00:00Z",
      signature_png: "data:image/png;base64,AAAA",
      share_token: "secret",
      created_by: "u1",
    },
    lead: {
      name: "Ramesh Gupta",
      phone: "9876543210",
      address: "12 Vikas Nagar",
    },
    company: {
      name: "Demo Solar",
      phone: "+91 99999 00001",
      brand_color: "#E07B00",
      gstin: "X",
    },
    project: { current_stage: "installation" },
    stages: [
      {
        stage: "discom_feasibility",
        position: 2,
        status: "done",
        done_at: "2026-10-09",
      },
      {
        stage: "portal_registration",
        position: 1,
        status: "done",
        done_at: "2026-10-08",
      },
    ],
    payment: {
      amount: 17280,
      status: "created",
      short_url: "https://rzp.io/x",
    },
    pdfUrl: "https://signed",
  });
  const text = JSON.stringify(r);
  assertEquals(r.customer_first_name, "Ramesh");
  assertEquals(r.subsidy, 108000);
  assertEquals(r.signed, true);
  assertEquals(
    (r.stages as { stage: string }[])[0].stage,
    "portal_registration",
  );
  assertEquals((r.payment as { url: string }).url, "https://rzp.io/x");
  for (
    const secret of ["9876543210", "Vikas", "Gupta", "secret", "gstin", "u1"]
  ) {
    assertEquals(text.includes(secret), false, `leaked ${secret}`);
  }
});

Deno.test("paid payment shows no pay link", () => {
  const r = buildTrackResponse({
    proposal: { status: "sent" },
    lead: { name: "A" },
    company: { name: "B" },
    payment: { amount: 100, status: "paid", short_url: "https://rzp.io/x" },
  });
  assertEquals((r.payment as { url: string | null }).url, null);
  assertEquals(r.stages, []);
  assertEquals(r.signed, false);
});
