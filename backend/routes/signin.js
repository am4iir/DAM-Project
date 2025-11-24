const express = require("express");
require("dotenv").config();
const router = express.Router();
const pool = require("../config/db");

const jwt = require("jsonwebtoken");

router.post("/signin", (req, res) => {
  const user = req.body;

  const queryText = `SELECT * FROM "users" WHERE email = $1;`;
  pool
    .query(queryText, [user.email])
    .then((result) => {
      const userFromDB = result.rows[0];
      if (userFromDB && userFromDB.password_hash === user.password) {
        
        const token = jwt.sign(
          { id: userFromDB.id, email: userFromDB.email, id_role: userFromDB.id_role },
          process.env.JWT_SECRET,
          { expiresIn: "100h" }
        );
        
        res.send({ message: "success", user: userFromDB, token: token, status: 200 });
      } else {
        res.send({ message: "Invalid credentials", status: 400 });
      }
    })
    .catch((error) => {
      console.log(error);
      res.send({ message: "Database error", status: 500 });
    });
});

module.exports = router;
