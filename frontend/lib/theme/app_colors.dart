import 'package:flutter/material.dart';

/// ألوان موحدة للمشروع - مريحة للعينين ومتناسقة
class AppColors {
  AppColors._(); // Private constructor

  // Primary Colors - Teal ناعم
  static const Color primary = Color(0xFF00A8B5);
  static const Color primaryLight = Color(0xFF4DD0E1);
  static const Color primaryDark = Color(0xFF00838F);
  
  // Secondary Colors - Purple ناعم
  static const Color secondary = Color(0xFF7B68EE);
  static const Color secondaryLight = Color(0xFF9C88FF);
  static const Color secondaryDark = Color(0xFF5C4CDB);
  
  // Background Colors - مريحة للعينين
  static const Color background = Color(0xFFF5F7FA);
  static const Color backgroundLight = Color(0xFFFAFBFC);
  static const Color backgroundDark = Color(0xFFE8ECF1);
  
  // Surface Colors - أبيض نقي
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF0F4F8);
  
  // Text Colors - للقراءة المريحة
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF2C2C2C);
  static const Color textTertiary = Color(0xFF5A5A5A);
  static const Color textDisabled = Color(0xFF9E9E9E);
  
  // Border Colors
  static const Color border = Color(0xFFE0E0E0);
  static const Color borderLight = Color(0xFFF0F0F0);
  
  // Pastel Colors - للعناصر الثانوية
  static const Color pastelBlue = Color(0xFFE3F2FD);
  static const Color pastelPurple = Color(0xFFF3E5F5);
  static const Color pastelGreen = Color(0xFFE8F5E9);
  static const Color pastelOrange = Color(0xFFFFF3E0);
  static const Color pastelPink = Color(0xFFFCE4EC);
  
  // Error & Success
  static const Color error = Color(0xFFE57373);
  static const Color success = Color(0xFF81C784);
  static const Color warning = Color(0xFFFFB74D);
  static const Color info = Color(0xFF64B5F6);
  
  // Shadow Colors
  static Color shadowLight = Colors.black.withOpacity(0.05);
  static Color shadowMedium = Colors.black.withOpacity(0.1);
  static Color shadowDark = Colors.black.withOpacity(0.15);
}

/// Helper methods للحصول على ألوان من الـ theme
extension AppColorScheme on ColorScheme {
  Color get pastelPrimary => primary.withOpacity(0.15);
  Color get pastelSecondary => secondary.withOpacity(0.15);
  
  Color get textOnSurface => onSurface;
  Color get textOnSurfaceVariant => onSurfaceVariant;
  
  Color get borderColor => outline.withOpacity(0.3);
  Color get borderColorLight => outline.withOpacity(0.1);
}

