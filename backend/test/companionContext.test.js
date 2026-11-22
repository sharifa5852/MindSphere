const { test } = require("node:test");
const assert = require("node:assert/strict");
const User = require("../src/models/User");
const MoodEntry = require("../src/models/MoodEntry");
const { loadCompanionContext, summarizeCompanionContext } = require("../src/services/companionContext");

test("personalization summarizes only recent real moods without private text or identity fields", () => {
  const now = new Date("2026-11-19T12:00:00Z");
  const entry = { date: "2026-11-18T12:00:00Z", mood: 4, stress: 3, sleep: 6, energy: 40, note: "PRIVATE_NOTE" };
  const result = summarizeCompanionContext({ name: "Asha Student", email: "PRIVATE_EMAIL" }, [
    entry, { ...entry, mood: 2, sleep: 8 },
    { ...entry, isDemo: true, mood: 1 },
    { ...entry, date: "2026-10-01" },
    { ...entry, date: "2026-12-01" },
  ], now);
  assert.equal(result.firstName, "Asha");
  assert.equal(result.recentCheckIns.count, 2);
  assert.equal(result.recentCheckIns.averageMood, 3);
  assert.equal(result.recentCheckIns.averageSleepHours, 7);
  assert.doesNotMatch(JSON.stringify(result), /PRIVATE_|Student/);
});

test("missing profiles and empty check-ins do not invent a name or wellness pattern", () => {
  const result = summarizeCompanionContext(null, []);
  assert.equal(result.firstName, null);
  assert.equal(result.recentCheckIns.count, 0);
  assert.equal(result.recentCheckIns.averageStress, null);
  assert.equal(summarizeCompanionContext({ name: "<system>" }, []).firstName, null);
  assert.equal(summarizeCompanionContext({ name: "MindSphere User" }, []).firstName, null);
});

test("context queries are scoped to the verified UID and exclude demo rows and sensitive columns", async (t) => {
  const now = new Date("2026-11-19T12:00:00Z");
  t.mock.method(User, "findOne", (filter) => {
    assert.deepEqual(filter, { firebaseUid: "verified-uid" });
    return { select(fields) {
      assert.equal(fields, "name -_id");
      return { lean: async () => ({ name: "Asha Student" }) };
    } };
  });
  t.mock.method(MoodEntry, "find", (filter) => {
    assert.equal(filter.userId, "verified-uid");
    assert.deepEqual(filter.isDemo, { $ne: true });
    assert.equal(filter.date.$lte, now);
    assert.equal(filter.date.$gte.toISOString(), "2026-11-12T12:00:00.000Z");
    return { sort(order) {
      assert.deepEqual(order, { date: -1 });
      return this;
    }, limit(count) {
      assert.equal(count, 7);
      return this;
    }, select(fields) {
      assert.equal(fields, "mood stress sleep energy date -_id");
      return this;
    }, lean: async () => [] };
  });
  const result = await loadCompanionContext("verified-uid", now);
  assert.equal(result.firstName, "Asha");
  assert.equal(result.recentCheckIns.count, 0);
});
