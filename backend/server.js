const express = require("express");
const cors = require("cors");
require("dotenv").config();

const connectDB = require("./src/config/db");
const authRoutes = require("./src/routes/authRoutes");

const app = express();

app.use(cors());
app.use(express.json());

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