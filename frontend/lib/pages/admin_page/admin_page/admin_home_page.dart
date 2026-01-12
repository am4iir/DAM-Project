import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/widgets/Adminpages/admin_home_widgets.dart';

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
  int _selectedIndex = 0;
  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);
    try {
      await Future.wait([
        _loadUserData(),
        _loadTotalGroups(),
        _loadTotalUsers(),
        _loadTotalUsersApproved(),
        _loadTotalUsersPending(),
      ]);
    } catch (e) {
      debugPrint('❌ Error loading dashboard data: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
    if (mounted) {
      setState(() {
        _username = prefs.getString('username') ?? 'Admin';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: cs.background,
      body: CustomScrollView(
        slivers: [
          buildAdminSliverAppBar(theme, cs),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildAdminWelcomeCard(theme, cs, _username),
                  const SizedBox(height: 24),
                  _buildStatsSection(theme, cs),
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
              child: buildAdminStatCard(
                cs,
                Icons.people,
                _totalUsers.toString(),
                'Total Users',
                Colors.blue,
                isLoading: _isLoading,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: buildAdminStatCard(
                cs,
                Icons.groups,
                _totalGroups.toString(),
                'Groups',
                Colors.green,
                isLoading: _isLoading,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: buildAdminStatCard(
                cs,
                Icons.pending_actions,
                _totalUsersPending.toString(),
                'Pending',
                Colors.orange,
                isLoading: _isLoading,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: buildAdminStatCard(
                cs,
                Icons.check_circle,
                _totalUsersApproved.toString(),
                'Approved',
                Colors.teal,
                isLoading: _isLoading,
              ),
            ),
          ],
        ),
      ],
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
        buildAdminActivityItem(
          cs,
          Icons.person_add,
          'New user registered',
          'John Doe joined the platform',
          '2 hours ago',
          Colors.blue,
        ),
        const SizedBox(height: 12),
        buildAdminActivityItem(
          cs,
          Icons.check_circle,
          'User approved',
          'Sarah Smith was approved',
          '5 hours ago',
          Colors.green,
        ),
        const SizedBox(height: 12),
        buildAdminActivityItem(
          cs,
          Icons.group,
          'Group created',
          'New study group: Advanced Math',
          '1 day ago',
          Colors.purple,
        ),
        const SizedBox(height: 12),
        buildAdminActivityItem(
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
}
