
const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  port: process.env.DB_PORT,
});
pool.on('connect',()=>{
    console.log('connected to the database');
})
pool.on('error', (err) => {
  console.error('❌ PostgreSQL client error:', err.stack);
});


module.exports = pool;
