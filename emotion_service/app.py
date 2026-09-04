from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

from emotion_model import predict_emotions


app = FastAPI(
    title="MindSphere Emotion Service",
    description="Emotion classification service using RoBERTa-GoEmotions",
    version="1.0.0",
)


class EmotionRequest(BaseModel):
    text: str


@app.get("/health")
def health_check():
    return {
        "status": "ok",
        "service": "emotion_service",
    }


@app.post("/predict-emotion")
def predict_emotion(request: EmotionRequest):
    text = request.text.strip()

    if not text:
        raise HTTPException(
            status_code=400,
            detail="Text cannot be empty.",
        )

    if len(text) > 5000:
        raise HTTPException(
            status_code=400,
            detail="Text is too long.",
        )

    try:
        emotions = predict_emotions(text)

        return {
            "text": text,
            "emotions": emotions,
        }

    except Exception as error:
        print("Prediction error:", repr(error))

        raise HTTPException(
            status_code=500,
            detail="Emotion prediction failed.",
        )