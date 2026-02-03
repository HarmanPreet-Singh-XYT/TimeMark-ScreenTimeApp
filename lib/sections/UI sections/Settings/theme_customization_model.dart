import 'package:flutter/material.dart';

// ============== THEME MODEL ==============

class CustomThemeData {
  final String id;
  final String name;
  final bool isCustom;

  // Brand Colors
  final Color primaryAccent;
  final Color secondaryAccent;
  final Color successColor;
  final Color warningColor;
  final Color errorColor;

  // Light Theme Colors
  final Color lightBackground;
  final Color lightSurface;
  final Color lightSurfaceSecondary;
  final Color lightBorder;
  final Color lightTextPrimary;
  final Color lightTextSecondary;

  // Dark Theme Colors
  final Color darkBackground;
  final Color darkSurface;
  final Color darkSurfaceSecondary;
  final Color darkBorder;
  final Color darkTextPrimary;
  final Color darkTextSecondary;

  CustomThemeData({
    required this.id,
    required this.name,
    this.isCustom = false,
    required this.primaryAccent,
    required this.secondaryAccent,
    required this.successColor,
    required this.warningColor,
    required this.errorColor,
    required this.lightBackground,
    required this.lightSurface,
    required this.lightSurfaceSecondary,
    required this.lightBorder,
    required this.lightTextPrimary,
    required this.lightTextSecondary,
    required this.darkBackground,
    required this.darkSurface,
    required this.darkSurfaceSecondary,
    required this.darkBorder,
    required this.darkTextPrimary,
    required this.darkTextSecondary,
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'isCustom': isCustom,
      'primaryAccent': primaryAccent.value,
      'secondaryAccent': secondaryAccent.value,
      'successColor': successColor.value,
      'warningColor': warningColor.value,
      'errorColor': errorColor.value,
      'lightBackground': lightBackground.value,
      'lightSurface': lightSurface.value,
      'lightSurfaceSecondary': lightSurfaceSecondary.value,
      'lightBorder': lightBorder.value,
      'lightTextPrimary': lightTextPrimary.value,
      'lightTextSecondary': lightTextSecondary.value,
      'darkBackground': darkBackground.value,
      'darkSurface': darkSurface.value,
      'darkSurfaceSecondary': darkSurfaceSecondary.value,
      'darkBorder': darkBorder.value,
      'darkTextPrimary': darkTextPrimary.value,
      'darkTextSecondary': darkTextSecondary.value,
    };
  }

  // Create from JSON
  factory CustomThemeData.fromJson(Map<String, dynamic> json) {
    return CustomThemeData(
      id: json['id'],
      name: json['name'],
      isCustom: json['isCustom'] ?? false,
      primaryAccent: Color(json['primaryAccent']),
      secondaryAccent: Color(json['secondaryAccent']),
      successColor: Color(json['successColor']),
      warningColor: Color(json['warningColor']),
      errorColor: Color(json['errorColor']),
      lightBackground: Color(json['lightBackground']),
      lightSurface: Color(json['lightSurface']),
      lightSurfaceSecondary: Color(json['lightSurfaceSecondary']),
      lightBorder: Color(json['lightBorder']),
      lightTextPrimary: Color(json['lightTextPrimary']),
      lightTextSecondary: Color(json['lightTextSecondary']),
      darkBackground: Color(json['darkBackground']),
      darkSurface: Color(json['darkSurface']),
      darkSurfaceSecondary: Color(json['darkSurfaceSecondary']),
      darkBorder: Color(json['darkBorder']),
      darkTextPrimary: Color(json['darkTextPrimary']),
      darkTextSecondary: Color(json['darkTextSecondary']),
    );
  }

  // Create a copy with modified values
  CustomThemeData copyWith({
    String? id,
    String? name,
    bool? isCustom,
    Color? primaryAccent,
    Color? secondaryAccent,
    Color? successColor,
    Color? warningColor,
    Color? errorColor,
    Color? lightBackground,
    Color? lightSurface,
    Color? lightSurfaceSecondary,
    Color? lightBorder,
    Color? lightTextPrimary,
    Color? lightTextSecondary,
    Color? darkBackground,
    Color? darkSurface,
    Color? darkSurfaceSecondary,
    Color? darkBorder,
    Color? darkTextPrimary,
    Color? darkTextSecondary,
  }) {
    return CustomThemeData(
      id: id ?? this.id,
      name: name ?? this.name,
      isCustom: isCustom ?? this.isCustom,
      primaryAccent: primaryAccent ?? this.primaryAccent,
      secondaryAccent: secondaryAccent ?? this.secondaryAccent,
      successColor: successColor ?? this.successColor,
      warningColor: warningColor ?? this.warningColor,
      errorColor: errorColor ?? this.errorColor,
      lightBackground: lightBackground ?? this.lightBackground,
      lightSurface: lightSurface ?? this.lightSurface,
      lightSurfaceSecondary:
          lightSurfaceSecondary ?? this.lightSurfaceSecondary,
      lightBorder: lightBorder ?? this.lightBorder,
      lightTextPrimary: lightTextPrimary ?? this.lightTextPrimary,
      lightTextSecondary: lightTextSecondary ?? this.lightTextSecondary,
      darkBackground: darkBackground ?? this.darkBackground,
      darkSurface: darkSurface ?? this.darkSurface,
      darkSurfaceSecondary: darkSurfaceSecondary ?? this.darkSurfaceSecondary,
      darkBorder: darkBorder ?? this.darkBorder,
      darkTextPrimary: darkTextPrimary ?? this.darkTextPrimary,
      darkTextSecondary: darkTextSecondary ?? this.darkTextSecondary,
    );
  }

  /// Helper method to update any color by key
  CustomThemeData updateColor(String colorKey, Color color) {
    switch (colorKey) {
      // Brand Colors
      case 'primaryAccent':
        return copyWith(primaryAccent: color);
      case 'secondaryAccent':
        return copyWith(secondaryAccent: color);
      case 'successColor':
        return copyWith(successColor: color);
      case 'warningColor':
        return copyWith(warningColor: color);
      case 'errorColor':
        return copyWith(errorColor: color);

      // Light Theme Colors
      case 'lightBackground':
        return copyWith(lightBackground: color);
      case 'lightSurface':
        return copyWith(lightSurface: color);
      case 'lightSurfaceSecondary':
        return copyWith(lightSurfaceSecondary: color);
      case 'lightBorder':
        return copyWith(lightBorder: color);
      case 'lightTextPrimary':
        return copyWith(lightTextPrimary: color);
      case 'lightTextSecondary':
        return copyWith(lightTextSecondary: color);

      // Dark Theme Colors
      case 'darkBackground':
        return copyWith(darkBackground: color);
      case 'darkSurface':
        return copyWith(darkSurface: color);
      case 'darkSurfaceSecondary':
        return copyWith(darkSurfaceSecondary: color);
      case 'darkBorder':
        return copyWith(darkBorder: color);
      case 'darkTextPrimary':
        return copyWith(darkTextPrimary: color);
      case 'darkTextSecondary':
        return copyWith(darkTextSecondary: color);

      default:
        return this;
    }
  }

  /// Get color by key (for dynamic access)
  Color? getColor(String colorKey) {
    switch (colorKey) {
      case 'primaryAccent':
        return primaryAccent;
      case 'secondaryAccent':
        return secondaryAccent;
      case 'successColor':
        return successColor;
      case 'warningColor':
        return warningColor;
      case 'errorColor':
        return errorColor;
      case 'lightBackground':
        return lightBackground;
      case 'lightSurface':
        return lightSurface;
      case 'lightSurfaceSecondary':
        return lightSurfaceSecondary;
      case 'lightBorder':
        return lightBorder;
      case 'lightTextPrimary':
        return lightTextPrimary;
      case 'lightTextSecondary':
        return lightTextSecondary;
      case 'darkBackground':
        return darkBackground;
      case 'darkSurface':
        return darkSurface;
      case 'darkSurfaceSecondary':
        return darkSurfaceSecondary;
      case 'darkBorder':
        return darkBorder;
      case 'darkTextPrimary':
        return darkTextPrimary;
      case 'darkTextSecondary':
        return darkTextSecondary;
      default:
        return null;
    }
  }
}

// ============== THEME PRESETS ==============

class ThemePresets {
  // Default Theme (Current)
  static CustomThemeData get defaultTheme => CustomThemeData(
        id: 'default',
        name: 'Default',
        primaryAccent: const Color(0xFF6366F1),
        secondaryAccent: const Color(0xFF8B5CF6),
        successColor: const Color(0xFF10B981),
        warningColor: const Color(0xFFF59E0B),
        errorColor: const Color(0xFFEF4444),
        lightBackground: const Color(0xFFEEF2F7),
        lightSurface: const Color(0xFFFFFFFF),
        lightSurfaceSecondary: const Color(0xFFE6EDF7),
        lightBorder: const Color(0xFFCBD5E1),
        lightTextPrimary: const Color(0xFF0F172A),
        lightTextSecondary: const Color(0xFF475569),
        darkBackground: const Color(0xFF0A0F1C),
        darkSurface: const Color(0xFF141D2D),
        darkSurfaceSecondary: const Color(0xFF121822),
        darkBorder: const Color(0xFF1F2A3B),
        darkTextPrimary: const Color(0xFFE0E5EB),
        darkTextSecondary: const Color(0xFF7A8B9B),
      );

  // Ocean Blue Theme
  static CustomThemeData get oceanBlue => CustomThemeData(
        id: 'ocean_blue',
        name: 'Ocean Blue',
        primaryAccent: const Color(0xFF0EA5E9),
        secondaryAccent: const Color(0xFF06B6D4),
        successColor: const Color(0xFF14B8A6),
        warningColor: const Color(0xFFFBBF24),
        errorColor: const Color(0xFFF87171),
        lightBackground: const Color(0xFFEFF6FF),
        lightSurface: const Color(0xFFFFFFFF),
        lightSurfaceSecondary: const Color(0xFFDCEFFE),
        lightBorder: const Color(0xFFBAE6FD),
        lightTextPrimary: const Color(0xFF0C4A6E),
        lightTextSecondary: const Color(0xFF475569),
        darkBackground: const Color(0xFF082F49),
        darkSurface: const Color(0xFF0E4C6D),
        darkSurfaceSecondary: const Color(0xFF0A3A57),
        darkBorder: const Color(0xFF155E85),
        darkTextPrimary: const Color(0xFFE0F2FE),
        darkTextSecondary: const Color(0xFF7DD3FC),
      );

  // Forest Green Theme
  static CustomThemeData get forestGreen => CustomThemeData(
        id: 'forest_green',
        name: 'Forest Green',
        primaryAccent: const Color(0xFF10B981),
        secondaryAccent: const Color(0xFF059669),
        successColor: const Color(0xFF22C55E),
        warningColor: const Color(0xFFF59E0B),
        errorColor: const Color(0xFFEF4444),
        lightBackground: const Color(0xFFF0FDF4),
        lightSurface: const Color(0xFFFFFFFF),
        lightSurfaceSecondary: const Color(0xFFDCFCE7),
        lightBorder: const Color(0xFFBBF7D0),
        lightTextPrimary: const Color(0xFF064E3B),
        lightTextSecondary: const Color(0xFF475569),
        darkBackground: const Color(0xFF022C22),
        darkSurface: const Color(0xFF064E3B),
        darkSurfaceSecondary: const Color(0xFF043A2E),
        darkBorder: const Color(0xFF065F46),
        darkTextPrimary: const Color(0xFFD1FAE5),
        darkTextSecondary: const Color(0xFF6EE7B7),
      );

  // Sunset Orange Theme
  static CustomThemeData get sunsetOrange => CustomThemeData(
        id: 'sunset_orange',
        name: 'Sunset Orange',
        primaryAccent: const Color(0xFFF97316),
        secondaryAccent: const Color(0xFFEA580C),
        successColor: const Color(0xFF10B981),
        warningColor: const Color(0xFFFBBF24),
        errorColor: const Color(0xFFEF4444),
        lightBackground: const Color(0xFFFFF7ED),
        lightSurface: const Color(0xFFFFFFFF),
        lightSurfaceSecondary: const Color(0xFFFFEDD5),
        lightBorder: const Color(0xFFFED7AA),
        lightTextPrimary: const Color(0xFF7C2D12),
        lightTextSecondary: const Color(0xFF475569),
        darkBackground: const Color(0xFF431407),
        darkSurface: const Color(0xFF7C2D12),
        darkSurfaceSecondary: const Color(0xFF5A1F0D),
        darkBorder: const Color(0xFF9A3412),
        darkTextPrimary: const Color(0xFFFED7AA),
        darkTextSecondary: const Color(0xFFFB923C),
      );

  // Purple Dream Theme
  static CustomThemeData get purpleDream => CustomThemeData(
        id: 'purple_dream',
        name: 'Purple Dream',
        primaryAccent: const Color(0xFFA855F7),
        secondaryAccent: const Color(0xFF9333EA),
        successColor: const Color(0xFF10B981),
        warningColor: const Color(0xFFF59E0B),
        errorColor: const Color(0xFFEF4444),
        lightBackground: const Color(0xFFFAF5FF),
        lightSurface: const Color(0xFFFFFFFF),
        lightSurfaceSecondary: const Color(0xFFF3E8FF),
        lightBorder: const Color(0xFFE9D5FF),
        lightTextPrimary: const Color(0xFF581C87),
        lightTextSecondary: const Color(0xFF475569),
        darkBackground: const Color(0xFF3B0764),
        darkSurface: const Color(0xFF581C87),
        darkSurfaceSecondary: const Color(0xFF4A1472),
        darkBorder: const Color(0xFF6B21A8),
        darkTextPrimary: const Color(0xFFF3E8FF),
        darkTextSecondary: const Color(0xFFD8B4FE),
      );

  // Rose Pink Theme
  static CustomThemeData get rosePink => CustomThemeData(
        id: 'rose_pink',
        name: 'Rose Pink',
        primaryAccent: const Color(0xFFF43F5E),
        secondaryAccent: const Color(0xFFE11D48),
        successColor: const Color(0xFF10B981),
        warningColor: const Color(0xFFF59E0B),
        errorColor: const Color(0xFFEF4444),
        lightBackground: const Color(0xFFFFF1F2),
        lightSurface: const Color(0xFFFFFFFF),
        lightSurfaceSecondary: const Color(0xFFFFE4E6),
        lightBorder: const Color(0xFFFECDD3),
        lightTextPrimary: const Color(0xFF881337),
        lightTextSecondary: const Color(0xFF475569),
        darkBackground: const Color(0xFF4C0519),
        darkSurface: const Color(0xFF881337),
        darkSurfaceSecondary: const Color(0xFF6B0E28),
        darkBorder: const Color(0xFF9F1239),
        darkTextPrimary: const Color(0xFFFFE4E6),
        darkTextSecondary: const Color(0xFFFDA4AF),
      );

  // Monochrome Theme
  static CustomThemeData get monochrome => CustomThemeData(
        id: 'monochrome',
        name: 'Monochrome',
        primaryAccent: const Color(0xFF525252),
        secondaryAccent: const Color(0xFF404040),
        successColor: const Color(0xFF737373),
        warningColor: const Color(0xFFA3A3A3),
        errorColor: const Color(0xFF262626),
        lightBackground: const Color(0xFFFAFAFA),
        lightSurface: const Color(0xFFFFFFFF),
        lightSurfaceSecondary: const Color(0xFFF5F5F5),
        lightBorder: const Color(0xFFE5E5E5),
        lightTextPrimary: const Color(0xFF171717),
        lightTextSecondary: const Color(0xFF525252),
        darkBackground: const Color(0xFF0A0A0A),
        darkSurface: const Color(0xFF171717),
        darkSurfaceSecondary: const Color(0xFF0F0F0F),
        darkBorder: const Color(0xFF262626),
        darkTextPrimary: const Color(0xFFFAFAFA),
        darkTextSecondary: const Color(0xFFA3A3A3),
      );

  // Get all available presets
  static List<CustomThemeData> get allPresets => [
        defaultTheme,
        oceanBlue,
        forestGreen,
        sunsetOrange,
        purpleDream,
        rosePink,
        monochrome,
      ];

  // Get preset by ID
  static CustomThemeData? getPresetById(String id) {
    try {
      return allPresets.firstWhere((theme) => theme.id == id);
    } catch (e) {
      return null;
    }
  }
}
