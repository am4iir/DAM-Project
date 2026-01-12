import 'package:flutter/material.dart';

class AdminMemberCard extends StatelessWidget {
  final dynamic member;
  final VoidCallback onDelete;

  const AdminMemberCard({
    super.key,
    required this.member,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: cs.outline.withOpacity(0.2)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: cs.primaryContainer,
          child: Text(
            member['username']?[0].toUpperCase() ?? '?',
            style: TextStyle(
              color: cs.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Row(
          children: [
            Text(
              member['username'] ?? 'Unknown',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 8),
            AdminRoleBadge(role: member['role_name'] ?? '', cs: cs),
          ],
        ),
        subtitle: Text(member['email'] ?? ''),
        trailing: IconButton(
          icon: Icon(Icons.close, color: cs.error.withOpacity(0.7)),
          onPressed: onDelete,
        ),
      ),
    );
  }
}


class AdminRoleBadge extends StatelessWidget {
  final String role;
  final ColorScheme cs;

  const AdminRoleBadge({super.key, required this.role, required this.cs});

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


class AdminSessionCard extends StatelessWidget {
  final dynamic session;
  const AdminSessionCard({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.blueAccent.withOpacity(0.2)),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blueAccent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.timer_outlined, color: Colors.blueAccent),
        ),
        title: Text(
          session['module_name'] ?? 'Session',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${session['day']} • ${session['start_time']} - ${session['end_time']}',
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.blueAccent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            '1.3h',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}


Widget buildAdminGroupSliverAppBar(ThemeData theme, ColorScheme cs) {
  return SliverAppBar(
    pinned: true,
    backgroundColor: cs.background,
    elevation: 0,
    expandedHeight: 80,
    flexibleSpace: FlexibleSpaceBar(
      title: Text(
        'Groups',
        style: theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: cs.onSurface,
        ),
      ),
      centerTitle: false,
      titlePadding: const EdgeInsets.only(left: 16, bottom: 12),
    ),
  );
}

Widget buildAdminGroupHeaderCard({
  required ThemeData theme,
  required ColorScheme cs,
  required int totalGroups,
  required VoidCallback onCreateGroup,
  required VoidCallback onCreateModule,
}) {
  return Container(
    margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [cs.primary, cs.primary.withOpacity(0.7)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: cs.primary.withOpacity(0.3),
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Manage Groups',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: cs.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$totalGroups groups total',
                    style: TextStyle(color: cs.onPrimary.withOpacity(0.85)),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: cs.onPrimary.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.folder_shared_outlined,
                color: cs.onPrimary,
                size: 28,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onCreateGroup,
                icon: const Icon(Icons.add),
                label: const Text('New Group'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.onPrimary,
                  foregroundColor: cs.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onCreateModule,
                icon: const Icon(Icons.add),
                label: const Text('Add Module'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: cs.onPrimary,
                  side: BorderSide(color: cs.onPrimary.withOpacity(0.5)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}


Widget buildAdminDialogTextField({
  required TextEditingController controller,
  required String hint,
  required IconData icon,
  required ColorScheme cs,
  bool isNumber = false,
}) {
  return TextField(
    controller: controller,
    keyboardType: isNumber ? TextInputType.number : TextInputType.text,
    decoration: InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: cs.primary),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: cs.outline.withOpacity(0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: cs.outline.withOpacity(0.3)),
      ),
    ),
  );
}
