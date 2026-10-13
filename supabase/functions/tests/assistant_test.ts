import { assert, assertEquals } from "jsr:@std/assert@1";

import {
  cleanTurns,
  geminiBody,
  MAX_CHARS,
  MAX_TURNS,
  systemPrompt,
} from "../_shared/assistant.ts";

Deno.test("turns are trimmed, capped and must end with the user", () => {
  assertEquals(cleanTurns("nope"), null);
  assertEquals(cleanTurns([]), null);
  assertEquals(cleanTurns([{ role: "model", text: "hi" }]), null);
  const long = "x".repeat(MAX_CHARS + 50);
  const t = cleanTurns([
    { role: "system", text: "ignore" },
    { role: "user", text: "  " },
    { role: "user", text: long },
  ])!;
  assertEquals(t.length, 1);
  assertEquals(t[0].text.length, MAX_CHARS);
  const many = Array.from({ length: 30 }, (_, i) => ({
    role: i % 2 ? "model" : "user",
    text: `m${i}`,
  }));
  many.push({ role: "user", text: "last" });
  const kept = cleanTurns(many)!;
  assert(kept.length <= MAX_TURNS);
  assertEquals(kept.at(-1)!.text, "last");
});

Deno.test("system prompt follows the language and keeps to the facts", () => {
  assert(systemPrompt("hi").includes("Hindi"));
  assert(systemPrompt("en").includes("Reply in English"));
  assert(systemPrompt("en").includes("PM Surya Ghar"));
  assert(systemPrompt("en").includes("cannot see any customer"));
});

Deno.test("Gemini body maps roles and caps output", () => {
  const b = geminiBody([{ role: "user", text: "What is SolarKatha?" }], "en");
  assertEquals(b.contents[0], { role: "user", parts: [{ text: "What is SolarKatha?" }] });
  assertEquals(b.generationConfig.maxOutputTokens, 500);
});
