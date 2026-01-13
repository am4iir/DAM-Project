import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/widgets/Teacherpages/teacher_home_widgets.dart';

class TeacherHomePage extends StatefulWidget {
  const TeacherHomePage({super.key});

  @override
  State<TeacherHomePage> createState() => _TeacherHomePageState();
}

class _TeacherHomePageState extends State<TeacherHomePage> {
  String _username = 'Teacher';
  bool _isLoading = true;
  Map<String, dynamic> _stats = {};
  List<dynamic> _schedule = [];

  final String baseUrl = "http://10.0.2.2:3001";

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _loadUserInfo();
    await _fetchDashboardStats();
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? 'Teacher';
    });
  }

  Future<void> _fetchDashboardStats() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('id');
    final teacherId = id?.toString();

    if (teacherId == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/teacher/stats/$teacherId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _stats = data['stats'];
          _schedule = data['schedule'];
          _isLoading = false;
        });
      } else {
        // Handle error
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print("Error fetching stats: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    String greeting = 'Good Morning';
    if (hour >= 12 && hour < 17) greeting = 'Good Afternoon';
    if (hour >= 17) greeting = 'Good Evening';

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              greeting,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _username,
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D3142),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              const Icon(
                                Icons.notifications_outlined,
                                size: 28,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    SizedBox(
                      height: 140,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        clipBehavior: Clip.none,
                        children: [
                          buildTeacherStatCard(
                            title: 'Active Groups',
                            value: '${_stats['activeGroups'] ?? 0}',
                            icon: Icons.class_outlined,
                            color: const Color(0xFF6C63FF),
                          ),
                          const SizedBox(width: 16),
                          buildTeacherStatCard(
                            title: 'Total Students',
                            value: '${_stats['totalStudents'] ?? 0}',
                            icon: Icons.people_outline,
                            color: const Color(0xFF2EC4B6),
                          ),
                          const SizedBox(width: 16),
                          buildTeacherStatCard(
                            title: 'Assignments',
                            value: '${_stats['pendingAssignments'] ?? 0}',
                            icon: Icons.assignment_outlined,
                            color: const Color(0xFFFF9F1C),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    const Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3142),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        buildTeacherActionButton(
                          icon: Icons.add_circle_outline,
                          label: 'Assignments',
                          onTap: () {},
                        ),
                        buildTeacherActionButton(
                          icon: Icons.calendar_today_outlined,
                          label: 'Schedule',
                          onTap: () {},
                        ),
                        buildTeacherActionButton(
                          icon: Icons.grade_outlined,
                          label: 'Grades',
                          onTap: () {},
                        ),
                        buildTeacherActionButton(
                          icon: Icons.message_outlined,
                          label: 'Messages',
                          onTap: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Today's Classes",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3142),
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text('See All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ..._schedule.map((item) => buildTeacherScheduleCard(item)),
                  ],
                ),
              ),
      ),
    );
  }
}
