// Pure helpers for the generation-estimate function (no network).

export const daysInMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

/** Cache key: location rounded to 0.05°. */
export function roundKey(deg: number): number {
  return Math.round(deg * 20) / 20;
}

export interface EstimateInput {
  lat: number;
  lng: number;
  kw: number;
  tilt: number;
  azimuth: number;
}

/** Validates the request; tilt defaults to latitude, azimuth to south (180). */
export function parseInput(body: Record<string, unknown>): EstimateInput {
  const n = (v: unknown) => (typeof v === "number" ? v : Number(v));
  const lat = n(body.lat);
  const lng = n(body.lng);
  const kw = n(body.kw ?? 1);
  if (!Number.isFinite(lat) || lat < -90 || lat > 90) throw new Error("lat");
  if (!Number.isFinite(lng) || lng < -180 || lng > 180) throw new Error("lng");
  if (!Number.isFinite(kw) || kw <= 0 || kw > 1000) throw new Error("kw");
  const tilt = body.tilt === undefined || body.tilt === null
    ? Math.round(Math.abs(lat))
    : Math.round(n(body.tilt));
  const azimuth = body.azimuth === undefined || body.azimuth === null
    ? 180
    : Math.round(n(body.azimuth));
  if (!Number.isFinite(tilt) || tilt < 0 || tilt > 90) throw new Error("tilt");
  if (!Number.isFinite(azimuth) || azimuth < 0 || azimuth >= 360) {
    throw new Error("azimuth");
  }
  return { lat, lng, kw, tilt, azimuth };
}

/** PVGIS PVcalc URL for 1 kWp. PVGIS aspect: 0 = south, 90 = west. */
export function pvgisUrl(
  lat: number,
  lng: number,
  tilt: number,
  azimuth: number,
  lossPct: number,
): string {
  const params = new URLSearchParams({
    lat: String(lat),
    lon: String(lng),
    peakpower: "1",
    loss: String(lossPct),
    angle: String(tilt),
    aspect: String(azimuth - 180),
    outputformat: "json",
  });
  return `https://re.jrc.ec.europa.eu/api/v5_3/PVcalc?${params}`;
}

/** Monthly kWh per kWp from a PVcalc response. */
export function parsePvgis(json: unknown): number[] {
  const months = (json as {
    outputs?: { monthly?: { fixed?: { month: number; E_m: number }[] } };
  })?.outputs?.monthly?.fixed;
  if (!Array.isArray(months) || months.length !== 12) {
    throw new Error("Unexpected PVGIS response");
  }
  const out = new Array<number>(12).fill(0);
  for (const m of months) {
    if (typeof m.month !== "number" || m.month < 1 || m.month > 12) {
      throw new Error("Bad PVGIS month");
    }
    if (typeof m.E_m !== "number" || !Number.isFinite(m.E_m) || m.E_m < 0) {
      throw new Error("Bad PVGIS value");
    }
    out[m.month - 1] = Math.round(m.E_m * 100) / 100;
  }
  return out;
}

/** Flat fallback when PVGIS is down: yield × days in month. */
export function fallbackMonthly(yieldKwhPerKwDay: number): number[] {
  return daysInMonth.map((d) => Math.round(yieldKwhPerKwDay * d * 100) / 100);
}

export function scale(perKw: number[], kw: number): number[] {
  return perKw.map((v) => Math.round(v * kw * 100) / 100);
}
