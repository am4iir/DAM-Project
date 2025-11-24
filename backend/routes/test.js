const express = require('express');
const router = express.Router();
const pool = require('../config/db');

 router.get("/users", async (req, res) => {
  try {
    const result = await pool.query("SELECT id, username, email, created_at, role  FROM users");
    res.status(200).json({
      success: true,
      count: result.rowCount,
      users: result.rows
    });
  } catch (err) {
    console.error(" Database error:", err.message);
    res.status(500).json({ success: false, message: "Failed to fetch users" });
  }
});

module.exports = router;


