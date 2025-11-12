import 'package:flutter/material.dart';

void main() {
  runApp(const home());
}
class home extends StatelessWidget {
  const home({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Text("Home Page"),
      ) ,
    );
  }
}
