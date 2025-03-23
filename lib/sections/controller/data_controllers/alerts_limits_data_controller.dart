import 'package:flutter/foundation.dart';
import '../app_data_controller.dart'; // Import your AppDataStore
import 'package:screentime/sections/controller/notification_controller.dart'; // Add import for NotificationController

class AppUsageSummary {
  final String appName;
  final String category;
  final Duration dailyLimit;
  final Duration currentUsage;
  final bool limitStatus;
  final bool isProductive;
  final bool isAboutToReachLimit;
  final double percentageOfLimitUsed;
  final UsageTrend trend;

  AppUsageSummary({
    required this.appName,
    required this.category,
    required this.dailyLimit,
    required this.currentUsage,
    required this.limitStatus,
    required this.isProductive,
    required this.isAboutToReachLimit,
    required this.percentageOfLimitUsed,
    required this.trend,
  });

  // Factory constructor to create an instance from JSON
  factory AppUsageSummary.fromJson(Map<String, dynamic> json) {
    return AppUsageSummary(
      appName: json['appName'] as String,
      category: json['category'] as String,
      dailyLimit: Duration(minutes: json['dailyLimit'] as int),
      currentUsage: Duration(minutes: json['currentUsage'] as int),
      limitStatus: json['limitStatus'] as bool,
      isProductive: json['isProductive'] as bool,
      isAboutToReachLimit: json['isAboutToReachLimit'] as bool,
      percentageOfLimitUsed: json['percentageOfLimitUsed'] as double,
      trend: UsageTrend.values.firstWhere(
        (e) => e.toString() == json['trend'],
        orElse: () => UsageTrend.noData,
      ),
    );
  }

  // Convert instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'appName': appName,
      'category': category,
      'dailyLimit': dailyLimit.inMinutes,
      'currentUsage': currentUsage.inMinutes,
      'limitStatus': limitStatus,
      'isProductive': isProductive,
      'isAboutToReachLimit': isAboutToReachLimit,
      'percentageOfLimitUsed': percentageOfLimitUsed,
      'trend': trend.toString(),
    };
  }
}

enum UsageTrend {
  increasing,
  decreasing,
  stable,
  noData
}

class ScreenTimeDataController extends ChangeNotifier {
  // Singleton implementation
  static final ScreenTimeDataController _instance = ScreenTimeDataController._internal();
  factory ScreenTimeDataController() => _instance;
  ScreenTimeDataController._internal();

  final AppDataStore _dataStore = AppDataStore();
  final NotificationController _notificationController = NotificationController(); // Add reference to NotificationController
  
  // Keep track of notifications sent to avoid duplicates
  final Map<String, bool> _appLimitNotificationsSent = {};
  bool _overallLimitNotificationSent = false;
  bool _approachingOverallLimitNotificationSent = false;

  // Initialize the controller
  Future<bool> initialize() async {
    // Reset notification trackers
    _appLimitNotificationsSent.clear();
    _overallLimitNotificationSent = false;
    _approachingOverallLimitNotificationSent = false;
    
    return await _dataStore.init();
  }

  // Get a list of all apps with their current data
  List<AppUsageSummary> getAllAppsSummary() {
    final List<AppUsageSummary> result = _getAppSummariesWithoutNotificationChecks();
    
    // Check individual app notifications
    for (final summary in result) {
      final AppMetadata? metadata = _dataStore.getAppMetadata(summary.appName);
      if (metadata != null && metadata.limitStatus) {
        _checkAppLimitNotifications(summary.appName, metadata, summary.currentUsage, summary.percentageOfLimitUsed);
      }
    }
    
    // Check overall limits using the results we already have
    _checkOverallLimitNotifications(existingApps: result);

    return result;
  }

  // New method to check and send app limit notifications
  void _checkAppLimitNotifications(String appName, AppMetadata metadata, Duration currentUsage, double percentOfLimit) {
    // Skip if notifications already sent for this app today
    if (_appLimitNotificationsSent[appName] == true) return;
    
    // Send notification when the app reaches its limit
    if (metadata.limitStatus && metadata.dailyLimit > Duration.zero) {
      if (currentUsage >= metadata.dailyLimit) {
        _notificationController.sendAppLimitNotification(appName, metadata.dailyLimit.inMinutes);
        _appLimitNotificationsSent[appName] = true;
      } 
      // Or when approaching limit (90%)
      else if (percentOfLimit >= 0.9 && !_appLimitNotificationsSent.containsKey(appName)) {
        // You could add a function for approaching limits in NotificationController
        _notificationController.showPopupAlert(
          "Approaching App Limit", 
          "You're about to reach your daily limit for $appName"
        );
        _appLimitNotificationsSent[appName] = false; // Mark as warned but not fully notified
      }
    }
  }

  // Get a single app's summary
  AppUsageSummary? getAppSummary(String appName) {
    final AppMetadata? metadata = _dataStore.getAppMetadata(appName);
    if (metadata == null) return null;

    final DateTime today = DateTime.now();
    final AppUsageRecord? todayUsage = _dataStore.getAppUsage(appName, today);

    final UsageTrend trend = _calculateUsageTrend(appName);
    final Duration currentUsage = todayUsage?.timeSpent ?? Duration.zero;

    double percentOfLimit = 0.0;
    bool isApproachingLimit = false;

    if (metadata.limitStatus && metadata.dailyLimit > Duration.zero) {
      percentOfLimit = currentUsage.inSeconds / metadata.dailyLimit.inSeconds;

      // Check if approaching limit
      final Duration remainingTime = metadata.dailyLimit - currentUsage;
      isApproachingLimit = remainingTime > Duration.zero &&
                          remainingTime <= const Duration(minutes: 5); // Default threshold
                          
      // Check and send notifications for this app
      _checkAppLimitNotifications(appName, metadata, currentUsage, percentOfLimit);
    }

    return AppUsageSummary(
      appName: appName,
      category: metadata.category,
      dailyLimit: metadata.dailyLimit,
      currentUsage: currentUsage,
      limitStatus: metadata.limitStatus,
      isProductive: metadata.isProductive,
      isAboutToReachLimit: isApproachingLimit,
      percentageOfLimitUsed: percentOfLimit,
      trend: trend,
    );
  }

  // Calculate the usage trend for an app
  UsageTrend _calculateUsageTrend(String appName) {
    final DateTime today = DateTime.now();
    final DateTime weekAgo = today.subtract(const Duration(days: 7));

    final List<AppUsageRecord> weekUsage = _dataStore.getAppUsageRange(
      appName,
      weekAgo,
      today.subtract(const Duration(days: 1)), // Exclude today
    );

    if (weekUsage.length < 3) return UsageTrend.noData;

    // Calculate average daily change
    double totalChange = 0;
    int comparisons = 0;

    for (int i = 1; i < weekUsage.length; i++) {
      final Duration previous = weekUsage[i - 1].timeSpent;
      final Duration current = weekUsage[i].timeSpent;
      totalChange += current.inMinutes - previous.inMinutes;
      comparisons++;
    }

    if (comparisons == 0) return UsageTrend.noData;

    final double avgChange = totalChange / comparisons;

    if (avgChange > 5) return UsageTrend.increasing;
    if (avgChange < -5) return UsageTrend.decreasing;
    return UsageTrend.stable;
  }

  // Update app limit
  Future<bool> updateAppLimit(String appName, Duration limit, bool enableLimit) async {
    // Reset notification status for this app when limit is changed
    _appLimitNotificationsSent.remove(appName);
    
    return await _dataStore.updateAppMetadata(
      appName,
      dailyLimit: limit,
      limitStatus: enableLimit,
    );
  }

  // Update app category
  Future<bool> updateAppCategory(String appName, String category, bool isProductive) async {
    return await _dataStore.updateAppMetadata(
      appName,
      category: category,
      isProductive: isProductive,
    );
  }

  // Get usage statistics by category
  Map<String, Duration> getUsageByCategory() {
    final Map<String, Duration> result = {};
    final List<AppUsageSummary> apps = getAllAppsSummary();

    for (final app in apps) {
      if (!result.containsKey(app.category)) {
        result[app.category] = Duration.zero;
      }
      result[app.category] = result[app.category]! + app.currentUsage;
    }

    return result;
  }

  // Get most used apps
  List<AppUsageSummary> getMostUsedApps({int limit = 5}) {
    final List<AppUsageSummary> apps = getAllAppsSummary();
    apps.sort((a, b) => b.currentUsage.compareTo(a.currentUsage));
    return apps.take(limit).toList();
  }

  // Async function to get all data at once
  Future<Map<String, dynamic>> getAllData() async {
    final List<AppUsageSummary> appSummaries = getAllAppsSummary();
    final Map<String, Duration> usageByCategory = getUsageByCategory();
    final List<AppUsageSummary> mostUsedApps = getMostUsedApps();

    return {
      'appSummaries': appSummaries.map((summary) => summary.toJson()).toList(),
      'usageByCategory': usageByCategory.map((key, value) => MapEntry(key, value.inMinutes)),
      'mostUsedApps': mostUsedApps.map((app) => app.toJson()).toList(),
      'overallLimit':{
        'enabled': _overallLimitEnabled,
        'limit': _overallLimit.inMinutes,
        'currentUsage': _calculateTotalScreenTime().inMinutes,
      }
    };
  }

  // Helper method to format duration
  String _formatDuration(Duration duration) {
    final int hours = duration.inHours;
    final int minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '$hours h $minutes min';
    } else {
      return '$minutes min';
    }
  }

  Duration _overallLimit = Duration.zero;
  bool _overallLimitEnabled = false;
  
  // Update overall screen time limit
  void updateOverallLimit(Duration limit, bool enabled) {
    _overallLimit = limit;
    _overallLimitEnabled = enabled;
    
    // Reset notification status when limit is changed
    _overallLimitNotificationSent = false;
    _approachingOverallLimitNotificationSent = false;
    
    // Save to storage or database as needed
    _saveOverallLimitToStorage();
    
    // Check if any notifications need to be sent based on overall limits
    _checkOverallLimitNotifications();
    
    notifyListeners();
  }
  
  // Check if the user is approaching or has exceeded their overall limit
  void _checkOverallLimitNotifications({List<AppUsageSummary>? existingApps}) {
    if (!_overallLimitEnabled || _overallLimit == Duration.zero) return;
  
  // Calculate total screen time for today using existing apps if provided
    Duration totalScreenTime = _calculateTotalScreenTime(existingApps: existingApps);
    
    // // Calculate total screen time for today
    // Duration totalScreenTime = _calculateTotalScreenTime();
    
    // If over limit, show notification
    if (totalScreenTime >= _overallLimit && !_overallLimitNotificationSent) {
      _notificationController.sendScreenTimeNotification(_overallLimit.inMinutes);
      _overallLimitNotificationSent = true;
      _approachingOverallLimitNotificationSent = true; // Prevent approaching notification
    } 
    // If approaching limit (90%), show warning
    else if (totalScreenTime.inMinutes >= _overallLimit.inMinutes * 0.9 && 
            !_approachingOverallLimitNotificationSent && 
            !_overallLimitNotificationSent) {
      _notificationController.showPopupAlert(
        "Approaching Screen Time Limit", 
        "You're about to reach your daily screen time limit of ${_overallLimit.inMinutes} minutes"
      );
      _approachingOverallLimitNotificationSent = true;
    }
  }
  
  // Calculate total screen time across all apps
  // Modify _calculateTotalScreenTime() to accept an optional parameter
  Duration _calculateTotalScreenTime({List<AppUsageSummary>? existingApps}) {
    // Use provided list or fetch new one (but not recursively)
    final apps = existingApps ?? _getAppSummariesWithoutNotificationChecks();
    return Duration(minutes: apps.fold(0, (sum, app) => sum + app.currentUsage.inMinutes));
  }

  // Add this new method that gets app summaries without triggering notification checks
  List<AppUsageSummary> _getAppSummariesWithoutNotificationChecks() {
    final List<String> appNames = _dataStore.allAppNames;
    final List<AppUsageSummary> result = [];

    for (final String appName in appNames) {
      final AppMetadata? metadata = _dataStore.getAppMetadata(appName);
      if (metadata == null || !metadata.isVisible) continue;

      final DateTime today = DateTime.now();
      final AppUsageRecord? todayUsage = _dataStore.getAppUsage(appName, today);

      final UsageTrend trend = _calculateUsageTrend(appName);
      final Duration currentUsage = todayUsage?.timeSpent ?? Duration.zero;

      double percentOfLimit = 0.0;
      bool isApproachingLimit = false;

      if (metadata.limitStatus && metadata.dailyLimit > Duration.zero) {
        percentOfLimit = currentUsage.inSeconds / metadata.dailyLimit.inSeconds;

        // Check if approaching limit
        final Duration remainingTime = metadata.dailyLimit - currentUsage;
        isApproachingLimit = remainingTime > Duration.zero &&
                            remainingTime <= const Duration(minutes: 5);
      }

      result.add(AppUsageSummary(
        appName: appName,
        category: metadata.category,
        dailyLimit: metadata.dailyLimit,
        currentUsage: currentUsage,
        limitStatus: metadata.limitStatus,
        isProductive: metadata.isProductive,
        isAboutToReachLimit: isApproachingLimit,
        percentageOfLimitUsed: percentOfLimit,
        trend: trend,
      ));
    }

    return result;
  }
  
  // Save overall limit settings to storage
  void _saveOverallLimitToStorage() {
    // Implementation depends on your storage mechanism
    // Here we'll just log it
    debugPrint('Saving overall limit: $_overallLimitEnabled, $_overallLimit');
  }
  
  // Method to refresh and check all notifications
  // Call this periodically, e.g., every minute or when app usage updates
  void refreshAndCheckNotifications() {
    final apps = getAllAppsSummary();
    _checkOverallLimitNotifications();
    
    // May trigger additional notifications for individual apps if necessary
    notifyListeners();
  }
  
  // Reset notification status (e.g., at the start of a new day)
  void resetNotificationStatus() {
    _appLimitNotificationsSent.clear();
    _overallLimitNotificationSent = false;
    _approachingOverallLimitNotificationSent = false;
  }
  
  // Get current overall limit
  Duration getOverallLimit() {
    return _overallLimit;
  }
  
  // Get overall limit status
  bool isOverallLimitEnabled() {
    return _overallLimitEnabled;
  }
}