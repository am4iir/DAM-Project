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
  String _role = '';

  final String _baseUrl = 'http://10.0.2.2:3001/admin';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    if (!mounted) return;
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

  Future<void> _assignUser({
    required int userId,
    required String role,
    required int? groupId,
  }) async {
    final endpoint = role.toLowerCase() == 'teacher'
        ? 'assign-teacher'
        : 'assign-student';

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/students/$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          role.toLowerCase() == 'teacher' ? 'teacher_id' : 'student_id': userId,
          'group_id': groupId,
        }),
      );

      if (response.statusCode == 200) {
        _fetchData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Assignment updated'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception(response.body);
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

    final filteredUsers = _students.where((u) {
      if (_role.isEmpty) return true;
      return u['role_name']?.toString().toLowerCase() == _role.toLowerCase();
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'User Assignment',
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
              child: Column(
                children: [
                  // Filter Bar
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        _FilterChip(
                          label: 'All',
                          isSelected: _role == '',
                          onSelected: (val) => setState(() => _role = ''),
                          cs: cs,
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: 'Teachers',
                          isSelected: _role == 'Teacher',
                          onSelected: (val) {
                            setState(() => _role = val ? 'Teacher' : '');
                          },
                          cs: cs,
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: 'Students',
                          isSelected: _role == 'Student',
                          onSelected: (val) =>
                              setState(() => _role = val ? 'Student' : ''),
                          cs: cs,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: filteredUsers.isEmpty
                        ? Center(
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
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: filteredUsers.length,
                            itemBuilder: (context, index) {
                              final user = filteredUsers[index];
                              final List<dynamic> assignedGroups =
                                  user['assigned_groups'] ?? [];

                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          CircleAvatar(
                                            radius: 24,
                                            backgroundColor:
                                                cs.primaryContainer,
                                            child: Text(
                                              user['username'][0].toUpperCase(),
                                              style: TextStyle(
                                                color: cs.onPrimaryContainer,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      user['username'],
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    _RoleBadge(
                                                      role:
                                                          user['role_name'] ??
                                                          '',
                                                      cs: cs,
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  user['email'],
                                                  style: TextStyle(
                                                    color: cs.onSurfaceVariant,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          DropdownButton<int?>(
                                            value: null,
                                            alignment: Alignment.centerRight,
                                            hint: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 14,
                                                    vertical: 8,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: cs.primary,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: cs.primary
                                                        .withOpacity(0.2),
                                                    blurRadius: 6,
                                                    offset: const Offset(0, 3),
                                                  ),
                                                ],
                                              ),
                                              child: const Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    'Select Group',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 6),
                                                  const Icon(
                                                    Icons.add_circle_outline,
                                                    size: 20,
                                                    color: Colors.white,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            underline: const SizedBox(),
                                            icon: const SizedBox.shrink(),
                                            onChanged: (val) {
                                              _assignUser(
                                                userId: user['id'],
                                                role:
                                                    user['role_name']
                                                        ?.toString() ??
                                                    '',
                                                groupId: val,
                                              );
                                            },
                                            items: [
                                              const DropdownMenuItem<int?>(
                                                value: null,
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.add_circle_outline,
                                                      color: Colors.teal,
                                                      size: 20,
                                                    ),
                                                    SizedBox(width: 8),
                                                    Text(
                                                      'Add Group',
                                                      style: TextStyle(
                                                        color: Colors.teal,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              
                                              ..._groups.map((g) {
                                                final bool isAssigned =
                                                    assignedGroups.any(
                                                      (ag) =>
                                                          ag['id'] == g['id'],
                                                    );
                                                return DropdownMenuItem<int?>(
                                                  value: g['id'],
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        isAssigned
                                                            ? Icons.check_box
                                                            : Icons
                                                                  .check_box_outline_blank,
                                                        size: 20,
                                                        color: isAssigned
                                                            ? cs.primary
                                                            : cs.onSurfaceVariant,
                                                      ),
                                                      const SizedBox(width: 12),
                                                      Text(
                                                        g['name'],
                                                        style: TextStyle(
                                                          color: isAssigned
                                                              ? cs.primary
                                                              : cs.onSurface,
                                                          fontWeight: isAssigned
                                                              ? FontWeight.bold
                                                              : FontWeight
                                                                    .normal,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }),
                                            ],
                                          ),
                                        ],
                                      ),
                                      if (assignedGroups.isNotEmpty) ...[
                                        const SizedBox(height: 12),
                                        Wrap(
                                          spacing: 8,
                                          runSpacing: 4,
                                          children: assignedGroups.map((g) {
                                            return Chip(
                                              label: Text(
                                                g['name'],
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                ),
                                              ),
                                              backgroundColor: cs
                                                  .secondaryContainer
                                                  .withOpacity(0.5),
                                              side: BorderSide.none,
                                              padding: EdgeInsets.zero,
                                              materialTapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                              onDeleted: () => _assignUser(
                                                userId: user['id'],
                                                role: user['role_name'],
                                                groupId: g['id'],
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Function(bool) onSelected;
  final ColorScheme cs;

  const _FilterChip({
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
