const express = require('express');
const router = express.Router();
const jwt = require('jsonwebtoken');
require('dotenv').config();
const pool = require('../config/db');

router.post('/verify',async (req, res) => {
    try {
    const { token } = req.body; 
    if (!token) return res.status(400).json({ message: 'Token missing' });

    const decoded = jwt.verify(token, process.env.JWT_SECRET);


    const result = await pool.query('SELECT * FROM "users" WHERE id = $1', [decoded.id]);
    const user = result.rows[0];

    if (!user) return res.status(404).json({ message: 'User not found' });

    return res.status(200).json({ message: 'success', user });
  } catch (err) {
    return res.status(401).json({ message: 'Invalid or expired token' });
  }
});

module.exports = router;    