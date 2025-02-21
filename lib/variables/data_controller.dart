import 'app_data.dart';

class AppDataController {
  final AppData appData;
  AppDataController(this.appData);

  // Modify Total Screen Time
  void setTotalScreenTime(Duration time) {
    appData.totalScreenTime = time;
    appData.notifyListeners();
  }

  // Modify Productive Time
  void setProductiveTime(Duration time) {
    appData.productiveTime = time;
    appData.notifyListeners();
  }

  // Modify Most Used App
  void setMostUsedApp(String appName) {
    appData.mostUsedApp = appName;
    appData.notifyListeners();
  }

  // Add a New Focus Session
  void addFocusSession() {
    appData.focusSessions += 1;
    appData.notifyListeners();
  }

  // Set Available Applications
  void setAvailableApplications(List<String> apps) {
    appData.availableApplications = apps;
    appData.notifyListeners();
  }

  // Set Categories
  void setCategories(Map<String, String> categoryData) {
    appData.categories = categoryData;
    appData.notifyListeners();
  }

  // Set Application Limits
  void setApplicationLimits(String appName, Duration limit) {
    appData.applicationLimits[appName] = limit;
    appData.notifyListeners();
  }

  // Set Productivity Score
  void setProductivityScore(double score) {
    appData.productivityScore = score;
    appData.notifyListeners();
  }

  // Update Application Data
  void updateApplicationsData(String appName, dynamic data) {
    appData.applicationsData[appName] = data;
    appData.notifyListeners();
  }

  // Update Focus Data
  void updateFocusData(String sessionId, dynamic data) {
    appData.focusData[sessionId] = data;
    appData.notifyListeners();
  }
}
