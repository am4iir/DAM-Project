const express = require("express");
const router = express.Router();
const pool = require("../../config/db");

router.post("/create", async (req, res) => {
    const { name, level } = req.body;
    try {
        if (!name || !level) {
            return res.status(400).json({ message: "Missing name or level" });
        }
        const listlevel = ["L1", "L2", "L3", "M1", "M5", "G1", "G2", "G3", "G4", "G5"];
        if (!listlevel.includes(level)) {
            return res.status(400).json({
                message: "Level must be one of: L1, L2, L3, M1, M5, G1, G2, G3, G4, G5",
            });
        }
        const queryText = `INSERT INTO modules (name, level) VALUES ($1, $2) RETURNING *`;
        const result = await pool.query(queryText, [name, level]);

        return res.status(201).json({
            message: "Module created successfully",
            module: result.rows[0],
        });

    } catch (e) {
        console.log(e);
        res.status(500).json({ message: e.message });
    }
});
router.get("/all", async (req, res) => {
    try {
        const queryText = `SELECT * from modules`;
        const result = await pool.query(queryText);
        return res.status(200).json({
            message: "Modules fetched successfully",
            modules: result.rows,
        });

    } catch (e) {
        console.log(e);
        res.status(500).json({ message: e.message });
    }
})

module.exports = router;