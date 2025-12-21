import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend/pages/admin_page/admin_page/admin_student_assignment_page.dart';
import 'package:frontend/pages/admin_page/admin_page/admin_group_details_page.dart';

class AdminGroupMenegePage extends StatefulWidget {
  const AdminGroupMenegePage({super.key});

  @override
  State<AdminGroupMenegePage> createState() => _AdminGroupMenegePageState();
}

class _AdminGroupMenegePageState extends State<AdminGroupMenegePage> {
  late Future<List<dynamic>> _groupsFuture;
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _levelController = TextEditingController();
  final TextEditingController _maxStudentsController = TextEditingController();

  final String _baseUrl = 'http://10.0.2.2:3001/admin/groups';

  final List<Color> _groupColors = [
    Colors.blue,
    Colors.green,
    Colors.purple,
    Colors.orange,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
    Colors.cyan,
  ];

  @override
  void initState() {
    super.initState();
    _refreshGroups();
  }

  @override
  void dispose() {
    _groupNameController.dispose();
    _levelController.dispose();
    _maxStudentsController.dispose();
    super.dispose();
  }

  void _refreshGroups() {
    setState(() {
      _groupsFuture = _fetchGroups();
    });
  }

  Future<List<dynamic>> _fetchGroups() async {
    try {
      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        return decoded['groups'] ?? [];
      } else {
        throw Exception('Failed to load groups');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<void> _createGroup() async {
    final name = _groupNameController.text.trim();
    final level = _levelController.text.trim();
    final maxStr = _maxStudentsController.text.trim();

    if (name.isEmpty || level.isEmpty || maxStr.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    final max = int.tryParse(maxStr) ?? 0;
    if (max <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Max students must be greater than 0')),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'name': name, 'level': level, 'max_students': max}),
      );

      if (response.statusCode == 201) {
        Navigator.pop(context);
        _groupNameController.clear();
        _levelController.clear();
        _maxStudentsController.clear();
        _refreshGroups();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Group created successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception('Failed to create group');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _deleteGroup(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Group'),
        content: const Text('Are you sure you want to delete this group?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final response = await http.delete(Uri.parse('$_baseUrl/$id'));
      if (response.statusCode == 200) {
        _refreshGroups();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showCreateGroupDialog() {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cs.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: cs.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.group_add, color: cs.primary, size: 24),
            ),
            const SizedBox(width: 12),
            Text(
              'Create New Group',
              style: TextStyle(
                color: cs.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDialogTextField(
                controller: _groupNameController,
                hint: 'Group Name',
                icon: Icons.group,
                cs: cs,
              ),
              const SizedBox(height: 12),
              _buildDialogTextField(
                controller: _levelController,
                hint: 'Level (e.g. L3)',
                icon: Icons.grade,
                cs: cs,
              ),
              const SizedBox(height: 12),
              _buildDialogTextField(
                controller: _maxStudentsController,
                hint: 'Max Students',
                icon: Icons.people,
                cs: cs,
                isNumber: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: cs.onSurface.withOpacity(0.6)),
            ),
          ),
          ElevatedButton(
            onPressed: _createGroup,
            style: ElevatedButton.styleFrom(
              backgroundColor: cs.primary,
              foregroundColor: cs.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogTextField({
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
        hintStyle: TextStyle(color: cs.onSurface.withOpacity(0.5)),
        filled: true,
        fillColor: cs.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.outline.withOpacity(0.5)),
        ),
        prefixIcon: Icon(icon, color: cs.primary),
      ),
      style: TextStyle(color: cs.onSurface),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: cs.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateGroupDialog,
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        elevation: 4,
        icon: const Icon(Icons.add),
        label: const Text(
          'Create Group',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _groupsFuture,
        builder: (context, snapshot) {
          final groups = snapshot.data ?? [];
          return RefreshIndicator(
            onRefresh: () async => _refreshGroups(),
            child: CustomScrollView(
              slivers: [
                _buildSliverAppBar(theme, cs),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeaderCard(theme, cs, groups.length),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'All Groups',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: cs.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${groups.length} groups',
                                style: TextStyle(
                                  color: cs.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (snapshot.connectionState == ConnectionState.waiting)
                          const Center(child: CircularProgressIndicator())
                        else if (snapshot.hasError)
                          Center(child: Text('Error: ${snapshot.error}'))
                        else if (groups.isEmpty)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.only(top: 40),
                              child: Text('No groups yet'),
                            ),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: groups.length,
                            itemBuilder: (context, index) {
                              return _buildGroupCard(
                                cs,
                                theme,
                                groups[index],
                                index,
                              );
                            },
                          ),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSliverAppBar(ThemeData theme, ColorScheme cs) {
    return SliverAppBar(
      backgroundColor: cs.background,
      pinned: true,
      elevation: 0,
      expandedHeight: 100,
      actions: [
        IconButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AdminStudentAssignmentPage(),
            ),
          ),
          icon: const Icon(Icons.person_add_alt_1_outlined),
          tooltip: 'Assign Students',
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Groups',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: cs.onSurface,
          ),
        ),
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
      ),
    );
  }

  Widget _buildHeaderCard(ThemeData theme, ColorScheme cs, int totalGroups) {
    return Container(
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
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Manage Groups',
                  style: TextStyle(
                    color: cs.onPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Create and organize study groups',
                  style: TextStyle(
                    color: cs.onPrimary.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: cs.onPrimary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$totalGroups Groups Total',
                    style: TextStyle(
                      color: cs.onPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cs.onPrimary.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.groups, size: 40, color: cs.onPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupCard(
    ColorScheme cs,
    ThemeData theme,
    Map<String, dynamic> group,
    int index,
  ) {
    final Color groupColor = _groupColors[index % _groupColors.length];
    final String name = group['name'] ?? 'No Name';
    final String level = group['level'] ?? 'N/A';
    final int maxStudents = group['max_students'] ?? 0;
    final String createdAt = group['created_at'] != null
        ? group['created_at'].toString().substring(0, 10)
        : '2024-03-20';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outline.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AdminGroupDetailsPage(group: group),
            ),
          ),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [groupColor, groupColor.withOpacity(0.7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: groupColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      name.isNotEmpty
                          ? name.substring(0, 1).toUpperCase()
                          : 'G',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: cs.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.school_outlined,
                            size: 14,
                            color: cs.onSurface.withOpacity(0.5),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Level $level',
                            style: TextStyle(
                              fontSize: 12,
                              color: cs.onSurface.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 14,
                            color: cs.onSurface.withOpacity(0.5),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            createdAt,
                            style: TextStyle(
                              fontSize: 12,
                              color: cs.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _deleteGroup(group['id']),
                  icon: Icon(
                    Icons.delete_outline,
                    color: cs.error.withOpacity(0.7),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: cs.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.chevron_right, color: cs.primary, size: 20),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
