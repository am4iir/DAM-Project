import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminGroupDetailsPage extends StatefulWidget {
  final Map<String, dynamic> group;
  const AdminGroupDetailsPage({super.key, required this.group});

  @override
  State<AdminGroupDetailsPage> createState() => _AdminGroupDetailsPageState();
}

class _AdminGroupDetailsPageState extends State<AdminGroupDetailsPage> {
  late Future<List<dynamic>> _studentsFuture;
  final String _baseUrl = 'http://10.0.2.2:3001/admin/groups';
  final String _baseUrl2 = 'http://10.0.2.2:3001/admin/students';

  @override
  void initState() {
    super.initState();
    _studentsFuture = _fetchStudents();
  }

  Future<List<dynamic>> _fetchStudents() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/${widget.group['id']}/students'),
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        return decoded['students'] ?? [];
      } else {
        throw Exception('Failed to load students');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<void> _unassignMember(int userId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl2/delete/$userId'),
      );

      if (response.statusCode == 200) {
        setState(() {
          _studentsFuture = _fetchStudents();
        });
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Member unassigned')));
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Action failed')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Network error')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Group: ${widget.group['name']}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: cs.onSurface,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _studentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: cs.error),
                  const SizedBox(height: 16),
                  const Text('Error loading members'),
                  TextButton(
                    onPressed: () =>
                        setState(() => _studentsFuture = _fetchStudents()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final members = snapshot.data ?? [];
          final teachers = members
              .where(
                (m) => m['role_name']?.toString().toLowerCase() == 'teacher',
              )
              .toList();
          final students = members
              .where(
                (m) => m['role_name']?.toString().toLowerCase() == 'student',
              )
              .toList();

          if (members.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_off_outlined,
                    size: 80,
                    color: cs.onSurfaceVariant.withOpacity(0.2),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No members in this group yet',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              if (teachers.isNotEmpty) ...[
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      'TEACHERS',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        fontSize: 12,
                        color: Colors.orange,
                      ),
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _MemberCard(
                      member: teachers[index],
                      onDelete: () => _unassignMember(teachers[index]['id']),
                    ),
                    childCount: teachers.length,
                  ),
                ),
              ],
              if (students.isNotEmpty) ...[
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                    child: Text(
                      'STUDENTS',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        fontSize: 12,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _MemberCard(
                      member: students[index],
                      onDelete: () => _unassignMember(students[index]['id']),
                    ),
                    childCount: students.length,
                  ),
                ),
              ],
              const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
            ],
          );
        },
      ),
    );
  }
}

class _MemberCard extends StatelessWidget {
  final dynamic member;
  final VoidCallback onDelete;

  const _MemberCard({required this.member, required this.onDelete});

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
            _RoleBadge(role: member['role_name'] ?? '', cs: cs),
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

class _RoleBadge extends StatelessWidget {
  final String role;
  final ColorScheme cs;

  const _RoleBadge({required this.role, required this.cs});

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
