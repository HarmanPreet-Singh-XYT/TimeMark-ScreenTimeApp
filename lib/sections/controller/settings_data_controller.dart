import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:package_info_plus/package_info_plus.dart';
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
      "selected": "Dark",
      // "available": ["System", "Dark", "Light"]
      "available": ["Dark"]
    },
    "language": {
      "selected": "English",
      "available": ["English"]
    },
    "launchAtStartup": true,
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
      "system": true
    },
    "applications": {
      "tracking": true,
      "isHidden": true,
      "selectedCategory":"All"
    },
    "focusModeSettings":{
      "selectedMode":"Custom",
      "workDuration":25.0,
      "shortBreak":5.0,
      "longBreak":15.0,
      "autoStart":false,
      "blockDistractions":false,
      "enableSoundsNotifications":true
    }
  };

  /// Initialize SharedPreferences and load settings
  Future<void> init() async {
    if (!kIsWeb) {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    launchAtStartup.setup(
      appName: packageInfo.appName,
      appPath: Platform.resolvedExecutable,
      packageName: 'dev.productive.screentime',
    );
  }
    _prefs = await SharedPreferences.getInstance();
    _loadSettings();
    bool isStartupEnabled = await launchAtStartup.isEnabled();
    settings["launchAtStartup"] = isStartupEnabled;
  }

  /// Load settings from SharedPreferences
  void _loadSettings() {
    String? storedSettings = _prefs.getString("screenTime_settings");
    if (storedSettings != null) {
      settings = jsonDecode(storedSettings);
    }
  }

  /// Save settings to SharedPreferences
  void _saveSettings() {
    _prefs.setString("screenTime_settings", jsonEncode(settings));
  }

  /// 📌 Update any setting dynamically
  void updateSetting(String key, dynamic value) async {
    List<String> keys = key.split(".");

    if (keys.length == 1) {
      if (settings.containsKey(keys[0])) {
        settings[keys[0]] = value;
        if(keys[0] == 'launchAtStartup'){
          value ? await launchAtStartup.enable() : await launchAtStartup.disable();
        }
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

  //reset
  Future<void> resetSettings() async {
  // Default settings map
  final Map<String, dynamic> defaultSettings = {
    "theme": {
      "selected": "Dark",
      "available": ["Dark"]
    },
    "language": {
      "selected": "English",
      "available": ["English"]
    },
    "launchAtStartup": true,
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
      "system": true
    },
    "applications": {
      "tracking": true,
      "isHidden": true,
      "selectedCategory": "All"
    },
    "focusModeSettings": {
      "selectedMode": "Custom",
      "workDuration": 25.0,
      "shortBreak": 5.0,
      "longBreak": 15.0,
      "autoStart": false,
      "blockDistractions": false,
      "enableSoundsNotifications": true
    }
  };

  // Update the settings with default values
  settings = Map<String, dynamic>.from(defaultSettings);
  
  // Update launch at startup setting in the system
  if (!kIsWeb && Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
    if (settings["launchAtStartup"]) {
      await launchAtStartup.enable();
    } else {
      await launchAtStartup.disable();
    }
  }

  // Save the default settings to persistent storage
  _saveSettings();
  
  debugPrint("✅ Settings reset to default values");
}
}
