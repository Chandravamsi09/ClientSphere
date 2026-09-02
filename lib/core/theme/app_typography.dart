import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Typography scale for ClientSphere CRM.
///
/// Implements a complete Material 3 compliant typography scale tailored for CRM
/// data density, dashboards, form inputs, and pipeline views.
abstract final class AppTypography {
  /// Builds a [TextTheme] mapped to specific primary and secondary text colors.
  static TextTheme createTextTheme({
    required Color primaryColor,
    required Color secondaryColor,
    required Color mutedColor,
  }) {
    return TextTheme(
      // Display: High-impact dashboard metrics and splash headers
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1.25,
        letterSpacing: -0.5,
        color: primaryColor,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1.28,
        letterSpacing: -0.25,
        color: primaryColor,
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 1.33,
        letterSpacing: 0,
        color: primaryColor,
      ),

      // Headline: Section headers and modal titles
      headlineLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        height: 1.27,
        letterSpacing: 0,
        color: primaryColor,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.3,
        letterSpacing: 0.15,
        color: primaryColor,
      ),
      headlineSmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.33,
        letterSpacing: 0.15,
        color: primaryColor,
      ),

      // Title: Card headers, contact names, and pipeline stages
      titleLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.37,
        letterSpacing: 0.15,
        color: primaryColor,
      ),
      titleMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.42,
        letterSpacing: 0.1,
        color: primaryColor,
      ),
      titleSmall: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        height: 1.46,
        letterSpacing: 0.1,
        color: secondaryColor,
      ),

      // Body: General CRM records, activity logs, and table content
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        letterSpacing: 0.25,
        color: primaryColor,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.42,
        letterSpacing: 0.25,
        color: secondaryColor,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.33,
        letterSpacing: 0.4,
        color: mutedColor,
      ),

      // Label: Button text, status badges, chips, and table headers
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.42,
        letterSpacing: 0.5,
        color: primaryColor,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.33,
        letterSpacing: 0.5,
        color: secondaryColor,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        height: 1.27,
        letterSpacing: 0.5,
        color: mutedColor,
      ),
    );
  }

  /// TextTheme configured for Light mode.
  static final TextTheme lightTextTheme = createTextTheme(
    primaryColor: AppColors.lightTextPrimary,
    secondaryColor: AppColors.lightTextSecondary,
    mutedColor: AppColors.lightTextMuted,
  );

  /// TextTheme configured for Dark mode.
  static final TextTheme darkTextTheme = createTextTheme(
    primaryColor: AppColors.darkTextPrimary,
    secondaryColor: AppColors.darkTextSecondary,
    mutedColor: AppColors.darkTextMuted,
  );
}
