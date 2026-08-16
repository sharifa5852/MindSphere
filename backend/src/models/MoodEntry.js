const mongoose = require("mongoose");

const moodEntrySchema = new mongoose.Schema(
  {
    userId: {
      type: String,
      required: true,
    },
    mood: {
      type: Number,
      required: true,
      min: 1,
      max: 5,
    },
    stress: {
      type: Number,
      min: 1,
      max: 5,
    },
    sleep: {
      type: Number,
      min: 0,
      max: 24,
    },
    note: {
      type: String,
      maxlength: 500,
    },
    date: {
      type: Date,
      default: Date.now,
    },
  },
  { timestamps: true }
);

module.exports = mongoose.model("MoodEntry", moodEntrySchema);