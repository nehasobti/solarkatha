// Saves PNG screenshots of the sample Hindi proposal pages (for review
// without a PDF viewer). Needs CHROME_PATH.
import puppeteer from "puppeteer-core";

import { loadFontCss } from "../src/render.js";
import { renderProposalHtml } from "../src/template.js";
import { sampleProposal } from "../test/fixtures.js";

const lang = (process.argv[2] as "hi" | "en") ?? "hi";
const data = sampleProposal(lang);
data.signed_at = "2026-10-08T10:00:00Z";
const browser = await puppeteer.launch({
  executablePath: process.env.CHROME_PATH,
  args: ["--no-sandbox"],
  headless: true,
});
const page = await browser.newPage();
await page.setViewport({ width: 794, height: 1123, deviceScaleFactor: 1 });
await page.setContent(renderProposalHtml(data, loadFontCss()), { waitUntil: "load" });
await page.evaluateHandle("document.fonts.ready");
const sections = await page.$$("section.page");
for (const [i, s] of sections.entries()) {
  await s.screenshot({ path: `sample-${lang}-page${i + 1}.png` });
}
await browser.close();
console.log(`saved ${sections.length} pages`);
