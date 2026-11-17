require("dotenv").config();
const mongoose = require("mongoose");
const MoodEntry = require("../models/MoodEntry");
const JournalEntry = require("../models/JournalEntry");
const Assessment = require("../models/Assessment");
const Therapist = require("../models/Therapist");

const DEMO_SOURCE = "demo-v1";
const clamp = (value, min, max) => Math.min(max, Math.max(min, value));

const journalSamples = [
  ["Today felt busy, but I took things one step at a time and finished what mattered.", "neutral", "Steady", "A busy day felt manageable with a slower pace."],
  ["A short walk outside helped me clear my head after a stressful morning.", "positive", "Relieved", "A walk offered a helpful reset."],
  ["I felt tired today and gave myself permission to rest without guilt.", "neutral", "Tired", "Rest was the main need today."],
  ["Talking with a friend made me feel supported and less alone.", "positive", "Connected", "A supportive conversation lifted the day."],
  ["I was worried about a task, but breaking it into smaller steps helped.", "neutral", "Focused", "Small steps made a worry feel more manageable."],
  ["I had a quiet evening and felt calmer by the time I went to bed.", "positive", "Calm", "A quiet evening supported a calmer mood."],
  ["I felt disappointed when plans changed, then found another way to enjoy the day.", "neutral", "Adaptable", "Flexibility helped after plans changed."],
  ["I struggled to focus, but I still made a little progress and that counts.", "neutral", "Persistent", "Some progress was made despite distraction."],
  ["Sharing a meal with family gave me a warm moment in a busy week.", "positive", "Content", "Family time brought comfort."],
  ["Today was ordinary and steady. I am glad I kept my routine simple.", "neutral", "Grounded", "A simple routine felt grounding."],
  ["I felt anxious about tomorrow, so I wrote down what I can prepare today.", "negative", "Anxious", "Planning one next step eased some uncertainty."],
  ["Finishing a small task gave me a sense of accomplishment.", "positive", "Proud", "Completing a task brought satisfaction."],
  ["I needed a break, so I paused, stretched, and returned with more patience.", "positive", "Refreshed", "A short break helped restore patience."],
  ["It was a difficult day, but I reached out to someone I trust.", "negative", "Supported", "Reaching out helped during a hard day."],
  ["I noticed a few good moments today, even though the day was not perfect.", "positive", "Hopeful", "Small positive moments stood out."],
  ["I felt overwhelmed for a while and made the evening quieter for myself.", "negative", "Overwhelmed", "Reducing demands helped create space."],
  ["A good night's sleep helped me feel more present this morning.", "positive", "Rested", "Rest supported a more present morning."],
  ["I had a mix of emotions today and tried to notice them without judging them.", "neutral", "Reflective", "Naming emotions made room for reflection."],
  ["I kept putting something off, then started with five minutes and continued.", "neutral", "Motivated", "Starting briefly helped build momentum."],
  ["The day ended more peacefully than it began, and I feel thankful for that.", "positive", "Peaceful", "A calmer ending changed how the day felt."],
];

const demoTherapists = Array.from({ length: 20 }, (_, index) => {
  const number = String(index + 1).padStart(2, "0");
  const focus = ["anxiety", "stress", "mood", "sleep", "general wellness"][index % 5];
  return {
    name: `Demo Counselor ${number}`,
    specialization: [focus, index % 2 ? "general wellness" : "stress"],
    experienceYears: 2 + (index % 16),
    rating: Number((4.1 + (index % 9) / 10).toFixed(1)),
    reviewCount: 3 + index * 2,
    availability: index % 6 === 5 ? "limited" : "available",
    location: ["Dhaka", "Chattogram", "Sylhet", "Rajshahi"][index % 4],
    languages: index % 3 === 0 ? ["Bengali"] : ["Bengali", "English"],
    bio: "Demo profile for exploring the support directory. This is not a real provider and cannot be contacted.",
    profileImageUrl: null,
    verified: false,
    isActive: true,
    seedSource: DEMO_SOURCE,
    isDemo: true,
  };
});

function makeAnswers(questionCount, score) {
  const answers = Array(questionCount).fill(0);
  for (let index = 0; index < questionCount && score > 0; index += 1) {
    const value = Math.min(3, score);
    answers[index] = value;
    score -= value;
  }
  return answers;
}

function resultFor(type, score, answers) {
  let level;
  if (type === "phq9") {
    level = score <= 4 ? "minimal" : score <= 9 ? "mild" : score <= 14 ? "moderate" : score <= 19 ? "moderately_severe" : "severe";
  } else {
    level = score <= 4 ? "minimal" : score <= 9 ? "mild" : score <= 14 ? "moderate" : "severe";
  }
  return {
    level,
    needsSupportPrompt: type === "phq9" && answers[8] > 0,
    considerProfessionalSupport: score >= 10,
  };
}

function makeAssessments(userId, now) {
  return Array.from({ length: 20 }, (_, index) => {
    const type = index % 2 === 0 ? "phq9" : "gad7";
    const questionCount = type === "phq9" ? 9 : 7;
    const scores = type === "phq9"
      ? [3, 5, 7, 9, 11, 13, 15, 17, 8, 6]
      : [2, 4, 6, 8, 10, 12, 7, 5, 3, 1];
    const answers = makeAnswers(questionCount, scores[Math.floor(index / 2)]);
    const score = answers.reduce((total, value) => total + value, 0);
    const date = new Date(now);
    date.setDate(date.getDate() - index);
    return { userId, type, answers, score, result: resultFor(type, score, answers), date, isDemo: true };
  });
}

async function seed() {
  const uri = process.env.MONGODB_URI;
  const userId = process.env.DEMO_USER_ID;
  if (!uri) throw new Error("MONGODB_URI is not set.");
  if (!userId) throw new Error("Set DEMO_USER_ID to the Firebase UID of the account that should see this data.");

  const firebaseUser = await require("../config/firebaseAdmin").getUser(userId);
  const expectedEmail = process.env.DEMO_USER_EMAIL?.trim().toLowerCase();
  if (expectedEmail && firebaseUser.email?.toLowerCase() !== expectedEmail) {
    throw new Error("DEMO_USER_EMAIL does not match the Firebase UID. No data was changed.");
  }
  console.log(`Verified demo target: ${firebaseUser.email} (${firebaseUser.uid}).`);

  await mongoose.connect(uri);
  try {
    const now = new Date();
    const moods = Array.from({ length: 20 }, (_, index) => {
      const date = new Date(now);
      date.setDate(date.getDate() - index);
      const mood = 2 + ((index * 3) % 4);
      return {
        userId,
        mood,
        stress: clamp(6 - mood + (index % 2), 1, 5),
        energy: clamp(42 + ((index * 13) % 55), 0, 100),
        sleep: Number((5.5 + ((index * 7) % 35) / 10).toFixed(1)),
        socialConnection: 1 + (index % 4),
        note: ["Took a short walk and felt clearer.", "A busy day, but I managed one thing at a time.", "Had a restful evening.", "Connected with someone supportive."][index % 4],
        date,
        isDemo: true,
      };
    });

    const journals = journalSamples.map(([text, sentiment, emotion, summary], index) => {
      const date = new Date(now);
      date.setDate(date.getDate() - index);
      return { userId, text, sentiment, emotion, summary, date, isDemo: true };
    });

    const assessments = makeAssessments(userId, now);
    // Validate every document before replacing any existing demo records.
    await Promise.all([
      ...moods.map((data) => new MoodEntry(data).validate()),
      ...journals.map((data) => new JournalEntry(data).validate()),
      ...assessments.map((data) => new Assessment(data).validate()),
      ...demoTherapists.map((data) => new Therapist(data).validate()),
    ]);

    // Remove only records created by this demo command for this account.
    await Promise.all([
      MoodEntry.deleteMany({ userId, isDemo: true }),
      JournalEntry.deleteMany({ userId, isDemo: true }),
      Assessment.deleteMany({ userId, isDemo: true }),
    ]);

    await Promise.all([
      MoodEntry.insertMany(moods),
      JournalEntry.insertMany(journals),
      Assessment.insertMany(assessments),
      Therapist.bulkWrite(demoTherapists.map((therapist) => ({
        updateOne: {
          filter: { seedSource: DEMO_SOURCE, name: therapist.name },
          update: { $set: therapist },
          upsert: true,
        },
      }))),
    ]);

    console.log(`Added 20 demo mood check-ins, 20 journal entries, 20 assessments, and 20 clearly labeled demo therapist profiles for ${userId}.`);
  } finally {
    await mongoose.disconnect();
  }
}

seed().catch((error) => {
  console.error(`Demo data seeding failed: ${error.message}`);
  process.exitCode = 1;
});
