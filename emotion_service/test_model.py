from emotion_model import predict_emotions


test_sentences = [
    "I am really nervous about tomorrow's exam.",
    "Today was wonderful and I feel so happy.",
    "I feel lonely, exhausted, and disappointed.",
    "Everything is fine. I had a normal day.",
]


for sentence in test_sentences:
    print("\n" + "=" * 70)
    print("TEXT:", sentence)

    try:
        emotions = predict_emotions(sentence)

        if emotions:
            print("DETECTED EMOTIONS:")
            for emotion in emotions:
                print(
                    f"  {emotion['label']}: "
                    f"{emotion['score']}"
                )
        else:
            print("No emotion crossed the 0.5 threshold.")

    except Exception as error:
        print("ERROR:", error)