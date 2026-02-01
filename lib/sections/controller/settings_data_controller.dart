import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:adaptive_theme/adaptive_theme.dart';

// Theme constants
class ThemeOptions {
  static const String system = "System";
  static const String dark = "Dark";
  static const String light = "Light";
  static const List<String> available = [system, dark, light];
  static const String defaultTheme = system;
}

// Language constants
class LanguageOptions {
  static const List<Map<String, String>> available = [
    {'code': 'en', 'name': 'English'},
    {'code': 'zh', 'name': '中文 (Chinese)'},
    {'code': 'hi', 'name': 'हिन्दी (Hindi)'},
    {'code': 'es', 'name': 'Español'},
    {'code': 'fr', 'name': 'Français'},
    {'code': 'ar', 'name': 'العربية (Arabic)'},
    {'code': 'bn', 'name': 'বাংলা (Bengali)'},
    {'code': 'pt', 'name': 'Português'},
    {'code': 'ru', 'name': 'Русский (Russian)'},
    {'code': 'ur', 'name': 'اردو (Urdu)'},
    {'code': 'id', 'name': 'Bahasa Indonesia'},
    {'code': 'ja', 'name': '日本語 (Japanese)'},
  ];

  static const String defaultLanguage = "en";
}

// Focus mode constants
class FocusModeOptions {
  static const String custom = "Custom";
  static const List<String> available = [custom];
  static const String defaultMode = custom;
}

// App category constants
class CategoryOptions {
  static const String all = "All";
  static const List<String> available = [all];
  static const String defaultCategory = all;
}

// Idle timeout preset options
class IdleTimeoutOptions {
  // Values only - labels are handled via localization in the UI
  static const List<Map<String, dynamic>> presets = [
    {'value': 30}, // 30 seconds
    {'value': 60}, // 1 minute
    {'value': 120}, // 2 minutes
    {'value': 300}, // 5 minutes
    {'value': 600}, // 10 minutes
    {'value': -1}, // Custom
  ];

  static const int defaultTimeout = 600; // 10 minute default
  static const int minTimeout = 10; // 10 seconds minimum
  static const int maxTimeout = 3600; // 1 hour maximum
}

class SettingsManager {
  static final SettingsManager _instance = SettingsManager._internal();

  factory SettingsManager() {
    return _instance;
  }

  SettingsManager._internal();

  late SharedPreferences _prefs;

  /// Settings Map
  Map<String, dynamic> settings = {
    "theme": {
      "selected": ThemeOptions.defaultTheme,
    },
    "language": {
      "selected": LanguageOptions.defaultLanguage,
    },
    "launchAtStartup": true,
    "launchAsMinimized": false,
    "notifications": {
      "enabled": true,
      "focusMode": true,
      "screenTime": true,
      "appScreenTime": true,
    },
    "limitsAlerts": {
      "popup": true,
      "frequent": true,
      "sound": true,
      "system": true,
      "overallLimit": {"enabled": false, "hours": 2, "minutes": 0}
    },
    "applications": {
      "tracking": true,
      "isHidden": false,
      "selectedCategory": CategoryOptions.defaultCategory
    },
    "focusModeSettings": {
      "selectedMode": FocusModeOptions.defaultMode,
      "workDuration": 25.0,
      "shortBreak": 5.0,
      "longBreak": 15.0,
      "autoStart": false,
      "blockDistractions": false,
      "enableSoundsNotifications": true
    },
    "notificationController": {
      "reminderFrequency": 5, // minutes
    },
    // All tracking settings default to true
    "tracking": {
      "idleDetection": true,
      "idleTimeout": IdleTimeoutOptions.defaultTimeout,
      "monitorAudio": true,
      "monitorControllers": true,
      "monitorHIDDevices": true,
      "audioThreshold": 0.01,
    }
  };

  Map<String, String> versionInfo = {
    "version": "1.2.2",
    "type": "Stable Build"
  };

  /// Initialize SharedPreferences and load settings
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadSettings();
  }

  /// Load settings from SharedPreferences
  void _loadSettings() {
    String? storedSettings = _prefs.getString("screenTime_settings");
    if (storedSettings != null) {
      Map<String, dynamic> loadedSettings = jsonDecode(storedSettings);

      // Merge loaded settings with default settings
      _mergeSettings(settings, loadedSettings);

      // Validate theme
      if (!ThemeOptions.available.contains(settings["theme"]["selected"])) {
        settings["theme"]["selected"] = ThemeOptions.defaultTheme;
      }

      // Validate language - check if it's a valid language code
      String currentLang = settings["language"]["selected"];
      bool isValidLang =
          LanguageOptions.available.any((lang) => lang['code'] == currentLang);
      if (!isValidLang) {
        settings["language"]["selected"] = LanguageOptions.defaultLanguage;
      }

      // Validate focus mode
      if (settings.containsKey("focusModeSettings") &&
          settings["focusModeSettings"].containsKey("selectedMode") &&
          !FocusModeOptions.available
              .contains(settings["focusModeSettings"]["selectedMode"])) {
        settings["focusModeSettings"]["selectedMode"] =
            FocusModeOptions.defaultMode;
      }

      // Validate category
      if (settings.containsKey("applications") &&
          settings["applications"].containsKey("selectedCategory") &&
          !CategoryOptions.available
              .contains(settings["applications"]["selectedCategory"])) {
        settings["applications"]["selectedCategory"] =
            CategoryOptions.defaultCategory;
      }

      // Validate tracking settings
      if (settings.containsKey("tracking")) {
        // Ensure idleTimeout is within reasonable bounds
        int idleTimeout = settings["tracking"]["idleTimeout"] ??
            IdleTimeoutOptions.defaultTimeout;
        if (idleTimeout < IdleTimeoutOptions.minTimeout) {
          idleTimeout = IdleTimeoutOptions.minTimeout;
        }
        if (idleTimeout > IdleTimeoutOptions.maxTimeout) {
          idleTimeout = IdleTimeoutOptions.maxTimeout;
        }
        settings["tracking"]["idleTimeout"] = idleTimeout;

        // Ensure audioThreshold is within valid range (0.0001 - 0.1)
        double audioThreshold = settings["tracking"]["audioThreshold"] ?? 0.001;
        if (audioThreshold < 0.0001) audioThreshold = 0.0001;
        if (audioThreshold > 0.1) audioThreshold = 0.1;
        settings["tracking"]["audioThreshold"] = audioThreshold;
      }
    }
  }

  // Recursively merge loaded settings into default settings
  void _mergeSettings(
      Map<String, dynamic> target, Map<String, dynamic> source) {
    source.forEach((key, value) {
      if (value is Map<String, dynamic> &&
          target.containsKey(key) &&
          target[key] is Map) {
        _mergeSettings(target[key], value);
      } else {
        target[key] = value;
      }
    });
  }

  /// Save settings to SharedPreferences
  void _saveSettings() {
    _prefs.setString("screenTime_settings", jsonEncode(settings));
  }

  /// Update any setting dynamically
  void updateSetting(String key, dynamic value, [BuildContext? context]) async {
    List<String> keys = key.split(".");

    if (keys.length == 1) {
      if (settings.containsKey(keys[0])) {
        settings[keys[0]] = value;
      } else {
        debugPrint("❌ ERROR: Invalid setting: ${keys[0]}");
      }
    } else {
      Map<String, dynamic> current = settings;

      // Navigate to the nested object
      for (int i = 0; i < keys.length - 1; i++) {
        if (!current.containsKey(keys[i])) {
          current[keys[i]] = <String, dynamic>{};
          debugPrint("Creating missing nested setting: ${keys[i]}");
        } else if (current[keys[i]] is! Map) {
          current[keys[i]] = <String, dynamic>{};
          debugPrint("Converting to map: ${keys[i]}");
        }
        current = current[keys[i]];
      }

      current[keys.last] = value;
    }

    _saveSettings();

    // Log specific setting updates
    if (keys.isNotEmpty) {
      if (keys[0] == "notificationController") {
        debugPrint("🔔 Updated notification setting: $key = $value");
      } else if (keys[0] == "tracking") {
        debugPrint("📊 Updated tracking setting: $key = $value");
      }
    }
  }

  /// Apply the theme based on the selected theme value
  void applyTheme(String themeName, BuildContext context) {
    switch (themeName) {
      case ThemeOptions.dark:
        AdaptiveTheme.of(context).setDark();
        debugPrint("🎨 Theme set to Dark mode");
        break;
      case ThemeOptions.light:
        AdaptiveTheme.of(context).setLight();
        debugPrint("🎨 Theme set to Light mode");
        break;
      case ThemeOptions.system:
      default:
        AdaptiveTheme.of(context).setSystem();
        debugPrint("🎨 Theme set to System default mode");
        break;
    }
  }

  /// Apply current theme setting to the given context
  void applyCurrentTheme(BuildContext context) {
    String currentTheme =
        getSetting("theme.selected") ?? ThemeOptions.defaultTheme;
    applyTheme(currentTheme, context);
  }

  /// Get any setting dynamically
  dynamic getSetting(String key) {
    List<String> keys = key.split(".");
    dynamic current = settings;

    for (String k in keys) {
      if (current is Map && current.containsKey(k)) {
        current = current[k];
      } else {
        debugPrint("❌ ERROR: Setting not found: $key");
        return null;
      }
    }
    return current;
  }

  /// Save a setting directly (used for locale storage)
  Future<void> saveSetting(String key, dynamic value) async {
    await _prefs.setString(key, value.toString());
  }

  // Get available theme options
  List<String> getAvailableThemes() {
    return ThemeOptions.available;
  }

  // Get available language options
  List<Map<String, String>> getAvailableLanguages() {
    return LanguageOptions.available;
  }

  // Get available focus mode options
  List<String> getAvailableFocusModes() {
    return FocusModeOptions.available;
  }

  // Get available category options
  List<String> getAvailableCategories() {
    return CategoryOptions.available;
  }

  // Get available idle timeout presets
  List<Map<String, dynamic>> getIdleTimeoutPresets() {
    return IdleTimeoutOptions.presets;
  }

  /// Reset settings to default
  Future<void> resetSettings([BuildContext? context]) async {
    final Map<String, dynamic> defaultSettings = {
      "theme": {
        "selected": ThemeOptions.defaultTheme,
      },
      "language": {
        "selected": LanguageOptions.defaultLanguage,
      },
      "launchAtStartup": true,
      "launchAsMinimized": false,
      "notifications": {
        "enabled": true,
        "focusMode": true,
        "screenTime": true,
        "appScreenTime": true,
      },
      "limitsAlerts": {
        "popup": true,
        "frequent": true,
        "sound": true,
        "system": true,
        "overallLimit": {"enabled": false, "hours": 2, "minutes": 0}
      },
      "applications": {
        "tracking": true,
        "isHidden": false,
        "selectedCategory": CategoryOptions.defaultCategory
      },
      "focusModeSettings": {
        "selectedMode": FocusModeOptions.defaultMode,
        "workDuration": 25.0,
        "shortBreak": 5.0,
        "longBreak": 15.0,
        "autoStart": false,
        "blockDistractions": false,
        "enableSoundsNotifications": true
      },
      "notificationController": {
        "reminderFrequency": 5,
      },
      // All tracking settings default to true
      "tracking": {
        "idleDetection": true,
        "idleTimeout": IdleTimeoutOptions.defaultTimeout,
        "monitorAudio": true,
        "monitorControllers": true,
        "monitorHIDDevices": true,
        "audioThreshold": 0.01,
      }
    };

    settings = Map<String, dynamic>.from(defaultSettings);
    _saveSettings();

    debugPrint("✅ Settings reset to default values");
  }
}
