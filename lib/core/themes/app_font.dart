import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// AppFont defines the typography system for the application.
/// It uses "Poppins" for a clean, modern, and geometric UI.
abstract class AppFont {
  // --- Base Text Style ---
  static TextStyle get baseStyle => GoogleFonts.poppins();

  // --- Material 3 TextTheme Generator ---
  static TextTheme getTextTheme([Color? textColor]) {
    final baseTextTheme = GoogleFonts.poppinsTextTheme();

    return baseTextTheme.copyWith(
      // Display: large screens or splash pages
      displayLarge: baseTextTheme.displayLarge?.copyWith(
        fontWeight: FontWeight.w800,
        color: textColor,
      ),
      displayMedium: baseTextTheme.displayMedium?.copyWith(
        fontWeight: FontWeight.w800,
        color: textColor,
      ),
      displaySmall: baseTextTheme.displaySmall?.copyWith(
        fontWeight: FontWeight.w700,
        color: textColor,
      ),

      // Headline: Section headers
      headlineLarge: baseTextTheme.headlineLarge?.copyWith(
        fontWeight: FontWeight.w700,
        fontSize: 32,
        height: 1.2,
        color: textColor,
      ),
      headlineMedium: baseTextTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
        fontSize: 28,
        height: 1.2,
        color: textColor,
      ),
      headlineSmall: baseTextTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w600,
        fontSize: 24,
        height: 1.2,
        color: textColor,
      ),

      // Title: Cards, list items, appBar titles
      titleLarge: baseTextTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        fontSize: 20,
        height: 1.25,
        color: textColor,
      ),
      titleMedium: baseTextTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        fontSize: 16,
        height: 1.25,
        color: textColor,
      ),
      titleSmall: baseTextTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w500,
        fontSize: 14,
        height: 1.2,
        color: textColor,
      ),

      // Body: General text, descriptions, details
      bodyLarge: baseTextTheme.bodyLarge?.copyWith(
        fontWeight: FontWeight.normal,
        fontSize: 16,
        height: 1.5,
        color: textColor,
      ),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.normal,
        fontSize: 14,
        height: 1.45,
        color: textColor,
      ),
      bodySmall: baseTextTheme.bodySmall?.copyWith(
        fontWeight: FontWeight.normal,
        fontSize: 12,
        height: 1.4,
        color: textColor,
      ),

      // Label: Button text, tags, captions
      labelLarge: baseTextTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
        fontSize: 14,
        color: textColor,
      ),
      labelMedium: baseTextTheme.labelMedium?.copyWith(
        fontWeight: FontWeight.w600,
        fontSize: 12,
        color: textColor,
      ),
      labelSmall: baseTextTheme.labelSmall?.copyWith(
        fontWeight: FontWeight.w500,
        fontSize: 10,
        letterSpacing: 0.5,
        color: textColor,
      ),
    );
  }

  // --- Shortcut Text Styles for Direct Use ---
  static TextStyle get heading1 => baseStyle.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 1.2,
      );

  static TextStyle get heading2 => baseStyle.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.2,
      );

  static TextStyle get title => baseStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.3,
      );

  static TextStyle get body => baseStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        height: 1.4,
      );

  static TextStyle get caption => baseStyle.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        height: 1.3,
      );
}
