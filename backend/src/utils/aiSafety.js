const crisisKeywords = [
  "kill myself",
  "end my life",
  "suicide",
  "want to die",
  "don't want to live",
  "hurt myself",
  "harm myself",
  "self harm",
  "self-harm",
];

const hasCrisisLanguage = (text) => {
  const normalizedText = text.toLowerCase();

  return crisisKeywords.some((keyword) =>
    normalizedText.includes(keyword)
  );
};

const getCrisisResponse = () =>
  "I'm really sorry you're going through this. You deserve immediate support. Please contact someone you trust, a qualified mental-health professional, or a local crisis/emergency service now. If you may be in immediate danger, call your local emergency number right away. I cannot provide emergency care, but you do not have to handle this alone.";

const detectEmotion = (text) => {
  const normalizedText = text.toLowerCase();

  if (normalizedText.includes("anxious") || normalizedText.includes("anxiety")) {
    return "anxiety";
  }

  if (normalizedText.includes("stress") || normalizedText.includes("overwhelmed")) {
    return "stress";
  }

  if (normalizedText.includes("sad") || normalizedText.includes("down")) {
    return "sadness";
  }

  if (normalizedText.includes("happy") || normalizedText.includes("good")) {
    return "positive";
  }

  return "neutral";
};

module.exports = {
  hasCrisisLanguage,
  getCrisisResponse,
  detectEmotion,
};