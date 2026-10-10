// Push notifications through Firebase Cloud Messaging (HTTP v1).
//
// The service account JSON (FCM_SERVICE_ACCOUNT secret) signs a short-lived
// JWT, which Google exchanges for an OAuth token used to send messages.

export interface ServiceAccount {
  project_id: string;
  client_email: string;
  private_key: string;
}

export interface PushText {
  title: string;
  body: string;
}

const STAGES: Record<string, { en: string; hi: string }> = {
  portal_registration: { en: "Registration on the national portal", hi: "राष्ट्रीय पोर्टल पर पंजीकरण" },
  discom_feasibility: { en: "DISCOM feasibility approval", hi: "DISCOM से व्यवहार्यता मंज़ूरी" },
  vendor_selected: { en: "Vendor selected", hi: "वेंडर चुना गया" },
  installation: { en: "Installation", hi: "इंस्टॉलेशन" },
  net_meter_applied: { en: "Net meter applied", hi: "नेट मीटर के लिए आवेदन" },
  net_meter_installed: { en: "Net meter installed", hi: "नेट मीटर लगा" },
  inspection: { en: "Inspection", hi: "निरीक्षण" },
  commissioning_certificate: { en: "Commissioning certificate", hi: "कमीशनिंग प्रमाणपत्र" },
  subsidy_claimed: { en: "Subsidy claimed", hi: "सब्सिडी का दावा किया" },
  subsidy_credited: { en: "Subsidy credited", hi: "सब्सिडी जमा हुई" },
};

/** Notification text in the member's language. Null for unknown kinds. */
export function pushText(
  kind: string,
  data: Record<string, unknown>,
  customer: string,
  lang: string,
): PushText | null {
  const hi = lang === "hi";
  if (kind === "project_created") {
    const kw = Number(data.system_kw ?? 0);
    const size = Number.isFinite(kw) && kw > 0 ? ` (${kw} kW)` : "";
    return hi
      ? { title: "प्रस्ताव साइन हुआ", body: `${customer}${size}: प्रोजेक्ट शुरू हो गया।` }
      : { title: "Proposal signed", body: `${customer}${size}: project started.` };
  }
  if (kind === "stage_done") {
    const stage = STAGES[String(data.stage)];
    const name = stage ? (hi ? stage.hi : stage.en) : String(data.stage ?? "");
    return hi
      ? { title: "चरण पूरा", body: `${customer}: ${name}` }
      : { title: "Stage done", body: `${customer}: ${name}` };
  }
  return null;
}

/** FCM v1 message for one device token. */
export function fcmMessage(
  token: string,
  text: PushText,
  data: Record<string, string>,
) {
  return {
    message: {
      token,
      notification: text,
      data,
      android: { priority: "high" },
    },
  };
}

function base64url(bytes: Uint8Array | string): string {
  const b = typeof bytes === "string" ? new TextEncoder().encode(bytes) : bytes;
  let s = "";
  for (const x of b) s += String.fromCharCode(x);
  return btoa(s).replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");
}

function pemToDer(pem: string): Uint8Array<ArrayBuffer> {
  const b64 = pem.replace(/-----[^-]+-----/g, "").replace(/\s+/g, "");
  const raw = atob(b64);
  const out = new Uint8Array(raw.length);
  for (let i = 0; i < raw.length; i++) out[i] = raw.charCodeAt(i);
  return out;
}

/** Signed JWT asking Google for an FCM access token. */
export async function serviceAccountJwt(
  sa: ServiceAccount,
  nowSeconds = Math.floor(Date.now() / 1000),
): Promise<string> {
  const header = base64url(JSON.stringify({ alg: "RS256", typ: "JWT" }));
  const claims = base64url(JSON.stringify({
    iss: sa.client_email,
    scope: "https://www.googleapis.com/auth/firebase.messaging",
    aud: "https://oauth2.googleapis.com/token",
    iat: nowSeconds,
    exp: nowSeconds + 3600,
  }));
  const key = await crypto.subtle.importKey(
    "pkcs8",
    pemToDer(sa.private_key),
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const sig = await crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5",
    key,
    new TextEncoder().encode(`${header}.${claims}`),
  );
  return `${header}.${claims}.${base64url(new Uint8Array(sig))}`;
}

export async function accessToken(sa: ServiceAccount): Promise<string> {
  const res = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: await serviceAccountJwt(sa),
    }),
  });
  if (!res.ok) throw new Error(`oauth ${res.status}: ${await res.text()}`);
  return (await res.json()).access_token as string;
}

/** True when FCM says the token is gone and should be deleted. */
export function isDeadToken(status: number, body: string): boolean {
  return status === 404 || (status === 400 && body.includes("INVALID_ARGUMENT") && body.includes("token")) ||
    body.includes("UNREGISTERED");
}

/** Constant-time string comparison for the hook secret. */
export function safeEqual(a: string, b: string): boolean {
  if (!a || a.length !== b.length) return false;
  let diff = 0;
  for (let i = 0; i < a.length; i++) diff |= a.charCodeAt(i) ^ b.charCodeAt(i);
  return diff === 0;
}
