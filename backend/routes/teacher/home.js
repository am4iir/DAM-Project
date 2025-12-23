const express = require("express");
const router = express.Router();
const pool = require("../../config/db");

// Get Teacher Dashboard Stats
router.get("/stats", async (req, res) => {
    try {
        // In a real app, we would filter by req.user.id (teacher's ID)
        // For now, we will return global stats or mock data suitable for a demo.

        // 1. Count total students (Role 3)
        const studentCountQuery = `SELECT COUNT(*) FROM student_groups WHERE teacher_id = ${req.user.id}`;
        const studentCountResult = await pool.query(studentCountQuery);
        const totalStudents = parseInt(studentCountResult.rows[0].count, 10);

        // 2. Count total groups
        const groupCountQuery = `SELECT COUNT(*) FROM teacher_groups WHERE teacher_id = ${req.user.id}`;
        const groupCountResult = await pool.query(groupCountQuery);
        const totalGroups = parseInt(groupCountResult.rows[0].count, 10);

        // 3. Mock upcoming classes (since we don't have a schedule table yet)
        const upcomingClasses = [
            {
                id: 1,
                subject: "Mathematics",
                group: "Group A",
                time: "08:30 AM - 10:00 AM",
                room: "Room 101",
                color: 0xFF6C63FF // Hex for purple/primary
            },
            {
                id: 2,
                subject: "Physics",
                group: "Group B",
                time: "10:15 AM - 11:45 AM",
                room: "Lab 2",
                color: 0xFFFF6584 // Hex for pink/accent
            },
            {
                id: 3,
                subject: "Consultation",
                group: "Group C",
                time: "01:00 PM - 02:00 PM",
                room: "Office",
                color: 0xFF4CAF50 // Hex for green
            }
        ];

        return res.status(200).json({
            message: "Stats fetched successfully",
            stats: {
                totalStudents,
                activeGroups: totalGroups,
                pendingAssignments: 12, // Mock
                averageAttendance: "94%", // Mock
            },
            schedule: upcomingClasses
        });

    } catch (err) {
        console.error("Dashboard stats error:", err.message);
        return res.status(500).json({ message: "Server error" });
    }
});

module.exports = router;
