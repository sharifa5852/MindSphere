const mongoose = require("mongoose");

const assessmentSchema = new mongoose.Schema(
  {
    userId: {
      type: String,
      required: true,
      index: true,
    },
    type: {
      type: String,
      required: true,
      enum: ["phq9", "gad7"],
    },
    answers: {
      type: [Number],
      required: true,
    },
    score: {
      type: Number,
      required: true,
    },
    result: {
      level: {
        type: String,
        required: true,
      },
      needsSupportPrompt: {
        type: Boolean,
        default: false,
      },
      considerProfessionalSupport: {
        type: Boolean,
        default: false,
      },
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

module.exports = mongoose.model("Assessment", assessmentSchema);