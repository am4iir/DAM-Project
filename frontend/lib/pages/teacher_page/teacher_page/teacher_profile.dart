import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/widgets/widget/profile.dart'; // Import shared ProfileView

class TeacherProfilePage extends StatefulWidget {
  const TeacherProfilePage({super.key});

  @override
  State<TeacherProfilePage> createState() => _TeacherProfilePageState();
}

class _TeacherProfilePageState extends State<TeacherProfilePage> {
  String _username = 'Loading...';
  String _email = 'Loading...';
  String _role = 'Loading...';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? 'Teacher';
      _email = prefs.getString('email') ?? 'teacher@example.com';
      _role = prefs.getString('role') ?? '2';


      if (_role == '2') {
        _role = 'Teacher';
      } else if (_role == '1') {
        _role = 'Admin';
      }

      _isLoading = false;
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('username');
    await prefs.remove('email');

    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/singin', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: ProfileView(
        username: _username,
        email: _email,
        role: 'Teacher',
        roleIcon: Icons.school_outlined,
        onLogout: _logout,
      ),
    );
  }
}
