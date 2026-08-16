const MoodEntry = require("../models/MoodEntry");
const JournalEntry = require("../models/JournalEntry");
const Assessment = require("../models/Assessment");

const roundValue = (value) =>
  typeof value === "number" ? Number(value.toFixed(2)) : null;

const buildReport = async (userId, startDate, endDate, periodName) => {
  const dateFilter = {
    userId,
    date: {
      $gte: startDate,
      $lt: endDate,
    },
  };

  const [
    moodSummaryResult,
    moodTrend,
    journalSummaryResult,
    assessmentSummary,
  ] = await Promise.all([
    MoodEntry.aggregate([
      { $match: dateFilter },
      {
        $group: {
          _id: null,
          totalCheckIns: { $sum: 1 },
          averageMood: { $avg: "$mood" },
          averageStress: { $avg: "$stress" },
          averageSleep: { $avg: "$sleep" },
        },
      },
    ]),

    MoodEntry.aggregate([
      { $match: dateFilter },
      {
        $group: {
          _id: {
            $dateToString: {
              format: "%Y-%m-%d",
              date: "$date",
            },
          },
          averageMood: { $avg: "$mood" },
          averageStress: { $avg: "$stress" },
          averageSleep: { $avg: "$sleep" },
          checkInCount: { $sum: 1 },
        },
      },
      { $sort: { _id: 1 } },
      {
        $project: {
          _id: 0,
          date: "$_id",
          averageMood: 1,
          averageStress: 1,
          averageSleep: 1,
          checkInCount: 1,
        },
      },
    ]),

    JournalEntry.aggregate([
      { $match: dateFilter },
      {
        $group: {
          _id: null,
          totalEntries: { $sum: 1 },
          positiveEntries: {
            $sum: {
              $cond: [{ $eq: ["$sentiment", "positive"] }, 1, 0],
            },
          },
          neutralEntries: {
            $sum: {
              $cond: [{ $eq: ["$sentiment", "neutral"] }, 1, 0],
            },
          },
          negativeEntries: {
            $sum: {
              $cond: [{ $eq: ["$sentiment", "negative"] }, 1, 0],
            },
          },
        },
      },
    ]),

    Assessment.aggregate([
      { $match: dateFilter },
      { $sort: { date: -1 } },
      {
        $group: {
          _id: "$type",
          totalCompleted: { $sum: 1 },
          averageScore: { $avg: "$score" },
          latestScore: { $first: "$score" },
          latestLevel: { $first: "$result.level" },
          latestDate: { $first: "$date" },
        },
      },
      {
        $project: {
          _id: 0,
          type: "$_id",
          totalCompleted: 1,
          averageScore: 1,
          latestScore: 1,
          latestLevel: 1,
          latestDate: 1,
        },
      },
    ]),
  ]);

  const moodSummary = moodSummaryResult[0] || {
    totalCheckIns: 0,
    averageMood: null,
    averageStress: null,
    averageSleep: null,
  };

  const journalSummary = journalSummaryResult[0] || {
    totalEntries: 0,
    positiveEntries: 0,
    neutralEntries: 0,
    negativeEntries: 0,
  };

  return {
    period: {
      name: periodName,
      startDate,
      endDate,
    },
    mood: {
      totalCheckIns: moodSummary.totalCheckIns,
      averageMood: roundValue(moodSummary.averageMood),
      averageStress: roundValue(moodSummary.averageStress),
      averageSleep: roundValue(moodSummary.averageSleep),
      trend: moodTrend.map((item) => ({
        ...item,
        averageMood: roundValue(item.averageMood),
        averageStress: roundValue(item.averageStress),
        averageSleep: roundValue(item.averageSleep),
      })),
    },
    journal: journalSummary,
    assessments: assessmentSummary.map((item) => ({
      ...item,
      averageScore: roundValue(item.averageScore),
    })),
    disclaimer:
      "These are wellness trends and screening summaries, not medical diagnoses.",
  };
};

const getWeeklyReport = async (req, res) => {
  try {
    const endDate = new Date();
    const startDate = new Date();

    startDate.setDate(startDate.getDate() - 6);
    startDate.setHours(0, 0, 0, 0);

    const report = await buildReport(
      req.firebaseUser.uid,
      startDate,
      endDate,
      "weekly"
    );

    return res.status(200).json({
      success: true,
      report,
    });
  } catch (error) {
    console.error("Get weekly report failed:", error.message);

    return res.status(500).json({
      success: false,
      message: "Could not generate weekly report.",
    });
  }
};

const getMonthlyReport = async (req, res) => {
  try {
    const endDate = new Date();
    const startDate = new Date(
      endDate.getFullYear(),
      endDate.getMonth(),
      1
    );

    const report = await buildReport(
      req.firebaseUser.uid,
      startDate,
      endDate,
      "monthly"
    );

    return res.status(200).json({
      success: true,
      report,
    });
  } catch (error) {
    console.error("Get monthly report failed:", error.message);

    return res.status(500).json({
      success: false,
      message: "Could not generate monthly report.",
    });
  }
};

module.exports = {
  getWeeklyReport,
  getMonthlyReport,
};