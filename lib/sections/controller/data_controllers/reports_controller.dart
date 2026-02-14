import 'package:screentime/sections/controller/app_data_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'focus_mode_data_controller.dart';

// Analytics data models (unchanged)
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
  final bool isVisible;

  AppUsageSummary(
      {required this.appName,
      required this.category,
      required this.totalTime,
      required this.isProductive,
      required this.isVisible});
}

class UsageAnalyticsController extends ChangeNotifier {
  final AppDataStore _dataStore = AppDataStore();

  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> initialize() async {
    _setLoading(true);
    final bool success = await _dataStore.init();
    _setLoading(false);

    if (!success) {
      _error = _dataStore.lastError;
    }

    return success;
  }

  String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return "${hours}h ${minutes}m";
    } else {
      return "${minutes}m";
    }
  }

  double calculatePercentageChange(num current, num previous) {
    if (previous == 0) return 0;
    return ((current - previous) / previous) * 100;
  }

  Future<AnalyticsSummary> getSpecificDateRangeAnalytics(
      DateTime startDate, DateTime endDate,
      {bool compareWithPrevious = true}) async {
    _setLoading(true);

    try {
      final normalizedStartDate =
          DateTime(startDate.year, startDate.month, startDate.day);
      final normalizedEndDate =
          DateTime(endDate.year, endDate.month, endDate.day);

      if (normalizedEndDate.isBefore(normalizedStartDate)) {
        throw ArgumentError('End date must be after start date');
      }

      Map<String, DateTime>? comparisonPeriod;

      if (compareWithPrevious) {
        final int daysDifference =
            normalizedEndDate.difference(normalizedStartDate).inDays + 1;
        final DateTime previousEndDate =
            normalizedStartDate.subtract(const Duration(days: 1));
        final DateTime previousStartDate =
            previousEndDate.subtract(Duration(days: daysDifference - 1));

        comparisonPeriod = {"start": previousStartDate, "end": previousEndDate};
      }

      final result = await _getAnalyticsForDateRange(
        normalizedStartDate,
        normalizedEndDate,
        comparisonPeriod,
      );

      _setLoading(false);
      return result;
    } catch (e) {
      _setError("Error fetching specific date range analytics: $e");
      _setLoading(false);
      return _getEmptyAnalyticsSummary();
    }
  }

  Future<AnalyticsSummary> getSpecificDayAnalytics(DateTime date,
      {bool compareWithToday = true}) async {
    _setLoading(true);

    try {
      final normalizedDate = DateTime(date.year, date.month, date.day);
      final DateTime startDate = normalizedDate;
      final DateTime endDate = normalizedDate;

      Map<String, DateTime>? comparisonPeriod;

      if (compareWithToday) {
        final DateTime now = DateTime.now();
        final DateTime today = DateTime(now.year, now.month, now.day);

        if (normalizedDate != today) {
          comparisonPeriod = {"start": today, "end": today};
        }
      }

      final result = await _getAnalyticsForDateRange(
        startDate,
        endDate,
        comparisonPeriod,
      );

      _setLoading(false);
      return result;
    } catch (e) {
      _setError("Error fetching specific day analytics: $e");
      _setLoading(false);
      return _getEmptyAnalyticsSummary();
    }
  }

  Future<AnalyticsSummary> getLifetimeAnalytics() async {
    _setLoading(true);

    try {
      final DateTime now = DateTime.now();
      final DateTime today = DateTime(now.year, now.month, now.day);

      DateTime earliestDate = today.subtract(const Duration(days: 365));

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
        null,
      );

      _setLoading(false);
      return result;
    } catch (e) {
      _setError("Error fetching lifetime analytics: $e");
      _setLoading(false);
      return _getEmptyAnalyticsSummary();
    }
  }

  Future<AnalyticsSummary> getLastThreeMonthsAnalytics() async {
    _setLoading(true);

    try {
      final DateTime now = DateTime.now();
      final DateTime today = DateTime(now.year, now.month, now.day);

      final DateTime startDate = DateTime(
        today.year,
        today.month - 3,
        today.day,
      );

      final DateTime previousStartDate = DateTime(
        startDate.year,
        startDate.month - 3,
        startDate.day,
      );
      final DateTime previousEndDate =
          startDate.subtract(const Duration(days: 1));

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

  Future<AnalyticsSummary> getLastMonthAnalytics() async {
    _setLoading(true);

    try {
      final DateTime now = DateTime.now();
      final DateTime today = DateTime(now.year, now.month, now.day);

      final DateTime startDate = DateTime(
        today.year,
        today.month - 1,
        today.day,
      );

      final DateTime previousStartDate = DateTime(
        startDate.year,
        startDate.month - 1,
        startDate.day,
      );
      final DateTime previousEndDate =
          startDate.subtract(const Duration(days: 1));

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

  Future<AnalyticsSummary> getLastSevenDaysAnalytics() async {
    _setLoading(true);

    try {
      final DateTime now = DateTime.now();
      final DateTime today = DateTime(now.year, now.month, now.day);

      final DateTime startDate = today.subtract(const Duration(days: 6));

      final DateTime previousStartDate =
          startDate.subtract(const Duration(days: 7));
      final DateTime previousEndDate =
          startDate.subtract(const Duration(days: 1));

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

  // ============================================================
  // CORE ANALYTICS - OPTIMIZED WITH BATCH OPERATIONS
  // ============================================================

  Future<AnalyticsSummary> _getAnalyticsForDateRange(
    DateTime startDate,
    DateTime endDate,
    Map<String, DateTime>? comparisonPeriod,
  ) async {
    try {
      // 1. Calculate total screen time
      final Duration totalScreenTime =
          await _calculateTotalScreenTime(startDate, endDate);

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
      final Duration productiveTime =
          await _calculateProductiveTime(startDate, endDate);

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

      // 5. Find most used app - OPTIMIZED (uses batch query)
      final mostUsedAppData = await _findMostUsedApp(startDate, endDate);
      final String mostUsedApp = mostUsedAppData["appName"] as String;
      final Duration mostUsedAppTime = mostUsedAppData["duration"] as Duration;

      // 6. Count focus sessions
      final int focusSessionsCount =
          await _countFocusSessions(startDate, endDate);

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
      final List<DailyScreenTime> dailyScreenTimeData =
          await _getDailyScreenTimeData(
        startDate,
        endDate,
      );

      // 9. Get category breakdown
      final Map<String, double> categoryBreakdown = await _getCategoryBreakdown(
        startDate,
        endDate,
      );

      // 10. Get detailed app usage - OPTIMIZED (uses batch query)
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

  // ============================================================
  // OPTIMIZED HELPER METHODS
  // ============================================================

  Future<Duration> _calculateTotalScreenTime(
      DateTime startDate, DateTime endDate) async {
    try {
      // Use the optimized range method if available
      return _dataStore.getTotalScreenTimeRange(startDate, endDate);
    } catch (e) {
      _setError("Error calculating total screen time: $e");
      return Duration.zero;
    }
  }

  Future<Duration> _calculateProductiveTime(
      DateTime startDate, DateTime endDate) async {
    try {
      Duration total = Duration.zero;
      DateTime currentDate =
          DateTime(startDate.year, startDate.month, startDate.day);

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

  /// OPTIMIZED - Uses batch query instead of loop
  Future<Map<String, dynamic>> _findMostUsedApp(
      DateTime startDate, DateTime endDate) async {
    try {
      // 🚀 ONE batch query instead of N×M individual queries
      final appUsageTotals = _dataStore.getAppUsageTotals(startDate, endDate);

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

  Future<int> _countFocusSessions(DateTime startDate, DateTime endDate) async {
    try {
      int count = 0;
      DateTime currentDate =
          DateTime(startDate.year, startDate.month, startDate.day);

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

  Future<List<DailyScreenTime>> _getDailyScreenTimeData(
      DateTime startDate, DateTime endDate) async {
    try {
      final List<DailyScreenTime> result = [];
      DateTime currentDate =
          DateTime(startDate.year, startDate.month, startDate.day);

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

  Future<Map<String, double>> _getCategoryBreakdown(
      DateTime startDate, DateTime endDate) async {
    try {
      // Use optimized range method
      final categoryDurations =
          _dataStore.getCategoryBreakdownRange(startDate, endDate);

      // Calculate total duration
      Duration totalDuration = Duration.zero;
      categoryDurations.forEach((category, duration) {
        totalDuration += duration;
      });

      // Convert durations to percentages
      final Map<String, double> percentages = {};
      if (totalDuration.inSeconds > 0) {
        categoryDurations.forEach((category, duration) {
          percentages[category] =
              (duration.inSeconds / totalDuration.inSeconds) * 100;
        });
      }

      return percentages;
    } catch (e) {
      _setError("Error getting category breakdown: $e");
      return {};
    }
  }

  /// OPTIMIZED - Uses batch query instead of loop
  Future<List<AppUsageSummary>> _getAppUsageDetails(
      DateTime startDate, DateTime endDate) async {
    try {
      // 🚀 ONE batch query instead of N×M individual queries
      final appUsageTotals = _dataStore.getAppUsageTotals(startDate, endDate);
      final List<AppUsageSummary> result = [];

      // Create detailed summary objects
      for (final entry in appUsageTotals.entries) {
        final AppMetadata? metadata = _dataStore.getAppMetadata(entry.key);

        result.add(AppUsageSummary(
          appName: entry.key,
          category: metadata?.category ?? 'Uncategorized',
          totalTime: entry.value,
          isProductive: metadata?.isProductive ?? false,
          isVisible: metadata?.isVisible ?? false,
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

// Focus mode analytics unchanged
class FocusModeAnalytics {
  final FocusAnalyticsService _analyticsService = FocusAnalyticsService();

  Map<String, dynamic> getLastSevenDaysData({DateTime? endDate}) {
    final DateTime now = endDate ?? DateTime.now();
    final DateTime startDate = now.subtract(const Duration(days: 6));

    return _getPeriodData(startDate: startDate, endDate: now);
  }

  Map<String, dynamic> getLastMonthData({DateTime? endDate}) {
    final DateTime now = endDate ?? DateTime.now();
    final DateTime startDate = now.subtract(const Duration(days: 29));

    return _getPeriodData(startDate: startDate, endDate: now);
  }

  Map<String, dynamic> getLastThreeMonthsData({DateTime? endDate}) {
    final DateTime now = endDate ?? DateTime.now();
    final DateTime startDate = now.subtract(const Duration(days: 89));

    return _getPeriodData(startDate: startDate, endDate: now);
  }

  Map<String, dynamic> getLifetimeData() {
    final DateTime now = DateTime.now();
    final DateTime startDate = _getFirstRecordedSessionDate();

    return _getPeriodData(startDate: startDate, endDate: now);
  }

  DateTime _getFirstRecordedSessionDate() {
    return DateTime.now().subtract(const Duration(days: 365));
  }

  Map<String, dynamic> _getPeriodData(
      {required DateTime startDate, required DateTime endDate}) {
    final Map<String, int> sessionsByDay =
        _analyticsService.getSessionCountByDay(
      startDate: startDate,
      endDate: endDate,
    );

    final Map<String, dynamic> timeDistribution =
        _analyticsService.getTimeDistribution(
      startDate: startDate,
      endDate: endDate,
    );

    final List<Map<String, dynamic>> sessions =
        _analyticsService.getSessionHistory(
      startDate: startDate,
      endDate: endDate,
    );

    final int totalSessions =
        sessionsByDay.values.fold(0, (sum, count) => sum + count);
    final int daysInPeriod = endDate.difference(startDate).inDays + 1;
    final double avgDailySessions = totalSessions / daysInPeriod;

    String mostProductiveDay = "None";
    int maxSessions = 0;

    sessionsByDay.forEach((day, count) {
      if (count > maxSessions) {
        maxSessions = count;
        mostProductiveDay = day;
      }
    });

    if (mostProductiveDay != "None") {
      try {
        final DateTime date = DateFormat('yyyy-MM-dd').parse(mostProductiveDay);
        mostProductiveDay = DateFormat('EEEE').format(date);
      } catch (e) {
        debugPrint("Error formatting most productive day: $e");
      }
    }

    final Duration totalFocusTime = _calculateTotalFocusTime(sessions);
    final Duration avgSessionLength = totalSessions > 0
        ? Duration(minutes: totalFocusTime.inMinutes ~/ totalSessions)
        : const Duration();

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

  Duration _calculateTotalFocusTime(List<Map<String, dynamic>> sessions) {
    int totalMinutes = 0;

    for (final session in sessions) {
      if (session.containsKey('duration') && session['duration'] is int) {
        totalMinutes += session['duration'] as int;
      }
    }

    return Duration(minutes: totalMinutes);
  }

  int _calculateCurrentStreak(
      Map<String, int> sessionsByDay, DateTime endDate) {
    final List<String> sortedDays = sessionsByDay.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    if (sortedDays.isEmpty) return 0;

    final String endDateStr = DateFormat('yyyy-MM-dd').format(endDate);
    if (!sortedDays.contains(endDateStr) && sessionsByDay[endDateStr] == 0) {
      return 0;
    }

    int streak = 0;
    DateTime currentDate = endDate;

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
