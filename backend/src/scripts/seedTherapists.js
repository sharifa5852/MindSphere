/**
 * Seed script — PLACEHOLDER therapist data only.
 *
 * These are NOT real people. Every entry is marked `verified: false`
 * so the frontend can flag them and avoid presenting fake contact info
 * as something a user should actually reach out to.
 *
 * Usage:
 *   node backend/src/scripts/seedTherapists.js
 *
 * Requires MONGODB_URI in your .env (same as the rest of the backend).
 * Safe to re-run: it wipes only documents with `seedSource: "placeholder-v1"`
 * before inserting, so it won't touch real therapist records you add later.
 */
require("dotenv").config();
const mongoose = require("mongoose");
const Therapist = require("../models/Therapist");

const PLACEHOLDER_THERAPISTS = [
  { name: "Dr. Farhana Rahman", specialization: ["anxiety", "stress", "general wellness"], experienceYears: 9, rating: 4.7, reviewCount: 12, availability: "available", location: "Dhaka", languages: ["Bengali", "English"], bio: "Focuses on anxiety and everyday stress management using CBT-based techniques." },
  { name: "Dr. Imran Kabir", specialization: ["depression", "mood", "stress"], experienceYears: 14, rating: 4.8, reviewCount: 34, availability: "limited", location: "Dhaka", languages: ["Bengali", "English"], bio: "Works primarily with mood disorders and long-term depressive episodes." },
  { name: "Dr. Nusrat Jahan", specialization: ["anxiety", "sleep", "stress"], experienceYears: 6, rating: 4.5, reviewCount: 8, availability: "available", location: "Chattogram", languages: ["Bengali"], bio: "Specializes in sleep-related anxiety and stress reduction for young adults." },
  { name: "Dr. Mahfuzur Rahman", specialization: ["depression", "anxiety"], experienceYears: 11, rating: 4.6, reviewCount: 21, availability: "available", location: "Chattogram", languages: ["Bengali", "English"], bio: "General mental wellness practice with a focus on co-occurring depression and anxiety." },
  { name: "Dr. Sabrina Alam", specialization: ["stress", "social connection", "general wellness"], experienceYears: 5, rating: 4.4, reviewCount: 6, availability: "available", location: "Sylhet", languages: ["Bengali", "English"], bio: "Works with clients navigating stress from work, family, and social relationships." },
  { name: "Dr. Tanvir Ahmed", specialization: ["mood", "depression", "stress"], experienceYears: 17, rating: 4.9, reviewCount: 41, availability: "limited", location: "Dhaka", languages: ["Bengali", "English", "Hindi"], bio: "Senior practitioner with a long-running practice in mood disorder management." },
  { name: "Dr. Ruksana Begum", specialization: ["anxiety", "social connection"], experienceYears: 8, rating: 4.5, reviewCount: 15, availability: "available", location: "Khulna", languages: ["Bengali"], bio: "Supports clients working through social anxiety and isolation." },
  { name: "Dr. Shafiqul Islam", specialization: ["depression", "stress", "sleep"], experienceYears: 10, rating: 4.6, reviewCount: 19, availability: "available", location: "Rajshahi", languages: ["Bengali", "English"], bio: "Integrates sleep hygiene coaching into depression and stress treatment plans." },
  { name: "Dr. Afsana Karim", specialization: ["anxiety", "mood"], experienceYears: 7, rating: 4.5, reviewCount: 10, availability: "available", location: "Dhaka", languages: ["Bengali", "English"], bio: "Works with young professionals experiencing anxiety and mood fluctuations." },
  { name: "Dr. Kamrul Hasan", specialization: ["stress", "general wellness"], experienceYears: 13, rating: 4.7, reviewCount: 27, availability: "limited", location: "Dhaka", languages: ["Bengali", "English"], bio: "Broad wellness practice with an emphasis on stress and burnout recovery." },
  { name: "Dr. Farzana Yasmin", specialization: ["depression", "social connection"], experienceYears: 9, rating: 4.6, reviewCount: 17, availability: "available", location: "Barishal", languages: ["Bengali"], bio: "Focuses on depression linked to social isolation and life transitions." },
  { name: "Dr. Rakibul Islam", specialization: ["anxiety", "stress", "sleep"], experienceYears: 6, rating: 4.3, reviewCount: 9, availability: "available", location: "Sylhet", languages: ["Bengali", "English"], bio: "Works with students and young adults on exam-related stress and anxiety." },
  { name: "Dr. Sharmin Sultana", specialization: ["mood", "depression"], experienceYears: 15, rating: 4.8, reviewCount: 38, availability: "unavailable", location: "Dhaka", languages: ["Bengali", "English"], bio: "Long-standing practice focused on mood regulation and depressive disorders." },
  { name: "Dr. Ehsanul Kabir", specialization: ["stress", "anxiety"], experienceYears: 4, rating: 4.2, reviewCount: 5, availability: "available", location: "Chattogram", languages: ["Bengali"], bio: "Early-career practitioner focused on workplace stress and anxiety." },
  { name: "Dr. Nasrin Akter", specialization: ["general wellness", "social connection"], experienceYears: 12, rating: 4.6, reviewCount: 22, availability: "available", location: "Dhaka", languages: ["Bengali", "English"], bio: "Holistic wellness approach combining lifestyle coaching with talk therapy." },
  { name: "Dr. Zahidul Islam", specialization: ["depression", "stress"], experienceYears: 10, rating: 4.5, reviewCount: 18, availability: "limited", location: "Rangpur", languages: ["Bengali"], bio: "Community mental-health focus, primarily depression and chronic stress." },
  { name: "Dr. Tahmina Haque", specialization: ["anxiety", "mood", "sleep"], experienceYears: 8, rating: 4.6, reviewCount: 13, availability: "available", location: "Dhaka", languages: ["Bengali", "English"], bio: "Works on the overlap between sleep disruption, anxiety, and mood." },
  { name: "Dr. Golam Mostofa", specialization: ["stress", "general wellness"], experienceYears: 20, rating: 4.9, reviewCount: 52, availability: "limited", location: "Dhaka", languages: ["Bengali", "English"], bio: "Veteran counselor with two decades of general wellness practice." },
  { name: "Dr. Israt Jahan", specialization: ["anxiety", "social connection"], experienceYears: 5, rating: 4.3, reviewCount: 7, availability: "available", location: "Cumilla", languages: ["Bengali"], bio: "Focuses on social anxiety in younger clients and university students." },
  { name: "Dr. Mizanur Rahman", specialization: ["depression", "mood", "general wellness"], experienceYears: 16, rating: 4.7, reviewCount: 30, availability: "available", location: "Dhaka", languages: ["Bengali", "English"], bio: "Combines mood-tracking methods with traditional talk therapy." },
  { name: "Dr. Halima Khatun", specialization: ["stress", "sleep"], experienceYears: 7, rating: 4.4, reviewCount: 11, availability: "available", location: "Chattogram", languages: ["Bengali"], bio: "Practical, short-term stress and sleep counseling." },
  { name: "Dr. Anisur Rahman", specialization: ["anxiety", "depression"], experienceYears: 11, rating: 4.6, reviewCount: 20, availability: "limited", location: "Sylhet", languages: ["Bengali", "English"], bio: "Balanced practice addressing co-occurring anxiety and depression." },
  { name: "Dr. Rubina Yesmin", specialization: ["mood", "social connection"], experienceYears: 6, rating: 4.3, reviewCount: 8, availability: "available", location: "Khulna", languages: ["Bengali"], bio: "Works with clients rebuilding social routines after mood episodes." },
  { name: "Dr. Jahangir Alam", specialization: ["stress", "anxiety", "general wellness"], experienceYears: 9, rating: 4.5, reviewCount: 14, availability: "available", location: "Dhaka", languages: ["Bengali", "English"], bio: "General practice serving working professionals with chronic stress." },
  { name: "Dr. Shirin Sultana", specialization: ["depression", "sleep"], experienceYears: 13, rating: 4.7, reviewCount: 25, availability: "available", location: "Dhaka", languages: ["Bengali", "English"], bio: "Depression treatment with an emphasis on sleep-cycle stabilization." },
  { name: "Dr. Abu Hanif", specialization: ["anxiety", "stress"], experienceYears: 3, rating: 4.1, reviewCount: 4, availability: "available", location: "Barishal", languages: ["Bengali"], bio: "Newer practitioner focused on accessible, short-session stress support." },
  { name: "Dr. Mahmuda Sultana", specialization: ["mood", "depression", "anxiety"], experienceYears: 18, rating: 4.8, reviewCount: 45, availability: "limited", location: "Dhaka", languages: ["Bengali", "English", "Hindi"], bio: "Experienced practitioner treating complex, overlapping mood and anxiety cases." },
  { name: "Dr. Sohel Rana", specialization: ["stress", "general wellness"], experienceYears: 5, rating: 4.2, reviewCount: 6, availability: "available", location: "Rajshahi", languages: ["Bengali"], bio: "Focus on stress management for small-business owners and workers." },
  { name: "Dr. Nazia Ferdous", specialization: ["anxiety", "social connection", "sleep"], experienceYears: 8, rating: 4.5, reviewCount: 12, availability: "available", location: "Dhaka", languages: ["Bengali", "English"], bio: "Works with clients on social withdrawal linked to anxiety and poor sleep." },
  { name: "Dr. Belal Hossain", specialization: ["depression", "stress", "mood"], experienceYears: 12, rating: 4.6, reviewCount: 23, availability: "available", location: "Chattogram", languages: ["Bengali", "English"], bio: "General mood and stress counseling with a client-centered approach." },
];

async function seed() {
  const uri = process.env.MONGODB_URI;
  if (!uri) {
    console.error("MONGODB_URI is not set. Aborting.");
    process.exit(1);
  }

  await mongoose.connect(uri);
  console.log("Connected to MongoDB.");

  await Therapist.deleteMany({ seedSource: "placeholder-v2" });

  const docs = PLACEHOLDER_THERAPISTS.map((t) => ({
    ...t,
    profileImageUrl: null,
    isActive: true,
    seedSource: "placeholder-v2",
  }));

  const inserted = await Therapist.insertMany(docs);
  console.log(`Inserted ${inserted.length} therapist record(s).`);

  await mongoose.disconnect();
}

seed().catch((error) => {
  console.error("Seeding failed:", error);
  process.exit(1);
});