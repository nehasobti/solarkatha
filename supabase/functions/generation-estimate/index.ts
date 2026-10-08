// generation-estimate: monthly generation for a site from PVGIS, cached by
// rounded location; falls back to the configured flat yield.
//
// POST { "lat": 26.85, "lng": 80.95, "kw": 3, "tilt"?: 25, "azimuth"?: 180 }
// → { "monthly_kwh_per_kw": [12], "monthly_kwh": [12], "source": "pvgis" | "cache" | "fallback" }

import { configValue, requireMember } from "../_shared/auth.ts";
import { handler, HttpError, json, readJson } from "../_shared/http.ts";
import {
  fallbackMonthly,
  parseInput,
  parsePvgis,
  pvgisUrl,
  roundKey,
  scale,
} from "../_shared/pvgis.ts";

Deno.serve(handler(async (req) => {
  const { admin, companyId } = await requireMember(req);
  let input;
  try {
    input = parseInput(await readJson(req));
  } catch (e) {
    if (e instanceof HttpError) throw e;
    throw new HttpError(400, "bad_request", `Invalid ${(e as Error).message}`);
  }
  const key = {
    lat_key: roundKey(input.lat),
    lng_key: roundKey(input.lng),
    tilt: input.tilt,
    azimuth: input.azimuth,
  };

  const { data: cached } = await admin
    .from("generation_cache")
    .select("monthly_kwh_per_kw")
    .match(key)
    .maybeSingle();
  if (cached) {
    const perKw = cached.monthly_kwh_per_kw as number[];
    return json({ monthly_kwh_per_kw: perKw, monthly_kwh: scale(perKw, input.kw), source: "cache" });
  }

  const loss = await configValue<number>(admin, companyId, "system_loss_pct", 14);
  try {
    const res = await fetch(
      pvgisUrl(key.lat_key, key.lng_key, input.tilt, input.azimuth, loss),
      { signal: AbortSignal.timeout(12_000) },
    );
    if (!res.ok) throw new Error(`PVGIS ${res.status}`);
    const perKw = parsePvgis(await res.json());
    await admin.from("generation_cache").upsert({ ...key, monthly_kwh_per_kw: perKw });
    return json({ monthly_kwh_per_kw: perKw, monthly_kwh: scale(perKw, input.kw), source: "pvgis" });
  } catch (e) {
    console.warn("PVGIS unavailable, using fallback:", (e as Error).message);
    const yieldPerDay = await configValue<number>(
      admin,
      companyId,
      "default_yield_kwh_per_kw_day",
      4.2,
    );
    const perKw = fallbackMonthly(yieldPerDay);
    return json({ monthly_kwh_per_kw: perKw, monthly_kwh: scale(perKw, input.kw), source: "fallback" });
  }
}));
