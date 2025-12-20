const express = require('express');
const router = express.Router();
const pool = require('../../config/db');
const jwt = require('jsonwebtoken');

router.post('/singup', async (req, res) => {
    try {
        const {username, email, password} = req.body;
        
        const query= `INSERT INTO users (username,email,password_hash) values($1,$2,$3)`;
        await pool.query(query,[username,email,password]);
        const token = jwt.sign({username,password,role:3},process.env.JWT_SECRET,{expiresIn:'1h'});
        return res.status(201).json({message:"User created successfully",token:token});
    } catch (error) {
        console.error("❌ Database error:", error.message);
        return res.status(500).json({message: "user already exists"});
    }

})


module.exports = router;