const User = require("../models/User");
const MoodEntry = require("../models/MoodEntry");

// Send only a first name and recent numeric check-ins, never private journal text.
function summarizeCompanionContext(profile, entries, now = new Date()) {
  const candidate = profile?.name?.trim().split(/\s+/)[0] || "";
  const firstName = /^[\p{L}\p{M}.'-]{1,40}$/u.test(candidate) &&
    candidate !== "MindSphere" ? candidate : null;
  const start = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
  const recent = entries.filter((entry) => !entry.isDemo &&
    new Date(entry.date) >= start && new Date(entry.date) <= now);
  const average = (field) => {
    const values = recent.map((entry) => entry[field]).filter(Number.isFinite);
    return values.length
      ? Math.round(values.reduce((sum, value) => sum + value, 0) / values.length * 10) / 10
      : null;
  };

  return {
    firstName,
    recentCheckIns: {
      period: "past 7 days",
      count: recent.length,
      averageMood: average("mood"),
      averageStress: average("stress"),
      averageSleepHours: average("sleep"),
      averageEnergy: average("energy"),
    },
  };
}

async function loadCompanionContext(userId, now = new Date()) {
  const start = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
  const [profile, entries] = await Promise.all([
    User.findOne({ firebaseUid: userId }).select("name -_id").lean(),
    MoodEntry.find({
      userId,
      isDemo: { $ne: true },
      date: { $gte: start, $lte: now },
    }).sort({ date: -1 }).limit(7).select("mood stress sleep energy date -_id").lean(),
  ]);
  return summarizeCompanionContext(profile, entries, now);
}

module.exports = { loadCompanionContext, summarizeCompanionContext };
