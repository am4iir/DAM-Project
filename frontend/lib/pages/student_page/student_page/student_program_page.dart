import 'package:flutter/material.dart';

import 'package:frontend/widgets/calendar/timetable_tab.dart';

class StudentProgramPage extends StatefulWidget {
  const StudentProgramPage({super.key});

  @override
  State<StudentProgramPage> createState() => _StudentProgramPageState();
}

class _StudentProgramPageState extends State<StudentProgramPage>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

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
      body: SingleChildScrollView(
        child: Column(
          children: [
            TimetableTab(),

            // Tab Content - TabBarView already lazy loads tabs
          ],
        ),
      ),
    );
  }
}
