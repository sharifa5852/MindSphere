// const mongoose = require("mongoose");

// const moodEntrySchema = new mongoose.Schema(
//   {
//     userId: {
//       type: String,
//       required: true,
//     },
//     mood: {
//       type: Number,
//       required: true,
//       min: 1,
//       max: 5,
//     },
//     stress: {
//       type: Number,
//       required: true,
//       min: 1,
//       max: 5,
//     },
//     energy: {
//       type: Number,
//       required: true,
//       min: 0,
//       max: 100,
//     },
//     sleep: {
//       type: Number,
//       required: true,
//       min: 0,
//       max: 24,
//     },
//     socialConnection: {
//       type: Number,
//       required: true,
//       min: 1,
//       max: 4,
//     },
//     note: {
//       type: String,
//       maxlength: 500,
//     },
//     date: {
//       type: Date,
//       default: Date.now,
//     },
//   },
//   { timestamps: true }
// );

// module.exports = mongoose.model("MoodEntry", moodEntrySchema);
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
      required: true,
      min: 1,
      max: 5,
    },
    energy: {
      type: Number,
      required: true,
      min: 0,
      max: 100,
    },
    sleep: {
      type: Number,
      required: true,
      min: 0,
      max: 24,
    },
    socialConnection: {
      type: Number,
      required: true,
      min: 1,
      max: 4,
    },
    note: {
      type: String,
      maxlength: 500,
    },
    date: {
      type: Date,
      default: Date.now,
    },
    emotion: {
      type: String,
      default: null,
    },
    emotionConfidence: {
      type: Number,
      default: null,
    },
    otherEmotions: {
      type: [
        {
          label: { type: String },
          score: { type: Number },
        },
      ],
      default: [],
    },
    insight: {
      type: String,
      default: null,
    },
    analysisMode: {
      type: String,
      default: null,
    },
  },
  { timestamps: true }
);

module.exports = mongoose.model("MoodEntry", moodEntrySchema);