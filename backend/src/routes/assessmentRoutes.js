const express = require("express");

const authenticateUser = require("../middleware/authMiddleware");
const {
  getAssessmentTypes,
  submitAssessment,
  getAssessmentHistory,
} = require("../controllers/assessmentController");

const router = express.Router();

router.get("/", authenticateUser, getAssessmentTypes);
router.post("/submit", authenticateUser, submitAssessment);
router.get("/history", authenticateUser, getAssessmentHistory);

module.exports = router;