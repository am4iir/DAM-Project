const express = require("express");
const router = express.Router();
const pool = require("../../config/db");

router.get("/", async (req, res) => {
  try {
    const queryText = `
            SELECT u.id, u.username, u.email, u.id_role, r.role_name,
                   (
                       SELECT json_agg(json_build_object('id', g.id, 'name', g.name))
                       FROM groups g
                       WHERE g.id IN (
                           SELECT group_id FROM student_groups WHERE student_id = u.id
                           UNION
                           SELECT group_id FROM teacher_groups WHERE teacher_id = u.id
                       )
                   ) as assigned_groups
            FROM users u
            LEFT JOIN roles r ON u.id_role = r.id_role
            WHERE u.id_role != 1 AND u.is_accept = true
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

router.post("/assign-student", async (req, res) => {
  try {
    const { student_id, group_id } = req.body;

    if (!student_id) {
      return res.status(400).json({ message: "Student ID is required" });
    }

    if (!group_id) {
      await pool.query("DELETE FROM student_groups WHERE student_id = $1", [
        student_id,
      ]);
      return res.status(200).json({ message: "Student unassigned" });
    }

    await pool.query(
      `
      INSERT INTO student_groups (student_id, group_id)
      VALUES ($1, $2)
      ON CONFLICT (student_id)
      DO UPDATE SET group_id = EXCLUDED.group_id
      `,
      [student_id, group_id]
    );

    return res.status(200).json({ message: "Student assigned successfully" });
  } catch (err) {
    console.error(err.message);
    return res.status(500).json({ message: "Database error" });
  }
});

router.post("/assign-teacher", async (req, res) => {
  try {
    const { teacher_id, group_id } = req.body;

    if (!teacher_id) {
      return res.status(400).json({ message: "Teacher ID is required" });
    }

    if (!group_id) {
      await pool.query("DELETE FROM teacher_groups WHERE teacher_id = $1", [
        teacher_id,
      ]);
      return res
        .status(200)
        .json({ message: "Teacher unassigned from all groups" });
    }

    const checkResult = await pool.query(
      "SELECT * FROM teacher_groups WHERE teacher_id = $1 AND group_id = $2",
      [teacher_id, group_id]
    );

    if (checkResult.rowCount > 0) {
      await pool.query(
        "DELETE FROM teacher_groups WHERE teacher_id = $1 AND group_id = $2",
        [teacher_id, group_id]
      );
      return res.status(200).json({ message: "Group removed from teacher" });
    } else {
      await pool.query(
        "INSERT INTO teacher_groups (teacher_id, group_id) VALUES ($1, $2)",
        [teacher_id, group_id]
      );
      return res.status(200).json({ message: "Group added to teacher" });
    }
  } catch (err) {
    console.error("Database error:", err.message);
    return res.status(500).json({ message: "Database error" });
  }
});

router.delete("/delete/:userId", async (req, res) => {
  try {
    const { userId } = req.params;

    const studentResult = await pool.query(
      "DELETE FROM student_groups WHERE student_id = $1",
      [userId]
    );
    const teacherResult = await pool.query(
      "DELETE FROM teacher_groups WHERE teacher_id = $1",
      [userId]
    );

    if (studentResult.rowCount === 0 && teacherResult.rowCount === 0) {
      return res.status(404).json({ message: "User association not found" });
    }

    return res.status(200).json({ message: "User unassigned successfully" });
  } catch (error) {
    console.error(error.message);
    return res.status(500).json({ message: "Database error" });
  }
});
router.get("/all_teacher", async (req, res) => {
  try {
    const queryText = `
        SELECT u.id, u.username, u.email, r.role_name,
               (
                   SELECT json_agg(json_build_object('id', g.id, 'name', g.name))
                   FROM groups g
                   JOIN teacher_groups tg ON g.id = tg.group_id
                   WHERE tg.teacher_id = u.id
               ) as assigned_groups
        FROM users u
        LEFT JOIN roles r ON u.id_role = r.id_role
        WHERE u.id_role = 2
        ORDER BY u.username ASC
    `;
    const result = await pool.query(queryText);
    return res.status(200).json({
      message: "success",
      teachers: result.rows,
    });
  } catch (error) {
    console.error("Database error:", error.message);
    return res.status(500).json({ message: "Database error" });
  }
});

module.exports = router;
