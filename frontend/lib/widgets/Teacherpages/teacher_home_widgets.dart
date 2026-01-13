import 'package:flutter/material.dart';


Widget buildTeacherStatCard({
  required String title,
  required String value,
  required IconData icon,
  required Color color,
}) {
  return Container(
    width: 130,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: color.withOpacity(0.3),
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}


Widget buildTeacherActionButton({
  required IconData icon,
  required String label,
  required VoidCallback onTap,
}) {
  return Column(
    children: [
      Container(
        width: 65,
        height: 65,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onTap,
            child: Icon(icon, color: const Color(0xFF6C63FF), size: 28),
          ),
        ),
      ),
      const SizedBox(height: 8),
      Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Color(0xFF2D3142),
        ),
      ),
    ],
  );
}


Widget buildTeacherScheduleCard(dynamic item) {
  Color cardColor = Color(item['color'] ?? 0xFF6C63FF);
  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.grey.withOpacity(0.1)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.02),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Row(
      children: [
        Container(
          width: 4,
          height: 50,
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item['subject'],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3142),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                ' • ${item['room']}',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: cardColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            item['time'],
            style: TextStyle(
              color: cardColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ],
    ),
  );
}
