import 'package:flutter/foundation.dart';

class SettingsData extends ChangeNotifier {
  // Theme (Light, Dark, System)
  String theme = "System";  

  // Language (Default: English)
  String language = "English";  

  // Launch at Startup
  bool launchAtStartup = false;  

  // Notifications
  bool notifications = true;  
  bool focusModeNotification = true;
  bool screenTimeNotification = true;
  bool appScreenTimeNotification = true;

  // Version Info
  Map<String, dynamic> versionInfo = {
    "version": "1.3",
    "type": "Stable Branch"
  };

  // Notify Listeners on Update
  void updateSettings() {
    notifyListeners();
  }
}
