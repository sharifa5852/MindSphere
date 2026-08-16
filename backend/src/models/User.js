const mongoose = require("mongoose");

const userSchema = new mongoose.Schema(
  {
    firebaseUid: {
      type: String,
      required: true,
      unique: true,
      trim: true,
    },
    name: {
      type: String,
      required: true,
      trim: true,
      maxlength: 100,
    },
    email: {
      type: String,
      required: true,
      unique: true,
      lowercase: true,
      trim: true,
    },
    preferences: {
      notificationsEnabled: {
        type: Boolean,
        default: true,
      },
      checkInTime: {
        type: String,
        default: "20:00",
      },
      theme: {
        type: String,
        enum: ["system", "light", "dark"],
        default: "system",
      },
    },
  },
  { timestamps: true }
);

module.exports = mongoose.model("User", userSchema);