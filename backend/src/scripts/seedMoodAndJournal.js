require("dotenv").config();
const mongoose = require("mongoose");
const MoodEntry = require("../models/MoodEntry");
const JournalEntry = require("../models/JournalEntry");

const USER_ID = "IWgIlJfWKFNCjxbBlKYxpS0Goi43"; // mim@gmail.com

const DAYS_BACK = 45; // covers weekly (last 7 days) + gives history to browse

const clamp = (value, min, max) => Math.min(max, Math.max(min, value));
const randInt = (min, max) => Math.floor(Math.random() * (max - min + 1)) + min;

function buildMoodEntries() {
  const entries = [];
  for (let i = DAYS_BACK; i >= 0; i--) {
    const date = new Date();
    date.setHours(randInt(8, 21), randInt(0, 59), 0, 0);
    date.setDate(date.getDate() - i);

    // Gentle wave so the chart isn't flat, plus daily noise
    const wave = Math.sin(i / 4) * 1.2;
    const mood = clamp(Math.round(3 + wave + randInt(-1, 1)), 1, 5);
    const stress = clamp(Math.round(3 - wave * 0.7 + randInt(-1, 1)), 1, 5);
    const energy = clamp(Math.round(55 + wave * 10 + randInt(-10, 10)), 0, 100);
    const sleep = clamp(Number((6.5 + wave * 0.5 + (Math.random() - 0.5)).toFixed(1)), 3, 10);
    const socialConnection = clamp(randInt(1, 4), 1, 4);

    const notes = [
      "Felt okay today, a bit tired.",
      "Good day, got some work done.",
      "Stressful morning but calmed down later.",
      "Slept well, felt more energetic.",
      "Quiet day, nothing much happened.",
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
      note: notes[randInt(0, notes.length - 1)] || undefined,
      date,
    });
  }
  return entries;
}

function buildJournalEntries() {
  const samples = [
    { text: "Today was pretty overwhelming with deadlines, but I managed to finish most of my tasks.", sentiment: "negative", emotion: "Stressed", summary: "Felt overwhelmed by deadlines but pushed through." },
    { text: "Had a really nice walk in the evening, cleared my head a lot.", sentiment: "positive", emotion: "Calm", summary: "An evening walk helped clear their mind." },
    { text: "Nothing special happened today, just a normal routine day.", sentiment: "neutral", emotion: "Neutral", summary: "A routine, uneventful day." },
    { text: "Talked to an old friend today, it really lifted my mood.", sentiment: "positive", emotion: "Happy", summary: "Reconnecting with a friend improved their mood." },
    { text: "Couldn't sleep well last night, feeling drained and unfocused today.", sentiment: "negative", emotion: "Tired", summary: "Poor sleep led to feeling drained and unfocused." },
    { text: "Finished a big assignment, feeling accomplished.", sentiment: "positive", emotion: "Proud", summary: "Completing a big task brought a sense of accomplishment." },
    { text: "Family dinner tonight, felt supported and relaxed.", sentiment: "positive", emotion: "Content", summary: "A family dinner brought comfort and relaxation." },
    { text: "Felt anxious about an upcoming exam, hard to focus on anything else.", sentiment: "negative", emotion: "Anxious", summary: "Anxiety about an exam made it hard to focus." },
    { text: "Spent the day mostly alone, felt a bit low but okay overall.", sentiment: "neutral", emotion: "Reflective", summary: "A quiet, mostly solitary day with a low but stable mood." },
    { text: "Productive day at university, group project is coming together nicely.", sentiment: "positive", emotion: "Motivated", summary: "Progress on a group project felt motivating." },
  ];

  const entries = [];
  for (let i = DAYS_BACK; i >= 0; i -= 3) {
    const date = new Date();
    date.setHours(randInt(18, 23), randInt(0, 59), 0, 0);
    date.setDate(date.getDate() - i);
    const sample = samples[randInt(0, samples.length - 1)];
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

  // Wipe previous test data for this user in the seeded window, so reruns don't duplicate.
  await MoodEntry.deleteMany({ userId: USER_ID, date: { $gte: cutoff } });
  await JournalEntry.deleteMany({ userId: USER_ID, date: { $gte: cutoff } });
  console.log("Cleared old test entries for this user.");

  const moodEntries = buildMoodEntries();
  const journalEntries = buildJournalEntries();

  await MoodEntry.insertMany(moodEntries);
  await JournalEntry.insertMany(journalEntries);

  console.log(`Inserted ${moodEntries.length} mood entries.`);
  console.log(`Inserted ${journalEntries.length} journal entries.`);

  await mongoose.disconnect();
  console.log("Done.");
}

seed().catch((error) => {
  console.error("Seeding failed:", error);
  process.exit(1);
});