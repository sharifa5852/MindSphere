const getGeminiClient = async () => {
  if (!process.env.GEMINI_API_KEY) {
    throw new Error("GEMINI_API_KEY is missing from the .env file.");
  }

  const { GoogleGenAI } = await import("@google/genai");

  return new GoogleGenAI({
    apiKey: process.env.GEMINI_API_KEY,
  });
};

const modelName = () => process.env.GEMINI_MODEL || "gemini-3.5-flash";

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

const generateWellnessResponse = async (message, history = []) => {
  const ai = await getGeminiClient();



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

  const response = await ai.models.generateContent({
    model: modelName(),
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

const analyzeJournalEntry = async (journalText) => {
  const ai = await getGeminiClient();

  const response = await ai.models.generateContent({
    model: modelName(),
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

const generateWeeklyInsight = async (wellnessData) => {
  const ai = await getGeminiClient();

  const response = await ai.models.generateContent({
    model: modelName(),
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

module.exports = {
  generateWellnessResponse,
  analyzeJournalEntry,
  generateWeeklyInsight,
};