const mongoose = require("mongoose");

const therapistSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: true,
      trim: true,
      maxlength: 100,
    },
    specialization: {
      type: [String],
      required: true,
      validate: {
        validator: (items) => items.length > 0,
        message: "At least one specialization is required.",
      },
    },
    experienceYears: {
      type: Number,
      required: true,
      min: 0,
    },
    rating: {
      type: Number,
      default: 0,
      min: 0,
      max: 5,
    },
    reviewCount: {
      type: Number,
      default: 0,
      min: 0,
    },
    availability: {
      type: String,
      enum: ["available", "limited", "unavailable"],
      default: "available",
    },
    location: {
      type: String,
      required: true,
      trim: true,
    },
    languages: {
      type: [String],
      default: [],
    },
    bio: {
      type: String,
      trim: true,
      maxlength: 1500,
    },
    
    profileImageUrl: {
      type: String,
      trim: true,
      default: null,
    },
     verified: {
      type: Boolean,
      default: false, // Only flip to true once a real person has confirmed these details.
    },
    isActive: {
      type: Boolean,
      default: true,
    },
        seedSource: {
      type: String,
      default: null,
    },
  },
  {
    timestamps: true,
  }
);

module.exports = mongoose.model("Therapist", therapistSchema);