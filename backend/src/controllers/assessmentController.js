const Assessment = require("../models/Assessment");
const {
  assessmentTypes,
  calculateAssessmentResult,
} = require("../utils/assessmentScoring");

// Return the available PHQ-9 and GAD-7 definitions and answer options.
const getAssessmentTypes = (req, res) => {
  const assessments = Object.entries(assessmentTypes).map(([id, details]) => ({
    id,
    ...details,
    answerOptions: [
      { value: 0, label: "Not at all" },
      { value: 1, label: "Several days" },
      { value: 2, label: "More than half the days" },
      { value: 3, label: "Nearly every day" },
    ],
    disclaimer:
      "This screening result is for wellness awareness only and is not a medical diagnosis.",
  }));

  return res.status(200).json({
    success: true,
    assessments,
  });
};

// Validate answers, calculate the screening result, and save it for this user.
const submitAssessment = async (req, res) => {
  try {
    const { type, answers, date } = req.body;
    const assessmentInfo = assessmentTypes[type];

    if (!assessmentInfo) {
      return res.status(400).json({
        success: false,
        message: "Assessment type must be either phq9 or gad7.",
      });
    }

    if (!Array.isArray(answers) || answers.length !== assessmentInfo.questionCount) {
      return res.status(400).json({
        success: false,
        message: `${assessmentInfo.name} requires exactly ${assessmentInfo.questionCount} answers.`,
      });
    }

    const answersAreValid = answers.every(
      (answer) => Number.isInteger(answer) && answer >= 0 && answer <= 3
    );

    if (!answersAreValid) {
      return res.status(400).json({
        success: false,
        message: "Every answer must be a whole number from 0 to 3.",
      });
    }

    if (date !== undefined && Number.isNaN(new Date(date).getTime())) {
      return res.status(400).json({
        success: false,
        message: "Date is invalid.",
      });
    }

    const calculatedResult = calculateAssessmentResult(type, answers);

    const assessment = await Assessment.create({
      userId: req.firebaseUser.uid,
      type,
      answers,
      score: calculatedResult.score,
      result: {
        level: calculatedResult.level,
        needsSupportPrompt: calculatedResult.needsSupportPrompt,
        considerProfessionalSupport:
          calculatedResult.considerProfessionalSupport,
      },
      date: date ? new Date(date) : new Date(),
    });

    const response = {
      success: true,
      message: "Assessment submitted successfully.",
      assessment: {
        _id: assessment._id,
        type: assessment.type,
        score: assessment.score,
        result: assessment.result,
        date: assessment.date,
      },
      disclaimer:
        "This is a screening result, not a diagnosis. A qualified professional can provide appropriate assessment and support.",
    };

    if (assessment.result.needsSupportPrompt) {
      response.supportMessage =
        "You indicated a difficult or safety-related feeling. Please consider reaching out now to someone you trust or a qualified mental-health professional. If you may be in immediate danger, contact local emergency services or an emergency crisis service.";
    }

    return res.status(201).json(response);
  } catch (error) {
    console.error("Submit assessment failed:", error.message);

    return res.status(500).json({
      success: false,
      message: "Could not submit assessment.",
    });
  }
};

// Return this user's assessment history without exposing submitted answers.
const getAssessmentHistory = async (req, res) => {
  try {
    const assessments = await Assessment.find({
      userId: req.firebaseUser.uid,
    })
      .sort({ date: -1 })
      .select("-userId -answers");

    return res.status(200).json({
      success: true,
      count: assessments.length,
      assessments,
    });
  } catch (error) {
    console.error("Get assessment history failed:", error.message);

    return res.status(500).json({
      success: false,
      message: "Could not retrieve assessment history.",
    });
  }
};

module.exports = {
  getAssessmentTypes,
  submitAssessment,
  getAssessmentHistory,
};
