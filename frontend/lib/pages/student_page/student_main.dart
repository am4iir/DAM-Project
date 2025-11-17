
import 'package:flutter/material.dart';

class Student extends StatelessWidget {
  const Student({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
      
        child: Center(child: Text('student',style: TextStyle(color: Colors.black,fontSize: 30),)),
      ),
    );
  }
}