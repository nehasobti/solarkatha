import { date, esc, kw, number, rupees, safeColor, safeImage } from "./format.js";
import { fill, strings } from "./i18n.js";
import type { ProposalPdfData } from "./types.js";

/** 12-month bar chart as inline SVG. */
export function generationChart(monthly: number[], labels: readonly string[], color: string): string {
  const w = 640;
  const h = 220;
  const pad = 28;
  const max = Math.max(1, ...monthly) * 1.15;
  const bw = (w - pad * 2) / 12;
  const bars = monthly
    .map((v, i) => {
      const bh = ((h - pad * 2) * v) / max;
      const x = pad + i * bw + bw * 0.15;
      const y = h - pad - bh;
      return `<rect x="${x.toFixed(1)}" y="${y.toFixed(1)}" width="${(bw * 0.7).toFixed(1)}" height="${bh.toFixed(1)}" rx="3" fill="${color}"/>
<text x="${(x + bw * 0.35).toFixed(1)}" y="${(y - 4).toFixed(1)}" font-size="10" text-anchor="middle" fill="#444">${number(v)}</text>
<text x="${(x + bw * 0.35).toFixed(1)}" y="${h - pad + 14}" font-size="11" text-anchor="middle" fill="#666">${esc(labels[i] ?? "")}</text>`;
    })
    .join("\n");
  return `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ${w} ${h}" width="100%">
<line x1="${pad}" y1="${h - pad}" x2="${w - pad}" y2="${h - pad}" stroke="#ccc"/>
${bars}
</svg>`;
}

/**
 * Proposal HTML (A4, 4 pages). Every dynamic value is escaped; images must
 * be PNG/JPEG data URLs; the brand colour must be #rrggbb.
 */
export function renderProposalHtml(data: ProposalPdfData, fontCss = ""): string {
  const t = data.language === "hi" ? strings.hi : strings.en;
  const p = data.proposal;
  const brand = safeColor(data.company.brand_color);
  const signature = safeImage(data.signature_png);
  const layout = safeImage(data.roof_layout_png);
  const annual = p.monthly_generation.reduce((a, b) => a + b, 0);
  const lifetimeYears = p.lifetime_years ?? 25;

  const header = `<div class="band"><div class="company">${esc(data.company.name)}</div>
<div class="small">${esc([data.company.phone, data.company.address].filter(Boolean).join(" · "))}</div></div>`;
  const footer = (n: number) =>
    `<div class="footer">${esc(data.company.name)}${data.company.gstin ? ` · GSTIN ${esc(data.company.gstin)}` : ""} · ${esc(t.proposalNo)} ${esc(p.number)} · ${esc(t.page)} ${n}/4</div>`;

  const priceRows = [
    [t.systemPrice, rupees(p.gross_price), ""],
    [t.centralSubsidy, `− ${rupees(p.central_subsidy)}`, "green"],
    ...(p.state_subsidy > 0 ? [[t.stateSubsidy, `− ${rupees(p.state_subsidy)}`, "green"]] : []),
  ]
    .map(([l, v, c]) => `<tr><td>${esc(l)}</td><td class="num ${c}">${esc(v)}</td></tr>`)
    .join("");

  const productRows = [
    p.panel
      ? `<tr><td>${esc(t.panels)}</td><td>${esc(`${p.panel.brand} ${p.panel.model}`)}${p.panel.count && p.panel.watt_peak ? `<br><span class="small">${p.panel.count} × ${number(p.panel.watt_peak)} Wp</span>` : ""}${p.panel.is_dcr && p.panel.almm_listed ? `<br><span class="tag">${esc(t.dcrAlmm)}</span>` : ""}</td><td>${p.panel.warranty_years ? esc(fill(t.years, { n: p.panel.warranty_years })) : "—"}</td></tr>`
      : "",
    p.inverter
      ? `<tr><td>${esc(t.inverter)}</td><td>${esc(`${p.inverter.brand} ${p.inverter.model}`)}</td><td>${p.inverter.warranty_years ? esc(fill(t.years, { n: p.inverter.warranty_years })) : "—"}</td></tr>`
      : "",
  ].join("");

  return `<!doctype html>
<html lang="${data.language}">
<head>
<meta charset="utf-8">
<title>${esc(t.title)} – ${esc(data.customer.name)}</title>
<style>
${fontCss}
@page { size: A4; margin: 0; }
* { box-sizing: border-box; }
body { margin: 0; font-family: 'NotoSans', 'NotoSansDevanagari', sans-serif; color: #1f1f1f; font-size: 13px; line-height: 1.5; }
.page { width: 210mm; height: 297mm; padding: 0 16mm 18mm; position: relative; page-break-after: always; overflow: hidden; }
.page:last-child { page-break-after: auto; }
.band { background: ${brand}; color: #fff; margin: 0 -16mm 10mm; padding: 9mm 16mm 7mm; }
.company { font-size: 20px; font-weight: 700; }
.small { font-size: 11px; opacity: .9; }
h1 { font-size: 30px; margin: 30mm 0 4mm; color: ${brand}; }
h2 { font-size: 18px; margin: 8mm 0 3mm; color: ${brand}; }
.big { font-size: 64px; font-weight: 700; color: ${brand}; line-height: 1.1; }
.muted { color: #666; }
table { width: 100%; border-collapse: collapse; }
td, th { padding: 7px 4px; border-bottom: 1px solid #e6e6e6; text-align: left; vertical-align: top; }
th { font-size: 11px; text-transform: uppercase; color: #666; }
.num { text-align: right; white-space: nowrap; }
.green { color: #2e7d32; }
.total td { font-size: 17px; font-weight: 700; border-top: 2px solid ${brand}; border-bottom: none; }
.boxes { display: flex; gap: 8mm; margin-top: 3mm; }
.box { flex: 1; border-radius: 8px; padding: 5mm; }
.box .label { font-size: 12px; color: #444; }
.box .value { font-size: 26px; font-weight: 700; }
.emi { background: #e8f5e9; } .emi .value { color: #2e7d32; }
.bill { background: #fdecea; } .bill .value { color: #c62828; }
.tag { display: inline-block; font-size: 10px; background: #e8f5e9; color: #2e7d32; border-radius: 4px; padding: 1px 6px; }
.layout { border: 1px dashed #bbb; border-radius: 8px; padding: 8mm; text-align: center; color: #777; }
.layout img { max-width: 100%; max-height: 80mm; }
ol { padding-left: 5mm; margin: 0; columns: 2; column-gap: 8mm; }
ol li { margin-bottom: 2px; }
ul.terms { padding-left: 5mm; font-size: 11.5px; color: #333; }
.sign { margin-top: 6mm; display: flex; gap: 10mm; align-items: flex-end; }
.sign .slot { flex: 1; border-bottom: 1px solid #333; height: 30mm; display: flex; align-items: flex-end; justify-content: center; }
.sign img { max-height: 28mm; max-width: 100%; }
.footer { position: absolute; bottom: 8mm; left: 16mm; right: 16mm; font-size: 10px; color: #888; border-top: 1px solid #eee; padding-top: 2mm; }
</style>
</head>
<body>

<section class="page">
${header}
<h1>${esc(t.title)}</h1>
<div class="muted">${esc(t.underScheme)}</div>
<div style="margin-top: 18mm" class="muted">${esc(t.preparedFor)}</div>
<div style="font-size: 26px; font-weight: 700">${esc(data.customer.name)}</div>
<div class="muted">${esc([data.customer.phone, data.customer.address].filter(Boolean).join(" · "))}</div>
<div style="margin-top: 16mm" class="muted">${esc(t.systemSize)}</div>
<div class="big">${esc(kw(p.system_kw))}</div>
<table style="margin-top: 18mm; width: 60%">
<tr><td class="muted">${esc(t.proposalNo)}</td><td>${esc(p.number)}</td></tr>
<tr><td class="muted">${esc(t.date)}</td><td>${esc(date(p.date, data.language))}</td></tr>
${p.valid_until ? `<tr><td class="muted">${esc(t.validUntil)}</td><td>${esc(date(p.valid_until, data.language))}</td></tr>` : ""}
</table>
${footer(1)}
</section>

<section class="page">
${header}
<h2>${esc(t.recommendation)}</h2>
<table>
<tr><td>${esc(t.systemSize)}</td><td class="num"><b>${esc(kw(p.system_kw))}</b></td></tr>
${p.panel ? `<tr><td>${esc(t.panels)}</td><td class="num">${esc(p.panel.count ? `${p.panel.count} × ` : "")}${esc(`${p.panel.brand} ${p.panel.watt_peak ? `${number(p.panel.watt_peak)} Wp` : ""}`)}</td></tr>` : ""}
${p.inverter ? `<tr><td>${esc(t.inverter)}</td><td class="num">${esc(`${p.inverter.brand} ${p.inverter.model}`)}</td></tr>` : ""}
</table>
<h2>${esc(t.roofLayout)}</h2>
<div class="layout">${layout ? `<img src="${layout}" alt="">` : esc(t.roofLayoutPending)}</div>
<h2>${esc(t.generation)}</h2>
${generationChart(p.monthly_generation, t.months, brand)}
<div class="muted">${esc(fill(t.yearlyGeneration, { units: number(annual) }))}</div>
${footer(2)}
</section>

<section class="page">
${header}
<h2>${esc(t.priceTitle)}</h2>
<table>
${priceRows}
<tr class="total"><td>${esc(t.youPay)}</td><td class="num">${esc(rupees(p.net_price))}</td></tr>
</table>
<p class="muted small" style="color:#555">${esc(t.subsidyNote)}</p>
${p.loan ? `<h2>${esc(t.emiTitle)}</h2>
<div class="boxes">
<div class="box emi"><div class="label">${esc(t.emi)}</div><div class="value">${esc(rupees(p.loan.emi))}</div></div>
${p.current_monthly_bill ? `<div class="box bill"><div class="label">${esc(t.currentBill)}</div><div class="value">${esc(rupees(p.current_monthly_bill))}</div></div>` : ""}
</div>
<div class="muted" style="margin-top: 2mm">${esc(fill(t.loanDetails, { bank: p.loan.bank ?? "", rate: p.loan.rate, years: p.loan.years, amount: rupees(p.loan.amount) }))}</div>` : ""}
${p.annual_savings != null ? `<h2>${esc(t.savingsTitle)}</h2>
<table>
<tr><td>${esc(t.monthlySaving)}</td><td class="num">${esc(rupees(p.annual_savings / 12))}</td></tr>
${p.payback_years != null ? `<tr><td>${esc(t.payback)}</td><td class="num">${esc(fill(t.paybackYears, { years: p.payback_years.toFixed(1) }))}</td></tr>` : ""}
${p.lifetime_savings != null ? `<tr class="total"><td>${esc(fill(t.lifetime, { years: lifetimeYears }))}</td><td class="num green">${esc(rupees(p.lifetime_savings))}</td></tr>` : ""}
</table>` : ""}
${footer(3)}
</section>

<section class="page">
${header}
<h2>${esc(t.productsTitle)}</h2>
<table>
<tr><th>${esc(t.product)}</th><th>${esc(t.details)}</th><th>${esc(t.warranty)}</th></tr>
${productRows}
</table>
<h2>${esc(t.processTitle)}</h2>
<ol>${t.steps.map((s) => `<li>${esc(s)}</li>`).join("")}</ol>
<h2>${esc(t.termsTitle)}</h2>
<ul class="terms">${t.terms.map((s) => `<li>${esc(s)}</li>`).join("")}</ul>
<h2>${esc(t.acceptance)}</h2>
<div class="sign">
<div class="slot">${signature ? `<img src="${signature}" alt="">` : ""}</div>
<div style="flex:1">
<div><b>${esc(data.customer.name)}</b></div>
<div class="muted">${esc(t.signHere)}</div>
${data.signed_at ? `<div class="muted">${esc(fill(t.signedOn, { date: date(data.signed_at, data.language) }))}</div>` : ""}
</div>
</div>
${footer(4)}
</section>

</body>
</html>`;
}
