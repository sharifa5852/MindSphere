const express = require("express");

const router = express.Router();

const authenticateUser = require("../middleware/authMiddleware");

const {
  getWeeklyReport,
  getMonthlyReport,
} = require("../controllers/reportController");

// Weekly wellness report
router.get(
  "/weekly",
  authenticateUser,
  getWeeklyReport
);

// Monthly wellness report
router.get(
  "/monthly",
  authenticateUser,
  getMonthlyReport
);

module.exports = router;