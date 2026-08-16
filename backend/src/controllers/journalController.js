const mongoose = require("mongoose");
const JournalEntry = require("../models/JournalEntry");

const createJournalEntry = async (req, res) => {
  try {
    const { text, date } = req.body;

    if (typeof text !== "string" || !text.trim()) {
      return res.status(400).json({
        success: false,
        message: "Journal text is required.",
      });
    }

    if (text.trim().length > 5000) {
      return res.status(400).json({
        success: false,
        message: "Journal text cannot be longer than 5000 characters.",
      });
    }

    if (date !== undefined && Number.isNaN(new Date(date).getTime())) {
      return res.status(400).json({
        success: false,
        message: "Date is invalid.",
      });
    }

    const journalEntry = await JournalEntry.create({
      userId: req.firebaseUser.uid,
      text: text.trim(),
      date: date ? new Date(date) : new Date(),
    });

    return res.status(201).json({
      success: true,
      message: "Journal entry saved successfully.",
      journalEntry,
    });
  } catch (error) {
    console.error("Create journal entry failed:", error.message);

    return res.status(500).json({
      success: false,
      message: "Could not save journal entry.",
    });
  }
};

const getJournalEntries = async (req, res) => {
  try {
    const journalEntries = await JournalEntry.find({
      userId: req.firebaseUser.uid,
    })
      .sort({ date: -1 })
      .select("-userId");

    return res.status(200).json({
      success: true,
      count: journalEntries.length,
      journalEntries,
    });
  } catch (error) {
    console.error("Get journal entries failed:", error.message);

    return res.status(500).json({
      success: false,
      message: "Could not retrieve journal entries.",
    });
  }
};

const getJournalEntryById = async (req, res) => {
  try {
    const { id } = req.params;

    if (!mongoose.isValidObjectId(id)) {
      return res.status(400).json({
        success: false,
        message: "Invalid journal entry ID.",
      });
    }

    const journalEntry = await JournalEntry.findOne({
      _id: id,
      userId: req.firebaseUser.uid,
    }).select("-userId");

    if (!journalEntry) {
      return res.status(404).json({
        success: false,
        message: "Journal entry not found.",
      });
    }

    return res.status(200).json({
      success: true,
      journalEntry,
    });
  } catch (error) {
    console.error("Get journal entry failed:", error.message);

    return res.status(500).json({
      success: false,
      message: "Could not retrieve journal entry.",
    });
  }
};

const deleteJournalEntry = async (req, res) => {
  try {
    const { id } = req.params;

    if (!mongoose.isValidObjectId(id)) {
      return res.status(400).json({
        success: false,
        message: "Invalid journal entry ID.",
      });
    }

    const journalEntry = await JournalEntry.findOneAndDelete({
      _id: id,
      userId: req.firebaseUser.uid,
    });

    if (!journalEntry) {
      return res.status(404).json({
        success: false,
        message: "Journal entry not found.",
      });
    }

    return res.status(200).json({
      success: true,
      message: "Journal entry deleted successfully.",
    });
  } catch (error) {
    console.error("Delete journal entry failed:", error.message);

    return res.status(500).json({
      success: false,
      message: "Could not delete journal entry.",
    });
  }
};

module.exports = {
  createJournalEntry,
  getJournalEntries,
  getJournalEntryById,
  deleteJournalEntry,
};