const express = require("express");
const router = express.Router();
const pool = require("../../config/db");

router.post("/save-timetable", async (req, res) => {
  let { groupId, timetable } = req.body;

  if (!groupId || !timetable) {
    return res
      .status(400)
      .json({ error: "Group ID and timetable data are required" });
  }

  // Ensure groupId is an integer for correct comparison in the conflict check
  const gId = parseInt(groupId);
  if (isNaN(gId)) {
    return res.status(400).json({ error: "Invalid Group ID" });
  }

  try {
    await pool.query("BEGIN");

    // Check for teacher conflicts BEFORE deleting current group's timetable
    const conflictCheckQuery = `
      SELECT t.*, g.name as group_name, u.username as teacher_name
      FROM timetable t
      JOIN groups g ON t.group_id = g.id
      JOIN users u ON t.teacher_id = u.id
      WHERE t.day = $1 AND t.time = $2 AND t.teacher_id = $3 AND t.group_id != $4
    `;

    for (const entry of timetable) {
      if (!entry.teacher_id) continue;
      
      const teacherId = parseInt(entry.teacher_id);
      if (isNaN(teacherId)) continue;

      const conflict = await pool.query(conflictCheckQuery, [
        entry.day,
        entry.time,
        teacherId,
        gId
      ]);
      
      if (conflict.rows.length > 0) {
        const conflictInfo = conflict.rows[0];
        await pool.query("ROLLBACK");
        return res.status(400).json({ 
          error: `Conflict: ${conflictInfo.teacher_name} is already teaching "${conflictInfo.subject}" for ${conflictInfo.group_name} on ${entry.day} at ${entry.time}` 
        });
      }
    }

    // No conflicts, proceed with saving
    await pool.query("DELETE FROM timetable WHERE group_id = $1", [gId]);

    const insertQuery = `
      INSERT INTO timetable (group_id, subject, teacher_id, day, time, type, room) 
      VALUES ($1, $2, $3, $4, $5, $6, $7)
    `;

    for (const entry of timetable) {
      const teacherId = entry.teacher_id ? parseInt(entry.teacher_id) : null;
      await pool.query(insertQuery, [
        gId,
        entry.subject,
        teacherId,
        entry.day,
        entry.time,
        entry.type,
        entry.room || "Room TBD",
      ]);
    }

    await pool.query("COMMIT");
    res.json({ message: "Timetable confirmed and saved successfully!" });
  } catch (err) {
    if (pool.query) await pool.query("ROLLBACK");
    console.error(err);
    res.status(500).json({ error: "Failed to save timetable" });
  }
});

router.get("/check-conflict", async (req, res) => {
  const { teacherId, day, time, groupId } = req.query;

  if (!teacherId || !day || !time) {
    return res.status(400).json({ error: "teacherId, day, and time are required" });
  }

  try {
    const conflictQuery = `
      SELECT t.*, g.name as group_name, u.username as teacher_name
      FROM timetable t
      JOIN groups g ON t.group_id = g.id
      JOIN users u ON t.teacher_id = u.id
      WHERE t.day = $1 AND t.time = $2 AND t.teacher_id = $3 AND t.group_id != $4
    `;
    const gId = groupId ? parseInt(groupId) : -1;
    const result = await pool.query(conflictQuery, [day, time, parseInt(teacherId), gId]);

    if (result.rows.length > 0) {
      const info = result.rows[0];
      return res.status(200).json({
        conflict: true,
        message: `${info.teacher_name} is already teaching "${info.subject}" for ${info.group_name} on ${day} at ${time}`
      });
    }

    res.json({ conflict: false });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Wait... check conflict failed" });
  }
});

router.get("/group/:groupId/teachers", async (req, res) => {
  const { groupId } = req.params;
  try {
    const allTeachersQuery = `
        SELECT id, username, email 
        FROM users 
        WHERE id_role = 2 AND is_accept = true
        ORDER BY username ASC
    `;
    const result = await pool.query(allTeachersQuery);

    res.json({ teachers: result.rows });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Failed to fetch teachers" });
  }
});

router.get("/timetable/:groupId", async (req, res) => {
  const { groupId } = req.params;
  try {
    const query = `
      SELECT t.*, u.username as teacher_name 
      FROM timetable t 
      LEFT JOIN users u ON t.teacher_id = u.id 
      WHERE t.group_id = $1
    `;
    const { rows } = await pool.query(query, [groupId]);
    res.json({ timetable: rows });
  } catch (err) {
    console.error("Error fetching timetable:", err);
    res.status(500).json({ error: "Failed to fetch timetable" });
  }
});

router.get("/timetable/teacher/:teacherId", async (req, res) => {
  const { teacherId } = req.params;
  try {
    const query = `
      SELECT t.*, g.name as group_name
      FROM timetable t
      JOIN groups g ON t.group_id = g.id
      WHERE t.teacher_id = $1
    `;
    const { rows } = await pool.query(query, [teacherId]);
    res.json({ timetable: rows });
  } catch (err) {
    console.error("Error fetching teacher timetable:", err);
    res.status(500).json({ error: "Failed to fetch teacher timetable" });
  }
});

module.exports = router;
