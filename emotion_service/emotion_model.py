import torch
from transformers import AutoTokenizer, AutoModel

MODEL_ID = "Hidden-States/roberta-base-goemotions"

EMOTION_LABELS = [
    "admiration",
    "amusement",
    "anger",
    "annoyance",
    "approval",
    "caring",
    "confusion",
    "curiosity",
    "desire",
    "disappointment",
    "disapproval",
    "disgust",
    "embarrassment",
    "excitement",
    "fear",
    "gratitude",
    "grief",
    "joy",
    "love",
    "nervousness",
    "optimism",
    "pride",
    "realization",
    "relief",
    "remorse",
    "sadness",
    "surprise",
    "neutral",
]

device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

print(f"Loading emotion model on: {device}")
print("Loading tokenizer...")

tokenizer = AutoTokenizer.from_pretrained(MODEL_ID)

print("Loading model...")

model = AutoModel.from_pretrained(
    MODEL_ID,
    trust_remote_code=True,
)

model.to(device)
model.eval()

print("Emotion model loaded successfully!")


def predict_emotions(text: str):
    """
    Predict possible emotions from text.

    Returns a list of labels whose probability is >= 0.5,
    following the model author's published inference approach.
    """

    if not text or not text.strip():
        raise ValueError("Text cannot be empty.")

    inputs = tokenizer(
        text,
        truncation=True,
        max_length=128,
        padding=True,
        return_attention_mask=True,
        return_tensors="pt",
    ).to(device)

    with torch.inference_mode():
        _, logits = model(**inputs)

    probabilities = torch.sigmoid(logits)[0]

    results = []

    for i, probability in enumerate(probabilities):
        score = float(probability.item())

        if score >= 0.5:
            results.append(
                {
                    "label": EMOTION_LABELS[i],
                    "score": round(score, 4),
                }
            )

    # Highest-confidence emotions first
    results.sort(key=lambda item: item["score"], reverse=True)

    return results