// Renders sample Hindi and English proposals with a local Chrome, to check
// the layout and Devanagari shaping:
//   $env:CHROME_PATH = "C:\Program Files\Google\Chrome\Application\chrome.exe"
//   npm run render:sample
import { writeFileSync } from "node:fs";

import { renderPdf } from "../src/render.js";
import { sampleProposal } from "../test/fixtures.js";

for (const lang of ["hi", "en"] as const) {
  const data = sampleProposal(lang);
  if (lang === "hi") {
    data.signed_at = "2026-10-08T10:00:00Z";
  }
  const pdf = await renderPdf(data);
  const out = `sample-proposal-${lang}.pdf`;
  writeFileSync(out, pdf);
  console.log(`${out}: ${pdf.length} bytes`);
}
