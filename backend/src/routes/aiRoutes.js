const express = require("express");

const authenticateUser = require("../middleware/authMiddleware");
const {
  chatWithAi,
  analyzeJournal,
  getWeeklyInsight,
} = require("../controllers/aiController");

const router = express.Router();

router.post("/chat", authenticateUser, chatWithAi);
router.post("/journal-analysis", authenticateUser, analyzeJournal);
router.get("/weekly-insight", authenticateUser, getWeeklyInsight);

module.exports = router;