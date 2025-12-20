import 'package:flutter/material.dart';

class TeacherProgramPage extends StatelessWidget {
  const TeacherProgramPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              Text("Teacher Program Page"),
            ],
          ),
        ),
      ),
    );
  }
}