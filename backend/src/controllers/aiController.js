const mongoose = require("mongoose");

const ChatHistory = require("../models/ChatHistory");
const JournalEntry = require("../models/JournalEntry");
const MoodEntry = require("../models/MoodEntry");
const Assessment = require("../models/Assessment");

const {
  generateWellnessResponse,
  analyzeJournalEntry,
  generateWeeklyInsight,
} = require("../services/geminiService");

const {
  hasCrisisLanguage,
  getCrisisResponse,
  detectEmotion,
} = require("../utils/aiSafety");

const chatWithAi = async (req, res) => {
  try {
    const { message } = req.body;

    if (typeof message !== "string" || !message.trim()) {
      return res.status(400).json({
        success: false,
        message: "Message is required.",
      });
    }

    if (message.trim().length > 2000) {
      return res.status(400).json({
        success: false,
        message: "Message cannot exceed 2000 characters.",
      });
    }

    const userMessage = message.trim();
    const detectedEmotion = detectEmotion(userMessage);
    const isSafetyResponse = hasCrisisLanguage(userMessage);

    let aiResponse;

    if (isSafetyResponse) {
      aiResponse = getCrisisResponse();
    } else {
      const recentHistory = await ChatHistory.find({
        userId: req.firebaseUser.uid,
      })
        .sort({ timestamp: -1 })
        .limit(6)
        .select("message response -_id")
        .lean();

      aiResponse = await generateWellnessResponse(
        userMessage,
        recentHistory.reverse()
      );
    }

    const chatHistory = await ChatHistory.create({
      userId: req.firebaseUser.uid,
      message: userMessage,
      response: aiResponse,
      detectedEmotion,
      isSafetyResponse,
    });

    return res.status(200).json({
      success: true,
      response: aiResponse,
      detectedEmotion,
      isSafetyResponse,
      chatId: chatHistory._id,
    });
  } catch (error) {
    console.error("AI chat failed:", error.message);

    return res.status(500).json({
      success: false,
      message: "Could not generate an AI response right now.",
    });
  }
};

const analyzeJournal = async (req, res) => {
  try {
    const { journalId } = req.body;

    if (!mongoose.isValidObjectId(journalId)) {
      return res.status(400).json({
        success: false,
        message: "A valid journalId is required.",
      });
    }

    const journalEntry = await JournalEntry.findOne({
      _id: journalId,
      userId: req.firebaseUser.uid,
    });

    if (!journalEntry) {
      return res.status(404).json({
        success: false,
        message: "Journal entry not found.",
      });
    }

    let analysis;

    if (hasCrisisLanguage(journalEntry.text)) {
      analysis = {
        sentiment: "negative",
        emotion: "distress",
        summary: "This entry may describe a difficult or urgent experience.",
        reflection: getCrisisResponse(),
        needsSupportPrompt: true,
      };
    } else {
      analysis = await analyzeJournalEntry(journalEntry.text);
    }

    journalEntry.sentiment = analysis.sentiment;
    journalEntry.emotion = analysis.emotion;
    journalEntry.summary = analysis.summary;
    await journalEntry.save();

    return res.status(200).json({
      success: true,
      analysis: {
        sentiment: analysis.sentiment,
        emotion: analysis.emotion,
        summary: analysis.summary,
        reflection: analysis.reflection,
        needsSupportPrompt: analysis.needsSupportPrompt,
      },
      disclaimer:
        "This reflection is for general wellness awareness and is not a diagnosis.",
    });
  } catch (error) {
    console.error("Journal analysis failed:", error.message);

    return res.status(500).json({
      success: false,
      message: "Could not analyze the journal entry right now.",
    });
  }
};

const getWeeklyInsight = async (req, res) => {
  try {
    const endDate = new Date();
    const startDate = new Date();

    startDate.setDate(startDate.getDate() - 6);
    startDate.setHours(0, 0, 0, 0);

    const dateFilter = {
      userId: req.firebaseUser.uid,
      date: { $gte: startDate, $lt: endDate },
    };

    const [moodSummaryResult, journalCount, assessmentSummary] =
      await Promise.all([
        MoodEntry.aggregate([
          { $match: dateFilter },
          {
            $group: {
              _id: null,
              checkInCount: { $sum: 1 },
              averageMood: { $avg: "$mood" },
              averageStress: { $avg: "$stress" },
              averageSleep: { $avg: "$sleep" },
            },
          },
        ]),
        JournalEntry.countDocuments(dateFilter),
        Assessment.aggregate([
          { $match: dateFilter },
          {
            $group: {
              _id: "$type",
              totalCompleted: { $sum: 1 },
              latestScore: { $last: "$score" },
              latestLevel: { $last: "$result.level" },
            },
          },
        ]),
      ]);

    const moodSummary = moodSummaryResult[0] || {
      checkInCount: 0,
      averageMood: null,
      averageStress: null,
      averageSleep: null,
    };

    const wellnessData = {
      period: "Last 7 days",
      moodCheckIns: moodSummary.checkInCount,
      averageMood: moodSummary.averageMood,
      averageStress: moodSummary.averageStress,
      averageSleep: moodSummary.averageSleep,
      journalEntries: journalCount,
      assessments: assessmentSummary,
    };

    const insight = await generateWeeklyInsight(wellnessData);

    return res.status(200).json({
      success: true,
      insight,
      dataUsed: wellnessData,
      disclaimer:
        "This is a general wellness reflection, not medical advice or a diagnosis.",
    });
  } catch (error) {
    console.error("Weekly AI insight failed:", error.message);

    return res.status(500).json({
      success: false,
      message: "Could not generate weekly insight right now.",
    });
  }
};

module.exports = {
  chatWithAi,
  analyzeJournal,
  getWeeklyInsight,
};