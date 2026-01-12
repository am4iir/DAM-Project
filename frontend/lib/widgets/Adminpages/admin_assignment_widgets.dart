import 'package:flutter/material.dart';

class AdminAssignmentFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Function(bool) onSelected;
  final ColorScheme cs;

  const AdminAssignmentFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onSelected,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
      selectedColor: cs.primaryContainer,
      checkmarkColor: cs.onPrimaryContainer,
      labelStyle: TextStyle(
        color: isSelected ? cs.onPrimaryContainer : cs.onSurfaceVariant,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      backgroundColor: cs.surfaceVariant.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: isSelected ? cs.primary : Colors.transparent),
      ),
    );
  }
}


class AdminAssignmentRoleBadge extends StatelessWidget {
  final String role;
  final ColorScheme cs;

  const AdminAssignmentRoleBadge({
    super.key,
    required this.role,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    if (role.isEmpty) return const SizedBox.shrink();

    final isTeacher = role.toLowerCase() == 'teacher';
    final color = isTeacher ? Colors.orange : Colors.blue;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        role.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}


Widget buildAssignmentEmptyState(ColorScheme cs) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.person_off_outlined,
          size: 64,
          color: cs.onSurfaceVariant.withOpacity(0.5),
        ),
        const SizedBox(height: 16),
        Text(
          'No users found for this role',
          style: TextStyle(color: cs.onSurfaceVariant),
        ),
      ],
    ),
  );
}
