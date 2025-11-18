import 'package:flutter/material.dart';

class StudentCartPage extends StatelessWidget {
  const StudentCartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        child: Text('Student Cart Page',style: TextStyle(fontSize: 20 ,fontWeight: FontWeight.bold,color: Colors.black)),
      ),
    );
  }
}
