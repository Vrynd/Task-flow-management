import 'package:flutter/material.dart';

/// AppColors defines the color system for the application.
/// It uses the "Indigo Aurora" palette, customized for both
/// Light and Dark modes.
abstract class AppColors {
  // --- Raw Brand/Palette Colors (Indigo Aurora) ---
  static const Color indigo50 = Color(0xFFE0E7FF);
  static const Color indigo100 = Color(0xFFC7D2FE);
  static const Color indigo500 = Color(0xFF6366F1);
  static const Color indigo600 = Color(0xFF4F46E5);
  static const Color indigo900 = Color(0xFF312E81);

  static const Color blue50 = Color(0xFFEFF6FF);
  static const Color blue100 = Color(0xFFDBEAFE);
  static const Color blue500 = Color(0xFF3B82F6);
  static const Color blue600 = Color(0xFF2563EB);
  static const Color blue900 = Color(0xFF1E3A8A);

  static const Color slate50 = Color(0xFFF8FAFC);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate900 = Color(0xFF0F172A);

  // --- Priority & Status Colors ---
  static const Color priorityHigh = Color(0xFFF43F5E); // Rose 500
  static const Color priorityMedium = Color(0xFFF59E0B); // Amber 500
  static const Color priorityLow = Color(0xFF10B981); // Emerald 500
  static const Color info = Color(0xFF06B6D4); // Cyan 500

  // --- Light Theme Colors ---
  static const Color primaryLight = indigo600;
  static const Color onPrimaryLight = Colors.white;
  static const Color primaryContainerLight = indigo50;
  static const Color onPrimaryContainerLight = indigo900;

  static const Color secondaryLight = blue600;
  static const Color onSecondaryLight = Colors.white;
  static const Color secondaryContainerLight = blue100;
  static const Color onSecondaryContainerLight = blue900;

  static const Color backgroundLight = slate50;
  static const Color onBackgroundLight = slate900;
  
  static const Color surfaceLight = Colors.white;
  static const Color onSurfaceLight = slate900;
  static const Color surfaceVariantLight = slate100;
  static const Color onSurfaceVariantLight = slate600;

  static const Color borderLight = slate200;
  static const Color outlineLight = slate300;
  static const Color textMutedLight = slate400;

  // --- Dark Theme Colors ---
  static const Color primaryDark = indigo500;
  static const Color onPrimaryDark = Colors.white;
  static const Color primaryContainerDark = indigo900;
  static const Color onPrimaryContainerDark = indigo50;

  static const Color secondaryDark = Color(0xFF60A5FA); // Blue 400
  static const Color onSecondaryDark = slate900;
  static const Color secondaryContainerDark = Color(0xFF1E3A8A); // Blue 900
  static const Color onSecondaryContainerDark = Color(0xFFDBEAFE); // Blue 100

  static const Color backgroundDark = slate900;
  static const Color onBackgroundDark = slate50;
  
  static const Color surfaceDark = slate800;
  static const Color onSurfaceDark = slate50;
  static const Color surfaceVariantDark = slate700;
  static const Color onSurfaceVariantDark = slate300;

  static const Color borderDark = slate700;
  static const Color outlineDark = slate500;
  static const Color textMutedDark = slate500;
}
