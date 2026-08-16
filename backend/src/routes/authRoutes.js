const express = require("express");
const {
  syncUser,
  getCurrentUser,
} = require("../controllers/authController");
const authenticateUser = require("../middleware/authMiddleware");

const router = express.Router();

router.post("/sync", authenticateUser, syncUser);
router.get("/me", authenticateUser, getCurrentUser);

module.exports = router;