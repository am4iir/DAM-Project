const pool = require('../config/db');

async function initTimetable() {
    const createTableQuery = `
    CREATE TABLE IF NOT EXISTS timetable (
      id SERIAL PRIMARY KEY,
      group_id INT NOT NULL,
      subject VARCHAR(100) NOT NULL,
      teacher VARCHAR(100),
      day VARCHAR(20) NOT NULL,
      time VARCHAR(50) NOT NULL,
      type VARCHAR(50),
      room VARCHAR(50)
    );
  `;

    try {
        await pool.query(createTableQuery);
        console.log("✅ Timetable table created or already exists.");
    } catch (err) {
        console.error("❌ Error creating timetable table:", err);
    } finally {
        process.exit();
    }
}

initTimetable();
