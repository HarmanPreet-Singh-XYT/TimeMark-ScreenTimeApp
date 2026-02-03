import 'package:flutter/material.dart';
import 'package:screentime/sections/UI sections/Settings/theme_customization_model.dart';

// ============== UPDATED APP DESIGN CLASS ==============

class AppDesign {
  final CustomThemeData themeData;

  AppDesign(this.themeData);

  // Factory constructor for default theme
  factory AppDesign.defaultTheme() {
    return AppDesign(ThemePresets.defaultTheme);
  }

  // Brand Colors
  Color get primaryAccent => themeData.primaryAccent;
  Color get secondaryAccent => themeData.secondaryAccent;
  Color get successColor => themeData.successColor;
  Color get warningColor => themeData.warningColor;
  Color get errorColor => themeData.errorColor;

  // Light Theme Colors
  Color get lightBackground => themeData.lightBackground;
  Color get lightSurface => themeData.lightSurface;
  Color get lightSurfaceSecondary => themeData.lightSurfaceSecondary;
  Color get lightBorder => themeData.lightBorder;
  Color get lightTextPrimary => themeData.lightTextPrimary;
  Color get lightTextSecondary => themeData.lightTextSecondary;

  // Dark Theme Colors
  Color get darkBackground => themeData.darkBackground;
  Color get darkSurface => themeData.darkSurface;
  Color get darkSurfaceSecondary => themeData.darkSurfaceSecondary;
  Color get darkBorder => themeData.darkBorder;
  Color get darkTextPrimary => themeData.darkTextPrimary;
  Color get darkTextSecondary => themeData.darkTextSecondary;

  // Spacing (unchanged)
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 12.0;
  static const double spacingLg = 16.0;
  static const double spacingXl = 24.0;

  // Border Radius (unchanged)
  static const double radiusSm = 6.0;
  static const double radiusMd = 8.0;
  static const double radiusLg = 12.0;

  // Animations (unchanged)
  static const Duration animFast = Duration(milliseconds: 150);
  static const Duration animMedium = Duration(milliseconds: 250);
  static const Duration animSlow = Duration(milliseconds: 350);

  // Sidebar (unchanged)
  static const double sidebarExpandedWidth = 280.0;
  static const double sidebarCollapsedWidth = 68.0;

  // Gradients
  LinearGradient get primaryGradient => LinearGradient(
        colors: [primaryAccent, secondaryAccent],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  LinearGradient subtleGradient(bool isDark) => LinearGradient(
        colors: [
          primaryAccent.withValues(alpha: isDark ? 0.15 : 0.08),
          secondaryAccent.withValues(alpha: isDark ? 0.15 : 0.08),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  // Helper method to get colors by theme mode
  Color getBackground(bool isDark) => isDark ? darkBackground : lightBackground;
  Color getSurface(bool isDark) => isDark ? darkSurface : lightSurface;
  Color getSurfaceSecondary(bool isDark) =>
      isDark ? darkSurfaceSecondary : lightSurfaceSecondary;
  Color getBorder(bool isDark) => isDark ? darkBorder : lightBorder;
  Color getTextPrimary(bool isDark) =>
      isDark ? darkTextPrimary : lightTextPrimary;
  Color getTextSecondary(bool isDark) =>
      isDark ? darkTextSecondary : lightTextSecondary;
}

// ============== STATIC DESIGN CONSTANTS ==============
// Keep these for backward compatibility or static references

class AppDesignConstants {
  // Default Brand Colors
  static const Color primaryAccent = Color(0xFF6366F1);
  static const Color secondaryAccent = Color(0xFF8B5CF6);
  static const Color successColor = Color(0xFF10B981);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color errorColor = Color(0xFFEF4444);

  // Default Light Theme
  static const Color lightBackground = Color(0xFFEEF2F7);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceSecondary = Color(0xFFE6EDF7);
  static const Color lightBorder = Color(0xFFCBD5E1);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF475569);

  // Default Dark Theme
  static const Color darkBackground = Color(0xFF0A0F1C);
  static const Color darkSurface = Color(0xFF141D2D);
  static const Color darkSurfaceSecondary = Color(0xFF121822);
  static const Color darkBorder = Color(0xFF1F2A3B);
  static const Color darkTextPrimary = Color(0xFFE0E5EB);
  static const Color darkTextSecondary = Color(0xFF7A8B9B);

  // Spacing
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 12.0;
  static const double spacingLg = 16.0;
  static const double spacingXl = 24.0;

  // Border Radius
  static const double radiusSm = 6.0;
  static const double radiusMd = 8.0;
  static const double radiusLg = 12.0;

  // Animations
  static const Duration animFast = Duration(milliseconds: 150);
  static const Duration animMedium = Duration(milliseconds: 250);
  static const Duration animSlow = Duration(milliseconds: 350);

  // Sidebar
  static const double sidebarExpandedWidth = 280.0;
  static const double sidebarCollapsedWidth = 68.0;
}
