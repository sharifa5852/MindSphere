const mongoose = require("mongoose");

const journalEntrySchema = new mongoose.Schema(
  {
    userId: {
      type: String,
      required: true,
      index: true,
    },
    text: {
      type: String,
      required: true,
      trim: true,
      minlength: 1,
      maxlength: 5000,
    },
    sentiment: {
      type: String,
      enum: ["positive", "neutral", "negative"],
      default: null,
    },
    emotion: {
      type: String,
      default: null,
      trim: true,
    },
    summary: {
      type: String,
      default: null,
      trim: true,
      maxlength: 1000,
    },
    date: {
      type: Date,
      default: Date.now,
    },
  },
  {
    timestamps: true,
  }
);

module.exports = mongoose.model("JournalEntry", journalEntrySchema);