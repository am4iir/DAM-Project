// server.js
const express = require("express");
const cors = require("cors");
const pool = require('./config/db');// rename db.js → db.cjs
const singupRoutes = require("./routes/singup.js");
const userRoutes = require("./routes/signin.js");
const tokenRoutes = require("./routes/token.js");
const app = express();
const port = process.env.PORT || 3000;
const Host='0.0.0.0';

// Enable CORS for all origins (mobile app support)
app.use(cors());
app.use(express.json());

app.use("/", userRoutes);
app.use("/", singupRoutes);
app.use("/token", tokenRoutes);

app.listen(port,Host, () => {
  console.log(`🟢 Server running on http://localhost:${port}`);
  console.log(`🐘 Connected to DB: ${process.env.DB_NAME}@${process.env.DB_HOST}`);
});
