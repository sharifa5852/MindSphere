require("dotenv").config();
const mongoose = require("mongoose");
const MoodEntry = require("../models/MoodEntry");
const JournalEntry = require("../models/JournalEntry");
const Assessment = require("../models/Assessment");

const USER_ID = "i9xJiXHXupTiCGljRZZLyWOHuiF2"; // sharifatunnur83@gmail.com
const DAYS_BACK = 60;

const clamp = (value, min, max) => Math.min(max, Math.max(min, value));
const randInt = (min, max) => Math.floor(Math.random() * (max - min + 1)) + min;
const pick = (arr) => arr[randInt(0, arr.length - 1)];

function buildMoodEntries() {
  const entries = [];

  for (let i = DAYS_BACK; i >= 0; i--) {
    const date = new Date();
    date.setDate(date.getDate() - i);
    date.setHours(randInt(8, 22), randInt(0, 59), 0, 0);

    const wave = Math.sin(i / 4) * 1.3;
    const trend = Math.sin(i / 11) * 0.7;

    const mood = clamp(Math.round(3 + wave + trend + randInt(-1, 1)), 1, 5);
    const stress = clamp(Math.round(3 - wave * 0.8 + randInt(-1, 1)), 1, 5);
    const energy = clamp(Math.round(54 + wave * 10 + trend * 6 + randInt(-10, 10)), 0, 100);
    const sleep = clamp(Number((6.6 + wave * 0.45 + (Math.random() - 0.5)).toFixed(1)), 3, 10);
    const socialConnection = clamp(randInt(1, 4), 1, 4);

    const notes = [
      "Felt okay today, a bit tired.",
      "Good day, got some work done.",
      "Stressful morning but calmed down later.",
      "Slept well, felt more energetic.",
      "Quiet day, nothing much happened.",
      "Had a productive afternoon.",
      "Felt low at first, but the day improved.",
      "Spent time with family and felt better.",
      "Work was a little overwhelming, but manageable.",
      "Took a walk and that helped clear my mind.",
      "A little anxious, but still able to focus.",
      "Had a calm and steady day.",
      null,
      null,
    ];

    entries.push({
      userId: USER_ID,
      mood,
      stress,
      energy,
      sleep,
      socialConnection,
      note: pick(notes) || undefined,
      date,
    });
  }

  return entries;
}

function buildJournalEntries() {
  const samples = [
    { text: "Today felt busy from the moment I woke up, but I stayed on track and got through it.", sentiment: "neutral", emotion: "Busy", summary: "A busy but manageable day." },
    { text: "I had a stressful morning, but taking a break in the afternoon really helped.", sentiment: "neutral", emotion: "Stressed", summary: "A stressful morning improved after a break." },
    { text: "Had a nice conversation with someone close to me, and it lifted my mood a lot.", sentiment: "positive", emotion: "Happy", summary: "A good conversation improved their mood." },
    { text: "Nothing special happened today, but I feel okay and stable.", sentiment: "neutral", emotion: "Calm", summary: "A simple, steady day." },
    { text: "I felt tired most of the day, probably because I did not sleep well last night.", sentiment: "negative", emotion: "Tired", summary: "Poor sleep made the day feel heavy." },
    { text: "Finished something important today, and I feel proud of myself.", sentiment: "positive", emotion: "Proud", summary: "Completed an important task and felt accomplished." },
    { text: "Spent some quiet time alone and used it to think clearly.", sentiment: "neutral", emotion: "Reflective", summary: "A quiet reflective moment helped them reset." },
    { text: "I was anxious about what might happen tomorrow, but I tried to stay calm.", sentiment: "negative", emotion: "Anxious", summary: "Worry about tomorrow created tension." },
    { text: "Family time made the whole day feel warmer and more peaceful.", sentiment: "positive", emotion: "Content", summary: "Family time brought comfort." },
    { text: "I kept procrastinating at first, but eventually I pushed myself to finish my work.", sentiment: "neutral", emotion: "Motivated", summary: "Late productivity helped finish the day well." },
    { text: "A short walk outside made a bigger difference than I expected.", sentiment: "positive", emotion: "Calm", summary: "Going outside improved their mood." },
    { text: "I felt a little down today, but I know it will pass.", sentiment: "negative", emotion: "Low", summary: "A low mood, but temporary." },
    { text: "I had a productive morning and that gave me momentum for the rest of the day.", sentiment: "positive", emotion: "Motivated", summary: "A productive start led to a better day." },
    { text: "There was some pressure today, but I handled it better than I expected.", sentiment: "neutral", emotion: "Resilient", summary: "Handled pressure with more confidence." },
    { text: "I felt overwhelmed by everything for a while, then I slowed down and regrouped.", sentiment: "negative", emotion: "Overwhelmed", summary: "Overwhelm eased after pausing and regrouping." },
    { text: "Talking to a friend reminded me that things are not as bad as they seem.", sentiment: "positive", emotion: "Relieved", summary: "A supportive conversation brought relief." },
    { text: "I kept my routine simple today, and that actually felt comforting.", sentiment: "neutral", emotion: "Neutral", summary: "A simple routine felt grounding." },
    { text: "I felt better after eating properly and resting a little.", sentiment: "positive", emotion: "Better", summary: "Basic self-care improved their mood." },
    { text: "I had trouble focusing, but I still made progress.", sentiment: "neutral", emotion: "Frustrated", summary: "Focus was difficult, but some progress was made." },
    { text: "Today ended on a good note, which made the whole day feel lighter.", sentiment: "positive", emotion: "Happy", summary: "A positive ending improved the whole day." },
  ];

  const entries = [];
  for (let i = DAYS_BACK; i >= 0; i -= 2) {
    const date = new Date();
    date.setDate(date.getDate() - i);
    date.setHours(randInt(18, 23), randInt(0, 59), 0, 0);

    const sample = pick(samples);
    entries.push({
      userId: USER_ID,
      text: sample.text,
      sentiment: sample.sentiment,
      emotion: sample.emotion,
      summary: sample.summary,
      date,
    });
  }

  return entries;
}

function buildAnswers(questionCount, targetScore, protectedIndex = null, protectedValue = 0) {
  const answers = Array(questionCount).fill(0);

  if (protectedIndex !== null) {
    answers[protectedIndex] = protectedValue;
  }

  let remaining = targetScore - protectedValue;
  const availableIndexes = [...Array(questionCount).keys()].filter(
    (index) => index !== protectedIndex
  );

  if (remaining < 0) remaining = 0;

  while (remaining > 0) {
    const index = pick(availableIndexes);
    if (answers[index] < 3) {
      answers[index] += 1;
      remaining -= 1;
    }
  }

  return answers;
}

function buildAssessmentResult(type, score, answers) {
  let level;
  if (type === "phq9") {
    if (score <= 4) level = "minimal";
    else if (score <= 9) level = "mild";
    else if (score <= 14) level = "moderate";
    else if (score <= 19) level = "moderately_severe";
    else level = "severe";
  } else {
    if (score <= 4) level = "minimal";
    else if (score <= 9) level = "mild";
    else if (score <= 14) level = "moderate";
    else level = "severe";
  }

  return {
    level,
    needsSupportPrompt: type === "phq9" && answers[8] > 0,
    considerProfessionalSupport: score >= 10,
  };
}

function buildAssessmentEntries() {
  const phqScores = [2, 4, 6, 8, 10, 12, 14, 16, 18, 21, 19, 17, 15, 13, 11, 9, 7, 5, 3, 1];
  const gadScores = [1, 3, 5, 7, 9, 11, 13, 15, 17, 19, 16, 14, 12, 10, 8, 6, 4, 2, 5, 7];

  const entries = [];

  for (let i = DAYS_BACK; i >= 0; i--) {
    const type = i % 2 === 0 ? "phq9" : "gad7";
    const questionCount = type === "phq9" ? 9 : 7;

    const targetScore = type === "phq9"
      ? phqScores[(DAYS_BACK - i) % phqScores.length]
      : gadScores[(DAYS_BACK - i) % gadScores.length];

    const date = new Date();
    date.setDate(date.getDate() - i);
    date.setHours(randInt(9, 21), randInt(0, 59), 0, 0);

    let answers;
    if (type === "phq9") {
      // Occasionally give the self-harm question (index 8) a small nonzero
      // value so needsSupportPrompt gets exercised in testing too.
      const protectedValue = targetScore >= 15 ? 1 : (Math.random() < 0.15 ? 1 : 0);
      answers = buildAnswers(questionCount, targetScore, 8, protectedValue);
    } else {
      answers = buildAnswers(questionCount, targetScore);
    }

    const computedScore = answers.reduce((sum, value) => sum + value, 0);

    entries.push({
      userId: USER_ID,
      type,
      answers,
      score: computedScore,
      result: buildAssessmentResult(type, computedScore, answers),
      date,
    });
  }

  return entries;
}

async function seed() {
  const uri = process.env.MONGODB_URI;
  if (!uri) {
    console.error("MONGODB_URI is not set. Aborting.");
    process.exit(1);
  }

  await mongoose.connect(uri);
  console.log("Connected to MongoDB.");

  const cutoff = new Date();
  cutoff.setDate(cutoff.getDate() - (DAYS_BACK + 1));

  await MoodEntry.deleteMany({ userId: USER_ID, date: { $gte: cutoff } });
  await JournalEntry.deleteMany({ userId: USER_ID, date: { $gte: cutoff } });
  await Assessment.deleteMany({ userId: USER_ID, date: { $gte: cutoff } });
  console.log("Cleared old test entries for this user.");

  const moodEntries = buildMoodEntries();
  const journalEntries = buildJournalEntries();
  const assessmentEntries = buildAssessmentEntries();

  await MoodEntry.insertMany(moodEntries);
  await JournalEntry.insertMany(journalEntries);
  await Assessment.insertMany(assessmentEntries);

  console.log(`Inserted ${moodEntries.length} mood entries.`);
  console.log(`Inserted ${journalEntries.length} journal entries.`);
  console.log(`Inserted ${assessmentEntries.length} assessment entries.`);

  await mongoose.disconnect();
  console.log("Done.");
}

seed().catch((error) => {
  console.error("Seeding failed:", error);
  process.exit(1);
});