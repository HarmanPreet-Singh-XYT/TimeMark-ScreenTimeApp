import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:screentime/sections/UI sections/Settings/theme_customization_model.dart';
import 'package:screentime/sections/controller/settings_data_controller.dart';

// ============== THEME CUSTOMIZATION PROVIDER ==============

class ThemeCustomizationProvider extends ChangeNotifier {
  CustomThemeData _currentTheme = ThemePresets.defaultTheme;
  List<CustomThemeData> _customThemes = [];
  String _themeMode = ThemeOptions.defaultTheme; // NEW: Light/Dark/System

  static const String _currentThemeKey = 'current_theme_id';
  static const String _customThemesKey = 'custom_themes';

  ThemeCustomizationProvider() {
    _loadThemes();
  }

  // ============== GETTERS ==============

  CustomThemeData get currentTheme => _currentTheme;
  List<CustomThemeData> get customThemes => _customThemes;
  String get themeMode => _themeMode; // NEW

  // Convert string mode to AdaptiveThemeMode for FluentAdaptiveTheme
  AdaptiveThemeMode get adaptiveThemeMode {
    switch (_themeMode) {
      case ThemeOptions.dark:
        return AdaptiveThemeMode.dark;
      case ThemeOptions.light:
        return AdaptiveThemeMode.light;
      default:
        return AdaptiveThemeMode.system;
    }
  }

  // Get available theme mode options
  List<String> get availableThemeModes => ThemeOptions.available;

  // ============== LOAD THEMES ==============

  Future<void> _loadThemes() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load custom themes
      final customThemesJson = prefs.getString(_customThemesKey);
      if (customThemesJson != null) {
        final List<dynamic> decoded = jsonDecode(customThemesJson);
        _customThemes =
            decoded.map((json) => CustomThemeData.fromJson(json)).toList();
      }

      // Load current custom theme
      final currentThemeId = prefs.getString(_currentThemeKey);
      if (currentThemeId != null) {
        // Try to find in presets first
        final preset = ThemePresets.getPresetById(currentThemeId);
        if (preset != null) {
          _currentTheme = preset;
        } else {
          // Try to find in custom themes
          try {
            _currentTheme = _customThemes.firstWhere(
              (theme) => theme.id == currentThemeId,
            );
          } catch (e) {
            _currentTheme = ThemePresets.defaultTheme;
          }
        }
      }

      // NEW: Load theme mode from SettingsManager
      _themeMode = SettingsManager().getSetting("theme.selected") ??
          ThemeOptions.defaultTheme;

      // Validate theme mode
      if (!ThemeOptions.available.contains(_themeMode)) {
        _themeMode = ThemeOptions.defaultTheme;
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading themes: $e');
      _currentTheme = ThemePresets.defaultTheme;
      _themeMode = ThemeOptions.defaultTheme;
    }
  }

  // ============== SAVE METHODS ==============

  Future<void> _saveCurrentTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_currentThemeKey, _currentTheme.id);
    } catch (e) {
      debugPrint('Error saving current theme: $e');
    }
  }

  Future<void> _saveCustomThemes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final customThemesJson = jsonEncode(
        _customThemes.map((theme) => theme.toJson()).toList(),
      );
      await prefs.setString(_customThemesKey, customThemesJson);
    } catch (e) {
      debugPrint('Error saving custom themes: $e');
    }
  }

  // ============== THEME MODE (Light/Dark/System) ==============

  /// Set theme mode (Light/Dark/System)
  Future<void> setThemeMode(String mode) async {
    if (!ThemeOptions.available.contains(mode)) {
      mode = ThemeOptions.defaultTheme;
    }

    _themeMode = mode;

    // Save to SettingsManager for persistence
    SettingsManager().updateSetting("theme.selected", mode);

    debugPrint("🎨 Theme mode set to: $mode");
    notifyListeners();
  }

  // ============== CUSTOM THEME (Colors/Accents) ==============

  /// Set current custom theme
  Future<void> setTheme(CustomThemeData theme) async {
    _currentTheme = theme;
    await _saveCurrentTheme();
    notifyListeners();

    // Force a brief delay to ensure UI updates
    await Future.delayed(const Duration(milliseconds: 50));
  }

  /// Add a new custom theme
  Future<void> addCustomTheme(CustomThemeData theme) async {
    _customThemes.add(theme);
    await _saveCustomThemes();
    notifyListeners();
  }

  /// Update an existing custom theme
  Future<void> updateCustomTheme(CustomThemeData updatedTheme) async {
    final index = _customThemes.indexWhere((t) => t.id == updatedTheme.id);
    if (index != -1) {
      _customThemes[index] = updatedTheme;

      // If this is the current theme, update it too
      if (_currentTheme.id == updatedTheme.id) {
        _currentTheme = updatedTheme;
        await _saveCurrentTheme();
      }

      await _saveCustomThemes();
      notifyListeners();
    }
  }

  /// Delete a custom theme
  Future<void> deleteCustomTheme(String themeId) async {
    _customThemes.removeWhere((theme) => theme.id == themeId);

    // If the deleted theme was active, switch to default
    if (_currentTheme.id == themeId) {
      _currentTheme = ThemePresets.defaultTheme;
      await _saveCurrentTheme();
    }

    await _saveCustomThemes();
    notifyListeners();
  }

  /// Reset to default theme (both custom theme and mode)
  Future<void> resetToDefault() async {
    _currentTheme = ThemePresets.defaultTheme;
    _themeMode = ThemeOptions.defaultTheme;

    await _saveCurrentTheme();
    SettingsManager().updateSetting("theme.selected", _themeMode);

    notifyListeners();
  }

  /// Clear all custom themes
  Future<void> clearAllCustomThemes() async {
    _customThemes.clear();

    // If current theme is custom, switch to default
    if (_currentTheme.isCustom) {
      _currentTheme = ThemePresets.defaultTheme;
      await _saveCurrentTheme();
    }

    await _saveCustomThemes();
    notifyListeners();
  }

  // ============== IMPORT/EXPORT ==============

  /// Export theme as JSON
  String exportTheme(CustomThemeData theme) {
    return jsonEncode(theme.toJson());
  }

  /// Import theme from JSON
  Future<CustomThemeData?> importTheme(String jsonString) async {
    try {
      final json = jsonDecode(jsonString);
      final theme = CustomThemeData.fromJson(json);

      // Generate new ID to avoid conflicts
      final importedTheme = theme.copyWith(
        id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
        isCustom: true,
      );

      await addCustomTheme(importedTheme);
      return importedTheme;
    } catch (e) {
      debugPrint('Error importing theme: $e');
      return null;
    }
  }
}
