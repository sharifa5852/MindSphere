const mongoose = require("mongoose");
const Therapist = require("../models/Therapist");
const Assessment = require("../models/Assessment");

const escapeRegExp = (text) =>
  text.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");

const getTherapists = async (req, res) => {
  try {
    const { specialization, location, availability, language } = req.query;

    const filter = { isActive: true };

    if (specialization) {
      filter.specialization = {
        $regex: escapeRegExp(specialization),
        $options: "i",
      };
    }

    if (location) {
      filter.location = {
        $regex: escapeRegExp(location),
        $options: "i",
      };
    }

    if (availability) {
      filter.availability = availability;
    }

    if (language) {
      filter.languages = {
        $regex: escapeRegExp(language),
        $options: "i",
      };
    }

    const therapists = await Therapist.find(filter).sort({
      rating: -1,
      reviewCount: -1,
    });

    return res.status(200).json({
      success: true,
      count: therapists.length,
      therapists,
    });
  } catch (error) {
    console.error("Get therapists failed:", error.message);

    return res.status(500).json({
      success: false,
      message: "Could not retrieve therapists.",
    });
  }
};

const getTherapistById = async (req, res) => {
  try {
    const { id } = req.params;

    if (!mongoose.isValidObjectId(id)) {
      return res.status(400).json({
        success: false,
        message: "Invalid therapist ID.",
      });
    }

    const therapist = await Therapist.findOne({
      _id: id,
      isActive: true,
    });

    if (!therapist) {
      return res.status(404).json({
        success: false,
        message: "Therapist not found.",
      });
    }

    return res.status(200).json({
      success: true,
      therapist,
    });
  } catch (error) {
    console.error("Get therapist failed:", error.message);

    return res.status(500).json({
      success: false,
      message: "Could not retrieve therapist details.",
    });
  }
};

const getRecommendedTherapists = async (req, res) => {
  try {
    const { location, language, focus } = req.query;

    const therapists = await Therapist.find({
      isActive: true,
      availability: { $ne: "unavailable" },
    });

    const latestAssessments = await Assessment.find({
      userId: req.firebaseUser.uid,
    })
      .sort({ date: -1 })
      .limit(2);

    const focusAreas = new Set();

    // Optional user-selected focus, for example: ?focus=stress,anxiety
    if (focus) {
      focus
        .split(",")
        .map((item) => item.trim().toLowerCase())
        .filter(Boolean)
        .forEach((item) => focusAreas.add(item));
    }

    // These are matching keywords only—not diagnoses.
    latestAssessments.forEach((assessment) => {
      if (assessment.type === "phq9") {
        focusAreas.add("mood");
        focusAreas.add("stress");
        focusAreas.add("depression");
      }

      if (assessment.type === "gad7") {
        focusAreas.add("anxiety");
        focusAreas.add("stress");
      }
    });

    const recommendations = therapists
      .map((therapist) => {
        let matchScore = therapist.rating * 10;
        const reasons = [];

        const specialties = therapist.specialization.map((item) =>
          item.toLowerCase()
        );

        const matchedFocusAreas = [...focusAreas].filter((focusArea) =>
          specialties.some((specialty) => specialty.includes(focusArea))
        );

        if (matchedFocusAreas.length > 0) {
          matchScore += matchedFocusAreas.length * 25;
          reasons.push(
            `Their specialization includes ${matchedFocusAreas.join(", ")}.`
          );
        }

        if (
          location &&
          therapist.location.toLowerCase().includes(location.toLowerCase())
        ) {
          matchScore += 10;
          reasons.push("Their location matches your preference.");
        }

        if (
          language &&
          therapist.languages.some((item) =>
            item.toLowerCase().includes(language.toLowerCase())
          )
        ) {
          matchScore += 10;
          reasons.push("They offer your preferred language.");
        }

        if (therapist.availability === "available") {
          matchScore += 5;
          reasons.push("They are currently marked as available.");
        }

        if (reasons.length === 0) {
          reasons.push(
            "This profile is shown based on its rating and availability."
          );
        }

        return {
          therapist,
          matchScore: Math.min(Math.round(matchScore), 100),
          matchExplanation: reasons.join(" "),
        };
      })
      .sort((a, b) => b.matchScore - a.matchScore)
      .slice(0, 10);

    return res.status(200).json({
      success: true,
      disclaimer:
        "These matches are informational only and do not replace professional advice or a clinical referral.",
      recommendations,
    });
  } catch (error) {
    console.error("Get therapist recommendations failed:", error.message);

    return res.status(500).json({
      success: false,
      message: "Could not generate therapist recommendations.",
    });
  }
};

module.exports = {
  getTherapists,
  getTherapistById,
  getRecommendedTherapists,
};