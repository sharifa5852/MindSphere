const assessmentTypes = {
  phq9: {
    name: "PHQ-9",
    description: "A nine-item depression screening questionnaire.",
    questionCount: 9,
    maximumScore: 27,
  },
  gad7: {
    name: "GAD-7",
    description: "A seven-item anxiety screening questionnaire.",
    questionCount: 7,
    maximumScore: 21,
  },
};

const getResultLevel = (type, score) => {
  if (type === "phq9") {
    if (score <= 4) return "minimal";
    if (score <= 9) return "mild";
    if (score <= 14) return "moderate";
    if (score <= 19) return "moderately_severe";
    return "severe";
  }

  if (type === "gad7") {
    if (score <= 4) return "minimal";
    if (score <= 9) return "mild";
    if (score <= 14) return "moderate";
    return "severe";
  }

  return null;
};

const calculateAssessmentResult = (type, answers) => {
  const score = answers.reduce((total, answer) => total + answer, 0);
  const level = getResultLevel(type, score);

  return {
    score,
    level,
    // PHQ-9's final answer is a safety-sensitive response.
    needsSupportPrompt: type === "phq9" && answers[8] > 0,
    considerProfessionalSupport: score >= 10,
  };
};

module.exports = {
  assessmentTypes,
  calculateAssessmentResult,
};