// push: sends a phone notification for a row in public.notifications.
//
// Called by the database (pg_net) right after a notification is inserted,
// with the shared secret in `x-push-secret`. Deployed with --no-verify-jwt.
//
// Secrets: PUSH_HOOK_SECRET (same value as vault secret push_hook_secret),
// FCM_SERVICE_ACCOUNT (Firebase service account JSON).

import { createClient } from "npm:@supabase/supabase-js@2";

import { corsHeaders, json, requireEnv } from "../_shared/http.ts";
import {
  accessToken,
  fcmMessage,
  isDeadToken,
  pushText,
  safeEqual,
  type ServiceAccount,
} from "../_shared/push.ts";

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }
  if (req.method !== "POST") return json({ error: "method_not_allowed" }, 405);
  if (
    !safeEqual(
      Deno.env.get("PUSH_HOOK_SECRET") ?? "",
      req.headers.get("x-push-secret") ?? "",
    )
  ) {
    return json({ error: "unauthorized" }, 401);
  }

  let id: string;
  try {
    id = String((await req.json()).notification_id ?? "");
  } catch {
    return json({ error: "bad_request" }, 400);
  }
  const rawSa = Deno.env.get("FCM_SERVICE_ACCOUNT");
  if (!rawSa) return json({ ok: true, skipped: "fcm_not_configured" });

  const admin = createClient(
    requireEnv("SUPABASE_URL"),
    requireEnv("SUPABASE_SERVICE_ROLE_KEY"),
    { auth: { persistSession: false } },
  );

  const { data: n } = await admin
    .from("notifications")
    .select("id, profile_id, kind, entity_id, data")
    .eq("id", id)
    .maybeSingle();
  if (!n) return json({ error: "not_found" }, 404);

  const [{ data: profile }, { data: tokens }] = await Promise.all([
    admin.from("profiles").select("language, active").eq("id", n.profile_id)
      .maybeSingle(),
    admin.from("device_tokens").select("token").eq("profile_id", n.profile_id),
  ]);
  if (!profile?.active || !tokens?.length) return json({ ok: true, sent: 0 });

  const data = (n.data ?? {}) as Record<string, unknown>;
  let customer = "";
  if (data.lead_id) {
    const { data: lead } = await admin.from("leads").select("name")
      .eq("id", data.lead_id).maybeSingle();
    customer = lead?.name ?? "";
  }
  const text = pushText(n.kind, data, customer, profile.language ?? "en");
  if (!text) return json({ ok: true, sent: 0 });

  const sa = JSON.parse(rawSa) as ServiceAccount;
  const bearer = await accessToken(sa);
  const url =
    `https://fcm.googleapis.com/v1/projects/${sa.project_id}/messages:send`;
  const route = n.entity_id ? `/projects/${n.entity_id}` : "/notifications";

  let sent = 0;
  const dead: string[] = [];
  for (const { token } of tokens) {
    const res = await fetch(url, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${bearer}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify(
        fcmMessage(token, text, { route, notification_id: n.id }),
      ),
    });
    const body = await res.text();
    if (res.ok) sent++;
    else if (isDeadToken(res.status, body)) dead.push(token);
    else console.error("fcm", res.status, body);
  }
  if (dead.length) {
    await admin.from("device_tokens").delete().in("token", dead);
  }
  return json({ ok: true, sent, removed: dead.length });
});
