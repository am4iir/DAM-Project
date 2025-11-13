import 'package:flutter/material.dart';
import 'package:frontend/const/colors.dart';

class Bottom extends StatelessWidget {
  const Bottom({super.key});
  

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
                    onPressed: () {
                      // Handle login button press
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      shadowColor: primaryColor.withOpacity(0.4),
                    ),
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                  );
  }
}