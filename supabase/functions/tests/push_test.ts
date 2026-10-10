import { assert, assertEquals } from "jsr:@std/assert@1";

import {
  fcmMessage,
  isDeadToken,
  parseServiceAccount,
  pushText,
  safeEqual,
  serviceAccountJwt,
} from "../_shared/push.ts";

Deno.test("project_created text in English and Hindi", () => {
  assertEquals(
    pushText("project_created", { system_kw: 3 }, "Ramesh Gupta", "en"),
    { title: "Proposal signed", body: "Ramesh Gupta (3 kW): project started." },
  );
  assertEquals(
    pushText("project_created", { system_kw: 3 }, "Ramesh Gupta", "hi")?.title,
    "प्रस्ताव साइन हुआ",
  );
});

Deno.test("stage_done names the stage in the member's language", () => {
  assertEquals(
    pushText("stage_done", { stage: "installation" }, "Sunita", "en"),
    { title: "Stage done", body: "Sunita: Installation" },
  );
  assertEquals(
    pushText("stage_done", { stage: "net_meter_installed" }, "Sunita", "hi")
      ?.body,
    "Sunita: नेट मीटर लगा",
  );
});

Deno.test("unknown kinds send nothing", () => {
  assertEquals(pushText("something_else", {}, "X", "en"), null);
});

Deno.test("FCM message carries the route for tap-to-open", () => {
  const m = fcmMessage("tok", { title: "t", body: "b" }, { route: "/projects/p1" });
  assertEquals(m.message.token, "tok");
  assertEquals(m.message.data.route, "/projects/p1");
  assertEquals(m.message.android.priority, "high");
});

Deno.test("dead tokens are recognised", () => {
  assert(isDeadToken(404, '{"error":{"status":"NOT_FOUND"}}'));
  assert(isDeadToken(400, '{"details":[{"errorCode":"UNREGISTERED"}]}'));
  assert(!isDeadToken(500, "internal"));
});

Deno.test("hook secret comparison", () => {
  assert(safeEqual("abc123", "abc123"));
  assert(!safeEqual("abc123", "abc124"));
  assert(!safeEqual("", ""));
  assert(!safeEqual("abc", "abcd"));
});

Deno.test("service account JWT is RS256 and verifies", async () => {
  const pair = await crypto.subtle.generateKey(
    {
      name: "RSASSA-PKCS1-v1_5",
      modulusLength: 2048,
      publicExponent: new Uint8Array([1, 0, 1]),
      hash: "SHA-256",
    },
    true,
    ["sign", "verify"],
  );
  const der = new Uint8Array(
    await crypto.subtle.exportKey("pkcs8", pair.privateKey),
  );
  const pem = `-----BEGIN PRIVATE KEY-----\n${
    btoa(String.fromCharCode(...der))
  }\n-----END PRIVATE KEY-----\n`;
  const jwt = await serviceAccountJwt({
    project_id: "p",
    client_email: "svc@p.iam.gserviceaccount.com",
    private_key: pem,
  }, 1_000);
  const [h, c, s] = jwt.split(".");
  const dec = (x: string) =>
    JSON.parse(atob(x.replace(/-/g, "+").replace(/_/g, "/")));
  assertEquals(dec(h).alg, "RS256");
  assertEquals(dec(c).exp, 4_600);
  assertEquals(dec(c).iss, "svc@p.iam.gserviceaccount.com");
  const sig = Uint8Array.from(
    atob(s.replace(/-/g, "+").replace(/_/g, "/").padEnd(Math.ceil(s.length / 4) * 4, "=")),
    (ch) => ch.charCodeAt(0),
  );
  assert(
    await crypto.subtle.verify(
      "RSASSA-PKCS1-v1_5",
      pair.publicKey,
      sig,
      new TextEncoder().encode(`${h}.${c}`),
    ),
  );
});

Deno.test("service account secret may be raw JSON or base64", () => {
  const sa = { project_id: "p", client_email: "e", private_key: "k" };
  const raw = JSON.stringify(sa);
  assertEquals(parseServiceAccount(raw).project_id, "p");
  assertEquals(parseServiceAccount(btoa(raw)).client_email, "e");
});
