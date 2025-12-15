import 'package:flutter/material.dart';
 
 class AdminProfilePage extends StatelessWidget {
   const AdminProfilePage({super.key});
 
   @override
   Widget build(BuildContext context) {
     return  Scaffold(
      appBar: AppBar(
        title: Text('Admin Profile'),
      ),
      body: Container(
        child: Center(child: Text('Admin Profile')),
      ),
    );
   }
 }