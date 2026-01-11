const pool = require('../config/db');

async function migrateTimetable() {
    const updateTableQuery = `
    DROP TABLE IF EXISTS timetable;
    CREATE TABLE timetable (
      id SERIAL PRIMARY KEY,
      group_id INT REFERENCES groups(id) ON DELETE CASCADE,
      subject VARCHAR(100) NOT NULL,
      teacher_id INT REFERENCES users(id) ON DELETE SET NULL,
      day VARCHAR(20) NOT NULL,
      time VARCHAR(50) NOT NULL,
      type VARCHAR(50),
      room VARCHAR(50)
    );
  `;

    try {
        await pool.query(updateTableQuery);
        console.log("✅ Timetable table migrated successfully (teacher -> teacher_id).");
    } catch (err) {
        console.error("❌ Error migrating timetable table:", err);
    } finally {
        process.exit();
    }
}

migrateTimetable();
