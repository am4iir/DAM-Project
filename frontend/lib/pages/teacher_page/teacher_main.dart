import 'package:flutter/material.dart';
import 'package:frontend/theme/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Teacher extends StatelessWidget {
  const Teacher({super.key});

 @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(child: Scaffold(
        body: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(left: 25, right: 25),
              child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.black),
                  color: Colors.black,
                  onPressed: () {
                    SharedPreferences.getInstance().then((prefs) {
                      prefs.remove('token');
                    });
                    Navigator.pushReplacementNamed(context, '/singin');

                   
                  },
                ),
                Row(
                  children: [
                    Icon(Icons.search, color: Colors.black),
                    SizedBox(width: 20),
                  Icon(Icons.notifications, color: Colors.black)
                  ],
                )
             ],
          ) ,
            ),
             SizedBox(height: 15),
            Row(
              children: [
                  Container(
                    margin: const EdgeInsets.only(left: 20),
                    child: Text("Teacher Page ", style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold)),
                  )
              ],
            ),
          ],
        ),
      ),
      ),
    );
  }
}