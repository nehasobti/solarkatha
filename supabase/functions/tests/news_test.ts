import { assertEquals } from "jsr:@std/assert@1";

import { isRelevant, parseRss, pickLatest, titleKey } from "../_shared/news.ts";

const rss = `<?xml version="1.0"?><rss><channel>
<item><title>PM Surya Ghar crosses 20 lakh homes - The Hindu</title>
<link>https://news.google.com/rss/articles/abc</link>
<pubDate>Mon, 12 Oct 2026 08:00:00 GMT</pubDate>
<source url="https://www.thehindu.com">The Hindu</source></item>
<item><title><![CDATA[Rooftop solar &amp; subsidy: what changes - Mint]]></title>
<link>https://news.google.com/rss/articles/def</link>
<pubDate>Sun, 11 Oct 2026 08:00:00 GMT</pubDate>
<source url="https://www.livemint.com">Mint</source></item>
<item><title>bad</title><link>javascript:alert(1)</link></item>
</channel></rss>`;

Deno.test("RSS items keep title (without source suffix), source, date, link", () => {
  const items = parseRss(rss, "en");
  assertEquals(items.length, 2);
  assertEquals(items[0].title, "PM Surya Ghar crosses 20 lakh homes");
  assertEquals(items[0].source, "The Hindu");
  assertEquals(items[0].published_at, "2026-10-12T08:00:00.000Z");
  assertEquals(items[1].title, "Rooftop solar & subsidy: what changes");
});

Deno.test("latest first, one per story", () => {
  const items = parseRss(rss, "en");
  const dup = {
    ...items[1],
    url: "https://news.google.com/rss/articles/zzz",
    published_at: "2026-10-12T09:00:00.000Z",
    title: "Rooftop solar & subsidy: what changes!",
  };
  const picked = pickLatest([...items, dup]);
  assertEquals(picked.length, 2);
  assertEquals(picked[0].url, "https://news.google.com/rss/articles/zzz");
  assertEquals(titleKey("Hello, World!"), "hello world");
});

Deno.test("only Indian solar stories", () => {
  assertEquals(
    isRelevant("India May Mandate Local Inverters For Rooftop PV", "en"),
    true,
  );
  assertEquals(isRelevant("French Solar Tender Prices Drop 24%", "en"), false);
  assertEquals(isRelevant("Austria Solar Subsidy Call", "en"), false);
  assertEquals(isRelevant("Stock market update", "en"), false);
  assertEquals(isRelevant("सूर्य घर योजना में नया बदलाव", "hi"), true);
});
