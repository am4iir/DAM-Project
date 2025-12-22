import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  String _username = 'Admin';
  bool _isLoading = true;
  int _totalGroups = 0;
  int _totalUsers = 0;
  int _totalUsersPending = 0;
  int _totalUsersApproved = 0;
  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadTotalGroups();
    _loadTotalUsers();
    _loadTotalUsersApproved();
    _loadTotalUsersPending();
  }

  int _safeParseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.parse(value);
    return 0;
  }

  Future<void> _loadTotalUsers() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3001/admin/groups/numberUsers'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          _totalUsers = _safeParseInt(data['numberOfUsers']);
        });
      }
    } catch (e, stackTrace) {
      print('❌ Error loading total users: $e');
      print('Stack trace: $stackTrace');
    }
  }

  Future<void> _loadTotalUsersApproved() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3001/admin/groups/numberUsersApproved'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          _totalUsersApproved = _safeParseInt(data['numberOfUsersApproved']);
        });
      }
    } catch (e, stackTrace) {
      print('❌ Error loading total users: $e');
      print('Stack trace: $stackTrace');
    }
  }

  Future<void> _loadTotalUsersPending() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3001/admin/groups/numberUsersPending'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          _totalUsersPending = _safeParseInt(data['numberOfUsersPending']);
        });
      }
    } catch (e, stackTrace) {
      print('❌ Error loading total users: $e');
      print('Stack trace: $stackTrace');
    }
  }

  Future<void> _loadTotalGroups() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3001/admin/groups/number-group'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          _totalGroups = _safeParseInt(data['totalGroups']);
        });
      } else {}
    } catch (e, stackTrace) {
      print('❌ Error loading total groups: $e');
      print('Stack trace: $stackTrace');
    }
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? 'Admin';
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: cs.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(theme, cs),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWelcomeCard(theme, cs),
                  const SizedBox(height: 24),
                  _buildStatsSection(theme, cs),
                  const SizedBox(height: 24),
                  _buildQuickActionsSection(theme, cs),
                  const SizedBox(height: 24),
                  _buildRecentActivitySection(theme, cs),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
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
          'Dashboard',
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

  Widget _buildWelcomeCard(ThemeData theme, ColorScheme cs) {
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
                  'Welcome Back,',
                  style: TextStyle(
                    color: cs.onPrimary.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _username,
                  style: TextStyle(
                    color: cs.onPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Manage your platform efficiently',
                  style: TextStyle(
                    color: cs.onPrimary.withOpacity(0.8),
                    fontSize: 13,
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
            child: Icon(
              Icons.admin_panel_settings,
              size: 40,
              color: cs.onPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(ThemeData theme, ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                cs,
                Icons.people,
                _totalUsers.toString(),
                'Total Users',
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                cs,
                Icons.groups,
                _totalGroups.toString(),
                'Groups',
                Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                cs,
                Icons.pending_actions,
                _totalUsersPending.toString(),
                'Pending',
                Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                cs,
                Icons.check_circle,
                _totalUsersApproved.toString(),
                'Approved',
                Colors.teal,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    ColorScheme cs,
    IconData icon,
    String value,
    String label,
    Color accentColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: accentColor, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: cs.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection(ThemeData theme, ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.4,
          children: [
            _buildActionCard(cs, Icons.person_add, 'Add User', Colors.blue, () {
              
            }),
            _buildActionCard(
              cs,
              Icons.group_add,
              'Create Group',
              Colors.green,
              () {
                // TODO: Navigate to create group page
              },
            ),
            _buildActionCard(
              cs,
              Icons.assessment,
              'View Reports',
              Colors.purple,
              () {
                // TODO: Navigate to reports page
              },
            ),
            _buildActionCard(cs, Icons.settings, 'Settings', Colors.orange, () {
              // TODO: Navigate to settings page
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
    ColorScheme cs,
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivitySection(ThemeData theme, ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildActivityItem(
          cs,
          Icons.person_add,
          'New user registered',
          'John Doe joined the platform',
          '2 hours ago',
          Colors.blue,
        ),
        const SizedBox(height: 12),
        _buildActivityItem(
          cs,
          Icons.check_circle,
          'User approved',
          'Sarah Smith was approved',
          '5 hours ago',
          Colors.green,
        ),
        const SizedBox(height: 12),
        _buildActivityItem(
          cs,
          Icons.group,
          'Group created',
          'New study group: Advanced Math',
          '1 day ago',
          Colors.purple,
        ),
        const SizedBox(height: 12),
        _buildActivityItem(
          cs,
          Icons.warning,
          'Pending request',
          '3 users waiting for approval',
          '2 days ago',
          Colors.orange,
        ),
      ],
    );
  }

  Widget _buildActivityItem(
    ColorScheme cs,
    IconData icon,
    String title,
    String subtitle,
    String time,
    Color accentColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outline.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: accentColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: cs.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              fontSize: 11,
              color: cs.onSurface.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }
}
