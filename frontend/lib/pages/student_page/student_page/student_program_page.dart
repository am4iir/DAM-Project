import 'package:flutter/material.dart';
import 'package:frontend/widgets/calendar/attendance_tab.dart';
import 'package:frontend/widgets/calendar/timetable_tab.dart';
import 'package:frontend/widgets/calendar/events_tab.dart';

class StudentProgramPage extends StatefulWidget {
  const StudentProgramPage({super.key});

  @override
  State<StudentProgramPage> createState() => _StudentProgramPageState();
}

class _StudentProgramPageState extends State<StudentProgramPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Sample data
  final List<DateTime> _absentDates = [
    DateTime(2023, 1, 4),
    DateTime(2023, 1, 21),
  ];
  final List<DateTime> _leaveDates = [
    DateTime(2023, 1, 17),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Removed unnecessary setState listener
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
           
          },
        ),
        title: const Text(
          'Calendar',
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Tab Bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(14),
            ),
            child: TabBar(
              controller: _tabController,
              // Simplified indicator for performance
              indicator: BoxDecoration(
                color: theme.primary,
                borderRadius: BorderRadius.circular(14),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: theme.primary,
              dividerColor: Colors.transparent,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
              tabs: const [
                Tab(text: 'Attendance'),
                Tab(text: 'Timetable'),
                Tab(text: 'Events'),
              ],
            ),
          ),

          // Tab Content - TabBarView already lazy loads tabs
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                AttendanceTab(
                  absentDates: _absentDates,
                  leaveDates: _leaveDates,
                ),
                const TimetableTab(),
                const EventsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
