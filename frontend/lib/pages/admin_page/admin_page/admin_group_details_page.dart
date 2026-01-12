import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend/widgets/Adminpages/admin_group_widgets.dart';

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

  final List<String> _days = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
  ];

  // Pre-calculated slots for 1.3h (78 min) sessions starting from 08:30
  final List<Map<String, String>> _timeSlots = [
    {'start': '08:30', 'end': '09:48'},
    {'start': '10:00', 'end': '11:18'},
    {'start': '11:30', 'end': '12:48'},
    {'start': '13:00', 'end': '14:18'},
    {'start': '14:30', 'end': '15:48'},
  ];

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
            return Center(child: Text('Error loading data: ${snapshot.error}'));
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

          return CustomScrollView(
            slivers: [
              if (teachers.isNotEmpty) ...[
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
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
                    (context, index) => AdminMemberCard(
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
                    (context, index) => AdminMemberCard(
                      member: students[index],
                      onDelete: () => _unassignMember(students[index]['id']),
                    ),
                    childCount: students.length,
                  ),
                ),
              ],
              const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
            ],
          );
        },
      ),
    );
  }
}
