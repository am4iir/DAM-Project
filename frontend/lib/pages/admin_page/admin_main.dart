
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Admin extends StatelessWidget {
  const Admin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin'),

      ),
      body: Container(
      
        child: Center(child: Text('Admin' ,style: TextStyle(color: Colors.black,fontSize: 30))),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          SharedPreferences.getInstance().then((prefs) {
          prefs.remove('token');
        });
         Navigator.pushNamed(context, '/singin');
         
        },
        child: Icon(Icons.add),
      ),
    );
  }
}