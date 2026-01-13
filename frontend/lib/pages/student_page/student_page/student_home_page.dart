import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/widgets/Studentpages/student_home_widgets.dart';
import 'package:frontend/widgets/Studentpages/student_drawer.dart';

class StudentHomePage extends StatefulWidget {
  const StudentHomePage({super.key});

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  String? userName;
  String? firstLetter;
  String? secondLetter;
  String? email;
  bool _isLoading = true;
  Map<String, dynamic> _stats = {'assignments': '0', 'exams': '0'};
  List<dynamic> _schedule = [];
  String _todayName = '';
  final String baseUrl = "http://10.0.2.2:3001";

  Future<void> _loadData() async {
    await _getUserInfo();
    await _fetchDashboard();
  }

  Future<void> _getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      userName = prefs.getString('username');
      email = prefs.getString('email');
      if (userName != null && userName!.isNotEmpty) {
        List<String> parts = userName!.split(' ');
        firstLetter = parts[0][0].toUpperCase();
        secondLetter = parts.length > 1 ? parts[1][0].toUpperCase() : '';
      } else {
        firstLetter = '?';
        secondLetter = '';
      }
    });
  }

  Future<void> _fetchDashboard() async {
    final prefs = await SharedPreferences.getInstance();
    final studentId = prefs.getInt('id')?.toString();

    if (studentId == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/student/stats/$studentId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _stats = {
            'assignments': data['stats']['assignments'].toString(),
            'exams': data['stats']['exams'].toString(),
          };
          _schedule = data['schedule'];
          _todayName = data['today'];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print("Error fetching student dashboard: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: colorScheme.primary,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu_rounded, color: colorScheme.onPrimary),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(
          'Home',
          style: TextStyle(
            color: colorScheme.onPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: colorScheme.onPrimary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${firstLetter ?? '?'}${secondLetter ?? ''}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ),
          ),
        ],
      ),
      drawer: buildStudentDrawer(
        context,
        colorScheme,
        userName: userName,
        email: email,
        firstLetter: firstLetter,
        secondLetter: secondLetter,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with curved bottom
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome Back,',
                    style: TextStyle(
                      fontSize: 18,
                      color: colorScheme.onPrimary.withOpacity(0.85),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    userName ?? 'Student',
                    style: TextStyle(
                      fontSize: 28,
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Day Overview / Schedule
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _todayName.isNotEmpty
                            ? "$_todayName's Classes"
                            : "Today's Schedule",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onBackground,
                        ),
                      ),
                      Text(
                        "Plan your learning journey",
                        style: TextStyle(
                          fontSize: 13,
                          color: colorScheme.onSurfaceVariant.withOpacity(0.6),
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                  if (_schedule.isNotEmpty)
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'See All',
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _isLoading
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : _schedule.isEmpty
                  ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceVariant.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: colorScheme.outline.withOpacity(0.1),
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.event_available_outlined,
                            size: 40,
                            color: colorScheme.onSurfaceVariant.withOpacity(
                              0.2,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "No classes for today",
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant.withOpacity(
                                0.6,
                              ),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: _schedule
                          .map((item) => buildStudentScheduleCard(item))
                          .toList(),
                    ),
            ),

            // Stats Cards
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: buildStatCard(
                      context,
                      icon: Icons.assignment_outlined,
                      title: 'Assignments',
                      value: _stats['assignments'],
                      isPrimary: true,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: buildStatCard(
                      context,
                      icon: Icons.event_outlined,
                      title: 'Exams',
                      value: _stats['exams'],
                      isPrimary: false,
                    ),
                  ),
                ],
              ),
            ),

            // Quick Access Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Our Services',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onBackground,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '4 Services',
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Service Cards Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.0,
                children: [
                  buildServiceCard(
                    context,
                    icon: Icons.groups_outlined,
                    title: 'Group & Section',
                    isPrimary: true,
                   
                  ),
                  buildServiceCard(
                    context,
                    icon: Icons.school_outlined,
                    title: 'Exam Grades',
                    isPrimary: false,
                  
                  ),
                  buildServiceCard(
                    context,
                    icon: Icons.calendar_month_outlined,
                    title: 'Exam Schedule',
                    isPrimary: false,
                   
                  ),
                  buildServiceCard(
                    context,
                    icon: Icons.assessment_outlined,
                    title: 'Assessment',
                    isPrimary: true,
                   
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
