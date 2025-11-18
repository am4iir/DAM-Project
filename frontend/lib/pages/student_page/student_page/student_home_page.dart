import 'package:flutter/material.dart';


class StudentHomePage extends StatelessWidget {
  const StudentHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        child: Text('Student Home Page',style: TextStyle(fontSize: 20 ,fontWeight: FontWeight.bold,color: Colors.black)),
      ),
    );
  }
}
