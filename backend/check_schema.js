const pool = require('./config/db');
async function run() {
    try {
        const { rows } = await pool.query("SELECT column_name, data_type FROM information_schema.columns WHERE table_name = 'timetable'");
        console.log(rows);
    } catch (err) { console.error(err); }
    finally { process.exit(); }
}
run();
