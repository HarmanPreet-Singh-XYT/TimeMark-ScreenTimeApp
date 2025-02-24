import 'package:fluent_ui/fluent_ui.dart';

class SettingsManager {
  static final SettingsManager _instance = SettingsManager._internal();

  factory SettingsManager() {
    return _instance;
  }

  SettingsManager._internal(); // Private constructor

  /// Settings Map
  final Map<String, dynamic> settings = {
    "theme": {
      "selected":"System",
      "available":["System","Dark","Light"]
    },
    "language": {
      "selected":"English",
      "available":["English"]
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

  /// 📌 Update any setting dynamically
  void updateSetting(String key, dynamic value) {
    List<String> keys = key.split(".");

    if (keys.length == 1) {
      // Direct top-level setting update
      if (settings.containsKey(keys[0])) {
        settings[keys[0]] = value;
      } else {
        debugPrint("❌ ERROR: Invalid setting: \${keys[0]}");
      }
    } else {
      // Nested setting update (e.g., notifications.focusMode)
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
