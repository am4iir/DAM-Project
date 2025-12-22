const express = require("express");
const router = express.Router();
const pool = require("../../config/db");

// Get all groups
router.get("/", async (req, res) => {
    try {
        const queryText = `SELECT * FROM groups ORDER BY created_at DESC`;
        const result = await pool.query(queryText);

        return res.status(200).json({
            message: "success",
            groups: result.rows,
        });
    } catch (err) {
        console.error(" Database error:", err.message);
        return res.status(500).json({ message: "Database error" });
    }
});

// Create a group
router.post("/", async (req, res) => {
    try {
        const { name, level, max_students } = req.body;

        if (!name || !level || !max_students) {
            return res.status(400).json({ message: "All fields are required" });
        }

        console.log(" Creating group:", { name, level, max_students });
        const queryText = `INSERT INTO groups (name, level, max_students) VALUES ($1, $2, $3) RETURNING *`;
        const result = await pool.query(queryText, [name, level, max_students]);
        console.log(" Group created:", result.rows[0]);

        return res.status(201).json({
            message: "Group created successfully",
            group: result.rows[0],
        });
    } catch (err) {
        console.error(" Database error:", err.message);
        return res.status(500).json({ message: "Database error" });
    }
});

// Delete a group
router.delete("/:id", async (req, res) => {
    try {
        const { id } = req.params;

        const queryText = `DELETE FROM groups WHERE id = $1`;
        const result = await pool.query(queryText, [id]);

        if (result.rowCount === 0) {
            return res.status(404).json({ message: "Group not found" });
        }

        return res.status(200).json({ message: "Group deleted successfully" });
    } catch (err) {
        console.error(" Database error:", err.message);
        return res.status(500).json({ message: "Database error" });
    }
});


router.get("/:id/students", async (req, res) => {
    try {
        const { id } = req.params;
        const queryText = `
            SELECT  users.id,users.username, users.email 
           FROM users
           JOIN student_groups
           ON users.id = student_groups.student_id
            WHERE  student_groups.group_id = $1 AND id_role = 3 AND is_accept = true
            ORDER BY username ASC
        `;
        const result = await pool.query(queryText, [id]);

        return res.status(200).json({
            message: "success",
            students: result.rows,
        });
    } catch (err) {
        console.error(" Database error:", err.message);
        return res.status(500).json({ message: "Database error" });
    }
});
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
