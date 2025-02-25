import 'package:fluent_ui/fluent_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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
      "isHidden": true
    }
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
      settings = jsonDecode(storedSettings);
    }
  }

  /// Save settings to SharedPreferences
  void _saveSettings() {
    _prefs.setString("screenTime_settings", jsonEncode(settings));
  }

  /// 📌 Update any setting dynamically
  void updateSetting(String key, dynamic value) {
    List<String> keys = key.split(".");

    if (keys.length == 1) {
      if (settings.containsKey(keys[0])) {
        settings[keys[0]] = value;
      } else {
        debugPrint("❌ ERROR: Invalid setting: ${keys[0]}");
      }
    } else {
      dynamic current = settings;
      for (int i = 0; i < keys.length - 1; i++) {
        if (current is Map && current.containsKey(keys[i])) {
          current = current[keys[i]];
        } else {
          debugPrint("❌ ERROR: Invalid nested setting: $key");
          return;
        }
      }
      if (current is Map) {
        current[keys.last] = value;
      }
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
}
