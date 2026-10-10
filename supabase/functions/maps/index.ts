// maps: Google Maps Platform for the survey, with the key kept server-side.
//
// POST { "action": "geocode", "address": "..." }        → { lat, lng, address } | { found: false }
// POST { "action": "autocomplete", "input": "...", "session"?: "..." } → { suggestions: [{ placeId, text }] }
// POST { "action": "place", "placeId": "...", "session"?: "..." }      → { lat, lng, address }
// POST { "action": "solar", "lat": 26.85, "lng": 80.99 }  → SolarSummary | { found: false }
//
// Secret: GOOGLE_MAPS_SERVER_KEY (Geocoding, Places (New), Solar API).

import { requireMember } from "../_shared/auth.ts";
import { handler, HttpError, json, readJson, requireEnv } from "../_shared/http.ts";
import {
  isLatLng,
  parseGeocode,
  parseSuggestions,
  summariseBuilding,
} from "../_shared/maps.ts";

const str = (v: unknown, max = 300) =>
  typeof v === "string" && v.trim() ? v.trim().slice(0, max) : null;

Deno.serve(handler(async (req) => {
  await requireMember(req);
  const body = await readJson(req);
  const key = requireEnv("GOOGLE_MAPS_SERVER_KEY");

  switch (body.action) {
    case "geocode": {
      const address = str(body.address);
      if (!address) throw new HttpError(400, "bad_request", "address required");
      const url = new URL("https://maps.googleapis.com/maps/api/geocode/json");
      url.search = new URLSearchParams({ address, region: "in", components: "country:IN", key }).toString();
      const res = await fetch(url);
      const hit = parseGeocode(await res.json());
      return json(hit ?? { found: false });
    }
    case "autocomplete": {
      const input = str(body.input, 120);
      if (!input) return json({ suggestions: [] });
      const res = await fetch("https://places.googleapis.com/v1/places:autocomplete", {
        method: "POST",
        headers: { "Content-Type": "application/json", "X-Goog-Api-Key": key },
        body: JSON.stringify({
          input,
          includedRegionCodes: ["in"],
          ...(str(body.session) ? { sessionToken: str(body.session) } : {}),
        }),
      });
      return json({ suggestions: parseSuggestions(await res.json()) });
    }
    case "place": {
      const placeId = str(body.placeId, 200);
      if (!placeId || !/^[A-Za-z0-9_-]+$/.test(placeId)) {
        throw new HttpError(400, "bad_request", "placeId required");
      }
      const url = new URL(`https://places.googleapis.com/v1/places/${placeId}`);
      if (str(body.session)) url.searchParams.set("sessionToken", str(body.session)!);
      const res = await fetch(url, {
        headers: { "X-Goog-Api-Key": key, "X-Goog-FieldMask": "location,formattedAddress" },
      });
      const p = await res.json() as { location?: { latitude?: number; longitude?: number }; formattedAddress?: string };
      if (p.location?.latitude == null || p.location?.longitude == null) return json({ found: false });
      return json({ lat: p.location.latitude, lng: p.location.longitude, address: p.formattedAddress ?? "" });
    }
    case "solar": {
      const at = { lat: Number(body.lat), lng: Number(body.lng) };
      if (!isLatLng(at)) throw new HttpError(400, "bad_request", "lat/lng required");
      const url = new URL("https://solar.googleapis.com/v1/buildingInsights:findClosest");
      url.search = new URLSearchParams({
        "location.latitude": String(at.lat),
        "location.longitude": String(at.lng),
        // India has LOW-quality coverage only (Oct 2026).
        requiredQuality: "LOW",
        key,
      }).toString();
      const res = await fetch(url);
      if (res.status === 404) return json({ found: false });
      if (!res.ok) {
        console.error("solar", res.status, await res.text());
        throw new HttpError(502, "upstream", "Solar API failed");
      }
      return json(summariseBuilding(await res.json()) ?? { found: false });
    }
    default:
      throw new HttpError(400, "bad_request", "unknown action");
  }
}));
