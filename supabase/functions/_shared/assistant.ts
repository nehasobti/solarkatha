// Public product assistant for the landing page: answers questions about
// SolarKatha from a fixed fact sheet. It never sees customer data.

export interface Turn {
  role: "user" | "model";
  text: string;
}

export const MAX_TURNS = 10;
export const MAX_CHARS = 600;

export const FACTS = `
SolarKatha is a mobile (Android) and web app for Indian rooftop solar installers.
It runs a job from the first site visit to the PM Surya Ghar subsidy credit.

Who uses it:
- Owner: dashboard, team, products, prices and settings, all leads and projects.
- Sales rep: own leads, bill scan, sizing, roof survey, proposals.
- Installer: only the projects assigned to them; marks stages done, adds photos/documents.

Main features:
- Leads: add customers with phone, address, photos and follow-up dates. Works offline at the site and syncs automatically when the internet is back.
- AI bill scan: photograph the electricity bill; AI reads monthly units, sanctioned load and DISCOM. The rep confirms.
- Sizing: recommends the system size (kW) from usage, roof and sanctioned load. Shows central + state subsidy, customer's net price, loan EMI, payback years and 25-year savings, and monthly generation from PVGIS sun data.
- Roof survey: on satellite imagery (Google), search the address, tap the roof corners or tap "Detect roof (Google)" to outline it automatically. Panels are laid out automatically and the roof limits the maximum kW. Roof type, direction, tilt and shading are recorded.
- Proposals: compliance checks (DCR panels, ALMM list, approved inverter), Hindi or English PDF proposal, share on WhatsApp, customer signs on the phone, UPI advance payment link through Razorpay that is marked paid automatically.
- Projects: the 10 PM Surya Ghar stages (portal registration, DISCOM feasibility, vendor selection, installation, net meter applied, net meter installed, inspection, commissioning certificate, subsidy claimed, subsidy credited) with due dates, overdue alerts, documents and installer assignment.
- Customer tracking link: the customer opens a link (no login) to see progress, sign and pay, in Hindi or English, in the company's colours.
- Notifications: phone push notifications when a proposal is signed or a stage is done; WhatsApp update messages for customers.
- Owner dashboard: kW sold, revenue, conversion rate, subsidies pending, projects by stage, team performance, CSV export.
- Settings: subsidy slabs, electricity tariffs, loan options and message templates can be changed per company. Brand colour, logo details, GSTIN.
- Languages: Hindi and English everywhere. High-contrast mode and large text for outdoor use.

Access:
- Login is private: mobile number + password given by the administrator. There is no public sign-up or demo login.
- To get access or a demo, the visitor should contact the SolarKatha team (the person who shared this link). Do not invent phone numbers, emails or prices.
- Android app: "Download Android app" button on the login page. The web app works in any browser.

Subsidy facts (PM Surya Ghar, residential, as configured by default):
- Central subsidy: Rs 30,000 per kW for the first 2 kW, Rs 18,000 for the 3rd kW, maximum Rs 78,000 (3 kW and above).
- Uttar Pradesh adds a state top-up of Rs 15,000 per kW, up to Rs 30,000.
- Subsidy needs DCR (made-in-India cells) panels from the ALMM list.
- These numbers are editable in the app's settings because rules change.
`.trim();

export function systemPrompt(lang: string): string {
  const language = lang === "hi" ? "Hindi (Devanagari script)" : "English";
  return [
    "You are the SolarKatha assistant on the app's login page.",
    "Answer only questions about SolarKatha, using the facts below, and general rooftop-solar questions an installer or homeowner in India might ask.",
    "If something is not in the facts, say you are not sure and suggest contacting the SolarKatha team. Never invent prices for SolarKatha itself, contact details, or features.",
    "You cannot see any customer, lead or company data and cannot log anyone in or change anything.",
    "Politely refuse unrelated requests (coding, other topics) in one sentence.",
    `Reply in ${language} unless the user clearly writes in the other language. Keep answers short: 2 to 6 sentences or a short list. Plain text, no markdown headings.`,
    "",
    "FACTS:",
    FACTS,
  ].join("\n");
}

/** Keeps the last few valid turns, trimmed, ending with the user's question. */
export function cleanTurns(input: unknown): Turn[] | null {
  if (!Array.isArray(input)) return null;
  const turns: Turn[] = [];
  for (const t of input.slice(-MAX_TURNS)) {
    const o = t as { role?: unknown; text?: unknown } | null;
    const role = o?.role === "model" ? "model" : o?.role === "user" ? "user" : null;
    const text = typeof o?.text === "string" ? o.text.trim().slice(0, MAX_CHARS) : "";
    if (role && text) turns.push({ role, text });
  }
  return turns.length && turns[turns.length - 1].role === "user" ? turns : null;
}

export function geminiBody(turns: Turn[], lang: string) {
  return {
    systemInstruction: { parts: [{ text: systemPrompt(lang) }] },
    contents: turns.map((t) => ({ role: t.role, parts: [{ text: t.text }] })),
    generationConfig: { temperature: 0.3, maxOutputTokens: 500 },
  };
}
