import 'package:frontend/pages/student_page/student_page/student_cart_page.dart';
import 'package:frontend/pages/student_page/student_page/student_home_page.dart';
import 'package:frontend/pages/student_page/student_page/student_profile_page.dart';
import 'package:frontend/pages/student_page/student_page/student_program_page.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:flutter/material.dart';

class Student extends StatefulWidget {
  Student({super.key});

  @override
  State<Student> createState() => _StudentState();
}

class _StudentState extends State<Student> {
  int _selectedIndex = 0;

  final List<Widget> studentPages = [
    StudentHomePage(),
    StudentProgramPage(),
    StudentCartPage(),
    StudentProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,

      // Use IndexedStack to preserve page states when switching tabs
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
              color: Theme.of(context).colorScheme.background,
              border: Border.all(
                color: theme.colorScheme.onBackground.withOpacity(0.08),
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: GNav(
             
              rippleColor: Colors.grey.shade300,
              hoverColor: Colors.black,
              gap: 8,
              activeColor: Theme.of(context).colorScheme.onBackground,
              color:Colors.black87,
              iconSize: 24,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              tabBackgroundColor:Colors.grey.shade300,
              tabActiveBorder: Border.all(
                color: Colors.grey.shade300,
                width: 2,
              ),
            
              selectedIndex: _selectedIndex,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              tabs: const [
                GButton(icon: Icons.home, text: 'Home'),
                GButton(icon: Icons.calendar_month, text: 'Program'),
                GButton(icon: Icons.credit_card, text: 'Card'),
                GButton(icon: Icons.person, text: 'Profile'),
              ],
              onTabChange: (index) => setState(() => _selectedIndex = index),
            ),
          ),
        ),
      ),
    );
  }
}
