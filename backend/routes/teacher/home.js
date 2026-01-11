const express = require("express");
const router = express.Router();
const pool = require("../../config/db");

// Get Teacher Dashboard Stats
router.get("/stats", async (req, res) => {
    try {
     
        const studentCountQuery = `SELECT COUNT(*) FROM student_groups WHERE teacher_id = ${req.user.id}`;
        const studentCountResult = await pool.query(studentCountQuery);
        const totalStudents = parseInt(studentCountResult.rows[0].count, 10);

        const groupCountQuery = `SELECT COUNT(*) FROM teacher_groups WHERE teacher_id = ${req.user.id}`;
        const groupCountResult = await pool.query(groupCountQuery);
        const totalGroups = parseInt(groupCountResult.rows[0].count, 10);
        const upcomingClasses = [
            {
                id: 1,
                subject: "Mathematics",
                group: "Group A",
                time: "08:30 AM - 10:00 AM",
                room: "Room 101",
                color: 0xFF6C63FF 
            },
            {
                id: 2,
                subject: "Physics",
                group: "Group B",
                time: "10:15 AM - 11:45 AM",
                room: "Lab 2",
                color: 0xFFFF6584 
            },
            {
                id: 3,
                subject: "Consultation",
                group: "Group C",
                time: "01:00 PM - 02:00 PM",
                room: "Office",
                color: 0xFF4CAF50 
            }
        ];

        return res.status(200).json({
            message: "Stats fetched successfully",
            stats: {
                totalStudents,
                activeGroups: totalGroups,
                pendingAssignments: 12, 
                averageAttendance: "94%", 
            },
            schedule: upcomingClasses
        });

    } catch (err) {
        console.error("Dashboard stats error:", err.message);
        return res.status(500).json({ message: "Server error" });
    }
});
router.get("/allStudent/:id", async (req, res) => {
    try {
        const teacherId = req.params.id;
        const studentsQuery = `
            SELECT DISTINCT 
                u.id,
                u.username,
                u.email,
                g.name as group_name,
                g.level,
                g.id as group_id
            FROM users u
            INNER JOIN student_groups sg ON u.id = sg.student_id
            INNER JOIN groups g ON sg.group_id = g.id
            INNER JOIN teacher_groups tg ON tg.group_id = g.id
            WHERE tg.teacher_id = $1 AND u.id_role = 3
            ORDER BY g.name, u.username ASC
        `;
        
        const studentsResult = await pool.query(studentsQuery, [teacherId]);
        const students = studentsResult.rows;
        
        // Get count of students
        const totalStudents = students.length;
        
        // Get distinct groups
        const groupsSet = new Set(students.map(s => s.group_name));
        const totalGroups = groupsSet.size;

        return res.status(200).json({
            message: "Students fetched successfully",
            students: students,
            stats: {
                totalStudents,
                totalGroups
            }
        });
    } catch (error) {
        console.error("All student error:", error.message);
        return res.status(500).json({ message: "Server error" });
    }
})

module.exports = router;
