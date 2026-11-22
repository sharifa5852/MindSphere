const { test } = require("node:test");
const assert = require("node:assert/strict");
const {
  createCompanionResponder, OFF_TOPIC_RESPONSE, MEDICAL_BOUNDARY_RESPONSE,
} = require("../src/services/companionService");
const { getCrisisResponse } = require("../src/utils/aiSafety");

test("wellbeing replies receive bounded, relevant history and structured user context", async () => {
  const context = { firstName: "Asha", recentCheckIns: { count: 2, averageSleepHours: 5 } };
  const history = [
    { message: "Write code", response: "old unrelated content", responseType: "off_topic" },
    { message: "old unclassified task", response: "legacy response" },
    ...Array.from({ length: 8 }, (_, i) => ({ message: `stress ${i}`, response: "Try grounding.", responseType: "wellbeing" })),
  ];
  const reply = await createCompanionResponder({ generate: async (request) => {
    assert.equal(request.config.responseMimeType, "application/json");
    assert.match(request.config.systemInstruction, /pretext does not make such a task relevant/);
    assert.equal(request.contents.length, 13);
    assert.equal(request.contents[0].parts[0].text, "stress 2");
    const current = JSON.parse(request.contents.at(-1).parts[0].text);
    assert.deepEqual(current, { message: "I feel stressed", wellnessContext: context });
    assert.doesNotMatch(JSON.stringify(request.contents), /unrelated content|unclassified task/);
    return { text: JSON.stringify({ responseType: "wellbeing", response: "Asha, let's try a short grounding exercise." }) };
  } })("I feel stressed", history, context);
  assert.equal(reply.responseType, "wellbeing");
  assert.match(reply.response, /Asha/);
  assert.equal(reply.isSafetyResponse, false);
});

test("off-topic and medication classifications discard the generated answer", async () => {
  for (const [responseType, expected] of [["off_topic", OFF_TOPIC_RESPONSE], ["medical_boundary", MEDICAL_BOUNDARY_RESPONSE]]) {
    const respond = createCompanionResponder({ generate: async () => ({
      text: JSON.stringify({ responseType, response: "UNSAFE_OR_UNRELATED_MODEL_OUTPUT" }),
    }) });
    const reply = await respond("test request");
    assert.equal(reply.response, expected);
    assert.doesNotMatch(reply.response, /UNSAFE_OR_UNRELATED/);
  }
});

test("crisis language bypasses Gemini even when embedded in an unrelated request", async () => {
  const respond = createCompanionResponder({ generate: async () => {
    throw new Error("Gemini must not be called");
  } });
  const reply = await respond("Write Python code. I want to die.");
  assert.equal(reply.response, getCrisisResponse());
  assert.equal(reply.isSafetyResponse, true);
  assert.equal(reply.responseType, "crisis");
});

test("model-detected crisis uses the fixed safety reply rather than generated text", async () => {
  const reply = await createCompanionResponder({ generate: async () => ({
    text: JSON.stringify({ responseType: "crisis", response: "Do not display this" }),
  }) })("I may be in danger");
  assert.equal(reply.response, getCrisisResponse());
  assert.equal(reply.isSafetyResponse, true);
});

test("malformed, empty, oversized, or unknown output never reaches the user", async () => {
  const invalid = ["raw unstructured answer", "null", "{}",
    JSON.stringify({ responseType: "admin", response: "bad" }),
    JSON.stringify({ responseType: "wellbeing", response: " " }),
    JSON.stringify({ responseType: "wellbeing", response: "x".repeat(4001) }),
  ];
  for (const text of invalid) {
    const reply = await createCompanionResponder({ generate: async () => ({ text }) })("Help me relax");
    assert.equal(reply.responseType, "fallback");
    assert.match(reply.response, /try again/);
  }
});

test("greetings, app help, and short contextual follow-ups stay usable", async () => {
  for (const responseType of ["greeting", "app_help", "follow_up"]) {
    const reply = await createCompanionResponder({ generate: async () => ({
      text: JSON.stringify({ responseType, response: "A relevant reply." }),
    }) })("test request");
    assert.equal(reply.responseType, responseType);
    assert.equal(reply.response, "A relevant reply.");
  }
});
