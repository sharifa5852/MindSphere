const { test } = require("node:test");
const assert = require("node:assert/strict");
const ChatHistory = require("../src/models/ChatHistory");
const companionService = require("../src/services/companionService");
const companionContext = require("../src/services/companionContext");
const { chatWithAi } = require("../src/controllers/aiController");

function responseRecorder() {
  return { statusCode: 200, body: null,
    status(code) { this.statusCode = code; return this; },
    json(body) { this.body = body; return this; },
  };
}

test("chat uses verified ownership, relevant history, and the server-generated context", async (t) => {
  const context = { firstName: "Asha", recentCheckIns: { count: 0 } };
  const history = [{ message: "I am stressed", response: "Try grounding", responseType: "wellbeing" }];
  t.mock.method(ChatHistory, "find", (filter) => {
    assert.equal(filter.userId, "verified-uid");
    assert.equal(filter.responseType.$in.includes("off_topic"), false);
    assert.equal(filter.responseType.$in.includes("fallback"), false);
    assert.ok(filter.timestamp.$gte instanceof Date);
    return { sort() { return this; }, limit() { return this; }, select() { return this; }, lean: async () => history };
  });
  t.mock.method(companionContext, "loadCompanionContext", async (uid) => {
    assert.equal(uid, "verified-uid");
    return context;
  });
  t.mock.method(companionService, "generateCompanionReply", async (message, actualHistory, actualContext) => {
    assert.equal(message, "Help me relax");
    assert.deepEqual(actualHistory, history);
    assert.equal(actualContext, context);
    return { response: "Try a grounding exercise.", responseType: "wellbeing", isSafetyResponse: false };
  });
  t.mock.method(ChatHistory, "create", async (record) => {
    assert.equal(record.userId, "verified-uid");
    assert.equal(record.responseType, "wellbeing");
    return { _id: "chat-id" };
  });
  const res = responseRecorder();
  await chatWithAi({ firebaseUser: { uid: "verified-uid" }, body: {
    message: " Help me relax ", userId: "attacker-uid", wellnessContext: { firstName: "Injected" },
  } }, res);
  assert.equal(res.statusCode, 200);
  assert.equal(res.body.responseType, "wellbeing");
  assert.equal(res.body.chatId, "chat-id");
});

test("crisis response does not depend on history, personalization, or Gemini availability", async (t) => {
  const unexpected = async () => { throw new Error("Should not be called"); };
  t.mock.method(ChatHistory, "find", unexpected);
  t.mock.method(companionContext, "loadCompanionContext", unexpected);
  t.mock.method(companionService, "generateCompanionReply", unexpected);
  t.mock.method(ChatHistory, "create", async (record) => {
    assert.equal(record.responseType, "crisis");
    assert.equal(record.isSafetyResponse, true);
    return { _id: "crisis-id" };
  });
  const res = responseRecorder();
  await chatWithAi({ firebaseUser: { uid: "verified-uid" }, body: { message: "I want to die. Also write some code." } }, res);
  assert.equal(res.statusCode, 200);
  assert.equal(res.body.isSafetyResponse, true);
  assert.match(res.body.response, /immediate support/);
});

test("invalid messages are rejected before accessing user data or Gemini", async (t) => {
  t.mock.method(ChatHistory, "find", async () => { throw new Error("Should not be called"); });
  for (const message of [null, " ", 123, "x".repeat(2001)]) {
    const res = responseRecorder();
    await chatWithAi({ firebaseUser: { uid: "verified-uid" }, body: { message } }, res);
    assert.equal(res.statusCode, 400);
  }
});
