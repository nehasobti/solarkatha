import { assert, assertEquals } from "jsr:@std/assert@1";

import {
  isLatLng,
  parseGeocode,
  parseSuggestions,
  summariseBuilding,
} from "../_shared/maps.ts";

Deno.test("geocode takes the first result", () => {
  assertEquals(
    parseGeocode({
      status: "OK",
      results: [{
        formatted_address: "Gomti Nagar, Lucknow",
        geometry: { location: { lat: 26.85, lng: 81.0 } },
      }],
    }),
    { lat: 26.85, lng: 81.0, address: "Gomti Nagar, Lucknow" },
  );
  assertEquals(parseGeocode({ status: "ZERO_RESULTS", results: [] }), null);
});

Deno.test("autocomplete suggestions keep place id and text, max 5", () => {
  const body = {
    suggestions: Array.from({ length: 7 }, (_, i) => ({
      placePrediction: { placeId: `p${i}`, text: { text: `Place ${i}` } },
    })),
  };
  const s = parseSuggestions(body);
  assertEquals(s.length, 5);
  assertEquals(s[0], { placeId: "p0", text: "Place 0" });
  assertEquals(parseSuggestions({}), []);
});

Deno.test("building insights summary picks the largest segment first", () => {
  const s = summariseBuilding({
    center: { latitude: 26.85, longitude: 80.99 },
    imageryQuality: "LOW",
    imageryDate: { year: 2023, month: 3, day: 9 },
    boundingBox: {
      sw: { latitude: 26.8501, longitude: 80.9991 },
      ne: { latitude: 26.8503, longitude: 80.9994 },
    },
    solarPotential: {
      maxArrayPanelsCount: 21,
      panelCapacityWatts: 400,
      maxSunshineHoursPerYear: 1762.9,
      wholeRoofStats: { areaMeters2: 120.5 },
      roofSegmentStats: [
        { pitchDegrees: 2, azimuthDegrees: 90, stats: { areaMeters2: 20, sunshineQuantiles: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11] } },
        { pitchDegrees: 1, azimuthDegrees: 185, stats: { areaMeters2: 80, sunshineQuantiles: [1, 2, 3, 4, 5, 1700, 7, 8, 9, 10, 11] } },
      ],
    },
  })!;
  assertEquals(s.maxPanels, 21);
  assertEquals(s.areaSqm, 120.5);
  assertEquals(s.imageryDate, "2023-03-09");
  assertEquals(s.segments[0].azimuthDeg, 185);
  assertEquals(s.segments[0].sunshineMedian, 1700);
  assert(s.box);
});

Deno.test("summary is null without a center", () => {
  assertEquals(summariseBuilding({}), null);
});

Deno.test("lat/lng validation", () => {
  assert(isLatLng({ lat: 26.8, lng: 80.9 }));
  assert(!isLatLng({ lat: 100, lng: 80 }));
  assert(!isLatLng({ lat: "x", lng: 1 }));
});
