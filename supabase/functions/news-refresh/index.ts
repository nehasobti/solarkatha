// news-refresh: pulls solar news headlines (Google News RSS) into
// public.news_items. Called daily by pg_cron with `x-cron-secret`.
// Deployed with --no-verify-jwt. Secret: CRON_SECRET (= Vault cron_secret).

import { createClient } from "npm:@supabase/supabase-js@2";

import { corsHeaders, json, requireEnv } from "../_shared/http.ts";
import { FEEDS, type NewsItem, parseRss, pickLatest } from "../_shared/news.ts";
import { safeEqual } from "../_shared/push.ts";

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }
  if (req.method !== "POST") return json({ error: "method_not_allowed" }, 405);
  if (!safeEqual(Deno.env.get("CRON_SECRET") ?? "", req.headers.get("x-cron-secret") ?? "")) {
    return json({ error: "unauthorized" }, 401);
  }

  const all: NewsItem[] = [];
  for (const feed of FEEDS) {
    try {
      const res = await fetch(feed.url, {
        headers: { "User-Agent": "SolarKatha news (info@tychonsoftware.com)" },
        signal: AbortSignal.timeout(15_000),
      });
      if (res.ok) all.push(...parseRss(await res.text(), feed.lang));
      else console.error("feed", feed.url, res.status);
    } catch (e) {
      console.error("feed", feed.url, e);
    }
  }
  const latest = [
    ...pickLatest(all.filter((i) => i.lang === "en"), 30),
    ...pickLatest(all.filter((i) => i.lang === "hi"), 30),
  ];
  if (!latest.length) return json({ ok: true, saved: 0 });

  const admin = createClient(
    requireEnv("SUPABASE_URL"),
    requireEnv("SUPABASE_SERVICE_ROLE_KEY"),
    { auth: { persistSession: false } },
  );
  const { error } = await admin
    .from("news_items")
    .upsert(latest.map((i) => ({ ...i, fetched_at: new Date().toISOString() })), { onConflict: "url" });
  if (error) {
    console.error(error);
    return json({ error: "db_failed" }, 500);
  }
  // Keep the table small: 45 days.
  await admin.from("news_items").delete()
    .lt("published_at", new Date(Date.now() - 45 * 86_400_000).toISOString());
  return json({ ok: true, saved: latest.length });
});
