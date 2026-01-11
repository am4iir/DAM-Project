// server.js
const express = require("express");
const cors = require("cors");
const pool = require('./config/db');
const singupRoutes = require("./routes/auth/singup.js");
const userRoutes = require("./routes/auth/signin.js");
const tokenRoutes = require("./routes/token/token.js");
const acceptRoutes = require("./routes/admin/accept_users.js");
const groupsRoutes = require("./routes/admin/groups.js");
const programRoutes = require("./routes/admin/program.js");
const studentRoutes = require("./routes/admin/students.js");
const moduleRoutes = require("./routes/admin/modules.js");
const teacherRoutes = require("./routes/teacher/home.js");

const app = express();
const port = process.env.PORT || 3001;
const Host = '0.0.0.0';

app.use(cors());
app.use(express.json());

// Health Check
app.get("/health", (req, res) => res.json({ status: "ok", time: new Date() }));

app.use("/", userRoutes);
app.use("/", singupRoutes);
app.use("/token", tokenRoutes);
app.use("/admin/groups", groupsRoutes);
app.use("/admin/programs", programRoutes);
app.use("/admin/modules", moduleRoutes);
app.use("/admin/students", studentRoutes);
app.use("/admin", acceptRoutes); // Keep generic /admin last
app.use("/teacher", teacherRoutes);

// Global Error Handler for JSON responses
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: "Internal Server Error", details: err.message });
});

// Final 404 Handler for JSON responses
app.use((req, res) => {
  res.status(404).json({ error: "Route not found", path: req.originalUrl });
});

app.listen(port, Host, () => {
  console.log(`🟢 Server running on http://localhost:${port}`);
  console.log(`🐘 Connected to DB: ${process.env.DB_NAME}@${process.env.DB_HOST}`);
});
