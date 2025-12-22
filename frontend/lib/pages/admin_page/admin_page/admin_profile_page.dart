import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/widgets/widget/profile.dart'; // Import shared ProfileView

class AdminProfilePage extends StatefulWidget {
  const AdminProfilePage({super.key});

  @override
  State<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
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
      _username = prefs.getString('username') ?? 'Admin';
      _email = prefs.getString('email') ?? 'admin@example.com';
      _role = prefs.getString('role') ?? '1';

    
      if (_role == '2') {
        _role = 'Teacher';
      } else if (_role == '1') {
        _role = 'Admin';
      } else {
        _role = 'Administrator';
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
    context.go('/signin');
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
        role: 'Administrator', // Or use _role if you want it dynamic
        roleIcon: Icons.security,
        onLogout: _logout,
      ),
    );
  }
}
