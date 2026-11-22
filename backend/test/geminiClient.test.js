const { test } = require("node:test");
const assert = require("node:assert/strict");
const { createContentGenerator } = require("../src/services/geminiClient");

function stubGenerator(responses) {
  const calls = [];
  const generate = createContentGenerator({
    getClient: async () => ({ models: { generateContent: async (request) => {
      calls.push(request);
      const response = responses.shift();
      if (response instanceof Error) throw response;
      return response;
    } } }),
    wait: async () => {},
  });
  return { generate, calls };
}

const providerError = (status) => Object.assign(new Error("Provider request failed"), { status });

test("busy primary retries once, then fallback preserves the prompt and safety settings", async () => {
  const { generate, calls } = stubGenerator([providerError(503), providerError(503), { text: "Take a short break." }]);
  const contents = [{ role: "user", parts: [{ text: "I feel stressed." }] }];
  const safetySettings = [{ category: "HARM_CATEGORY_DANGEROUS_CONTENT", threshold: "BLOCK_MEDIUM_AND_ABOVE" }];
  const response = await generate({ contents, config: { systemInstruction: "Be supportive.", safetySettings } });
  assert.equal(response.text, "Take a short break.");
  assert.equal(calls.length, 3);
  assert.equal(calls[0].model, calls[1].model);
  assert.notEqual(calls[1].model, calls[2].model);
  assert.equal(calls[2].contents, contents);
  assert.equal(calls[2].config.safetySettings, safetySettings);
  assert.equal(calls[2].config.systemInstruction, "Be supportive.");
  assert.equal(calls[2].config.thinkingConfig.thinkingLevel, "MINIMAL");
  assert.ok(calls[2].config.abortSignal instanceof AbortSignal);
});

test("retired primary switches to fallback without retrying the missing model", async () => {
  const { generate, calls } = stubGenerator([providerError(404), { text: "Ready." }]);
  assert.equal((await generate({ contents: "Hello" })).text, "Ready.");
  assert.equal(calls.length, 2);
});

test("invalid credentials do not trigger repeated requests or a fallback", async () => {
  const error = providerError(403);
  const { generate, calls } = stubGenerator([error]);
  await assert.rejects(generate({ contents: "Hello" }), (actual) => actual === error);
  assert.equal(calls.length, 1);
});

test("network timeouts retry even when DOMException supplies a non-HTTP error code", async () => {
  const { generate, calls } = stubGenerator([new DOMException("Request timed out", "TimeoutError"), { text: "Ready." }]);
  assert.equal((await generate({ contents: "Hello" })).text, "Ready.");
  assert.equal(calls.length, 2);
});

test("unavailable models produce a bounded, readable 503 without exposing provider details", async () => {
  const { generate, calls } = stubGenerator([providerError(503), providerError(503), providerError(429)]);
  await assert.rejects(generate({ contents: "Hello" }), (error) => {
    assert.equal(error.statusCode, 503);
    assert.match(error.message, /temporarily busy/);
    return true;
  });
  assert.equal(calls.length, 3);
});
