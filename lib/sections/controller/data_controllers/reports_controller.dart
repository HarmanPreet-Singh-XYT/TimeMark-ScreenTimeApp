import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:screentime/sections/controller/app_data_controller.dart';
import '../data_controllers/focusMode_data_controller.dart';

// Import your AppDataStore class
// import 'app_data_store.dart';
// Analytics data models
class AnalyticsSummary {
  final Duration totalScreenTime;
  final double screenTimeComparisonPercent;
  final Duration productiveTime;
  final double productiveTimeComparisonPercent;
  final String mostUsedApp;
  final Duration mostUsedAppTime;
  final int focusSessionsCount;
  final double focusSessionsComparisonPercent;
  final List<DailyScreenTime> dailyScreenTimeData;
  final Map<String, double> categoryBreakdown;
  final List<AppUsageSummary> appUsageDetails;
  
  AnalyticsSummary({
    required this.totalScreenTime,
    required this.screenTimeComparisonPercent,
    required this.productiveTime,
    required this.productiveTimeComparisonPercent,
    required this.mostUsedApp,
    required this.mostUsedAppTime,
    required this.focusSessionsCount,
    required this.focusSessionsComparisonPercent,
    required this.dailyScreenTimeData,
    required this.categoryBreakdown,
    required this.appUsageDetails,
  });
}

class DailyScreenTime {
  final DateTime date;
  final Duration screenTime;
  
  DailyScreenTime({
    required this.date,
    required this.screenTime,
  });
}

class AppUsageSummary {
  final String appName;
  final String category;
  final Duration totalTime;
  final bool isProductive;
  
  AppUsageSummary({
    required this.appName,
    required this.category,
    required this.totalTime,
    required this.isProductive,
  });
}
class UsageAnalyticsController extends ChangeNotifier {
  final AppDataStore _dataStore = AppDataStore();
  
  bool _isLoading = false;
  String? _error;
  
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  
  
  // Initialize the controller
  Future<bool> initialize() async {
    _setLoading(true);
    final bool success = await _dataStore.init();
    _setLoading(false);
    
    if (!success) {
      _error = _dataStore.lastError;
    }
    
    return success;
  }
  
  // Format duration to "Xh Ym" format
  String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    
    if (hours > 0) {
      return "${hours}h ${minutes}m";
    } else {
      return "${minutes}m";
    }
  }
  
  // Calculate percentage change between two values
  double calculatePercentageChange(num current, num previous) {
    if (previous == 0) return 0;
    return ((current - previous) / previous) * 100;
  }
  
  // Get data for lifetime
  Future<AnalyticsSummary> getLifetimeAnalytics() async {
    _setLoading(true);
    
    try {
      // Get the earliest recorded date
      final DateTime now = DateTime.now();
      final DateTime today = DateTime(now.year, now.month, now.day);
      
      // Default to 1 year if no data is found
      DateTime earliestDate = today.subtract(const Duration(days: 365));
      
      // Try to find the earliest date with data
      for (final appName in _dataStore.allAppNames) {
        for (int i = 365; i >= 0; i--) {
          final DateTime checkDate = today.subtract(Duration(days: i));
          final usage = _dataStore.getAppUsage(appName, checkDate);
          if (usage != null) {
            if (checkDate.isBefore(earliestDate)) {
              earliestDate = checkDate;
            }
            break;
          }
        }
      }
      
      final result = await _getAnalyticsForDateRange(
        earliestDate,
        today,
        null, // No comparison for lifetime
      );
      
      _setLoading(false);
      return result;
    } catch (e) {
      _setError("Error fetching lifetime analytics: $e");
      _setLoading(false);
      return _getEmptyAnalyticsSummary();
    }
  }
  
  // Get data for last 3 months
  Future<AnalyticsSummary> getLastThreeMonthsAnalytics() async {
    _setLoading(true);
    
    try {
      final DateTime now = DateTime.now();
      final DateTime today = DateTime(now.year, now.month, now.day);
      
      // Current period
      final DateTime startDate = DateTime(
        today.year,
        today.month - 3,
        today.day,
      );
      
      // Previous period (for comparison)
      final DateTime previousStartDate = DateTime(
        startDate.year,
        startDate.month - 3,
        startDate.day,
      );
      final DateTime previousEndDate = startDate.subtract(const Duration(days: 1));
      
      final result = await _getAnalyticsForDateRange(
        startDate,
        today,
        {"start": previousStartDate, "end": previousEndDate},
      );
      
      _setLoading(false);
      return result;
    } catch (e) {
      _setError("Error fetching last three months analytics: $e");
      _setLoading(false);
      return _getEmptyAnalyticsSummary();
    }
  }
  
  // Get data for last month
  Future<AnalyticsSummary> getLastMonthAnalytics() async {
    _setLoading(true);
    
    try {
      final DateTime now = DateTime.now();
      final DateTime today = DateTime(now.year, now.month, now.day);
      
      // Current period
      final DateTime startDate = DateTime(
        today.year,
        today.month - 1,
        today.day,
      );
      
      // Previous period (for comparison)
      final DateTime previousStartDate = DateTime(
        startDate.year,
        startDate.month - 1,
        startDate.day,
      );
      final DateTime previousEndDate = startDate.subtract(const Duration(days: 1));
      
      final result = await _getAnalyticsForDateRange(
        startDate,
        today,
        {"start": previousStartDate, "end": previousEndDate},
      );
      
      _setLoading(false);
      return result;
    } catch (e) {
      _setError("Error fetching last month analytics: $e");
      _setLoading(false);
      return _getEmptyAnalyticsSummary();
    }
  }
  
  // Get data for last 7 days
  Future<AnalyticsSummary> getLastSevenDaysAnalytics() async {
    _setLoading(true);
    
    try {
      final DateTime now = DateTime.now();
      final DateTime today = DateTime(now.year, now.month, now.day);
      
      // Current period
      final DateTime startDate = today.subtract(const Duration(days: 6));
      
      // Previous period (for comparison)
      final DateTime previousStartDate = startDate.subtract(const Duration(days: 7));
      final DateTime previousEndDate = startDate.subtract(const Duration(days: 1));
      
      final result = await _getAnalyticsForDateRange(
        startDate,
        today,
        {"start": previousStartDate, "end": previousEndDate},
      );
      
      _setLoading(false);
      return result;
    } catch (e) {
      _setError("Error fetching last seven days analytics: $e");
      _setLoading(false);
      return _getEmptyAnalyticsSummary();
    }
  }
  
  // Core analytics calculation for a given date range
  Future<AnalyticsSummary> _getAnalyticsForDateRange(
    DateTime startDate,
    DateTime endDate,
    Map<String, DateTime>? comparisonPeriod,
  ) async {
    try {
      // 1. Calculate total screen time
      final Duration totalScreenTime = await _calculateTotalScreenTime(startDate, endDate);
      
      // 2. Calculate screen time comparison
      double screenTimeComparisonPercent = 0;
      if (comparisonPeriod != null) {
        final Duration previousScreenTime = await _calculateTotalScreenTime(
          comparisonPeriod["start"]!,
          comparisonPeriod["end"]!,
        );
        screenTimeComparisonPercent = calculatePercentageChange(
          totalScreenTime.inMinutes,
          previousScreenTime.inMinutes,
        );
      }
      
      // 3. Calculate productive time
      final Duration productiveTime = await _calculateProductiveTime(startDate, endDate);
      
      // 4. Calculate productive time comparison
      double productiveTimeComparisonPercent = 0;
      if (comparisonPeriod != null) {
        final Duration previousProductiveTime = await _calculateProductiveTime(
          comparisonPeriod["start"]!,
          comparisonPeriod["end"]!,
        );
        productiveTimeComparisonPercent = calculatePercentageChange(
          productiveTime.inMinutes,
          previousProductiveTime.inMinutes,
        );
      }
      
      // 5. Find most used app and its usage time
      final mostUsedAppData = await _findMostUsedApp(startDate, endDate);
      final String mostUsedApp = mostUsedAppData["appName"] as String;
      final Duration mostUsedAppTime = mostUsedAppData["duration"] as Duration;
      
      // 6. Count focus sessions
      final int focusSessionsCount = await _countFocusSessions(startDate, endDate);
      
      // 7. Calculate focus sessions comparison
      double focusSessionsComparisonPercent = 0;
      if (comparisonPeriod != null) {
        final int previousFocusSessionsCount = await _countFocusSessions(
          comparisonPeriod["start"]!,
          comparisonPeriod["end"]!,
        );
        focusSessionsComparisonPercent = calculatePercentageChange(
          focusSessionsCount,
          previousFocusSessionsCount,
        );
      }
      
      // 8. Get daily screen time data
      final List<DailyScreenTime> dailyScreenTimeData = await _getDailyScreenTimeData(
        startDate,
        endDate,
      );
      
      // 9. Get category breakdown
      final Map<String, double> categoryBreakdown = await _getCategoryBreakdown(
        startDate,
        endDate,
      );
      
      // 10. Get detailed app usage
      final List<AppUsageSummary> appUsageDetails = await _getAppUsageDetails(
        startDate,
        endDate,
      );
      
      return AnalyticsSummary(
        totalScreenTime: totalScreenTime,
        screenTimeComparisonPercent: screenTimeComparisonPercent,
        productiveTime: productiveTime,
        productiveTimeComparisonPercent: productiveTimeComparisonPercent,
        mostUsedApp: mostUsedApp,
        mostUsedAppTime: mostUsedAppTime,
        focusSessionsCount: focusSessionsCount,
        focusSessionsComparisonPercent: focusSessionsComparisonPercent,
        dailyScreenTimeData: dailyScreenTimeData,
        categoryBreakdown: categoryBreakdown,
        appUsageDetails: appUsageDetails,
      );
    } catch (e) {
      _setError("Error in _getAnalyticsForDateRange: $e");
      return _getEmptyAnalyticsSummary();
    }
  }
  
  // Helper method to calculate total screen time
  Future<Duration> _calculateTotalScreenTime(DateTime startDate, DateTime endDate) async {
    try {
      Duration total = Duration.zero;
      DateTime currentDate = DateTime(startDate.year, startDate.month, startDate.day);
      
      while (!currentDate.isAfter(endDate)) {
        total += _dataStore.getTotalScreenTime(currentDate);
        currentDate = currentDate.add(const Duration(days: 1));
      }
      
      return total;
    } catch (e) {
      _setError("Error calculating total screen time: $e");
      return Duration.zero;
    }
  }
  
  // Helper method to calculate productive time
  Future<Duration> _calculateProductiveTime(DateTime startDate, DateTime endDate) async {
    try {
      Duration total = Duration.zero;
      DateTime currentDate = DateTime(startDate.year, startDate.month, startDate.day);
      
      while (!currentDate.isAfter(endDate)) {
        total += _dataStore.getProductiveTime(currentDate);
        currentDate = currentDate.add(const Duration(days: 1));
      }
      
      return total;
    } catch (e) {
      _setError("Error calculating productive time: $e");
      return Duration.zero;
    }
  }
  
  // Helper method to find most used app
  Future<Map<String, dynamic>> _findMostUsedApp(DateTime startDate, DateTime endDate) async {
    try {
      final Map<String, Duration> appUsageTotals = {};
      
      // Iterate through all apps
      for (final appName in _dataStore.allAppNames) {
        Duration total = Duration.zero;
        DateTime currentDate = DateTime(startDate.year, startDate.month, startDate.day);
        
        // Calculate total usage for this app in the date range
        while (!currentDate.isAfter(endDate)) {
          final usage = _dataStore.getAppUsage(appName, currentDate);
          if (usage != null) {
            total += usage.timeSpent;
          }
          currentDate = currentDate.add(const Duration(days: 1));
        }
        
        if (total.inSeconds > 0) {
          appUsageTotals[appName] = total;
        }
      }
      
      // Find the app with maximum usage
      String mostUsedApp = "None";
      Duration maxDuration = Duration.zero;
      
      appUsageTotals.forEach((app, duration) {
        if (duration > maxDuration) {
          mostUsedApp = app;
          maxDuration = duration;
        }
      });
      
      return {
        "appName": mostUsedApp,
        "duration": maxDuration,
      };
    } catch (e) {
      _setError("Error finding most used app: $e");
      return {
        "appName": "Error",
        "duration": Duration.zero,
      };
    }
  }
  
  // Helper method to count focus sessions
  Future<int> _countFocusSessions(DateTime startDate, DateTime endDate) async {
    try {
      int count = 0;
      DateTime currentDate = DateTime(startDate.year, startDate.month, startDate.day);
      
      while (!currentDate.isAfter(endDate)) {
        count += _dataStore.getFocusSessionsCount(currentDate);
        currentDate = currentDate.add(const Duration(days: 1));
      }
      
      return count;
    } catch (e) {
      _setError("Error counting focus sessions: $e");
      return 0;
    }
  }
  
  // Helper method to get daily screen time data
  Future<List<DailyScreenTime>> _getDailyScreenTimeData(DateTime startDate, DateTime endDate) async {
    try {
      final List<DailyScreenTime> result = [];
      DateTime currentDate = DateTime(startDate.year, startDate.month, startDate.day);
      
      while (!currentDate.isAfter(endDate)) {
        final screenTime = _dataStore.getTotalScreenTime(currentDate);
        result.add(DailyScreenTime(
          date: currentDate,
          screenTime: screenTime,
        ));
        currentDate = currentDate.add(const Duration(days: 1));
      }
      
      return result;
    } catch (e) {
      _setError("Error getting daily screen time data: $e");
      return [];
    }
  }
  
  // Helper method to get category breakdown
  Future<Map<String, double>> _getCategoryBreakdown(DateTime startDate, DateTime endDate) async {
    try {
      final Map<String, Duration> categoryDurations = {};
      Duration totalDuration = Duration.zero;
      DateTime currentDate = DateTime(startDate.year, startDate.month, startDate.day);
      
      // Calculate total duration per category
      while (!currentDate.isAfter(endDate)) {
        final Map<String, Duration> dailyBreakdown = _dataStore.getCategoryBreakdown(currentDate);
        
        dailyBreakdown.forEach((category, duration) {
          categoryDurations[category] = (categoryDurations[category] ?? Duration.zero) + duration;
          totalDuration += duration;
        });
        
        currentDate = currentDate.add(const Duration(days: 1));
      }
      
      // Convert durations to percentages
      final Map<String, double> percentages = {};
      if (totalDuration.inSeconds > 0) {
        categoryDurations.forEach((category, duration) {
          percentages[category] = (duration.inSeconds / totalDuration.inSeconds) * 100;
        });
      }
      
      return percentages;
    } catch (e) {
      _setError("Error getting category breakdown: $e");
      return {};
    }
  }
  
  // Helper method to get detailed app usage
  Future<List<AppUsageSummary>> _getAppUsageDetails(DateTime startDate, DateTime endDate) async {
    try {
      final Map<String, Duration> appUsageTotals = {};
      final List<AppUsageSummary> result = [];
      
      // Calculate total usage for each app
      for (final appName in _dataStore.allAppNames) {
        Duration total = Duration.zero;
        DateTime currentDate = DateTime(startDate.year, startDate.month, startDate.day);
        
        while (!currentDate.isAfter(endDate)) {
          final usage = _dataStore.getAppUsage(appName, currentDate);
          if (usage != null) {
            total += usage.timeSpent;
          }
          currentDate = currentDate.add(const Duration(days: 1));
        }
        
        if (total.inSeconds > 0) {
          appUsageTotals[appName] = total;
        }
      }
      
      // Create detailed summary objects
      for (final appName in appUsageTotals.keys) {
        final AppMetadata? metadata = _dataStore.getAppMetadata(appName);
        
        result.add(AppUsageSummary(
          appName: appName,
          category: metadata?.category ?? 'Uncategorized',
          totalTime: appUsageTotals[appName]!,
          isProductive: metadata?.isProductive ?? false,
        ));
      }
      
      // Sort by usage time (descending)
      result.sort((a, b) => b.totalTime.compareTo(a.totalTime));
      
      return result;
    } catch (e) {
      _setError("Error getting app usage details: $e");
      return [];
    }
  }
  
  // Helper to create an empty analytics summary (for error cases)
  AnalyticsSummary _getEmptyAnalyticsSummary() {
    return AnalyticsSummary(
      totalScreenTime: Duration.zero,
      screenTimeComparisonPercent: 0,
      productiveTime: Duration.zero,
      productiveTimeComparisonPercent: 0,
      mostUsedApp: "None",
      mostUsedAppTime: Duration.zero,
      focusSessionsCount: 0,
      focusSessionsComparisonPercent: 0,
      dailyScreenTimeData: [],
      categoryBreakdown: {},
      appUsageDetails: [],
    );
  }
  
  // Helper methods for state management
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setError(String? errorMessage) {
    _error = errorMessage;
    debugPrint("UsageAnalyticsController Error: $_error");
    notifyListeners();
  }
}

class FocusModeAnalytics {
  // Get data for the last 7 days
  final FocusAnalyticsService _analyticsService = FocusAnalyticsService();
  Map<String, dynamic> getLastSevenDaysData({DateTime? endDate}) {
    final DateTime now = endDate ?? DateTime.now();
    final DateTime startDate = now.subtract(const Duration(days: 6));
    
    return _getPeriodData(startDate: startDate, endDate: now);
  }
  
  // Get data for the last month (30 days)
  Map<String, dynamic> getLastMonthData({DateTime? endDate}) {
    final DateTime now = endDate ?? DateTime.now();
    final DateTime startDate = now.subtract(const Duration(days: 29));
    
    return _getPeriodData(startDate: startDate, endDate: now);
  }
  
  // Get data for the last 3 months (90 days)
  Map<String, dynamic> getLastThreeMonthsData({DateTime? endDate}) {
    final DateTime now = endDate ?? DateTime.now();
    final DateTime startDate = now.subtract(const Duration(days: 89));
    
    return _getPeriodData(startDate: startDate, endDate: now);
  }
  
  // Get lifetime data
  Map<String, dynamic> getLifetimeData() {
    // You need to define how to get the start date for lifetime data
    // This could be the first recorded session, app installation date, etc.
    final DateTime now = DateTime.now();
    final DateTime startDate = _getFirstRecordedSessionDate();
    
    return _getPeriodData(startDate: startDate, endDate: now);
  }
  
  // Helper method to get the date of the first recorded session
  DateTime _getFirstRecordedSessionDate() {
    // Implementation depends on how your data is stored
    // This is a placeholder - replace with actual implementation
    // For example, query your database for the oldest session
    
    // Default fallback to 1 year if no data is found
    return DateTime.now().subtract(const Duration(days: 365));
  }
  
  // Core method to get data for any time period
  Map<String, dynamic> _getPeriodData({required DateTime startDate, required DateTime endDate}) {
    // Get session count by day
    final Map<String, int> sessionsByDay = _analyticsService.getSessionCountByDay(
      startDate: startDate,
      endDate: endDate,
    );
    
    // Get time distribution
    final Map<String, dynamic> timeDistribution = _analyticsService.getTimeDistribution(
      startDate: startDate,
      endDate: endDate,
    );
    
    // Get detailed sessions
    final List<Map<String, dynamic>> sessions = _analyticsService.getSessionHistory(
      startDate: startDate,
      endDate: endDate,
    );
    
    // Calculate total sessions for the period
    final int totalSessions = sessionsByDay.values.fold(0, (sum, count) => sum + count);
    
    // Calculate days in period
    final int daysInPeriod = endDate.difference(startDate).inDays + 1;
    
    // Calculate average daily sessions
    final double avgDailySessions = totalSessions / daysInPeriod;
    
    // Find the day with most sessions
    String mostProductiveDay = "None";
    int maxSessions = 0;
    
    sessionsByDay.forEach((day, count) {
      if (count > maxSessions) {
        maxSessions = count;
        mostProductiveDay = day;
      }
    });
    
    // Format the most productive day to be more readable
    if (mostProductiveDay != "None") {
      try {
        final DateTime date = DateFormat('yyyy-MM-dd').parse(mostProductiveDay);
        mostProductiveDay = DateFormat('EEEE').format(date); // Day name (e.g., "Monday")
      } catch (e) {
        debugPrint("Error formatting most productive day: $e");
      }
    }
    
    // Calculate total focus time
    final Duration totalFocusTime = _calculateTotalFocusTime(sessions);
    
    // Calculate average focus session length
    final Duration avgSessionLength = totalSessions > 0 
        ? Duration(minutes: totalFocusTime.inMinutes ~/ totalSessions)
        : const Duration();
    
    // Calculate streak (consecutive days with focus sessions)
    final int currentStreak = _calculateCurrentStreak(sessionsByDay, endDate);
    
    return {
      'periodStart': startDate,
      'periodEnd': endDate,
      'totalSessions': totalSessions,
      'avgDailySessions': avgDailySessions,
      'mostProductiveDay': mostProductiveDay,
      'sessionsByDay': sessionsByDay,
      'timeDistribution': timeDistribution,
      'sessions': sessions,
      'totalFocusTime': totalFocusTime,
      'avgSessionLength': avgSessionLength,
      'currentStreak': currentStreak,
      'daysInPeriod': daysInPeriod,
    };
  }
  
  // Helper method to calculate total focus time from sessions
  Duration _calculateTotalFocusTime(List<Map<String, dynamic>> sessions) {
    int totalMinutes = 0;
    
    for (final session in sessions) {
      // Assuming each session has a 'duration' field in minutes
      if (session.containsKey('duration') && session['duration'] is int) {
        totalMinutes += session['duration'] as int;
      }
    }
    
    return Duration(minutes: totalMinutes);
  }
  
  // Helper method to calculate current streak
  int _calculateCurrentStreak(Map<String, int> sessionsByDay, DateTime endDate) {
    // Sort days in descending order
    final List<String> sortedDays = sessionsByDay.keys.toList()
      ..sort((a, b) => b.compareTo(a));
    
    if (sortedDays.isEmpty) return 0;
    
    // Check if the most recent day with sessions is the end date
    final String endDateStr = DateFormat('yyyy-MM-dd').format(endDate);
    if (!sortedDays.contains(endDateStr) && sessionsByDay[endDateStr] == 0) {
      return 0; // No sessions on the most recent day, streak is 0
    }
    
    int streak = 0;
    DateTime currentDate = endDate;
    
    // Count consecutive days with sessions
    while (true) {
      final String dateStr = DateFormat('yyyy-MM-dd').format(currentDate);
      
      if (sessionsByDay.containsKey(dateStr) && sessionsByDay[dateStr]! > 0) {
        streak++;
        currentDate = currentDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    
    return streak;
  }
}