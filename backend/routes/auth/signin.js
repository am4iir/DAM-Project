const express = require("express");
require("dotenv").config();
const router = express.Router();
const pool = require("../../config/db");
const jwt = require("jsonwebtoken");


router.post("/signin", async (req, res) => {
  const { email, password } = req.body;

  try {
    
    if (!email || !password) {
      return res.status(400).json({
        message: "Email and password are required",
        error: "MISSING_FIELDS",
      });
    }

    const queryText = `SELECT * FROM users WHERE email = $1 LIMIT 1`;
    const result = await pool.query(queryText, [email]);

    if (result.rows.length === 0) {
      return res.status(404).json({
        message: "User not found",
        error: "USER_NOT_FOUND",
      });
    }

    const user = result.rows[0];

    if (user.password_hash !== password) {
      return res.status(401).json({
        message: "Incorrect password",
        error: "WRONG_PASSWORD",
      });
    }

    const token = jwt.sign(
      {
        id: user.id,
        email: user.email,
        id_role: user.id_role,
      },
      process.env.JWT_SECRET,
      { expiresIn: "100h" }
    );

    const { password_hash, ...safeUser } = user;

    res.status(200).json({
      message: "success",
      user: safeUser,
      token: token,
    });
  } catch (error) {
    console.error("Signin error:", error);
    res.status(500).json({
      message: "Database error",
      error: "DATABASE_ERROR",
    });
  }
});

module.exports = router;
