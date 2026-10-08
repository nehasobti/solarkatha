import { assertEquals, assertThrows } from "jsr:@std/assert@1";

import {
  fallbackMonthly,
  parseInput,
  parsePvgis,
  pvgisUrl,
  roundKey,
  scale,
} from "../_shared/pvgis.ts";

const pvgisResponse = {
  outputs: {
    monthly: {
      fixed: Array.from({ length: 12 }, (_, i) => ({
        month: i + 1,
        E_m: 100 + i * 5.123,
      })),
    },
  },
};

Deno.test("rounds location to 0.05°", () => {
  assertEquals(roundKey(26.8467), 26.85);
  assertEquals(roundKey(80.9212), 80.9);
  assertEquals(roundKey(-0.024), -0);
});

Deno.test("builds the PVcalc URL (aspect 0 = south)", () => {
  const url = new URL(pvgisUrl(26.85, 80.9, 25, 180, 14));
  assertEquals(url.hostname, "re.jrc.ec.europa.eu");
  assertEquals(url.searchParams.get("aspect"), "0");
  assertEquals(url.searchParams.get("angle"), "25");
  assertEquals(url.searchParams.get("loss"), "14");
  assertEquals(url.searchParams.get("peakpower"), "1");
  assertEquals(new URL(pvgisUrl(1, 1, 10, 270, 14)).searchParams.get("aspect"), "90");
});

Deno.test("parses PVGIS monthly output", () => {
  const months = parsePvgis(pvgisResponse);
  assertEquals(months.length, 12);
  assertEquals(months[0], 100);
  assertEquals(months[11], 156.35);
});

Deno.test("rejects malformed PVGIS output", () => {
  assertThrows(() => parsePvgis({}));
  assertThrows(() => parsePvgis({ outputs: { monthly: { fixed: [] } } }));
  const bad = structuredClone(pvgisResponse);
  bad.outputs.monthly.fixed[3].E_m = -1;
  assertThrows(() => parsePvgis(bad));
  const badMonth = structuredClone(pvgisResponse);
  badMonth.outputs.monthly.fixed[0].month = 13;
  assertThrows(() => parsePvgis(badMonth));
});

Deno.test("fallback is yield × days", () => {
  const f = fallbackMonthly(4.2);
  assertEquals(f[0], 130.2);
  assertEquals(f[1], 117.6);
  assertEquals(scale([100, 50.5], 3), [300, 151.5]);
});

Deno.test("input defaults and validation", () => {
  const i = parseInput({ lat: 26.85, lng: 80.95, kw: 3 });
  assertEquals(i.tilt, 27);
  assertEquals(i.azimuth, 180);
  assertEquals(parseInput({ lat: "26.8", lng: "80.9" }).kw, 1);
  assertThrows(() => parseInput({ lat: 100, lng: 80 }));
  assertThrows(() => parseInput({ lat: 26, lng: 200 }));
  assertThrows(() => parseInput({ lat: 26, lng: 80, kw: 0 }));
  assertThrows(() => parseInput({ lat: 26, lng: 80, tilt: 95 }));
  assertThrows(() => parseInput({ lat: 26, lng: 80, azimuth: 360 }));
});
