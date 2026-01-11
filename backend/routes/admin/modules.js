const express = require("express");
const router = express.Router();
const pool = require("../../config/db");

router.post("/create", async (req, res) => {
  const { name, level, teacherId } = req.body;
  try {
    if (!name || !level) {
      return res.status(400).json({ message: "Missing name or level" });
    }

    await pool.query("BEGIN");

    const insertModuleQuery = `INSERT INTO modules (name, level) VALUES ($1, $2) RETURNING *`;
    const moduleResult = await pool.query(insertModuleQuery, [name, level]);
    const newModule = moduleResult.rows[0];

    if (teacherId) {
      await pool.query(
        `INSERT INTO teacher_modules (teacher_id, module_id) VALUES ($1, $2)`,
        [teacherId, newModule.id]
      );
    }

    await pool.query("COMMIT");

    return res.status(201).json({
      message: "Module created efficiently and linked to teacher",
      module: newModule,
    });
  } catch (e) {
    await pool.query("ROLLBACK");
    console.error(e);
    res.status(500).json({ message: e.message });
  }
});
router.get("/all", async (req, res) => {
  try {
    const queryText = `
      SELECT modules.id as module_id, modules.name, modules.level, u.username, u.username as teacher_name, u.id as teacher_id
      FROM modules 
      JOIN teacher_modules tm ON modules.id = tm.module_id 
      JOIN users u ON tm.teacher_id = u.id 
      WHERE u.id_role = 2 AND u.is_accept = true 
      ORDER BY modules.name ASC
    `;
    const result = await pool.query(queryText);
    return res.status(200).json({
      message: "Modules fetched successfully",
      modules: result.rows,
    });
  } catch (e) {
    console.log(e);
    res.status(500).json({ message: e.message });
  }
});
router.delete("/delete/:id", async (req, res) => {
  const { id } = req.params;
  try {
    await pool.query("BEGIN");

    await pool.query("DELETE FROM teacher_modules WHERE module_id = $1", [id]);
    const result = await pool.query(
      "DELETE FROM modules WHERE id = $1 RETURNING *",
      [id]
    );

    if (result.rowCount === 0) {
      await pool.query("ROLLBACK");
      return res.status(404).json({ message: "Module not found" });
    }

    await pool.query("COMMIT");
    res.json({ message: "Module deleted successfully" });
  } catch (err) {
    await pool.query("ROLLBACK");
    console.error(err);
    res.status(500).json({ error: "Failed to delete module" });
  }
});

module.exports = router;
