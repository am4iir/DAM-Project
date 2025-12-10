const pool = require('./config/db');

async function testDB() {
  try {
    const res = await pool.query('SELECT NOW()');
    console.log('🕒 DB Time:', res.rows[0]);
  } catch (err) {
    console.error(err);
  }
}

testDB();