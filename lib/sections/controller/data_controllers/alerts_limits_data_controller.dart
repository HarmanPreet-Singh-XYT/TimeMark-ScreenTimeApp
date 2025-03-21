import 'package:flutter/foundation.dart';
import '../app_data_controller.dart'; // Import your AppDataStore

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

  // Initialize the controller
  Future<bool> initialize() async {
    return await _dataStore.init();
  }

  // Get a list of all apps with their current data
  List<AppUsageSummary> getAllAppsSummary() {
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
                            remainingTime <= const Duration(minutes: 5); // Default threshold
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
}