// server.js
const express = require("express");
const cors = require("cors");
const pool = require('./config/db');
const singupRoutes = require("./routes/auth/singup.js");
const userRoutes = require("./routes/auth/signin.js");
const tokenRoutes = require("./routes/token/token.js");
const acceptRoutes = require("./routes/admin/accept_users.js");
const groupsRoutes = require("./routes/admin/groups.js");

const studentRoutes = require("./routes/admin/students.js");

const app = express();
const port = process.env.PORT || 3001;
const Host = '0.0.0.0';

app.use(cors());
app.use(express.json());

app.use("/", userRoutes);
app.use("/", singupRoutes);
app.use("/token", tokenRoutes);
app.use("/admin", acceptRoutes);
app.use("/admin/groups", groupsRoutes);
app.use("/admin/students", studentRoutes);

app.listen(port, Host, () => {
  console.log(`🟢 Server running on http://localhost:${port}`);
  console.log(`🐘 Connected to DB: ${process.env.DB_NAME}@${process.env.DB_HOST}`);
});
