import 'package:flutter/material.dart';
import 'package:frontend/pages/admin_page/admin_main.dart';
import 'package:frontend/pages/admin_page/admin_page/admin_group_menege_page.dart';
import 'package:frontend/pages/auth/singin_page.dart';
import 'package:frontend/pages/auth/singup_page.dart';
import 'package:frontend/pages/splash_screen_page/splash_screen.dart';
import 'package:frontend/pages/student_page/student_main.dart';
import 'package:frontend/pages/teacher_page/teacher_main.dart';
import 'package:frontend/pages/waiting_page/waiting_page.dart';

void main() {
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Canvas',
      theme: ThemeData(
        colorScheme: const ColorScheme(
          brightness: Brightness.light,

          primary: Color(0xFF00A8B5),
          onPrimary: Color(0xFFFFFFFF),

          secondary: Color(0xFF7B68EE),
          onSecondary: Color(0xFFFFFFFF),

          background: Color(0xFFF5F7FA),
          onBackground: Color(0xFF1A1A1A),

          surface: Color(0xFFFFFFFF),
          onSurface: Color(0xFF2C2C2C),

          error: Color(0xFFE57373),
          onError: Color(0xFFFFFFFF),

          surfaceVariant: Color(0xFFF0F4F8),
          onSurfaceVariant: Color(0xFF5A5A5A),

          outline: Color(0xFFE0E0E0),
        ),
        useMaterial3: true,

        textTheme: const TextTheme(
          displayLarge: TextStyle(
            color: Color(0xFF1A1A1A),
            fontWeight: FontWeight.bold,
          ),
          displayMedium: TextStyle(
            color: Color(0xFF1A1A1A),
            fontWeight: FontWeight.bold,
          ),
          displaySmall: TextStyle(
            color: Color(0xFF1A1A1A),
            fontWeight: FontWeight.bold,
          ),
          headlineMedium: TextStyle(
            color: Color(0xFF2C2C2C),
            fontWeight: FontWeight.w600,
          ),
          titleLarge: TextStyle(
            color: Color(0xFF2C2C2C),
            fontWeight: FontWeight.w600,
          ),
          bodyLarge: TextStyle(
            color: Color(0xFF2C2C2C),
            fontWeight: FontWeight.normal,
          ),
          bodyMedium: TextStyle(
            color: Color(0xFF5A5A5A),
            fontWeight: FontWeight.normal,
          ),
        ),

        cardTheme: CardThemeData(
          color: const Color(0xFFFFFFFF),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: const Color(0xFFE0E0E0).withOpacity(0.5),
              width: 1,
            ),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        ),
      ),

      routes: {
        '/singin': (context) => SinginPage(),
        '/signup': (context) => SingupPage(),
        '/Admin': (context) => Admin(),
        '/Teacher': (context) => Teacher(),
        '/Student': (context) => Student(),
        '/waiting': (context) => WaitingPage(),
      },
      debugShowCheckedModeBanner: false,
      home: Scaffold(body: SolashScreen()),
    );
  }
}
