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

  Future<void> _deleteStudent(int studentId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl2/delete/$studentId'),
      );

      if (response.statusCode == 200) {
        setState(() {
          _studentsFuture = _fetchStudents();
        });
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Delete failed')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Network error')));
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
                  const Text('Error loading students'),
                  TextButton(
                    onPressed: () =>
                        setState(() => _studentsFuture = _fetchStudents()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final students = snapshot.data ?? [];

          if (students.isEmpty) {
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
                    'No students in this group yet',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(19),
                  side: BorderSide(color: cs.outline.withOpacity(0.8)),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: cs.primaryContainer,
                    child: Text(
                      student['username'][0].toUpperCase(),
                      style: TextStyle(
                        color: cs.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    student['username'],
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(student['email']),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: cs.error),
                    onPressed: () => _deleteStudent(student['id']),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
