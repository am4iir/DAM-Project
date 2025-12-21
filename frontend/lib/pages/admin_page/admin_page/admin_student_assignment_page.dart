import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminStudentAssignmentPage extends StatefulWidget {
  const AdminStudentAssignmentPage({super.key});

  @override
  State<AdminStudentAssignmentPage> createState() =>
      _AdminStudentAssignmentPageState();
}

class _AdminStudentAssignmentPageState
    extends State<AdminStudentAssignmentPage> {
  List<dynamic> _students = [];
  List<dynamic> _groups = [];
  bool _isLoading = true;

  final String _baseUrl = 'http://10.0.2.2:3001/admin';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final studentRes = await http.get(Uri.parse('$_baseUrl/students'));
      final groupRes = await http.get(Uri.parse('$_baseUrl/groups'));

      if (studentRes.statusCode == 200 && groupRes.statusCode == 200) {
        setState(() {
          _students = json.decode(studentRes.body)['students'] ?? [];
          _groups = json.decode(groupRes.body)['groups'] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _assignStudent(int studentId, int? groupId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/students/assign'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'student_id': studentId, 'group_id': groupId}),
      );

      if (response.statusCode == 200) {
        _fetchData(); // Refresh list
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Assignment updated!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Assign Students',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: cs.onSurface,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchData,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _students.length,
                itemBuilder: (context, index) {
                  final student = _students[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: cs.primaryContainer,
                            child: Text(
                              student['username'][0].toUpperCase(),
                              style: TextStyle(color: cs.onPrimaryContainer),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  student['username'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  student['email'],
                                  style: TextStyle(
                                    color: cs.onSurfaceVariant,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          DropdownButton<int?>(
                            value: student['group_id'],
                            hint: const Text('No Group'),
                            underline: const SizedBox(),
                            onChanged: (val) =>
                                _assignStudent(student['id'], val),
                            items: [
                              const DropdownMenuItem<int?>(
                                value: null,
                                child: Text('No Group'),
                              ),
                              ..._groups.map(
                                (g) => DropdownMenuItem<int?>(
                                  value: g['id'],
                                  child: Text(g['name']),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
