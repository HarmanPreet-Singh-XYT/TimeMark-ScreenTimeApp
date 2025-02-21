import 'settings_data.dart';

class SettingsController {
  final SettingsData settingsData;
  SettingsController(this.settingsData);

  // Update Theme
  void setTheme(String newTheme) {
    settingsData.theme = newTheme;
    settingsData.notifyListeners();
  }

  // Update Language
  void setLanguage(String newLanguage) {
    settingsData.language = newLanguage;
    settingsData.notifyListeners();
  }

  // Toggle Launch at Startup
  void toggleLaunchAtStartup(bool value) {
    settingsData.launchAtStartup = value;
    settingsData.notifyListeners();
  }

  // Toggle Notifications
  void toggleNotifications(bool value) {
    settingsData.notifications = value;
    settingsData.notifyListeners();
  }

  // Toggle Focus Mode Notifications
  void toggleFocusModeNotification(bool value) {
    settingsData.focusModeNotification = value;
    settingsData.notifyListeners();
  }

  // Toggle Screen Time Notifications
  void toggleScreenTimeNotification(bool value) {
    settingsData.screenTimeNotification = value;
    settingsData.notifyListeners();
  }

  // Toggle Application Screen Time Notifications
  void toggleAppScreenTimeNotification(bool value) {
    settingsData.appScreenTimeNotification = value;
    settingsData.notifyListeners();
  }

  // Update Version Info
  void setVersion(String version, String type) {
    settingsData.versionInfo = {"version": version, "type": type};
    settingsData.notifyListeners();
  }
}