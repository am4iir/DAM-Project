import 'package:flutter/material.dart';

import 'package:frontend/pages/student_page/student_page/student_profile_page.dart';
import 'package:frontend/pages/student_page/student_page/student_program_page.dart';
import 'package:frontend/widgets/Studentpages/groupandsection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/widgets/Studentpages/Examgrades.dart';
import 'package:frontend/widgets/Studentpages/AssessmentPage.dart';
import 'package:frontend/widgets/Studentpages/ExamsSchedule.dart';



class StudentHomePage extends StatefulWidget {
  const StudentHomePage({super.key});

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  String? userName;
  String? firstLetter;
  String? SecendLetter;
  String? email;

  void getUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      userName = prefs.getString('username');
      email = prefs.getString('email');
      if (userName != null && userName!.isNotEmpty) {
        List<String> parts = userName!.split(' ');
        firstLetter = parts[0][0].toUpperCase();
        SecendLetter = parts.length > 1 ? parts[1][0].toUpperCase() : '';
      } else {
        firstLetter = '?';
        SecendLetter = '';
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getUserName();
  }

  @override
  void dispose() {
    super.dispose();
  }
  
  final List<String> bookImages = [
    "assets/logo.png",
    "assets/logo.png",
    "assets/logo.png",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          actionsPadding: const EdgeInsets.only(right: 10),
          backgroundColor: const Color.fromARGB(0, 46, 22, 22),
          elevation: 0,
          leading: Builder(
            builder: (BuildContext ctx) => Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              
              child: IconButton(
                icon: Icon(
                  Icons.menu_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              ),
            ),
          ),
          
          actions: [
            Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.all(5),
              width: 60,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.primary.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(
                '${firstLetter ?? '?'}${SecendLetter ?? ''}',
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onPrimary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person,
                      color: Theme.of(context).colorScheme.primary,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userName ?? 'User',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email ?? 'email',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(
                        context,
                      ).colorScheme.onPrimary.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.home_outlined,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text(
                'Home',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.calendar_month_outlined,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text(
                'Program',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const StudentProgramPage(),
                  ),
                );
              },
            ),

            ListTile(
              leading: Icon(
                Icons.person_outline,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text(
                'Profile',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const StudentProfilePage(),
                  ),
                );
              },
            ),
            Divider(height: 1, thickness: 1, indent: 16, endIndent: 16),
            ListTile(
              leading: Icon(
                Icons.logout_outlined,
                color: Theme.of(context).colorScheme.error,
              ),
              title: Text(
                'Logout',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(
                      'Log out',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    content: Text(
                      'Are you sure you want to log out?',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () async {
                          final prefs = await SharedPreferences.getInstance();
                          prefs.remove('token');
                          prefs.remove('username');
                          prefs.remove('email');
                          Navigator.pushReplacementNamed(context, '/singin');
                        },
                        child: Text(
                          'Log out',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
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
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome Back ',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userName ?? 'Student',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // Banner Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  height: 160,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.primary.withOpacity(0.7),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: PageView.builder(
                      controller: PageController(viewportFraction: 0.8),
                      itemCount: bookImages.length,
                      itemBuilder: (_, i) {
                        return Image.asset(
                          bookImages[i],
                         
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              
                              color: Colors.white,
                              child: Icon(
                                Icons.school,
                                size: 60,
                                color: Colors.white,
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              // Services Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Services',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Services Grid Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.1,
                  children: [
                
                  _buildServiceButton(
                    context,
                    icon: Icons.groups_outlined,
                    label: 'Group and Section',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>  Groupandsection (),
                        ),
                      );
                    },
                  ),
                  _buildServiceButton(
                    context,
                    icon: Icons.school_outlined,
                    label: 'Exam Grades',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>  Examgrades (),
                        ),
                      );
                    },
                  ),
                 
                  _buildServiceButton(
                    context,
                    icon: Icons.event_note_outlined,
                    label: 'Exams Schedule',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>  ExamsSchedule (),
                        ),
                      );
                    },
                  ),
                  _buildServiceButton(
                    context,
                    icon: Icons.edit_outlined,
                    label: 'Assessment',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>  AssessmentPage (),
                        ),
                      );
                    },
                  ),
                  
                  
                 
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
