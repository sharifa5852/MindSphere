const express = require("express");
const cors = require("cors");
require("dotenv").config();

const connectDB = require("./src/config/db");
const authRoutes = require("./src/routes/authRoutes");

const app = express();

const allowedOrigins = process.env.CORS_ORIGINS
  ? process.env.CORS_ORIGINS.split(",").map((origin) => origin.trim())
  : null;

app.use(cors({ origin: allowedOrigins || true }));
app.use(express.json({ limit: "1mb" }));

app.use("/api/auth", authRoutes);

app.get("/api/health", (req, res) => {
  res.json({
    success: true,
    message: "MindSphere API is running",
  });
});

const PORT = process.env.PORT || 5000;

const startServer = async () => {
  await connectDB();

  app.listen(PORT, () => {
    console.log(`MindSphere backend running on port ${PORT}`);
  });
};
const moodRoutes = require("./src/routes/moodRoutes");
app.use("/api/moods", moodRoutes);

const journalRoutes = require("./src/routes/journalRoutes");
app.use("/api/journals", journalRoutes);

const assessmentRoutes = require("./src/routes/assessmentRoutes");
app.use("/api/assessments", assessmentRoutes);

const therapistRoutes = require("./src/routes/therapistRoutes");
app.use("/api/therapists", therapistRoutes);

const reportRoutes = require("./src/routes/reportRoutes");
app.use("/api/reports", reportRoutes);

const aiRoutes = require("./src/routes/aiRoutes");
app.use("/api/ai", aiRoutes);
startServer();



// temp

const { detectEmotions } = require("./src/services/emotionService");

app.get("/api/test-emotion", async (req, res) => {
  const text = req.query.text;
  if (!text) {
    return res.status(400).json({ success: false, message: "Provide ?text=... in the URL." });
  }
  try {
    const emotions = await detectEmotions(text);
    return res.status(200).json({ success: true, emotions });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});