const express = require("express");
require("dotenv").config();
const router = express.Router();
const pool = require("../../config/db");


router.get("/show_users", async (req, res) => {
  try {
    const queryText = `SELECT * FROM USERS WHERE is_accept = false`;
    const result = await pool.query(queryText);

    return res.status(200).json({
      message: "success",
      users: result.rows,
    });
  } catch (err) {
    console.error(" Database error:", err.message);
    return res.status(500).json({ message: "Database error" });
  }
});




router.post("/accept", async (req, res) => {
  try {
    const { id } = req.body;

    if (!id) {
      return res.status(400).json({ message: "User id is required" });
    }

    const queryText = `UPDATE USERS SET is_accept = true WHERE ID = $1`;
    const result = await pool.query(queryText, [id]);

    if (result.rowCount === 0) {
      return res.status(404).json({ message: "User not found" });
    }

    return res.status(200).json({ message: "User accepted successfully" });
  } catch (err) {
    console.error(" Database error:", err.message);
    return res.status(500).json({ message: "Database error" });
  }
});


router.post("/reject", async (req, res) => {
  try {
    const { id } = req.body;

    if (!id) {
      return res.status(400).json({ message: "User id is required" });
    }

    const queryText = `delete from users WHERE ID = $1`;
    const result = await pool.query(queryText, [id]);

    if (result.rowCount === 0) {
      return res.status(404).json({ message: "User not found" });
    }

    return res.status(200).json({ message: "User rejected successfully" });
  } catch (err) {
    console.error(" Database error:", err.message);
    return res.status(500).json({ message: "Database error" });
  }
});

module.exports = router;
