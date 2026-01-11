import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:go_router/go_router.dart';

class AdminGroupMenegePage extends StatefulWidget {
  const AdminGroupMenegePage({super.key});

  @override
  State<AdminGroupMenegePage> createState() => _AdminGroupMenegePageState();
}

class _AdminGroupMenegePageState extends State<AdminGroupMenegePage> {
  late Future<List<dynamic>> _groupsFuture;
  late Future<List<dynamic>> _modulesFuture;
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _levelController = TextEditingController();
  final TextEditingController _maxStudentsController = TextEditingController();
  final TextEditingController _moduleNameController = TextEditingController();
  final TextEditingController _moduleLevelController = TextEditingController();
  List<dynamic> _allTeachers = [];
  int? _selectedTeacherIdForModule;

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
    _refreshModules();
    _fetchTeachers();
  }

  Future<void> _fetchTeachers() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3001/admin/programs/group/0/teachers'),
      );
      // Using /group/0/teachers will trigger the fallback to all teachers based on the backend change
      if (response.statusCode == 200) {
        setState(() {
          _allTeachers = json.decode(response.body)['teachers'] ?? [];
        });
      }
    } catch (e) {
      debugPrint('Error fetching teachers: $e');
    }
  }

  @override
  void dispose() {
    _groupNameController.dispose();
    _levelController.dispose();
    _maxStudentsController.dispose();
    _moduleNameController.dispose();
    _moduleLevelController.dispose();
    super.dispose();
  }

  void _refreshGroups() {
    setState(() {
      _groupsFuture = _fetchGroups();
    });
  }

  void _refreshModules() {
    setState(() {
      _modulesFuture = _fetchModules();
    });
  }

  Future<List<dynamic>> _fetchModules() async {
    try {
      final response = await http.get(
        Uri.parse("http://10.0.2.2:3001/admin/modules/all"),
        headers: {'Content-Type': 'application/json'},
      );

      final decoded = json.decode(response.body);

      if (response.statusCode == 200) {
        return decoded['modules'] ?? [];
      } else {
        final message = decoded['message'] ?? 'Unknown server error';
        throw Exception(message);
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<List<dynamic>> _fetchGroups() async {
    try {
      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
      );

      final decoded = json.decode(response.body);

      if (response.statusCode == 200) {
        return decoded['groups'] ?? [];
      } else {
        final message = decoded['message'] ?? 'Unknown server error';
        throw Exception(message);
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> _createModules() async {
    final name = _moduleNameController.text.trim();
    final level = _moduleLevelController.text.trim();

    if (name.isEmpty || level.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    try {
      final response = await http.post(
        Uri.parse("http://10.0.2.2:3001/admin/modules/create"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'level': level,
          'teacherId': _selectedTeacherIdForModule,
        }),
      );

      final decoded = json.decode(response.body);

      if (response.statusCode == 201) {
        if (!mounted) return;

        Navigator.pop(context);

        _moduleNameController.clear();
        _moduleLevelController.clear();

        _refreshModules();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Module created successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        final message = decoded['message'] ?? 'Failed to create module';
        Navigator.pop(context);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Network error. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
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

    final max = int.tryParse(maxStr);
    if (max == null || max <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Max students must be a valid number')),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'name': name, 'level': level, 'max_students': max}),
      );

      final decoded = json.decode(response.body);

      if (response.statusCode == 201) {
        if (!mounted) return;

        Navigator.pop(context);

        _groupNameController.clear();
        _levelController.clear();
        _maxStudentsController.clear();

        _refreshGroups();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Group created successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        final message = decoded['message'] ?? 'Failed to create group';
        Navigator.pop(context);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Network error. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
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

  void _showCreateModuleDialog() {
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
                color: Colors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.book_online,
                color: Colors.purple,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Create New Module',
              style: TextStyle(
                color: cs.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: StatefulBuilder(
          builder: (context, setDialogState) => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDialogTextField(
                  controller: _moduleNameController,
                  hint: 'Module Name',
                  icon: Icons.bookmark_border,
                  cs: cs,
                ),
                const SizedBox(height: 12),
                _buildDialogTextField(
                  controller: _moduleLevelController,
                  hint: 'Level (e.g. L3)',
                  icon: Icons.grade,
                  cs: cs,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  decoration: InputDecoration(
                    hintText: 'Select Teacher',
                    prefixIcon: const Icon(Icons.person, color: Colors.purple),
                    filled: true,
                    fillColor: cs.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: cs.outline.withOpacity(0.5),
                      ),
                    ),
                  ),
                  value: _selectedTeacherIdForModule,
                  items: _allTeachers.map((t) {
                    return DropdownMenuItem<int>(
                      value: t['id'],
                      child: Text(t['username']),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setDialogState(() {
                      _selectedTeacherIdForModule = val;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => _selectedTeacherIdForModule = null);
              Navigator.pop(context);
            },
            child: Text(
              'Cancel',
              style: TextStyle(color: cs.onSurface.withOpacity(0.6)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _createModules();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
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
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'create_module',
            onPressed: _showCreateModuleDialog,
            backgroundColor: Colors.purple,
            foregroundColor: Colors.white,
            elevation: 4,
            icon: const Icon(Icons.book_outlined),
            label: const Text(
              'Create Module',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'create_group',
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
        ],
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
                            Row(
                              children: [
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
                                const SizedBox(width: 6),
                                FutureBuilder<List<dynamic>>(
                                  future: _modulesFuture,
                                  builder: (context, moduleSnapshot) {
                                    final modules = moduleSnapshot.data ?? [];
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: cs.primary.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        '${modules.length} modules',
                                        style: TextStyle(
                                          color: cs.primary,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
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
                            level,
                            style: TextStyle(
                              fontSize: 12,
                              color: cs.onSurface.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Icon(
                            Icons.person_outline,
                            size: 14,
                            color: cs.onSurface.withOpacity(0.5),
                          ),
                          Text(
                            maxStudents.toString(),
                            style: TextStyle(
                              fontSize: 12,
                              color: cs.onSurface.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    color: cs.onSurface.withOpacity(0.7),
                    size: 24,
                  ),
                  color: cs.surface,
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  onSelected: (value) {
                    if (value == 'students') {
                      context.push('/admin-group-details', extra: group);
                    } else if (value == 'add') {
                      context.push('/admin-assignment');
                    } else if (value == 'delete') {
                      _deleteGroup(group['id']);
                    } else if (value == 'program') {
                      context.push('/admin-program', extra: group);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'add',
                      child: Row(
                        children: [
                          Icon(
                            Icons.person_add_alt_1,
                            size: 18,
                            color: cs.primary,
                          ),
                          const SizedBox(width: 10),
                          const Text('Add'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'students',
                      child: Row(
                        children: [
                          Icon(
                            Icons.groups_outlined,
                            size: 18,
                            color: cs.secondary,
                          ),
                          const SizedBox(width: 10),
                          const Text('Students'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'program',
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 18,
                            color: const Color.fromARGB(255, 33, 7, 5),
                          ),
                          const SizedBox(width: 10),
                          const Text('Program'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline,
                            size: 18,
                            color: Colors.red,
                          ),
                          const SizedBox(width: 10),
                          const Text('Delete'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
