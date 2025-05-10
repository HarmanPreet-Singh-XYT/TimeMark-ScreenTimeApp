import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:launch_at_startup/launch_at_startup.dart';
// import 'package:package_info_plus/package_info_plus.dart';
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
  static const String english = "English";
  static const List<String> available = [english];
  static const String defaultLanguage = english;
}

// Focus mode constants
class FocusModeOptions {
  static const String custom = "Custom";
  static const List<String> available = [custom]; // Add more as needed
  static const String defaultMode = custom;
}

// App category constants
class CategoryOptions {
  static const String all = "All";
  static const List<String> available = [all]; // Add more as needed
  static const String defaultCategory = all;
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
    "launchAsMinimized":false,
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
      "overallLimit": {
        "enabled": false,
        "hours": 2,
        "minutes": 0
      }
    },
    "applications": {
      "tracking": true,
      "isHidden": false,
      "selectedCategory": CategoryOptions.defaultCategory
    },
    "focusModeSettings":{
      "selectedMode": FocusModeOptions.defaultMode,
      "workDuration": 25.0,
      "shortBreak": 5.0,
      "longBreak": 15.0,
      "autoStart": false,
      "blockDistractions": false,
      "enableSoundsNotifications": true
    },
    // Add the new notificationController section with default values
    "notificationController": {
      "reminderFrequency": 5, // minutes
    }
  };
  Map<String, String> versionInfo = {"version": "1.1.0", "type": "Stable Build"};
  /// Initialize SharedPreferences and load settings
  Future<void> init() async {
    // if (!kIsWeb) {
    //   PackageInfo packageInfo = await PackageInfo.fromPlatform();
    //   launchAtStartup.setup(
    //     appName: packageInfo.appName,
    //     appPath: Platform.resolvedExecutable,
    //     packageName: "Harmanita.TimeMark-TrackScreenTimeAppUsage",
    //     args: ['--auto-launched'],
    //   );
    // }
    _prefs = await SharedPreferences.getInstance();
    _loadSettings();
    // bool isStartupEnabled = await launchAtStartup.isEnabled();
    // settings["launchAtStartup"] = isStartupEnabled;
  }

  /// Load settings from SharedPreferences
  void _loadSettings() {
    String? storedSettings = _prefs.getString("screenTime_settings");
    if (storedSettings != null) {
      Map<String, dynamic> loadedSettings = jsonDecode(storedSettings);
      
      // Merge loaded settings with default settings to ensure all required fields exist
      _mergeSettings(settings, loadedSettings);
      
      // Validate theme - ensure it's one of the available options
      if (!ThemeOptions.available.contains(settings["theme"]["selected"])) {
        settings["theme"]["selected"] = ThemeOptions.defaultTheme;
      }
      
      // Validate language
      if (!LanguageOptions.available.contains(settings["language"]["selected"])) {
        settings["language"]["selected"] = LanguageOptions.defaultLanguage;
      }
      
      // Validate focus mode
      if (settings.containsKey("focusModeSettings") && 
          settings["focusModeSettings"].containsKey("selectedMode") &&
          !FocusModeOptions.available.contains(settings["focusModeSettings"]["selectedMode"])) {
        settings["focusModeSettings"]["selectedMode"] = FocusModeOptions.defaultMode;
      }
      
      // Validate category
      if (settings.containsKey("applications") && 
          settings["applications"].containsKey("selectedCategory") &&
          !CategoryOptions.available.contains(settings["applications"]["selectedCategory"])) {
        settings["applications"]["selectedCategory"] = CategoryOptions.defaultCategory;
      }
    }
  }
  
  // Recursively merge loaded settings into default settings
  void _mergeSettings(Map<String, dynamic> target, Map<String, dynamic> source) {
    source.forEach((key, value) {
      if (value is Map<String, dynamic> && target.containsKey(key) && target[key] is Map) {
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

  /// 📌 Update any setting dynamically
  void updateSetting(String key, dynamic value, [BuildContext? context]) async {
    List<String> keys = key.split(".");

    if (keys.length == 1) {
      if (settings.containsKey(keys[0])) {
        settings[keys[0]] = value;
        // if(keys[0] == 'launchAtStartup'){
        //   value ? await launchAtStartup.enable() : await launchAtStartup.disable();
        // }
      } else {
        debugPrint("❌ ERROR: Invalid setting: ${keys[0]}");
      }
    } else {
      Map<String, dynamic> current = settings;
      
      // Navigate to the nested object, creating it if it doesn't exist
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
      
      // Set the final value
      current[keys.last] = value;
    }
    
    _saveSettings(); // Save updated settings
    
    // Debug print for notification controller settings
    if (keys.isNotEmpty && keys[0] == "notificationController") {
      debugPrint("🔔 Updated notification setting: $key = $value");
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
    String currentTheme = getSetting("theme.selected") ?? ThemeOptions.defaultTheme;
    applyTheme(currentTheme, context);
  }
  
  /// 📌 Get any setting dynamically
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

  // Get available theme options
  List<String> getAvailableThemes() {
    return ThemeOptions.available;
  }
  
  // Get available language options
  List<String> getAvailableLanguages() {
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

  //reset
  Future<void> resetSettings([BuildContext? context]) async {
    // Default settings map
    final Map<String, dynamic> defaultSettings = {
      "theme": {
        "selected": ThemeOptions.defaultTheme,
      },
      "language": {
        "selected": LanguageOptions.defaultLanguage,
      },
      "launchAtStartup": true,
      "launchAsMinimized":false,
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
        "overallLimit": {
          "enabled": false,
          "hours": 2,
          "minutes": 0
        }
      },
      "applications": {
        "tracking": true,
        "isHidden": false,
        "selectedCategory": CategoryOptions.defaultCategory
      },
      "focusModeSettings":{
        "selectedMode": FocusModeOptions.defaultMode,
        "workDuration": 25.0,
        "shortBreak": 5.0,
        "longBreak": 15.0,
        "autoStart": false,
        "blockDistractions": false,
        "enableSoundsNotifications": true
      },
      // Add the new notificationController section with default values
      "notificationController": {
        "reminderFrequency": 5, // minute
      }
    };

    // Update the settings with default values
    settings = Map<String, dynamic>.from(defaultSettings);
    
    // Update launch at startup setting in the system
    // if (!kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux)) {
    //   if (settings["launchAtStartup"]) {
    //     await launchAtStartup.enable();
    //   } else {
    //     await launchAtStartup.disable();
    //   }
    // }

    // Save the default settings to persistent storage
    _saveSettings();
    
    debugPrint("✅ Settings reset to default values");
  }
}