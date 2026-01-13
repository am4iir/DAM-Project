const express = require("express");
const router = express.Router();
const pool = require("../../config/db");

router.get("/stats/:id", async (req, res) => {
    try {
        const studentId = req.params.id;

        // Get current day
        const days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
        const today = days[new Date().getDay()];

        // Join timetable with groups and student_groups to get classes for this student
        const scheduleQuery = `
            SELECT 
                t.id, 
                t.subject, 
               
                t.time, 
                t.room,
                t.type,
                g.name as "group"
            FROM timetable t
            JOIN groups g ON t.group_id = g.id
            JOIN student_groups sg ON g.id = sg.group_id
            WHERE sg.student_id = $1 AND t.day = $2
            ORDER BY t.time ASC
        `;
        
        const scheduleResult = await pool.query(scheduleQuery, [studentId, today]);
        
        const schedule = scheduleResult.rows.map(cls => {
            let color = 0xFF6C63FF;
            const subject = cls.subject.toLowerCase();
            if (subject.includes('physics')) color = 0xFFFF6584;
            else if (subject.includes('math')) color = 0xFF6C63FF;
            else if (subject.includes('english')) color = 0xFFFF9F1C;
            else if (subject.includes('consultation')) color = 0xFF4CAF50;

            return {
                ...cls,
                color: color
            };
        });

        const groupQuery = `
            SELECT g.name 
            FROM groups g
            JOIN student_groups sg ON g.id = sg.group_id
            WHERE sg.student_id = $1
        `;
        const groupResult = await pool.query(groupQuery, [studentId]);
        const groupName = groupResult.rows.length > 0 ? groupResult.rows[0].name : 'N/A';

        const stats = {
            group: groupName,
            exams: 5,
            scheduleCount: schedule.length
        };

        return res.status(200).json({
            message: "Student dashboard data fetched successfully",
            stats,
            schedule,
            today
        });

    } catch (err) {
        console.error("Student dashboard error:", err.message);
        return res.status(500).json({ message: "Server error" });
    }
});

module.exports = router;
