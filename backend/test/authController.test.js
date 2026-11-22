const { test } = require("node:test");
const assert = require("node:assert/strict");
const User = require("../src/models/User");
const { syncUser } = require("../src/controllers/authController");

function responseRecorder() {
  return { statusCode: 200, body: null,
    status(code) { this.statusCode = code; return this; },
    json(body) { this.body = body; return this; },
  };
}

const identity = { uid: "test-firebase-uid", email: "student@example.test" };

test("profile creation uses an atomic upsert bound to the verified identity", async (t) => {
  const user = { _id: "profile-id", firebaseUid: identity.uid, email: identity.email, name: "Demo Student" };
  t.mock.method(User, "findOneAndUpdate", async (filter, update, options) => {
    assert.deepEqual(filter, { firebaseUid: identity.uid });
    assert.equal(update.$set.name, "Demo Student");
    assert.equal(update.$set.email, identity.email);
    assert.equal(options.upsert, true);
    assert.equal(options.runValidators, true);
    return { value: user, lastErrorObject: { updatedExisting: false } };
  });
  const res = responseRecorder();
  await syncUser({ firebaseUser: identity, body: { name: " Demo Student ", userId: "untrusted-id" } }, res);
  assert.equal(res.statusCode, 201);
  assert.equal(res.body.user.firebaseUid, identity.uid);
});

test("restoring a session without a display name preserves the existing profile name", async (t) => {
  t.mock.method(User, "findOneAndUpdate", async (_filter, update) => {
    assert.equal(Object.hasOwn(update.$set, "name"), false);
    assert.equal(update.$setOnInsert.name, "MindSphere User");
    return { value: { name: "Existing Name", firebaseUid: identity.uid }, lastErrorObject: { updatedExisting: true } };
  });
  const res = responseRecorder();
  await syncUser({ firebaseUser: identity, body: {} }, res);
  assert.equal(res.statusCode, 200);
  assert.equal(res.body.user.name, "Existing Name");
});

test("invalid profile names are rejected before writing to MongoDB", async (t) => {
  const write = t.mock.method(User, "findOneAndUpdate", async () => { throw new Error("Unexpected database write"); });
  const res = responseRecorder();
  await syncUser({ firebaseUser: identity, body: { name: 123 } }, res);
  assert.equal(res.statusCode, 400);
  assert.equal(write.mock.calls.length, 0);
});

test("incomplete Firebase identity cannot create a profile", async (t) => {
  const write = t.mock.method(User, "findOneAndUpdate", async () => { throw new Error("Unexpected database write"); });
  const res = responseRecorder();
  await syncUser({ firebaseUser: { uid: identity.uid }, body: {} }, res);
  assert.equal(res.statusCode, 400);
  assert.equal(write.mock.calls.length, 0);
});
