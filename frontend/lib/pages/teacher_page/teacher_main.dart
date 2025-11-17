import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class Teacher extends StatelessWidget {
  const Teacher({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Teacher')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          toastification.show(
            context: context,
            type: ToastificationType.success,
            title: Text("Login Successful"),
            description: Text("Welcome back!"),
            autoCloseDuration: const Duration(seconds: 3),
          );
        },
        child: Icon(Icons.add),
      ),
      body: Container(
        child: Center(
          child: Text(
            'Teaceher',
            style: TextStyle(color: Colors.black, fontSize: 30),
          ),
        ),
      ),
    );
  }
}
