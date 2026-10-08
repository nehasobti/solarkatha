import assert from "node:assert/strict";
import { test } from "node:test";

import { esc, kw, rupees, safeColor, safeImage } from "../src/format.js";
import { fill } from "../src/i18n.js";
import { signBody, verifySignature } from "../src/sign.js";
import { generationChart, renderProposalHtml } from "../src/template.js";
import { sampleProposal } from "./fixtures.js";

test("Indian rupee formatting", () => {
  assert.equal(rupees(108000), "₹1,08,000");
  assert.equal(rupees(86400.4), "₹86,400");
  assert.equal(kw(3.24), "3.24 kW");
  assert.equal(kw(3), "3 kW");
});

test("Hindi proposal contains Hindi labels and the numbers", () => {
  const html = renderProposalHtml(sampleProposal("hi"));
  assert.match(html, /lang="hi"/);
  assert.match(html, /रूफ़टॉप सोलर प्रस्ताव/);
  assert.match(html, /रमेश गुप्ता/);
  assert.match(html, /₹86,400/);
  assert.match(html, /₹1,08,000|₹78,000/);
  assert.equal((html.match(/class="page"/g) ?? []).length, 4);
});

test("English proposal", () => {
  const html = renderProposalHtml(sampleProposal("en"));
  assert.match(html, /Rooftop Solar Proposal/);
  assert.match(html, /You pay after subsidy/);
  assert.match(html, /DCR · ALMM listed/);
});

test("user text is escaped (no HTML injection)", () => {
  const data = sampleProposal("en");
  data.customer.name = '<script>alert("x")</script>';
  data.company.name = "A & B <b>";
  const html = renderProposalHtml(data);
  assert.doesNotMatch(html, /<script>alert/);
  assert.match(html, /&lt;script&gt;/);
  assert.match(html, /A &amp; B &lt;b&gt;/);
  assert.equal(esc(`"'`), "&quot;&#39;");
});

test("only safe colours and data-URL images are used", () => {
  assert.equal(safeColor("#123abc"), "#123abc");
  assert.equal(safeColor("red; background:url(x)"), "#E07B00");
  assert.equal(safeImage("data:image/png;base64,iVBORw0KGgo="), "data:image/png;base64,iVBORw0KGgo=");
  assert.equal(safeImage("https://evil.example/x.png"), null);
  assert.equal(safeImage('data:image/png;base64,AAA" onerror="x'), null);
  const data = sampleProposal("en");
  data.signature_png = "https://evil.example/s.png";
  assert.doesNotMatch(renderProposalHtml(data), /evil\.example/);
});

test("signature appears when signed", () => {
  const data = sampleProposal("hi");
  data.signature_png = "data:image/png;base64,iVBORw0KGgo=";
  data.signed_at = "2026-10-08T10:00:00Z";
  const html = renderProposalHtml(data);
  assert.match(html, /<img src="data:image\/png;base64,iVBORw0KGgo="/);
  assert.match(html, /हस्ताक्षर किए/);
});

test("chart has 12 bars", () => {
  const svg = generationChart([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "JFMAMJJASOND".split(""), "#E07B00");
  assert.equal((svg.match(/<rect /g) ?? []).length, 12);
});

test("fill replaces placeholders and keeps unknown ones", () => {
  assert.equal(fill("{a} and {b}", { a: 1 }), "1 and {b}");
});

test("HMAC signature: valid, tampered, expired, missing", () => {
  const secret = "s3cret";
  const body = '{"a":1}';
  const now = 1_800_000_000;
  const ts = String(now);
  const sig = signBody(secret, ts, body);
  assert.equal(verifySignature({ secret, timestamp: ts, signature: sig, body, nowSeconds: now }), true);
  assert.equal(verifySignature({ secret, timestamp: ts, signature: sig, body: '{"a":2}', nowSeconds: now }), false);
  assert.equal(verifySignature({ secret: "other", timestamp: ts, signature: sig, body, nowSeconds: now }), false);
  assert.equal(verifySignature({ secret, timestamp: ts, signature: sig, body, nowSeconds: now + 301 }), false);
  assert.equal(verifySignature({ secret, timestamp: null, signature: sig, body, nowSeconds: now }), false);
  assert.equal(verifySignature({ secret, timestamp: ts, signature: "zz", body, nowSeconds: now }), false);
  assert.equal(verifySignature({ secret: "", timestamp: ts, signature: sig, body, nowSeconds: now }), false);
});
