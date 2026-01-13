const pool = require('./config/db');
async function run() {
    try {
        const { rows } = await pool.query(`
            SELECT t.day, t.time, t.subject, g.name as group_name, u.username as teacher_name
            FROM timetable t
            JOIN groups g ON t.group_id = g.id
            JOIN users u ON t.teacher_id = u.id
            WHERE u.username ILIKE '%amir%'
        `);
        console.log(JSON.stringify(rows, null, 2));
    } catch (err) { console.error(err); }
    finally { process.exit(); }
}
run();
