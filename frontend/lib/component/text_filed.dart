import 'package:flutter/material.dart';
import 'package:frontend/const/colors.dart';

class TextFilds extends StatelessWidget {
  const TextFilds({
    super.key,
    required this.hintText,
    required this.obscureText,
    required this.cotroller,
  });
  final String hintText;
  final bool obscureText;
  final TextEditingController cotroller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: cotroller,
      obscureText: obscureText,
      style: const TextStyle(
        fontSize: 16,
        color: primaryColor,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: primaryColor.withOpacity(0.4),
          fontSize: 16,
        ),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }
}
