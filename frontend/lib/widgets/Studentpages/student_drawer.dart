import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/pages/student_page/student_page/student_profile_page.dart';
import 'package:frontend/pages/student_page/student_page/student_program_page.dart';
import 'package:frontend/widgets/Studentpages/student_home_widgets.dart';


Widget buildStudentDrawer(
  BuildContext context,
  ColorScheme colorScheme, {
  String? userName,
  String? email,
  String? firstLetter,
  String? secondLetter,
}) {
  return Drawer(
    backgroundColor: colorScheme.surface,
    child: ListView(
      padding: EdgeInsets.zero,
      children: [
        // Drawer Header
        Container(
          height: 200,
          decoration: BoxDecoration(color: colorScheme.primary),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: colorScheme.onPrimary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${firstLetter ?? '?'}${secondLetter ?? ''}',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                userName ?? 'User',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                email ?? 'email@example.com',
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onPrimary.withOpacity(0.85),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Menu Items
        buildDrawerItem(
          context,
          icon: Icons.home_outlined,
          title: 'Home',
          isSelected: true,
          onTap: () => Navigator.pop(context),
        ),
        buildDrawerItem(
          context,
          icon: Icons.calendar_today_outlined,
          title: 'Program',
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const StudentProgramPage(),
              ),
            );
          },
        ),
        buildDrawerItem(
          context,
          icon: Icons.person_outline,
          title: 'Profile',
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const StudentProfilePage(),
              ),
            );
          },
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Divider(color: colorScheme.outline),
        ),

        buildDrawerItem(
          context,
          icon: Icons.logout_outlined,
          title: 'Logout',
          isLogout: true,
          onTap: () {
            Navigator.pop(context);
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: Text(
                  'Logout',
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: Text(
                  'Are you sure you want to logout?',
                  style: TextStyle(color: colorScheme.onSurface),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      prefs.remove('token');
                      prefs.remove('username');
                      prefs.remove('email');
                      context.go('/signin');
                    },
                    child: Text(
                      'Logout',
                      style: TextStyle(
                        color: colorScheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    ),
  );
}
