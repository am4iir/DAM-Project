import 'package:flutter/material.dart';

/// Builds a drawer item for navigation menus.
///
/// Parameters:
/// - [context]: The build context
/// - [icon]: The icon to display
/// - [title]: The title text
/// - [onTap]: Callback when tapped
/// - [isSelected]: Whether this item is currently selected
/// - [isLogout]: Whether this is a logout button (displays in error color)
Widget buildDrawerItem(
  BuildContext context, {
  required IconData icon,
  required String title,
  required VoidCallback onTap,
  bool isSelected = false,
  bool isLogout = false,
}) {
  final colorScheme = Theme.of(context).colorScheme;

  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    decoration: BoxDecoration(
      color: isSelected
          ? colorScheme.primary.withOpacity(0.1)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
    ),
    child: ListTile(
      leading: Icon(
        icon,
        color: isSelected
            ? colorScheme.primary
            : (isLogout ? colorScheme.error : colorScheme.onSurfaceVariant),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isLogout ? colorScheme.error : colorScheme.onSurface,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}

/// Builds a statistics card displaying a value with an icon.
///
/// Parameters:
/// - [context]: The build context
/// - [icon]: The icon to display
/// - [title]: The title/label text
/// - [value]: The main value to display
/// - [isPrimary]: Whether to use primary color (true) or secondary color (false)
Widget buildStatCard(
  BuildContext context, {
  required IconData icon,
  required String title,
  required String value,
  required bool isPrimary,
}) {
  final colorScheme = Theme.of(context).colorScheme;
  final cardColor = isPrimary ? colorScheme.primary : colorScheme.secondary;

  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: cardColor,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: cardColor.withOpacity(0.3),
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(height: 16),
        Text(
          value,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.9)),
        ),
      ],
    ),
  );
}

/// Builds a service/action card with icon and title.
///
/// Parameters:
/// - [context]: The build context
/// - [icon]: The icon to display
/// - [title]: The title text
/// - [isPrimary]: Whether to use primary color (true) or secondary color (false)
/// - [onTap]: Callback when tapped
Widget buildServiceCard(
  BuildContext context, {
  required IconData icon,
  required String title,
  required bool isPrimary,
  required VoidCallback onTap,
}) {
  final colorScheme = Theme.of(context).colorScheme;
  final cardColor = isPrimary ? colorScheme.primary : colorScheme.secondary;

  return Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: cardColor.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 32),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    ),
  );
}

Widget buildStudentScheduleCard(dynamic item) {
  Color cardColor = Color(item['color'] ?? 0xFF6C63FF);
  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.03),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Row(
      children: [
        Container(
          width: 5,
          height: 60,
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    item['subject'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3142),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: cardColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      item['type'] ?? 'Class',
                      style: TextStyle(
                        color: cardColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.person_outline, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    item['teacher'] ?? 'No teacher',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.location_on_outlined,
                    size: 14,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    item['room'],
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              item['time'].split('-')[0].trim(),
              style: TextStyle(
                color: cardColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            Text(
              'to ${item['time'].split('-')[1].trim()}',
              style: TextStyle(color: Colors.grey[400], fontSize: 11),
            ),
          ],
        ),
      ],
    ),
  );
}
