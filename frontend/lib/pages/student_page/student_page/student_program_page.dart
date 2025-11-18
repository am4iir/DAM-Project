import 'package:flutter/material.dart';

class StudentProgramPage extends StatelessWidget {
  const StudentProgramPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Container(
      child: Text("Student Program Page",style: TextStyle(fontSize: 20 ,fontWeight: FontWeight.bold,color: Colors.black)),
    ));
  }
}