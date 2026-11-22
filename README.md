# MindSphere

> An AI-powered mental wellness app for students: mood tracking, journaling, an AI companion with built-in safety checks, PHQ-9 / GAD-7 screenings, and therapist recommendations.

## Overview

MindSphere is a mobile wellness application built with **Flutter** and a **Node.js / Express** backend. Users sign in with Firebase Authentication, record daily mood check-ins, write journal entries, chat with an AI companion, take standard screening questionnaires, and get matched with therapists.

AI features are powered by **Google Gemini**, with an optional **FastAPI + RoBERTa** emotion-classification service as a "trained model" analysis path. A crisis-keyword check runs in the backend so that high-risk messages receive a prepared safety-support reply instead of a generated one.

> **Disclaimer:** MindSphere is a wellness support tool, not a medical device. PHQ-9 / GAD-7 results are screening scores, not diagnoses. If you are in crisis, please contact local emergency services or a trusted professional.

## Features

- **Authentication & profile**: email/password sign-up, email verification, Firebase sign-in, profile and preference management (theme, check-in time, notifications)
- **Mood tracking**: daily check-ins (mood, stress, energy, sleep, social connection), history, weekly summaries, and optional AI analysis
- **Journaling**: write, view, delete, and analyze entries (emotion, summary, reflection)
- **AI companion**: chat with Gemini using recent chat history, with crisis-keyword detection and a prepared safety response
- **PHQ-9 / GAD-7 screening**: scoring, severity, saved history, and a disclaimer
- **Therapist recommendations**: browse and filter therapists, with rule-based ranking and match reasons
- **Wellness reports**: weekly and monthly aggregates
- **Dual analysis modes**: Gemini or a trained RoBERTa emotion model (with Gemini fallback)

## Tech Stack

| Layer | Technology |
|---|---|
| Presentation | Flutter / Dart |
| Application | Node.js / Express |
| Data | MongoDB (Mongoose) |
| Authentication | Firebase Authentication (ID token verification) |
| AI | Google Gemini API |
| Emotion classification | Python FastAPI + RoBERTa |

## Architecture

### Level 0: Context Diagram

![Context diagram](docs/diagrams/context-diagram.png)

### Level 0: Architectural Design

![Level 0 architecture](docs/diagrams/architecture-level-0.png)

### Level 1: Architectural Design

![Level 1 architecture](docs/diagrams/architecture-level-1.png)

### Level 2: Module Decomposition

![Level 2 architecture](docs/diagrams/architecture-level-2.png)

### AI Integration

![AI integration](docs/diagrams/ai-integration.png)

## Use Case Diagrams

### Authentication & Profile

![Authentication use cases](docs/diagrams/usecase-authentication.png)

### Mood Tracking & Reports

![Mood and reports use cases](docs/diagrams/usecase-mood-reports.png)

### AI Companion Chat

![AI chat use cases](docs/diagrams/usecase-ai-chat.png)

### Journal

![Journal use cases](docs/diagrams/usecase-journal.png)

### Assessments & Therapists

![Assessment and therapist use cases](docs/diagrams/usecase-assessment-therapist.png)

## Activity Diagrams

### Authentication Flow

![Authentication activity](docs/diagrams/activity-authentication.png)

### Mood / Journal Flow

![Mood and journal activity](docs/diagrams/activity-mood-journal.png)

### AI Chat Flow

![AI chat activity](docs/diagrams/activity-ai-chat.png)

### Assessment & Therapist Recommendation Flow

![Assessment activity](docs/diagrams/activity-assessment-therapist.png)

## Sequence Diagrams

### Mood Check-in & Analysis

![Mood analysis sequence](docs/diagrams/sequence-mood-analysis.png)

### AI Chat

![AI chat sequence](docs/diagrams/sequence-ai-chat.png)

## Data Model

### Entity-Relationship Diagram

![ER diagram](docs/diagrams/er-diagram.png)

### Class Diagrams

**User and preferences**

![User class diagram](docs/diagrams/class-user.png)

**Mood and journal entries**

![Mood and journal class diagram](docs/diagrams/class-mood-journal.png)

**Assessment, chat history, therapist, and Gemini service**

![Assessment, chat, therapist class diagram](docs/diagrams/class-assessment-chat-therapist.png)

## Component Design

### User Management

![User management design](docs/diagrams/design-user-management.png)

### Mood & Journal Manager

![Mood journal manager design](docs/diagrams/design-mood-journal.png)

### Assessment Support

![Assessment support design](docs/diagrams/design-assessment-support.png)

### AI Companion

![AI companion design](docs/diagrams/design-ai-companion.png)

## Getting Started

> Replace the commands below with your project's actual folder names and scripts.

### Prerequisites

- Flutter SDK
- Node.js and npm
- MongoDB (local or Atlas)
- A Firebase project (Authentication enabled)
- A Google Gemini API key
- Python 3.9+ (only for the optional emotion service)

### Installation

```bash
git clone https://github.com/sharifa5852/MindSphere.git
cd MindSphere
```

**Backend**
```bash
cd backend
npm install
cp .env.example .env   # add your keys
npm start
```

**Emotion service (optional)**
```bash
cd emotion-service
pip install -r requirements.txt
uvicorn main:app --reload
```

**Mobile app**
```bash
cd app
flutter pub get
flutter run
```

### Environment Variables

```
MONGODB_URI=
GEMINI_API_KEY=
FIREBASE_SERVICE_ACCOUNT=
EMOTION_SERVICE_URL=
```

## Project Structure

```
MindSphere/
├── app/                # Flutter application
├── backend/            # Node.js / Express API
├── emotion-service/    # FastAPI + RoBERTa (optional)
├── docs/
│   └── diagrams/       # Design diagrams used in this README
└── README.md
```

## Contributing

1. Fork the repository
2. Create a branch (`git checkout -b feature/your-feature`)
3. Commit your changes
4. Open a pull request

## License

Add your license here.

## Author

[@sharifa5852](https://github.com/sharifa5852)