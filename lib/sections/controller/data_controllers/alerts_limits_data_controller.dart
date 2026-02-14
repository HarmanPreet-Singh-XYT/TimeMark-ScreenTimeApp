import 'package:flutter/foundation.dart';
import '../app_data_controller.dart';

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

  factory AppUsageSummary.fromJson(Map<String, dynamic> json) {
    return AppUsageSummary(
      appName: json['appName'] as String,
      category: json['category'] as String,
      dailyLimit: Duration(seconds: json['dailyLimit'] as int),
      currentUsage: Duration(seconds: json['currentUsage'] as int),
      limitStatus: json['limitStatus'] as bool,
      isProductive: json['isProductive'] as bool,
      isAboutToReachLimit: json['isAboutToReachLimit'] as bool,
      percentageOfLimitUsed: (json['percentageOfLimitUsed'] as num).toDouble(),
      trend: UsageTrend.values.firstWhere(
        (e) => e.toString() == json['trend'],
        orElse: () => UsageTrend.noData,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'appName': appName,
      'category': category,
      'dailyLimit': dailyLimit.inSeconds,
      'currentUsage': currentUsage.inSeconds,
      'limitStatus': limitStatus,
      'isProductive': isProductive,
      'isAboutToReachLimit': isAboutToReachLimit,
      'percentageOfLimitUsed': percentageOfLimitUsed,
      'trend': trend.toString(),
    };
  }
}

enum UsageTrend { increasing, decreasing, stable, noData }

class ScreenTimeDataController extends ChangeNotifier {
  static final ScreenTimeDataController _instance =
      ScreenTimeDataController._internal();
  factory ScreenTimeDataController() => _instance;
  ScreenTimeDataController._internal();

  final AppDataStore _dataStore = AppDataStore();

  Duration _overallLimit = Duration.zero;
  bool _overallLimitEnabled = false;

  Future<bool> initialize() async {
    return await _dataStore.init();
  }

  // ============================================================
  // OVERALL LIMIT MANAGEMENT
  // ============================================================

  void updateOverallLimit(Duration limit, bool enabled) {
    _overallLimit = limit;
    _overallLimitEnabled = enabled;
    _saveOverallLimitToStorage();
    notifyListeners();
  }

  Duration getOverallLimit() {
    return _overallLimit;
  }

  /// OPTIMIZED: Uses cached getTotalScreenTime
  Duration getOverallUsage() {
    return _dataStore.getTotalScreenTime(DateTime.now());
  }

  bool isOverallLimitEnabled() {
    return _overallLimitEnabled;
  }

  bool isOverallLimitReached() {
    if (!_overallLimitEnabled || _overallLimit == Duration.zero) return false;
    return getOverallUsage() >= _overallLimit;
  }

  double getOverallLimitPercentage() {
    if (!_overallLimitEnabled || _overallLimit == Duration.zero) return 0.0;

    final Duration totalScreenTime = getOverallUsage();
    if (_overallLimit.inSeconds == 0) return 0.0;

    return (totalScreenTime.inSeconds / _overallLimit.inSeconds)
        .clamp(0.0, 1.0);
  }

  bool isApproachingOverallLimit(
      {Duration threshold = const Duration(minutes: 15)}) {
    if (!_overallLimitEnabled || _overallLimit == Duration.zero) return false;

    final Duration totalScreenTime = getOverallUsage();
    final Duration remaining = _overallLimit - totalScreenTime;

    return remaining > Duration.zero && remaining <= threshold;
  }

  void _saveOverallLimitToStorage() {
    debugPrint(
        'Saving overall limit: enabled=$_overallLimitEnabled, limit=$_overallLimit');
  }

  // ============================================================
  // APP SUMMARIES - OPTIMIZED
  // ============================================================

  /// OPTIMIZED: Single pass through all apps
  List<AppUsageSummary> getAllAppsSummary() {
    return _buildAppSummaries();
  }

  AppUsageSummary? getAppSummary(String appName) {
    final AppMetadata? metadata = _dataStore.getAppMetadata(appName);
    if (metadata == null) return null;

    final DateTime today = DateTime.now();
    final AppUsageRecord? todayUsage = _dataStore.getAppUsage(appName, today);
    final Duration currentUsage = todayUsage?.timeSpent ?? Duration.zero;

    return _createAppSummary(
      appName: appName,
      metadata: metadata,
      currentUsage: currentUsage,
    );
  }

  List<AppUsageSummary> getAppsWithLimits() {
    return getAllAppsSummary().where((app) => app.limitStatus).toList()
      ..sort(
          (a, b) => b.percentageOfLimitUsed.compareTo(a.percentageOfLimitUsed));
  }

  List<AppUsageSummary> getAppsNearLimit({double threshold = 0.8}) {
    return getAppsWithLimits()
        .where((app) => app.percentageOfLimitUsed >= threshold)
        .toList();
  }

  List<AppUsageSummary> getAppsExceededLimit() {
    return getAppsWithLimits()
        .where((app) => app.percentageOfLimitUsed >= 1.0)
        .toList();
  }

  // ============================================================
  // APP LIMIT MANAGEMENT
  // ============================================================

  Future<bool> updateAppLimit(
      String appName, Duration limit, bool enableLimit) async {
    return await _dataStore.updateAppMetadata(
      appName,
      dailyLimit: limit,
      limitStatus: enableLimit,
    );
  }

  Future<bool> updateAppCategory(
      String appName, String category, bool isProductive) async {
    return await _dataStore.updateAppMetadata(
      appName,
      category: category,
      isProductive: isProductive,
    );
  }

  // ============================================================
  // ANALYTICS
  // ============================================================

  Map<String, Duration> getUsageByCategory() {
    final Map<String, Duration> result = {};
    final List<AppUsageSummary> apps = getAllAppsSummary();

    for (final app in apps) {
      result[app.category] =
          (result[app.category] ?? Duration.zero) + app.currentUsage;
    }

    return result;
  }

  List<AppUsageSummary> getMostUsedApps({int limit = 5}) {
    final List<AppUsageSummary> apps = getAllAppsSummary();
    apps.sort((a, b) => b.currentUsage.compareTo(a.currentUsage));
    return apps.take(limit).toList();
  }

  Future<Map<String, dynamic>> getAllData() async {
    final List<AppUsageSummary> appSummaries = getAllAppsSummary();
    final Map<String, Duration> usageByCategory = getUsageByCategory();
    final List<AppUsageSummary> mostUsedApps = getMostUsedApps();

    return {
      'appSummaries': appSummaries.map((s) => s.toJson()).toList(),
      'usageByCategory':
          usageByCategory.map((key, value) => MapEntry(key, value.inSeconds)),
      'mostUsedApps': mostUsedApps.map((app) => app.toJson()).toList(),
      'overallUsageSeconds': getOverallUsage().inSeconds,
      'overallLimitSeconds': _overallLimit.inSeconds,
      'overallLimitEnabled': _overallLimitEnabled,
      'overallLimitPercentage': getOverallLimitPercentage(),
    };
  }

  // ============================================================
  // PRIVATE HELPERS - OPTIMIZED
  // ============================================================

  /// OPTIMIZED: Single pass through apps with cache/Hive fallback
  List<AppUsageSummary> _buildAppSummaries() {
    final List<String> appNames = _dataStore.allAppNames;
    final List<AppUsageSummary> result = [];
    final DateTime today = DateTime.now();

    // 🚀 Single loop - getAppUsage handles cache fallback automatically
    for (final String appName in appNames) {
      final AppMetadata? metadata = _dataStore.getAppMetadata(appName);
      if (metadata == null || !metadata.isVisible) continue;

      final AppUsageRecord? todayUsage = _dataStore.getAppUsage(appName, today);
      final Duration currentUsage = todayUsage?.timeSpent ?? Duration.zero;

      result.add(_createAppSummary(
        appName: appName,
        metadata: metadata,
        currentUsage: currentUsage,
      ));
    }

    return result;
  }

  AppUsageSummary _createAppSummary({
    required String appName,
    required AppMetadata metadata,
    required Duration currentUsage,
  }) {
    final UsageTrend trend = _calculateUsageTrend(appName);

    double percentOfLimit = 0.0;
    bool isApproachingLimit = false;

    if (metadata.limitStatus && metadata.dailyLimit > Duration.zero) {
      percentOfLimit = currentUsage.inSeconds / metadata.dailyLimit.inSeconds;

      final Duration remainingTime = metadata.dailyLimit - currentUsage;
      isApproachingLimit = remainingTime > Duration.zero &&
          remainingTime <= const Duration(minutes: 5);
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

  /// OPTIMIZED: Uses getAppUsageRange with cache fallback
  UsageTrend _calculateUsageTrend(String appName) {
    final DateTime today = DateTime.now();
    final DateTime weekAgo = today.subtract(const Duration(days: 7));

    // 🚀 This uses cache for recent data, Hive for older
    final List<AppUsageRecord> weekUsage = _dataStore.getAppUsageRange(
      appName,
      weekAgo,
      today.subtract(const Duration(days: 1)),
    );

    if (weekUsage.length < 3) return UsageTrend.noData;

    double totalChange = 0;
    int comparisons = 0;

    for (int i = 1; i < weekUsage.length; i++) {
      final Duration previous = weekUsage[i - 1].timeSpent;
      final Duration current = weekUsage[i].timeSpent;
      totalChange += current.inSeconds - previous.inSeconds;
      comparisons++;
    }

    if (comparisons == 0) return UsageTrend.noData;

    final double avgChangeSeconds = totalChange / comparisons;

    if (avgChangeSeconds > 300) return UsageTrend.increasing;
    if (avgChangeSeconds < -300) return UsageTrend.decreasing;
    return UsageTrend.stable;
  }
}
