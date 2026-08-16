const MoodEntry = require("../models/MoodEntry");

const isNumberInRange = (value, min, max) =>
  typeof value === "number" && value >= min && value <= max;

const createMoodEntry = async (req, res) => {
  try {
    const { mood, stress, sleep, note, date } = req.body;

    if (!isNumberInRange(mood, 1, 5)) {
      return res.status(400).json({
        success: false,
        message: "Mood must be a number between 1 and 5.",
      });
    }

    if (stress !== undefined && !isNumberInRange(stress, 1, 5)) {
      return res.status(400).json({
        success: false,
        message: "Stress must be a number between 1 and 5.",
      });
    }

   if (sleep !== undefined && (typeof sleep !== "number" || sleep < 0 || sleep > 24)) {
  return res.status(400).json({
    success: false,
    message: "Sleep must be a number between 0 and 24.",
  });
}

    if (note !== undefined && typeof note !== "string") {
      return res.status(400).json({
        success: false,
        message: "Note must be text.",
      });
    }

    if (date !== undefined && Number.isNaN(new Date(date).getTime())) {
      return res.status(400).json({
        success: false,
        message: "Date is invalid.",
      });
    }

    const moodEntry = await MoodEntry.create({
      userId: req.firebaseUser.uid,
      mood,
      stress,
      sleep,
      note: note?.trim(),
      date: date ? new Date(date) : new Date(),
    });

    return res.status(201).json({
      success: true,
      message: "Mood check-in saved successfully.",
      moodEntry,
    });
  } catch (error) {
    console.error("Create mood entry failed:", error.message);

    return res.status(500).json({
      success: false,
      message: "Could not save mood check-in.",
    });
  }
};

const getMoodEntries = async (req, res) => {
  try {
    const moodEntries = await MoodEntry.find({
      userId: req.firebaseUser.uid,
    }).sort({ date: -1 });

    return res.status(200).json({
      success: true,
      count: moodEntries.length,
      moodEntries,
    });
  } catch (error) {
    console.error("Get mood entries failed:", error.message);

    return res.status(500).json({
      success: false,
      message: "Could not retrieve mood check-ins.",
    });
  }
};

const getWeeklyMoodSummary = async (req, res) => {
  try {
    const startOfWeek = new Date();
    startOfWeek.setHours(0, 0, 0, 0);
    startOfWeek.setDate(startOfWeek.getDate() - 6);

    const weeklyEntries = await MoodEntry.find({
      userId: req.firebaseUser.uid,
      date: { $gte: startOfWeek },
    }).sort({ date: 1 });

    const summary = await MoodEntry.aggregate([
      {
        $match: {
          userId: req.firebaseUser.uid,
          date: { $gte: startOfWeek },
        },
      },
      {
        $group: {
          _id: null,
          averageMood: { $avg: "$mood" },
          averageStress: { $avg: "$stress" },
          averageSleep: { $avg: "$sleep" },
          totalCheckIns: { $sum: 1 },
        },
      },
    ]);

    const averages = summary[0] || {
      averageMood: 0,
      averageStress: 0,
      averageSleep: 0,
      totalCheckIns: 0,
    };

    return res.status(200).json({
      success: true,
      period: {
        startDate: startOfWeek,
        endDate: new Date(),
      },
      summary: {
        totalCheckIns: averages.totalCheckIns,
        averageMood: Number(averages.averageMood.toFixed(2)),
        averageStress: Number(averages.averageStress.toFixed(2)),
        averageSleep: Number(averages.averageSleep.toFixed(2)),
      },
      entries: weeklyEntries,
    });
  } catch (error) {
    console.error("Get weekly mood summary failed:", error.message);

    return res.status(500).json({
      success: false,
      message: "Could not retrieve weekly mood summary.",
    });
  }
};

module.exports = {
  createMoodEntry,
  getMoodEntries,
  getWeeklyMoodSummary,
};