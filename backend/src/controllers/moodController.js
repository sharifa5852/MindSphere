const mongoose = require("mongoose");
const MoodEntry = require("../models/MoodEntry");
const {
  analyzeMoodCheckIn,
  generateInsightForDetectedEmotion,
} = require("../services/geminiService");
const { detectEmotions } = require("../services/emotionService");

const isNumberInRange = (value, min, max) =>
  typeof value === "number" && value >= min && value <= max;

const roundToTwo = (value) =>
  Number((typeof value === "number" ? value : 0).toFixed(2));

const capitalize = (text) =>
  typeof text === "string" && text.length
    ? text.charAt(0).toUpperCase() + text.slice(1)
    : text;

const FALLBACK_ANALYSIS = {
  emotion: "Nervousness",
  confidence: 0.84,
  otherEmotions: [
    { label: "Fear", score: 0.09 },
    { label: "Sadness", score: 0.04 },
    { label: "Neutral", score: 0.03 },
  ],
  insight:
    "Your answers suggest language associated with nervousness. This is a general reflection, not a diagnosis.",
};

const createMoodEntry = async (req, res) => {
  try {
    const { mood, stress, energy, sleep, socialConnection, note, date } = req.body;

    if (!isNumberInRange(mood, 1, 5)) {
      return res.status(400).json({ success: false, message: "Mood must be a number between 1 and 5." });
    }
    if (!isNumberInRange(stress, 1, 5)) {
      return res.status(400).json({ success: false, message: "Stress must be a number between 1 and 5." });
    }
    if (!isNumberInRange(energy, 0, 100)) {
      return res.status(400).json({ success: false, message: "Energy must be a number between 0 and 100." });
    }
    if (typeof sleep !== "number" || sleep < 0 || sleep > 24) {
      return res.status(400).json({ success: false, message: "Sleep must be a number between 0 and 24." });
    }
    if (!isNumberInRange(socialConnection, 1, 4)) {
      return res.status(400).json({ success: false, message: "Social connection must be a number between 1 and 4." });
    }
    if (note !== undefined && typeof note !== "string") {
      return res.status(400).json({ success: false, message: "Note must be text." });
    }
    if (date !== undefined && Number.isNaN(new Date(date).getTime())) {
      return res.status(400).json({ success: false, message: "Date is invalid." });
    }

    const moodEntry = await MoodEntry.create({
      userId: req.firebaseUser.uid,
      mood,
      stress,
      energy,
      sleep,
      socialConnection,
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
    return res.status(500).json({ success: false, message: "Could not save mood check-in." });
  }
};

const analyzeMoodEntry = async (req, res) => {
  try {
    const { id } = req.params;
    const requestedMode = req.body?.mode === "trained_model" ? "trained_model" : "gemini";

    if (!mongoose.isValidObjectId(id)) {
      return res.status(400).json({ success: false, message: "Invalid mood entry ID." });
    }

    const moodEntry = await MoodEntry.findOne({ _id: id, userId: req.firebaseUser.uid });
    if (!moodEntry) {
      return res.status(404).json({ success: false, message: "Mood entry not found." });
    }

    const moodData = {
      mood: moodEntry.mood,
      stress: moodEntry.stress,
      energy: moodEntry.energy,
      sleep: moodEntry.sleep,
      socialConnection: moodEntry.socialConnection,
      note: moodEntry.note,
    };

    let analysis = null;
    let usedFallback = false;
    let actualMode = requestedMode;

    // --- Trained model path (RoBERTa detects emotion, Gemini writes insight) ---
    if (requestedMode === "trained_model" && moodData.note && moodData.note.trim()) {
      try {
        const detected = await detectEmotions(moodData.note);
        if (!detected.length) {
          throw new Error("No emotions detected above threshold.");
        }
        const sorted = [...detected].sort((a, b) => b.score - a.score);
        const top = sorted[0];
        const others = sorted.slice(1, 4);

        let insight;
        try {
          insight = await generateInsightForDetectedEmotion(moodData, top.label);
        } catch (insightError) {
          console.error("Gemini insight generation failed:", insightError.message);
          insight = `Your reflection suggests a sense of ${top.label.toLowerCase()}. Be gentle with yourself today.`;
        }

        analysis = {
          emotion: capitalize(top.label),
          confidence: top.score,
          otherEmotions: others.map((item) => ({
            label: capitalize(item.label),
            score: item.score,
          })),
          insight,
        };
      } catch (modelError) {
        console.error("Trained model analysis failed, falling back to Gemini:", modelError.message);
        actualMode = "gemini";
      }
    } else if (requestedMode === "trained_model") {
      // No reflection text was written — the trained model needs text to analyze.
      actualMode = "gemini";
    }

    // --- Gemini-only path (also the fallback if trained_model above failed) ---
    if (!analysis) {
      try {
        analysis = await analyzeMoodCheckIn(moodData);
        actualMode = "gemini";
      } catch (aiError) {
        console.error("Gemini mood analysis failed, using fallback:", aiError.message);
        analysis = FALLBACK_ANALYSIS;
        usedFallback = true;
        actualMode = "fallback";
      }
    }

    moodEntry.emotion = analysis.emotion;
    moodEntry.emotionConfidence = analysis.confidence;
    moodEntry.otherEmotions = analysis.otherEmotions;
    moodEntry.insight = analysis.insight;
    moodEntry.analysisMode = actualMode;
    await moodEntry.save();

    return res.status(200).json({
      success: true,
      usedFallback,
      mode: actualMode,
      analysis,
    });
  } catch (error) {
    console.error("Analyze mood entry failed:", error.message);
    return res.status(500).json({ success: false, message: "Could not analyze mood check-in." });
  }
};

const getMoodEntries = async (req, res) => {
  try {
    const moodEntries = await MoodEntry.find({ userId: req.firebaseUser.uid }).sort({ date: -1 });
    return res.status(200).json({ success: true, count: moodEntries.length, moodEntries });
  } catch (error) {
    console.error("Get mood entries failed:", error.message);
    return res.status(500).json({ success: false, message: "Could not retrieve mood check-ins." });
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
      { $match: { userId: req.firebaseUser.uid, date: { $gte: startOfWeek } } },
      {
        $group: {
          _id: null,
          averageMood: { $avg: "$mood" },
          averageStress: { $avg: "$stress" },
          averageEnergy: { $avg: "$energy" },
          averageSleep: { $avg: "$sleep" },
          averageSocialConnection: { $avg: "$socialConnection" },
          totalCheckIns: { $sum: 1 },
        },
      },
    ]);

    const averages = summary[0] || {
      averageMood: 0,
      averageStress: 0,
      averageEnergy: 0,
      averageSleep: 0,
      averageSocialConnection: 0,
      totalCheckIns: 0,
    };

    return res.status(200).json({
      success: true,
      period: { startDate: startOfWeek, endDate: new Date() },
      summary: {
        totalCheckIns: averages.totalCheckIns,
        averageMood: roundToTwo(averages.averageMood),
        averageStress: roundToTwo(averages.averageStress),
        averageEnergy: roundToTwo(averages.averageEnergy),
        averageSleep: roundToTwo(averages.averageSleep),
        averageSocialConnection: roundToTwo(averages.averageSocialConnection),
      },
      entries: weeklyEntries,
    });
  } catch (error) {
    console.error("Get weekly mood summary failed:", error.message);
    return res.status(500).json({ success: false, message: "Could not retrieve weekly mood summary." });
  }
};

module.exports = {
  createMoodEntry,
  getMoodEntries,
  getWeeklyMoodSummary,
  analyzeMoodEntry,
};