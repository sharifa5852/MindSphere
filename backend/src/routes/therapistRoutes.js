const express = require("express");

const authenticateUser = require("../middleware/authMiddleware");
const {
  getTherapists,
  getTherapistById,
  getRecommendedTherapists,
} = require("../controllers/therapistController");

const router = express.Router();

router.get("/", authenticateUser, getTherapists);
router.get("/recommended", authenticateUser, getRecommendedTherapists);
router.get("/:id", authenticateUser, getTherapistById);

module.exports = router;