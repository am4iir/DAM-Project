import 'package:flutter/material.dart';
import 'widgets/router/app_router.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Canvas',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF00A8B5),
          secondary: Color(0xFF7B68EE),
          background: Color(0xFFF5F7FA),
          surface: Color(0xFFFFFFFF),
          error: Color(0xFFE57373),
        ),
      ),
    );
  }
}
