import 'package:flutter/material.dart';
import 'package:frontend/pages/teacher_page/teacher_page/teacher_group_page.dart';
import 'package:frontend/pages/teacher_page/teacher_page/teacher_home_page.dart';
import 'package:frontend/pages/teacher_page/teacher_page/teacher_profile.dart';
import 'package:frontend/pages/teacher_page/teacher_page/teacher_program_page.dart';
import 'package:frontend/theme/app_colors.dart';
import 'package:frontend/widgets/widget/navbar.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Teacher extends StatefulWidget {
  const Teacher({super.key});

  @override
  State<Teacher> createState() => _TeacherState();
}

class _TeacherState extends State<Teacher> {
  int _selectedIndex = 0;

  final List<Widget> studentPages = const [
   TeacherHomePage(),
   
   TeacherProgramPage(),
   TeacherGroupPage(),
   TeacherProfilePage(),
    
  ];

  final List<Map<String, dynamic>> navItems = const [
    {'icon': Icons.home, 'text': 'Home'},
    {'icon': Icons.school, 'text': 'Program'},
    {'icon': Icons.group, 'text': 'Group'},
    {'icon': Icons.person, 'text': 'Profile'},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,

      body: IndexedStack(
        index: _selectedIndex,
        children: studentPages,
      ),

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              color: theme.colorScheme.background,
              border: Border.all(
                color: theme.colorScheme.onBackground.withOpacity(0.08),
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Navbar(
              items: navItems,
              selectedIndex: _selectedIndex,
              onChanged: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}