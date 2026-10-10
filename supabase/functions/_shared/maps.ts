// Google Maps Platform helpers: geocoding, Places autocomplete and the
// Solar API, called from the `maps` Edge Function so the key stays here.

export interface LatLng {
  lat: number;
  lng: number;
}

export interface Box {
  sw: LatLng;
  ne: LatLng;
}

export interface RoofSegment {
  pitchDeg: number;
  azimuthDeg: number;
  areaSqm: number;
  sunshineMedian: number | null;
  box: Box | null;
}

export interface SolarSummary {
  center: LatLng;
  box: Box | null;
  areaSqm: number | null;
  maxPanels: number | null;
  panelWatts: number | null;
  maxSunshineHours: number | null;
  imageryDate: string | null;
  quality: string | null;
  segments: RoofSegment[];
}

const num = (v: unknown): number | null =>
  typeof v === "number" && Number.isFinite(v) ? v : null;

function latLng(v: unknown): LatLng | null {
  const o = v as { latitude?: unknown; longitude?: unknown } | null;
  const lat = num(o?.latitude);
  const lng = num(o?.longitude);
  return lat == null || lng == null ? null : { lat, lng };
}

function box(v: unknown): Box | null {
  const o = v as { sw?: unknown; ne?: unknown } | null;
  const sw = latLng(o?.sw);
  const ne = latLng(o?.ne);
  return sw && ne ? { sw, ne } : null;
}

/** Median (quantile 5 of 11) sunshine hours from a stats object. */
function median(stats: unknown): number | null {
  const q = (stats as { sunshineQuantiles?: unknown[] } | null)
    ?.sunshineQuantiles;
  return Array.isArray(q) && q.length >= 6 ? num(q[Math.floor(q.length / 2)]) : null;
}

/** Trims a Solar API buildingInsights response to what the survey needs. */
export function summariseBuilding(b: Record<string, unknown>): SolarSummary | null {
  const center = latLng(b.center);
  if (!center) return null;
  const sp = (b.solarPotential ?? {}) as Record<string, unknown>;
  const whole = (sp.wholeRoofStats ?? {}) as Record<string, unknown>;
  const d = b.imageryDate as { year?: number; month?: number; day?: number } | undefined;
  const segments = Array.isArray(sp.roofSegmentStats)
    ? (sp.roofSegmentStats as Record<string, unknown>[]).map((s) => ({
      pitchDeg: num(s.pitchDegrees) ?? 0,
      azimuthDeg: num(s.azimuthDegrees) ?? 180,
      areaSqm: num((s.stats as Record<string, unknown> | undefined)?.areaMeters2) ?? 0,
      sunshineMedian: median(s.stats),
      box: box(s.boundingBox),
    }))
      .sort((a, b) => b.areaSqm - a.areaSqm)
    : [];
  return {
    center,
    box: box(b.boundingBox),
    areaSqm: num(whole.areaMeters2),
    maxPanels: num(sp.maxArrayPanelsCount),
    panelWatts: num(sp.panelCapacityWatts),
    maxSunshineHours: num(sp.maxSunshineHoursPerYear),
    imageryDate: d?.year
      ? `${d.year}-${String(d.month ?? 1).padStart(2, "0")}-${String(d.day ?? 1).padStart(2, "0")}`
      : null,
    quality: typeof b.imageryQuality === "string" ? b.imageryQuality : null,
    segments,
  };
}

/** First geocoding result, or null. */
export function parseGeocode(body: Record<string, unknown>):
  | (LatLng & { address: string })
  | null {
  const r = (body.results as Record<string, unknown>[] | undefined)?.[0];
  const loc = (r?.geometry as { location?: { lat?: unknown; lng?: unknown } } | undefined)
    ?.location;
  const lat = num(loc?.lat);
  const lng = num(loc?.lng);
  if (lat == null || lng == null) return null;
  return { lat, lng, address: String(r?.formatted_address ?? "") };
}

/** Places (New) autocomplete suggestions. */
export function parseSuggestions(body: Record<string, unknown>) {
  const s = body.suggestions as Record<string, unknown>[] | undefined;
  return (s ?? [])
    .map((x) => x.placePrediction as Record<string, unknown> | undefined)
    .filter((p): p is Record<string, unknown> => !!p?.placeId)
    .map((p) => ({
      placeId: String(p.placeId),
      text: String((p.text as { text?: string } | undefined)?.text ?? ""),
    }))
    .slice(0, 5);
}

export function isLatLng(v: unknown): v is LatLng {
  const o = v as LatLng | null;
  return !!o && num(o.lat) != null && num(o.lng) != null &&
    Math.abs(o.lat) <= 90 && Math.abs(o.lng) <= 180;
}
