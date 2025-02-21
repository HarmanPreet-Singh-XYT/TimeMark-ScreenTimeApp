import 'package:flutter/foundation.dart';

class AppData extends ChangeNotifier {
  // Screen Time Variables
  Duration totalScreenTime = Duration.zero;
  Duration productiveTime = Duration.zero;

  // Application Data
  String mostUsedApp = "Unknown";
  int focusSessions = 0;
  List<String> availableApplications = [];
  Map<String, String> categories = {}; // App Name -> Category

  // Limits & Productivity Score
  Map<String, Duration> applicationLimits = {}; // App Name -> Time Limit
  double productivityScore = 0.0; // A score between 0-100

  // Data Maps for Apps & Focus
  Map<String, dynamic> applicationsData = {}; // App usage stats
  Map<String, dynamic> focusData = {}; // Focus session details
}
