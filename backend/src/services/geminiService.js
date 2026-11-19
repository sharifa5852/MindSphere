const { generateContentWithFallback } = require("./geminiClient");

const wellnessSystemInstruction = `
You are MindSphere AI, a calm and supportive mental-wellness companion.

Your purpose:
- Offer general emotional-wellness support.
- Suggest low-risk self-care activities such as breathing, grounding, rest, journaling, and reaching out to trusted people.
- Use warm, simple, non-judgmental language.
- Keep responses concise and practical.

Strict safety rules:
- You are not a doctor, therapist, or emergency service.
- Do not diagnose mental-health conditions.
- Do not prescribe medicine or treatment.
- Do not claim certainty about a user's mental health.
- Encourage qualified professional support when appropriate.
- If the user may be in immediate danger or mentions self-harm or suicide, urge them to contact local emergency/crisis support and a trusted person immediately.
- Do not answer unrelated questions as if they are mental-wellness advice.
`;

// Generate a safe chat reply using the recent conversation as context.
const generateWellnessResponse = async (message, history = []) => {
  // Rebuild correct user/model message order.
  const orderedContents = [];

  history.forEach((item) => {
    orderedContents.push({
      role: "user",
      parts: [{ text: item.message }],
    });

    orderedContents.push({
      role: "model",
      parts: [{ text: item.response }],
    });
  });

  orderedContents.push({
    role: "user",
    parts: [{ text: message }],
  });

  const response = await generateContentWithFallback({
    contents: orderedContents,
    config: {
      systemInstruction: wellnessSystemInstruction,
      temperature: 0.5,
      maxOutputTokens: 350,
      safetySettings: [
        {
          category: "HARM_CATEGORY_HARASSMENT",
          threshold: "BLOCK_MEDIUM_AND_ABOVE",
        },
        {
          category: "HARM_CATEGORY_HATE_SPEECH",
          threshold: "BLOCK_MEDIUM_AND_ABOVE",
        },
        {
          category: "HARM_CATEGORY_DANGEROUS_CONTENT",
          threshold: "BLOCK_MEDIUM_AND_ABOVE",
        },
      ],
    },
  });

  const text = response.text?.trim();

  if (!text) {
    return "I'm sorry, I couldn't prepare a response right now. Please try again in a moment.";
  }

  return text;
};

// Ask Gemini for structured, non-diagnostic journal analysis.
const analyzeJournalEntry = async (journalText) => {
  const response = await generateContentWithFallback({
    contents: `
Analyze this private journal entry only as a general wellness reflection.

Journal entry:
"""${journalText}"""
`,
    config: {
      systemInstruction: `
${wellnessSystemInstruction}

Return JSON only. Do not diagnose. Keep the reflection supportive and under 100 words.
`,
      responseMimeType: "application/json",
      maxOutputTokens: 1024,
      responseSchema: {
        type: "object",
        properties: {
          sentiment: {
            type: "string",
            enum: ["positive", "neutral", "negative"],
          },
          emotion: {
            type: "string",
          },
          summary: {
            type: "string",
          },
          reflection: {
            type: "string",
          },
          needsSupportPrompt: {
            type: "boolean",
          },
        },
        required: [
          "sentiment",
          "emotion",
          "summary",
          "reflection",
          "needsSupportPrompt",
        ],
      },
    },
  });

  const text = response.text?.trim();

  if (!text) {
    throw new Error("Gemini did not return journal analysis.");
  }

  return JSON.parse(text);
};

// Turn aggregated weekly data into a brief general wellness reflection.
const generateWeeklyInsight = async (wellnessData) => {
  const response = await generateContentWithFallback({
    contents: `
Write a short, warm weekly wellness reflection based only on this aggregated data:

${JSON.stringify(wellnessData)}

Mention patterns gently, without diagnosing or predicting health conditions.
Give one practical, low-risk wellbeing suggestion.
Keep it under 120 words.
`,
    config: {
      systemInstruction: wellnessSystemInstruction,
      temperature: 0.4,
      maxOutputTokens: 250,
    },
  });

  const text = response.text?.trim();

  if (!text) {
    return "You have started building your wellness record. A small check-in each day can help reveal patterns over time.";
  }

  return text;
};
// Generate structured emotion and insight fields from a mood check-in.
const analyzeMoodCheckIn = async (moodData) => {
  const { mood, stress, energy, sleep, socialConnection, note } = moodData;

  const response = await generateContentWithFallback({
    contents: `
Analyze this mood check-in as a general wellness reflection.

Mood (1=very positive, 5=very negative): ${mood}
Stress (1=low, 5=very high): ${stress}
Energy (0-100): ${energy}
Sleep (hours): ${sleep}
Social connection (1=connected, 4=very withdrawn): ${socialConnection}
Optional note from the user: "${note || ""}"
`,
    config: {
      systemInstruction: `
${wellnessSystemInstruction}

Return JSON only. Do not diagnose. Identify the single most likely everyday emotion word (e.g. "Calm", "Nervousness", "Sadness", "Content", "Overwhelmed"), a confidence between 0 and 1, up to 3 other plausible emotions with lower scores between 0 and 1, and a short one or two sentence supportive insight under 40 words.
`,
      responseMimeType: "application/json",
      maxOutputTokens: 1024,
      responseSchema: {
        type: "object",
        properties: {
          emotion: { type: "string" },
          confidence: { type: "number" },
          otherEmotions: {
            type: "array",
            items: {
              type: "object",
              properties: {
                label: { type: "string" },
                score: { type: "number" },
              },
              required: ["label", "score"],
            },
          },
          insight: { type: "string" },
        },
        required: ["emotion", "confidence", "otherEmotions", "insight"],
      },
    },
  });

  const text = response.text?.trim();

  if (!text) {
    throw new Error("Gemini did not return mood analysis.");
  }

  return JSON.parse(text);
};
// Ask Gemini for a short insight grounded in the classifier's emotion label.
const generateInsightForDetectedEmotion = async (moodData, emotionLabel) => {
  const { mood, stress, energy, sleep, socialConnection, note } = moodData;

  const response = await generateContentWithFallback({
    contents: `
A trained emotion-detection model analyzed the user's reflection and detected the primary emotion: "${emotionLabel}".

Mood (1=very positive, 5=very negative): ${mood}
Stress (1=low, 5=very high): ${stress}
Energy (0-100): ${energy}
Sleep (hours): ${sleep}
Social connection (1=connected, 4=very withdrawn): ${socialConnection}
User's reflection: "${note || ""}"

Write a short, warm, supportive insight (1-2 sentences, under 40 words) that acknowledges this detected emotion.
`,
    config: {
      systemInstruction: `${wellnessSystemInstruction}\n\nReturn plain text only. Do not diagnose. Write naturally, do not just repeat the emotion label mechanically.`,
      temperature: 0.5,
      maxOutputTokens: 150,
    },
  });

  const text = response.text?.trim();
  if (!text) {
    throw new Error("Gemini did not return an insight.");
  }
  return text;
};
// Ask Gemini to reflect supportively on a journal entry and detected emotion.
const generateJournalReflectionForEmotion = async (journalText, emotionLabel) => {
  const response = await generateContentWithFallback({
    contents: `
A trained emotion-detection model analyzed this private journal entry and detected the primary emotion: "${emotionLabel}".

Journal entry:
"""${journalText}"""

Write a short, warm, comforting reflection (1-2 sentences, under 60 words) that acknowledges this detected emotion.
`,
    config: {
      systemInstruction: `
${wellnessSystemInstruction}

Return plain text only. Do not diagnose. Write naturally, do not just repeat the emotion label mechanically.
`,
      temperature: 0.5,
      maxOutputTokens: 150,
    },
  });

  const text = response.text?.trim();
  if (!text) {
    throw new Error("Gemini did not return a journal reflection.");
  }
  return text;
};
module.exports = {
  generateWellnessResponse,
  analyzeJournalEntry,
  generateWeeklyInsight,
  analyzeMoodCheckIn,
  generateJournalReflectionForEmotion,
  generateInsightForDetectedEmotion,
};
