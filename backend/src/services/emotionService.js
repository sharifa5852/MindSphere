const EMOTION_SERVICE_URL =
  process.env.EMOTION_SERVICE_URL || "http://127.0.0.1:8000";

const TIMEOUT_MS = 15000; // 15 seconds — RoBERTa inference isn't instant

const detectEmotions = async (text) => {
  if (typeof text !== "string" || !text.trim()) {
    throw new Error("Text is required for emotion detection.");
  }

  const controller = new AbortController();
  const timeoutId = setTimeout(() => controller.abort(), TIMEOUT_MS);

  let response;
  try {
    response = await fetch(`${EMOTION_SERVICE_URL}/predict-emotion`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ text: text.trim() }),
      signal: controller.signal,
    });
  } catch (error) {
    if (error.name === "AbortError") {
      throw new Error(
        "Emotion service timed out. It may be offline or overloaded."
      );
    }
    throw new Error(
      "Could not reach the emotion service. Is it running on " +
        EMOTION_SERVICE_URL +
        "?"
    );
  } finally {
    clearTimeout(timeoutId);
  }

  if (!response.ok) {
    const errorBody = await response.text().catch(() => "");
    throw new Error(
      `Emotion service returned an error (${response.status}): ${errorBody}`
    );
  }

  const data = await response.json();

  if (!Array.isArray(data.emotions)) {
    throw new Error("Emotion service returned an unexpected response shape.");
  }

  return data.emotions; // e.g. [{ label: "sadness", score: 0.8266 }]
};

module.exports = {
  detectEmotions,
};