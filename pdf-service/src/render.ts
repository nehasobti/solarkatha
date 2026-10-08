import { readFileSync } from "node:fs";
import { join } from "node:path";

import chromium from "@sparticuz/chromium";
import puppeteer from "puppeteer-core";

import { renderProposalHtml } from "./template.js";
import type { ProposalPdfData } from "./types.js";

let fontCss: string | undefined;

/** Bundled Noto fonts as data URLs, so Hindi renders without network fonts. */
export function loadFontCss(dir = join(process.cwd(), "fonts")): string {
  if (fontCss) return fontCss;
  const face = (family: string, file: string, weight: number) =>
    `@font-face { font-family: '${family}'; font-weight: ${weight}; src: url(data:font/ttf;base64,${readFileSync(join(dir, file)).toString("base64")}) format('truetype'); }`;
  fontCss = [
    face("NotoSans", "NotoSans-Regular.ttf", 400),
    face("NotoSans", "NotoSans-Bold.ttf", 700),
    face("NotoSansDevanagari", "NotoSansDevanagari-Regular.ttf", 400),
    face("NotoSansDevanagari", "NotoSansDevanagari-Bold.ttf", 700),
  ].join("\n");
  return fontCss;
}

/**
 * Renders the proposal to PDF. Locally set CHROME_PATH to an installed
 * Chrome; on Vercel the bundled @sparticuz/chromium is used.
 */
export async function renderPdf(data: ProposalPdfData): Promise<Uint8Array> {
  const html = renderProposalHtml(data, loadFontCss());
  const local = process.env.CHROME_PATH;
  const browser = await puppeteer.launch({
    executablePath: local || (await chromium.executablePath()),
    args: local ? ["--no-sandbox"] : chromium.args,
    headless: true,
  });
  try {
    const page = await browser.newPage();
    // No network: everything (fonts, images) is inline.
    await page.setRequestInterception(true);
    page.on("request", (r) => (r.url().startsWith("data:") ? r.continue() : r.abort()));
    await page.setContent(html, { waitUntil: "load" });
    await page.evaluateHandle("document.fonts.ready");
    return await page.pdf({ format: "A4", printBackground: true, preferCSSPageSize: true });
  } finally {
    await browser.close();
  }
}
