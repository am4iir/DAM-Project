const express = require("express");
const router = express.Router();
const pool = require("../../config/db");


router.get("/stats/:id", async (req, res) => {
    try {
        const teacherId = req.params.id;
     
        
        const studentCountQuery = `
            SELECT COUNT(DISTINCT sg.student_id) 
            FROM student_groups sg
            INNER JOIN teacher_groups tg ON sg.group_id = tg.group_id
            WHERE tg.teacher_id = $1
        `;
        const studentCountResult = await pool.query(studentCountQuery, [teacherId]);
        const totalStudents = parseInt(studentCountResult.rows[0].count, 10);

        const groupCountQuery = `SELECT COUNT(*) FROM teacher_groups WHERE teacher_id = $1`;
        const groupCountResult = await pool.query(groupCountQuery, [teacherId]);
        const totalGroups = parseInt(groupCountResult.rows[0].count, 10);

        // Get current day
        const days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
        const today = days[new Date().getDay()];

        const scheduleQuery = `
            SELECT 
                t.id, 
                t.subject, 
                g.name as "group", 
                t.time, 
                t.room
            FROM timetable t
            JOIN groups g ON t.group_id = g.id
            JOIN teacher_groups tg ON g.id = tg.group_id
            WHERE tg.teacher_id = $1 AND t.day = $2
            ORDER BY t.time ASC
        `;
        
        const scheduleResult = await pool.query(scheduleQuery, [teacherId, today]);
        
        const upcomingClasses = scheduleResult.rows.map(cls => {
            // Assign colors based on subject (or default)
            let color = 0xFF6C63FF; // Default purple/blue
            const subject = cls.subject.toLowerCase();
            
            if (subject.includes('physics')) {
                color = 0xFFFF6584; // Pinkish
            } else if (subject.includes('consultation')) {
                color = 0xFF4CAF50; // Green
            } else if (subject.includes('math')) {
                color = 0xFF6C63FF;
            }

            return {
                ...cls,
                color: color
            };
        });

        return res.status(200).json({
            message: "Stats fetched successfully",
            stats: {
                totalStudents,
                activeGroups: totalGroups,
                pendingAssignments: 0, 
                averageAttendance: "0%", 
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
        
       
        const totalStudents = students.length;
        
       
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
