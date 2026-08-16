const mongoose = require("mongoose");

const chatHistorySchema = new mongoose.Schema(
  {
    userId: {
      type: String,
      required: true,
      index: true,
    },
    message: {
      type: String,
      required: true,
      trim: true,
      maxlength: 2000,
    },
    response: {
      type: String,
      required: true,
      trim: true,
      maxlength: 5000,
    },
    detectedEmotion: {
      type: String,
      default: null,
    },
    isSafetyResponse: {
      type: Boolean,
      default: false,
    },
    timestamp: {
      type: Date,
      default: Date.now,
    },
  },
  {
    timestamps: true,
  }
);

module.exports = mongoose.model("ChatHistory", chatHistorySchema);