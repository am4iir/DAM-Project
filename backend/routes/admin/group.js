const express = require("express");
require("dotenv").config();
const router = express.Router();
const pool = require("../../config/db");



router.get("/number-group", async (req, res) => {
    try {
        
        const result = await pool.query(`SELECT count(*) FROM groups`);
        
        return res.status(200).json({
            totalGroups: result.rows[0].count,
        });

    } catch (error) {
        console.error("❌ Database error:", error.message);
        return res.status(500).json({ message: "Database error" });
    }
});
router.get("/numberUsers", async (req, res) => {
  try {
    const query = `
      SELECT
        COUNT(*) FILTER (WHERE id_role = 3) AS total_users
      FROM users
    `;

    const result = await pool.query(query);

    return res.status(200).json({
      numberOfUsers: result.rows[0].total_users,
    });

  } catch (error) {
    console.error("❌ Database error:", error);
    return res.status(500).json({ message: error.message });
  }
});
router.get("/numberUsersPending", async (req, res) => {
    try {
      const query = `
        SELECT
          COUNT(*) FILTER (WHERE is_accept = false and id_role = 3) AS total_users
        FROM users
      `;

      const result = await pool.query(query);

      return res.status(200).json({
        numberOfUsersPending: result.rows[0].total_users,
      });

    } catch (error) {
      console.error("❌ Database error:", error);
      return res.status(500).json({ message: error.message });
    }
  });
router.get("/numberUsersApproved", async (req, res) => {
    try {
      const query = `
        SELECT
          COUNT(*) FILTER (WHERE is_accept = true and id_role = 3) AS total_users
        FROM users
      `;

      const result = await pool.query(query);

      return res.status(200).json({
        numberOfUsersApproved: result.rows[0].total_users,
      });

    } catch (error) {
      console.error("❌ Database error:", error);
      return res.status(500).json({ message: error.message });
    }
  });

module.exports = router;
