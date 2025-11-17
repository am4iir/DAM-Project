import 'package:flutter/material.dart';
import 'package:frontend/pages/admin_page/admin_main.dart';
import 'package:frontend/pages/auth/singin_page.dart';
import 'package:frontend/pages/auth/singup_page.dart';
import 'package:frontend/pages/splash_screen.dart';
import 'package:frontend/pages/student_page/student_main.dart';
import 'package:frontend/pages/teacher_page/teacher_main.dart';
import 'package:frontend/pages/test.dart';

void main() {
  runApp( MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      title: 'Canvas',
    theme: ThemeData(
    colorScheme: ColorScheme(
      brightness: Brightness.dark, // Dark mode
      primary: Color(0xFF4B0082),   // Dark purple
      onPrimary: Colors.white,      // Text/icons on primary
      secondary: Color(0xFF6A0DAD), // Slightly lighter purple
      onSecondary: Colors.white,    // Text/icons on secondary
      background: Colors.grey[300], // Almost black background
      onBackground: Colors.white,   // Text on background
      surface: Colors.white,  // Card and button surfaces
      onSurface: Colors.white,      // Text on surfaces
      error: Colors.redAccent,
      onError: Colors.white,
    ),
    useMaterial3: true,
  ),

      routes: {
        '/singin':(context) => SinginPage(),
        '/signup':(context) => SingupPage(),
        '/Admin':(context) => Admin(),
        '/Teacher':(context) => Teacher(),
        '/Student':(context) => Student(),

      },
      debugShowCheckedModeBanner: false,
      home: Scaffold(

        body: SolashScreen(),
      ),
    );
  }
}
