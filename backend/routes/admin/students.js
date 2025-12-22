const express = require("express");
const router = express.Router();
const pool = require("../../config/db");


router.get("/", async (req, res) => {
    try {
        const queryText = `
            SELECT u.id, u.username, u.email, sg.group_id, g.name as group_name 
            FROM users u
            LEFT JOIN student_groups sg ON u.id = sg.student_id
            LEFT JOIN groups g ON sg.group_id = g.id
            WHERE u.id_role = 3 AND u.is_accept = true
            ORDER BY u.username ASC
        `;
        const result = await pool.query(queryText);

        return res.status(200).json({
            message: "success",
            students: result.rows,
        });
    } catch (err) {
        console.error(" Database error:", err.message);
        return res.status(500).json({ message: "Database error" });
    }
});


router.post("/assign", async (req, res) => {
    try {
        const { student_id, group_id } = req.body;

        if (!student_id) {
            return res.status(400).json({ message: "Student ID is required" });
        }
        if (!group_id) {
            return res.status(400).json({ message: "Group ID is required" });
        }

        const queryText = `insert into student_groups (group_id, student_id) values ($1, $2) `;
        const result = await pool.query(queryText, [group_id, student_id]);

        if (result.rowCount === 0) {
            return res.status(404).json({ message: "Student not found" });
        }

        return res.status(200).json({ message: "Student assigned successfully" });
    } catch (err) {
        console.error(" Database error:", err.message);
        return res.status(500).json({ message: "Database error" });
    }
});
router.delete("/delete/:studentId", async (req, res) => {
  try {
    const { studentId } = req.params;

    const result = await pool.query(
      "DELETE FROM student_groups WHERE student_id = $1",
      [studentId]
    );

    if (result.rowCount === 0) {
      return res.status(404).json({ message: "Student not found" });
    }

    return res.status(200).json({ message: "Student deleted successfully" });
  } catch (error) {
    console.error(error.message);
    return res.status(500).json({ message: "Database error" });
  }
});



module.exports = router;
