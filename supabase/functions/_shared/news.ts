// Google News RSS → headline rows for the landing page. Only the title,
// source, date and link are kept (no article text).

export interface NewsItem {
  url: string;
  title: string;
  source: string | null;
  lang: "en" | "hi";
  published_at: string | null;
}

export const FEEDS: { lang: "en" | "hi"; url: string }[] = [
  {
    lang: "en",
    url:
      "https://news.google.com/rss/search?q=%22PM%20Surya%20Ghar%22%20OR%20%22rooftop%20solar%22%20India%20when%3A30d&hl=en-IN&gl=IN&ceid=IN:en",
  },
  {
    lang: "en",
    url:
      "https://news.google.com/rss/search?q=solar%20subsidy%20India%20when%3A30d&hl=en-IN&gl=IN&ceid=IN:en",
  },
  {
    lang: "hi",
    url:
      "https://news.google.com/rss/search?q=%E0%A4%B8%E0%A5%82%E0%A4%B0%E0%A5%8D%E0%A4%AF%20%E0%A4%98%E0%A4%B0%20%E0%A4%AF%E0%A5%8B%E0%A4%9C%E0%A4%A8%E0%A4%BE%20when%3A30d&hl=hi&gl=IN&ceid=IN:hi",
  },
];

const ENTITIES: Record<string, string> = {
  "&amp;": "&",
  "&lt;": "<",
  "&gt;": ">",
  "&quot;": '"',
  "&#39;": "'",
  "&apos;": "'",
};

function decode(s: string): string {
  return s
    .replace(/<!\[CDATA\[([\s\S]*?)\]\]>/g, "$1")
    .replace(/&(amp|lt|gt|quot|apos|#39);/g, (m) => ENTITIES[m] ?? m)
    .replace(/&#(\d+);/g, (_, n) => String.fromCharCode(Number(n)))
    .trim();
}

function tag(block: string, name: string): string | null {
  const m = block.match(
    new RegExp(`<${name}(?:\\s[^>]*)?>([\\s\\S]*?)</${name}>`),
  );
  return m ? decode(m[1]) : null;
}

const FOREIGN =
  /\b(france|french|austria|austrian|germany|german|europe|european|uk|britain|british|us|usa|america|american|australia|australian|china|chinese|japan|pakistan|bangladesh|philippines|vietnam|brazil|canada|italy|spain|africa|nigeria|dubai|uae|saudi)\b/i;

/** Indian solar stories only (Google's search also returns foreign news). */
export function isRelevant(title: string, lang: "en" | "hi"): boolean {
  if (lang === "hi") return /सोलर|सौर|सूर्य/.test(title);
  return /solar|rooftop|surya ghar|net meter/i.test(title) &&
    !FOREIGN.test(title);
}

/** Normalised title for de-duplicating the same story from many outlets. */
export function titleKey(title: string): string {
  return title.toLowerCase().replace(/[^\p{L}\p{N}]+/gu, " ").trim().slice(
    0,
    80,
  );
}

export function parseRss(xml: string, lang: "en" | "hi"): NewsItem[] {
  const items: NewsItem[] = [];
  for (const m of xml.matchAll(/<item>([\s\S]*?)<\/item>/g)) {
    const block = m[1];
    const link = tag(block, "link");
    let title = tag(block, "title");
    if (!link || !title || !/^https:\/\//.test(link)) continue;
    const source = tag(block, "source");
    // Google appends " - Source" to the title.
    if (source && title.endsWith(` - ${source}`)) {
      title = title.slice(0, -(source.length + 3)).trim();
    }
    if (!isRelevant(title, lang)) continue;
    const date = tag(block, "pubDate");
    const t = date ? Date.parse(date) : NaN;
    items.push({
      url: link,
      title: title.slice(0, 300),
      source: source?.slice(0, 100) ?? null,
      lang,
      published_at: Number.isNaN(t) ? null : new Date(t).toISOString(),
    });
  }
  return items;
}

/** Newest first, one per story, at most [max]. */
export function pickLatest(items: NewsItem[], max = 30): NewsItem[] {
  const seen = new Set<string>();
  return [...items]
    .sort((a, b) => (b.published_at ?? "").localeCompare(a.published_at ?? ""))
    .filter((i) => {
      const k = `${i.lang}:${titleKey(i.title)}`;
      if (seen.has(k)) return false;
      seen.add(k);
      return true;
    })
    .slice(0, max);
}
