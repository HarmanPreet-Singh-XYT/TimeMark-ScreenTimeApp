// ignore: file_names
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:async';
import '../app_data_controller.dart';

// Assuming we're using the existing AppDataStore from your code
// import 'app_data_store.dart';

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
}

enum UsageTrend {
  increasing,
  decreasing,
  stable,
  noData
}

enum AlertType {
  limitReached,
  limitApproaching,
  highUsage,
  productivityImprovement,
  dailySummary
}

class AppAlert {
  final String appName;
  final AlertType type;
  final String message;
  final DateTime time;
  final bool isRead;
  final dynamic data;

  AppAlert({
    required this.appName,
    required this.type,
    required this.message,
    required this.time,
    this.isRead = false,
    this.data,
  });
}

class ScreenTimeController extends ChangeNotifier {
  // Singleton implementation
  static final ScreenTimeController _instance = ScreenTimeController._internal();
  factory ScreenTimeController() => _instance;
  ScreenTimeController._internal();
  final AppDataStore _dataStore = AppDataStore();
  final List<AppAlert> _alerts = [];
  Timer? _monitoringTimer;
  bool _isMonitoring = false;
  
  // Configuration options for alerts and limits
  Duration _approachingLimitThreshold = const Duration(minutes: 5);
  Duration _highUsageThreshold = const Duration(hours: 2);
  bool _enableAutoLimits = false;
  bool _enableDailyReports = true;
  TimeOfDay _dailyReportTime = const TimeOfDay(hour: 21, minute: 0);
  bool _enableFocusModeSuggestions = true;


  // Stream controllers
  final _appSummariesController = StreamController<List<AppUsageSummary>>.broadcast();
  final _alertsController = StreamController<List<AppAlert>>.broadcast();
  final _configController = StreamController<Map<String, dynamic>>.broadcast();
  
  // Getters for configuration options
  Duration get approachingLimitThreshold => _approachingLimitThreshold;
  Duration get highUsageThreshold => _highUsageThreshold;
  bool get enableAutoLimits => _enableAutoLimits;
  bool get enableDailyReports => _enableDailyReports;
  TimeOfDay get dailyReportTime => _dailyReportTime;
  bool get enableFocusModeSuggestions => _enableFocusModeSuggestions;
  
  // Setters for configuration options
  set approachingLimitThreshold(Duration value) {
    _approachingLimitThreshold = value;
    notifyListeners();
  }
  
  set highUsageThreshold(Duration value) {
    _highUsageThreshold = value;
    notifyListeners();
  }
  
  set enableAutoLimits(bool value) {
    _enableAutoLimits = value;
    notifyListeners();
  }
  
  set enableDailyReports(bool value) {
    _enableDailyReports = value;
    notifyListeners();
  }
  
  set dailyReportTime(TimeOfDay value) {
    _dailyReportTime = value;
    notifyListeners();
  }
  
  set enableFocusModeSuggestions(bool value) {
    _enableFocusModeSuggestions = value;
    notifyListeners();
  }

  // Stream getters
  Stream<List<AppUsageSummary>> get appSummaries => _appSummariesController.stream;
  Stream<List<AppAlert>> get alerts => _alertsController.stream;
  Stream<Map<String, dynamic>> get configUpdates => _configController.stream;
  
  // Initialize the controller
  Future<bool> initialize() async {
    // final bool success = await _dataStore.init();
    // if (success) {
      _startMonitoring();
      // Emit initial data
      _appSummariesController.add(getAllAppsSummary());
      _alertsController.add(List.from(_alerts));
      _emitConfigUpdate();
    // }
    return true;
  }

  // Start periodic monitoring for usage limits
  void _startMonitoring() {
    if (_isMonitoring) return;
    
    _isMonitoring = true;
    _monitoringTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      _checkAppLimits();
      _checkForDailyReport();
    });
  }

  // Stop monitoring
  void stopMonitoring() {
    _monitoringTimer?.cancel();
    _isMonitoring = false;
  }

  @override
  void dispose() {
    stopMonitoring();
    _appSummariesController.close();
    _alertsController.close();
    _configController.close();
    super.dispose();
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
        
        // Check if approaching limit (within the configurable threshold)
        final Duration remainingTime = metadata.dailyLimit - currentUsage;
        isApproachingLimit = remainingTime > Duration.zero && 
                            remainingTime <= _approachingLimitThreshold;
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
                          remainingTime <= _approachingLimitThreshold;
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
      final Duration previous = weekUsage[i-1].timeSpent;
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

  // Check all app limits and create alerts as needed
  void _checkAppLimits() {
    final List<AppUsageSummary> apps = getAllAppsSummary();
    
    for (final app in apps) {
      // Check for limit reached
      if (app.limitStatus && app.dailyLimit > Duration.zero && 
          app.currentUsage >= app.dailyLimit) {
        _createAlert(
          app.appName,
          AlertType.limitReached,
          "You've reached your daily limit for ${app.appName}",
        );
      }
      
      // Check for approaching limit
      else if (app.isAboutToReachLimit) {
        final int mins = _approachingLimitThreshold.inMinutes;
        _createAlert(
          app.appName,
          AlertType.limitApproaching,
          "You're approaching your daily limit for ${app.appName} (less than $mins mins left)",
        );
      }
      
      // Check for high usage (no limit set)
      else if (!app.limitStatus && !app.isProductive && 
              app.currentUsage >= _highUsageThreshold) {
        _createAlert(
          app.appName,
          AlertType.highUsage,
          "You've spent ${_formatDuration(app.currentUsage)} on ${app.appName} today",
        );
      }
    }
    
    notifyListeners();
  }

  // Create a new alert
  void _createAlert(String appName, AlertType type, String message, {dynamic data}) {
    // Check if a similar alert exists in the last hour
    final DateTime oneHourAgo = DateTime.now().subtract(const Duration(hours: 1));
    final bool existingSimilarAlert = _alerts.any((alert) => 
      alert.appName == appName && 
      alert.type == type && 
      alert.time.isAfter(oneHourAgo)
    );
    
    if (!existingSimilarAlert) {
      _alerts.add(AppAlert(
        appName: appName,
        type: type,
        message: message,
        time: DateTime.now(),
        data: data,
      ));
      
      notifyListeners();
    }
  }

  // Check if it's time for a daily report
  void _checkForDailyReport() {
    if (!_enableDailyReports) return;
    
    final DateTime now = DateTime.now();
    final DateTime reportTime = DateTime(
      now.year, 
      now.month, 
      now.day, 
      _dailyReportTime.hour, 
      _dailyReportTime.minute
    );
    
    // Check if it's within 5 minutes of the report time
    final bool isReportTime = now.difference(reportTime).abs() < const Duration(minutes: 5);
    
    if (isReportTime) {
      _generateDailyReport();
    }
  }

  // Generate a daily report
  void _generateDailyReport() {
    final List<AppUsageSummary> apps = getAllAppsSummary();
    
    // Check if a daily report has already been created today
    final bool reportAlreadyCreated = _alerts.any((alert) => 
      alert.type == AlertType.dailySummary && 
      _isSameDay(alert.time, DateTime.now())
    );
    
    if (reportAlreadyCreated) return;
    
    // Calculate total usage time
    Duration totalUsage = Duration.zero;
    Duration productiveTime = Duration.zero;
    Duration nonProductiveTime = Duration.zero;
    
    for (final app in apps) {
      totalUsage += app.currentUsage;
      if (app.isProductive) {
        productiveTime += app.currentUsage;
      } else {
        nonProductiveTime += app.currentUsage;
      }
    }
    
    // Format productivity percentage
    double productivityPercent = 0;
    if (totalUsage.inSeconds > 0) {
      productivityPercent = (productiveTime.inSeconds / totalUsage.inSeconds) * 100;
    }
    
    final String summaryMessage = "Today's screen time: ${_formatDuration(totalUsage)}. "
        "Productive: ${_formatDuration(productiveTime)} (${productivityPercent.toStringAsFixed(1)}%)";
    
    _createAlert(
      "Daily Summary",
      AlertType.dailySummary,
      summaryMessage,
      data: {
        'totalUsage': totalUsage,
        'productiveTime': productiveTime,
        'nonProductiveTime': nonProductiveTime,
        'productivityPercent': productivityPercent,
      },
    );
  }

  // Get all alerts
  List<AppAlert> getAlerts({bool unreadOnly = false}) {
    if (unreadOnly) {
      return _alerts.where((alert) => !alert.isRead).toList();
    }
    return List.from(_alerts);
  }

  // Mark alert as read
  void markAlertAsRead(AppAlert alert) {
    final int index = _alerts.indexOf(alert);
    if (index >= 0) {
      _alerts[index] = AppAlert(
        appName: alert.appName,
        type: alert.type,
        message: alert.message,
        time: alert.time,
        isRead: true,
        data: alert.data,
      );
      notifyListeners();
    }
  }

  // Mark all alerts as read
  void markAllAlertsAsRead() {
    for (int i = 0; i < _alerts.length; i++) {
      final alert = _alerts[i];
      _alerts[i] = AppAlert(
        appName: alert.appName,
        type: alert.type,
        message: alert.message,
        time: alert.time,
        isRead: true,
        data: alert.data,
      );
    }
    notifyListeners();
  }

  // Delete alert
  void deleteAlert(AppAlert alert) {
    _alerts.remove(alert);
    notifyListeners();
  }

  // Clear all alerts
  void clearAllAlerts() {
    _alerts.clear();
    notifyListeners();
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

  // Suggest focus mode based on recent usage patterns
  bool shouldSuggestFocusMode() {
    if (!_enableFocusModeSuggestions) return false;
    
    final List<AppUsageSummary> nonProductiveApps = getAllAppsSummary()
        .where((app) => !app.isProductive)
        .toList();
    
    Duration totalNonProductiveTime = Duration.zero;
    for (final app in nonProductiveApps) {
      totalNonProductiveTime += app.currentUsage;
    }
    
    // Suggest focus mode if non-productive app usage is high
    return totalNonProductiveTime > const Duration(hours: 1, minutes: 30);
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

  // Helper method to check if two dates are the same day
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // Format date for key operations
  void _emitConfigUpdate() {
    _configController.add({
      'approachingLimitThreshold': _approachingLimitThreshold,
      'highUsageThreshold': _highUsageThreshold,
      'enableAutoLimits': _enableAutoLimits,
      'enableDailyReports': _enableDailyReports,
      'dailyReportTime': _dailyReportTime,
      'enableFocusModeSuggestions': _enableFocusModeSuggestions,
    });
  }

}

// Add adapter for TimeOfDay
class TimeOfDayAdapter extends TypeAdapter<TimeOfDay> {
  @override
  final int typeId = 6;

  @override
  TimeOfDay read(BinaryReader reader) {
    final hour = reader.readInt();
    final minute = reader.readInt();
    return TimeOfDay(hour: hour, minute: minute);
  }

  @override
  void write(BinaryWriter writer, TimeOfDay obj) {
    writer.writeInt(obj.hour);
    writer.writeInt(obj.minute);
  }
}

// Extension methods for TimeOfDay
extension TimeOfDayExtension on TimeOfDay {
  String format(BuildContext context) {
    final MaterialLocalizations localizations = MaterialLocalizations.of(context);
    return localizations.formatTimeOfDay(this);
  }

  DateTime toDateTime() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute);
  }
}