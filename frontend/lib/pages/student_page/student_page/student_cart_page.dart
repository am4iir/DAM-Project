import 'package:flutter/material.dart';

class StudentCartPage extends StatelessWidget {
  const StudentCartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: Text('Student Cart Page'),
      ),
    );
  }
}
