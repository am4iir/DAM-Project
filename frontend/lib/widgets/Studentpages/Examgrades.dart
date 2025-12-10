import 'package:flutter/material.dart';


class Examgrades extends StatefulWidget {
  @override
  _ExamgradesState createState() => _ExamgradesState();
}

class _ExamgradesState extends State<Examgrades> {
  @override
  Widget build(BuildContext context) {
      return Scaffold(
      
      body: Container(
        alignment: Alignment.center,
        child: Text('Exams Grades'),
      ),
    );
  }
}