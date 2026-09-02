const express = require("express");
const router = express.Router();
const authenticateUser = require("../middleware/authMiddleware");
const {
  syncUser,
  getCurrentUser,
  updateProfile,
} = require("../controllers/authController");


router.post("/sync", authenticateUser, syncUser);
router.get("/me", authenticateUser, getCurrentUser);
router.put("/me", authenticateUser, updateProfile);

module.exports = router;