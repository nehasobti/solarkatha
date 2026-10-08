const rupeeFormat = new Intl.NumberFormat("en-IN", {
  style: "currency",
  currency: "INR",
  maximumFractionDigits: 0,
});
const numberFormat = new Intl.NumberFormat("en-IN", { maximumFractionDigits: 0 });

/** ₹1,23,456 (Indian grouping, no decimals). */
export function rupees(v: number): string {
  return rupeeFormat.format(Math.round(v));
}

export function number(v: number): string {
  return numberFormat.format(Math.round(v));
}

export function kw(v: number): string {
  return `${Number(v.toFixed(2))} kW`;
}

export function date(iso: string, language: "en" | "hi"): string {
  const d = new Date(iso);
  if (Number.isNaN(d.getTime())) return iso;
  return d.toLocaleDateString(language === "hi" ? "hi-IN" : "en-IN", {
    day: "numeric",
    month: "short",
    year: "numeric",
    timeZone: "Asia/Kolkata",
  });
}

/** Escapes text for HTML. Every user-supplied value goes through this. */
export function esc(v: unknown): string {
  return String(v ?? "")
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#39;");
}

/** Only a #rrggbb colour is accepted for branding. */
export function safeColor(v: string | null | undefined, fallback = "#E07B00"): string {
  return v && /^#[0-9a-fA-F]{6}$/.test(v) ? v : fallback;
}

/** Only PNG/JPEG data URLs are embedded. */
export function safeImage(v: string | null | undefined): string | null {
  return v && /^data:image\/(png|jpeg);base64,[A-Za-z0-9+/=]+$/.test(v) ? v : null;
}
