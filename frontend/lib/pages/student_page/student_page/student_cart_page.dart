import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;
import 'package:frontend/widgets/Studentpages/student_cart_widgets.dart';

class StudentCartPage extends StatefulWidget {
  const StudentCartPage({super.key});

  @override
  State<StudentCartPage> createState() => _StudentCartPageState();
}

class _StudentCartPageState extends State<StudentCartPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _flipAnimation;
  bool _showBack = false;
  String? userName;
  String? email;

  // Sample student data - Replace with actual data from your backend
  final Map<String, String> studentData = {
    'firstName': 'Mohammed',
    'lastName': 'Ahmed',
    'studentId': 'STU-2024-001234',
    'department': 'Computer Science',
    'faculty': 'Faculty of Engineering',
    'university': 'International University',
    'academicYear': '${DateTime.now().year} - ${DateTime.now().year + 1}',
    'level': '3rd Year',
    'dateOfBirth': '15/03/2002',
    'nationality': 'Algeria',
    'bloodType': 'O+',
    'validUntil': '30/06/2025',
  };

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _flipAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    getUserName();
  }

  void getUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      userName = prefs.getString('username');
      email = prefs.getString('email');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleCard() {
    if (_showBack) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
    setState(() {
      _showBack = !_showBack;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Student Card',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Tap the card to flip',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),

                GestureDetector(
                  onTap: _toggleCard,
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      final value = _controller.value;
                      final angle = value * math.pi;

                      return Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..rotateY(angle),
                        child: value < 0.5
                            ? buildFrontCard(
                                context,
                                userName: userName,
                                email: email,
                                studentData: studentData,
                              )
                            : Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.identity()..rotateY(math.pi),
                                child: buildBackCard(
                                  context,
                                  studentData: studentData,
                                ),
                              ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
