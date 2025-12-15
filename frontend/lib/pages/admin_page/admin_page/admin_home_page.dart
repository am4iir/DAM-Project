import 'package:flutter/material.dart';


class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Home'),
      ),
      body: Container(
        child: Center(child: Text('Admin Home')),
      ),
    );
  }
}