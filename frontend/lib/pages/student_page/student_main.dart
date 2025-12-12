import 'package:flutter/material.dart';
import 'package:frontend/pages/student_page/student_page/student_cart_page.dart';
import 'package:frontend/pages/student_page/student_page/student_home_page.dart';
import 'package:frontend/pages/student_page/student_page/student_profile_page.dart';
import 'package:frontend/pages/student_page/student_page/student_program_page.dart';
import 'package:frontend/widgets/widget/navbar.dart';

class Student extends StatefulWidget {
  const Student({super.key});

  @override
  State<Student> createState() => _StudentState();
}

class _StudentState extends State<Student> {
  int _selectedIndex = 0;

  final List<Widget> studentPages = const [
    StudentHomePage(),
    StudentProgramPage(),
    StudentCartPage(),
    StudentProfilePage(),
  ];

  final List<Map<String, dynamic>> navItems = const [
    {'icon': Icons.home, 'text': 'Home'},
    {'icon': Icons.calendar_month, 'text': 'Program'},
    {'icon': Icons.credit_card, 'text': 'Card'},
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
