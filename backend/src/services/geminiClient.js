const { setTimeout: pause } = require("node:timers/promises");

const REQUEST_TIMEOUT_MS = 12000;
const TRANSIENT_STATUS_CODES = new Set([408, 429, 500, 502, 503, 504]);

// Create the Google GenAI client from the server-side API key.
const getGeminiClient = async () => {
  if (!process.env.GEMINI_API_KEY) {
    throw new Error("GEMINI_API_KEY is missing from the .env file.");
  }
  const { GoogleGenAI } = await import("@google/genai");
  return new GoogleGenAI({
    apiKey: process.env.GEMINI_API_KEY,
    httpOptions: {
      timeout: REQUEST_TIMEOUT_MS,
      // Bound retries here so they cannot silently outlast the app timeout.
      retryOptions: { attempts: 1 },
    },
  });
};

// Choose a supported thinking setting for the selected Gemini model family.
function thinkingConfigFor(model) {
  if (/gemini-2\.5-flash/.test(model)) return { thinkingBudget: 0 };
  if (/gemini-(3\.5-flash(?:-lite)?|3\.6-flash|3\.1-flash-lite|3-flash-preview)$/.test(model)) {
    return { thinkingLevel: "MINIMAL" };
  }
  return { thinkingLevel: "LOW" };
}

// Generate content with bounded retries and a fallback model; injectable for tests.
function createContentGenerator({ getClient = getGeminiClient, wait = pause } = {}) {
  return async ({ contents, config = {} }) => {
    const client = await getClient();
    const models = [...new Set([
      process.env.GEMINI_MODEL?.trim() || "gemini-3.5-flash-lite",
      process.env.GEMINI_FALLBACK_MODEL?.trim() || "gemini-3.6-flash",
    ])];
    let lastError;

    for (const [modelIndex, model] of models.entries()) {
      const maxAttempts = modelIndex === 0 ? 2 : 1;
      for (let attempt = 1; attempt <= maxAttempts; attempt += 1) {
        try {
          return await client.models.generateContent({
            model,
            contents,
            config: {
              ...config,
              thinkingConfig: thinkingConfigFor(model),
              abortSignal: AbortSignal.timeout(REQUEST_TIMEOUT_MS),
            },
          });
        } catch (error) {
          lastError = error;
          const status = Number(error.status || error.code);
          const transient = TRANSIENT_STATUS_CODES.has(status) ||
            ((!Number.isFinite(status) || status < 100) &&
              /fetch failed|abort|timeout|timed out/i.test(`${error.name} ${error.message}`));
          if (!transient && status !== 404) throw error;
          console.warn(`Gemini ${model} attempt ${attempt} failed (${status || "network timeout"}).`);
          if (status === 404 || attempt === maxAttempts) break;
          await wait(300);
        }
      }
    }

    const error = new Error("AI is temporarily busy. Please try again in a moment.", { cause: lastError });
    error.statusCode = 503;
    throw error;
  };
}

module.exports = {
  createContentGenerator,
  generateContentWithFallback: createContentGenerator(),
};
