import 'package:flutter/material.dart';
import 'package:frontend/pages/singin_page.dart';
import 'package:frontend/pages/singup_page.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      routes: {
        '/singin':(context) => SinginPage(),
        '/signup':(context) => SingupPage(),

      },
      debugShowCheckedModeBanner: false,
      home: Scaffold(

        body: SinginPage(),
      ),
    );
  }
}
