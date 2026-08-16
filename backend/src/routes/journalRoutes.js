const express = require("express");

const authenticateUser = require("../middleware/authMiddleware");
const {
  createJournalEntry,
  getJournalEntries,
  getJournalEntryById,
  deleteJournalEntry,
} = require("../controllers/journalController");

const router = express.Router();

router.post("/", authenticateUser, createJournalEntry);
router.get("/", authenticateUser, getJournalEntries);
router.get("/:id", authenticateUser, getJournalEntryById);
router.delete("/:id", authenticateUser, deleteJournalEntry);

module.exports = router;