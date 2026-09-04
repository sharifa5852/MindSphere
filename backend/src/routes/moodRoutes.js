// const express = require("express");

// const authenticateUser = require("../middleware/authMiddleware");
// const {
//   createMoodEntry,
//   getMoodEntries,
//   getWeeklyMoodSummary,
// } = require("../controllers/moodController");

// const router = express.Router();

// router.post("/", authenticateUser, createMoodEntry);
// router.get("/", authenticateUser, getMoodEntries);
// router.get("/weekly", authenticateUser, getWeeklyMoodSummary);

// module.exports = router;

const express = require("express");

const authenticateUser = require("../middleware/authMiddleware");
const {
  createMoodEntry,
  getMoodEntries,
  getWeeklyMoodSummary,
  analyzeMoodEntry,
} = require("../controllers/moodController");

const router = express.Router();

router.post("/", authenticateUser, createMoodEntry);
router.get("/", authenticateUser, getMoodEntries);
router.get("/weekly", authenticateUser, getWeeklyMoodSummary);
router.post("/:id/analyze", authenticateUser, analyzeMoodEntry);

module.exports = router;