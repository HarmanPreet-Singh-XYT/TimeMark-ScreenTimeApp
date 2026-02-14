import 'package:intl/intl.dart';
import 'dart:math';
import '../app_data_controller.dart';

// Extension for formatting Duration objects
extension DurationFormatter on Duration {
  String toHourMinuteFormat() {
    final int hours = inHours;
    final int minutes = inMinutes % 60;

    if (hours > 0) {
      if (minutes > 0) {
        return "${hours}h ${minutes}m";
      } else {
        return "${hours}h";
      }
    } else if (minutes > 0) {
      return "${minutes}m";
    } else {
      final int seconds = inSeconds % 60;
      return "${seconds}s";
    }
  }
}

enum TimeRange { day, week, month }

class DateRange {
  final DateTime startDate;
  final DateTime endDate;

  DateRange({required this.startDate, required this.endDate});
}

class ApplicationBasicDetail {
  final String name;
  final String category;
  final Duration screenTime;
  final String formattedScreenTime;
  final bool isTracking;
  final bool isHidden;
  final bool isProductive;
  final Duration dailyLimit;
  final bool limitStatus;

  ApplicationBasicDetail(
      {required this.name,
      required this.category,
      required this.screenTime,
      required this.isTracking,
      required this.isHidden,
      required this.isProductive,
      required this.dailyLimit,
      required this.limitStatus})
      : formattedScreenTime = screenTime.toHourMinuteFormat();
}

class UsageTrendsData {
  final Map<String, Duration> daily;
  final Map<String, Duration> weekly;
  final Map<String, Duration> monthly;
  final Map<String, String> formattedDaily;
  final Map<String, String> formattedWeekly;
  final Map<String, String> formattedMonthly;

  UsageTrendsData({
    required this.daily,
    required this.weekly,
    required this.monthly,
  })  : formattedDaily = daily
            .map((key, value) => MapEntry(key, value.toHourMinuteFormat())),
        formattedWeekly = weekly
            .map((key, value) => MapEntry(key, value.toHourMinuteFormat())),
        formattedMonthly = monthly
            .map((key, value) => MapEntry(key, value.toHourMinuteFormat()));
}

class UsageInsights {
  final List<int> mostActiveHours;
  final Duration longestSession;
  final String formattedLongestSession;
  final Duration averageDailyUsage;
  final String formattedAverageDailyUsage;

  UsageInsights({
    required this.mostActiveHours,
    required this.longestSession,
    required this.averageDailyUsage,
  })  : formattedLongestSession = longestSession.toHourMinuteFormat(),
        formattedAverageDailyUsage = averageDailyUsage.toHourMinuteFormat();
}

class CategoryAppComparison {
  final String appName;
  final Duration usage;
  final String formattedUsage;
  final double comparisonPercentage;

  CategoryAppComparison({
    required this.appName,
    required this.usage,
    required this.comparisonPercentage,
  }) : formattedUsage = usage.toHourMinuteFormat();
}

class UsageComparisons {
  final Duration currentPeriodUsage;
  final String formattedCurrentPeriodUsage;
  final Duration previousPeriodUsage;
  final String formattedPreviousPeriodUsage;
  final double growthPercentage;
  final List<CategoryAppComparison> similarAppsComparison;

  UsageComparisons({
    required this.currentPeriodUsage,
    required this.previousPeriodUsage,
    required this.growthPercentage,
    required this.similarAppsComparison,
  })  : formattedCurrentPeriodUsage = currentPeriodUsage.toHourMinuteFormat(),
        formattedPreviousPeriodUsage = previousPeriodUsage.toHourMinuteFormat();
}

class SessionBreakdown {
  final Duration averageSessionDuration;
  final String formattedAverageSessionDuration;
  final Duration longestSessionDuration;
  final String formattedLongestSessionDuration;
  final Duration shortestSessionDuration;
  final String formattedShortestSessionDuration;
  final int totalSessions;
  final double averageLaunchesPerDay;
  final int maxLaunchesPerDay;
  final DateTime? lastUsedTimestamp;

  SessionBreakdown({
    required this.averageSessionDuration,
    required this.longestSessionDuration,
    required this.shortestSessionDuration,
    required this.totalSessions,
    required this.averageLaunchesPerDay,
    required this.maxLaunchesPerDay,
    required this.lastUsedTimestamp,
  })  : formattedAverageSessionDuration =
            averageSessionDuration.toHourMinuteFormat(),
        formattedLongestSessionDuration =
            longestSessionDuration.toHourMinuteFormat(),
        formattedShortestSessionDuration =
            shortestSessionDuration.toHourMinuteFormat();
}

class ApplicationDetailedData {
  final UsageTrendsData usageTrends;
  final Map<int, Duration> hourlyBreakdown;
  final Map<int, String> formattedHourlyBreakdown;
  final Map<String, Duration> categoryUsage;
  final Map<String, String> formattedCategoryUsage;
  final UsageInsights usageInsights;
  final UsageComparisons comparisons;
  final SessionBreakdown sessionBreakdown;

  ApplicationDetailedData({
    required this.usageTrends,
    required this.hourlyBreakdown,
    required this.categoryUsage,
    required this.usageInsights,
    required this.comparisons,
    required this.sessionBreakdown,
  })  : formattedHourlyBreakdown = hourlyBreakdown
            .map((key, value) => MapEntry(key, value.toHourMinuteFormat())),
        formattedCategoryUsage = categoryUsage
            .map((key, value) => MapEntry(key, value.toHourMinuteFormat()));
}

class ApplicationsDataProvider {
  static final ApplicationsDataProvider _instance =
      ApplicationsDataProvider._internal();
  factory ApplicationsDataProvider() => _instance;
  ApplicationsDataProvider._internal();

  final AppDataStore _dataStore = AppDataStore();

  /// OPTIMIZED: Already efficient - single pass through apps
  Future<List<ApplicationBasicDetail>> fetchAllApplications() async {
    await _dataStore.init();

    final List<ApplicationBasicDetail> applications = [];
    final DateTime today = DateTime.now();
    final DateTime startOfDay = DateTime(today.year, today.month, today.day);

    // 🚀 Single loop - cache/Hive fallback handled in getAppUsage
    for (final appName in _dataStore.allAppNames) {
      final AppMetadata? metadata = _dataStore.getAppMetadata(appName);
      final AppUsageRecord? usageRecord =
          _dataStore.getAppUsage(appName, startOfDay);

      if (metadata != null) {
        applications.add(ApplicationBasicDetail(
            name: appName,
            category: metadata.category,
            screenTime: usageRecord?.timeSpent ?? Duration.zero,
            isTracking: metadata.isTracking,
            isHidden: !metadata.isVisible,
            isProductive: metadata.isProductive,
            dailyLimit: metadata.dailyLimit,
            limitStatus: metadata.limitStatus));
      }
    }

    applications.sort((a, b) => b.screenTime.compareTo(a.screenTime));
    return applications;
  }

  /// Already efficient - single app query
  Future<ApplicationBasicDetail> fetchApplicationByName(String appName) async {
    await _dataStore.init();

    final AppMetadata? metadata = _dataStore.getAppMetadata(appName);
    if (metadata == null) {
      throw Exception('App metadata not found for: $appName');
    }

    final DateTime today = DateTime.now();
    final AppUsageRecord? usageRecord = _dataStore.getAppUsage(appName, today);

    return ApplicationBasicDetail(
        name: appName,
        category: metadata.category,
        screenTime: usageRecord?.timeSpent ?? Duration.zero,
        isTracking: metadata.isTracking,
        isHidden: !metadata.isVisible,
        isProductive: metadata.isProductive,
        dailyLimit: metadata.dailyLimit,
        limitStatus: metadata.limitStatus);
  }

  Future<ApplicationDetailedData> fetchApplicationDetails(
      String appName, TimeRange timeRange) async {
    await _dataStore.init();

    final AppMetadata? metadata = _dataStore.getAppMetadata(appName);
    if (metadata == null) {
      throw Exception('App metadata not found for: $appName');
    }

    final DateRange dateRange = _getDateRange(timeRange);

    // All these methods are already efficient - they use getAppUsage which has cache fallback
    final usageTrendsData = await _fetchUsageTrendsData(appName, dateRange);
    final hourlyBreakdownData =
        await _fetchHourlyBreakdownData(appName, dateRange);
    final categoryUsageData =
        await _fetchCategoryUsageData(appName, metadata.category, dateRange);
    final usageInsights = await _fetchUsageInsights(appName, dateRange);
    final comparisonsData =
        await _fetchComparisonsData(appName, metadata.category, dateRange);
    final sessionBreakdown = await _fetchSessionBreakdown(appName, dateRange);

    return ApplicationDetailedData(
      usageTrends: usageTrendsData,
      hourlyBreakdown: hourlyBreakdownData,
      categoryUsage: categoryUsageData,
      usageInsights: usageInsights,
      comparisons: comparisonsData,
      sessionBreakdown: sessionBreakdown,
    );
  }

  DateRange _getDateRange(TimeRange timeRange) {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);

    switch (timeRange) {
      case TimeRange.day:
        return DateRange(startDate: today, endDate: today);
      case TimeRange.week:
        return DateRange(
          startDate: today.subtract(const Duration(days: 6)),
          endDate: today,
        );
      case TimeRange.month:
        return DateRange(
          startDate: today.subtract(const Duration(days: 29)),
          endDate: today,
        );
    }
  }

  /// Already optimized - uses getAppUsage with cache fallback
  Future<UsageTrendsData> _fetchUsageTrendsData(
      String appName, DateRange dateRange) async {
    final Map<String, Duration> dailyUsage = {};
    final Map<String, Duration> weeklyUsage = {};
    final Map<String, Duration> monthlyUsage = {};

    // Daily usage
    DateTime currentDate = dateRange.startDate;
    while (currentDate.isBefore(dateRange.endDate) ||
        currentDate.isAtSameMomentAs(dateRange.endDate)) {
      final AppUsageRecord? record =
          _dataStore.getAppUsage(appName, currentDate);
      final String dateKey = DateFormat('MM/dd').format(currentDate);

      dailyUsage[dateKey] = record?.timeSpent ?? Duration.zero;
      currentDate = currentDate.add(const Duration(days: 1));
    }

    // Weekly usage
    if (dateRange.endDate.difference(dateRange.startDate).inDays >= 7) {
      final int totalWeeks =
          (dateRange.endDate.difference(dateRange.startDate).inDays ~/ 7) + 1;

      for (int weekIndex = 0; weekIndex < totalWeeks; weekIndex++) {
        Duration weekTotal = Duration.zero;

        DateTime weekStart =
            dateRange.startDate.add(Duration(days: weekIndex * 7));
        DateTime weekEnd = weekStart.add(const Duration(days: 6));

        if (weekEnd.isAfter(dateRange.endDate)) {
          weekEnd = dateRange.endDate;
        }

        DateTime currentWeekDate = weekStart;
        while (currentWeekDate.isBefore(weekEnd) ||
            currentWeekDate.isAtSameMomentAs(weekEnd)) {
          final AppUsageRecord? record =
              _dataStore.getAppUsage(appName, currentWeekDate);
          weekTotal += record?.timeSpent ?? Duration.zero;
          currentWeekDate = currentWeekDate.add(const Duration(days: 1));
        }

        if (weekTotal > Duration.zero) {
          weeklyUsage['Week ${weekIndex + 1}'] = weekTotal;
        }
      }
    }

    // Monthly usage
    if (dateRange.endDate.difference(dateRange.startDate).inDays >= 28) {
      final Map<String, Duration> monthMap = {};

      currentDate = dateRange.startDate;
      while (currentDate.isBefore(dateRange.endDate) ||
          currentDate.isAtSameMomentAs(dateRange.endDate)) {
        final String monthKey = DateFormat('MMM').format(currentDate);
        final AppUsageRecord? record =
            _dataStore.getAppUsage(appName, currentDate);

        monthMap[monthKey] = (monthMap[monthKey] ?? Duration.zero) +
            (record?.timeSpent ?? Duration.zero);

        currentDate = currentDate.add(const Duration(days: 1));
      }

      monthlyUsage.addAll(monthMap);
    }

    return UsageTrendsData(
      daily: dailyUsage,
      weekly: weeklyUsage,
      monthly: monthlyUsage,
    );
  }

  /// Already optimized - uses getAppUsage with cache fallback
  Future<Map<int, Duration>> _fetchHourlyBreakdownData(
      String appName, DateRange dateRange) async {
    final Map<int, Duration> hourlyUsage = {};

    for (int hour = 0; hour < 24; hour++) {
      hourlyUsage[hour] = Duration.zero;
    }

    DateTime currentDate = dateRange.startDate;
    while (currentDate.isBefore(dateRange.endDate) ||
        currentDate.isAtSameMomentAs(dateRange.endDate)) {
      final AppUsageRecord? record =
          _dataStore.getAppUsage(appName, currentDate);

      if (record != null && record.usagePeriods.isNotEmpty) {
        for (final period in record.usagePeriods) {
          final int startHour = period.startTime.hour;
          final int endHour = period.endTime.hour;

          if (startHour == endHour) {
            hourlyUsage[startHour] = hourlyUsage[startHour]! + period.duration;
          } else {
            for (int hour = startHour; hour <= endHour; hour++) {
              DateTime hourStart = DateTime(period.startTime.year,
                  period.startTime.month, period.startTime.day, hour);
              DateTime hourEnd = hourStart.add(const Duration(hours: 1));

              DateTime effectiveStart =
                  hour == startHour ? period.startTime : hourStart;
              DateTime effectiveEnd =
                  hour == endHour ? period.endTime : hourEnd;

              Duration hourDuration = effectiveEnd.difference(effectiveStart);
              hourlyUsage[hour] = hourlyUsage[hour]! + hourDuration;
            }
          }
        }
      }

      currentDate = currentDate.add(const Duration(days: 1));
    }

    return hourlyUsage;
  }

  /// Already optimized - single pass through apps
  Future<Map<String, Duration>> _fetchCategoryUsageData(
      String appName, String appCategory, DateRange dateRange) async {
    final Map<String, Duration> categoryUsage = {};

    for (final name in _dataStore.allAppNames) {
      final AppMetadata? metadata = _dataStore.getAppMetadata(name);

      if (metadata != null && metadata.category == appCategory) {
        Duration totalUsage = Duration.zero;

        DateTime currentDate = dateRange.startDate;
        while (currentDate.isBefore(dateRange.endDate) ||
            currentDate.isAtSameMomentAs(dateRange.endDate)) {
          final AppUsageRecord? record =
              _dataStore.getAppUsage(name, currentDate);
          totalUsage += record?.timeSpent ?? Duration.zero;
          currentDate = currentDate.add(const Duration(days: 1));
        }

        if (totalUsage > Duration.zero) {
          categoryUsage[name] = totalUsage;
        }
      }
    }

    return categoryUsage;
  }

  Future<UsageInsights> _fetchUsageInsights(
      String appName, DateRange dateRange) async {
    final Map<int, Duration> hourlyData =
        await _fetchHourlyBreakdownData(appName, dateRange);
    final List<int> activeHours = [];

    final List<MapEntry<int, Duration>> sortedHours =
        hourlyData.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    for (int i = 0; i < min(3, sortedHours.length); i++) {
      if (sortedHours[i].value > Duration.zero) {
        activeHours.add(sortedHours[i].key);
      }
    }

    Duration longestSession = Duration.zero;

    DateTime currentDate = dateRange.startDate;
    while (currentDate.isBefore(dateRange.endDate) ||
        currentDate.isAtSameMomentAs(dateRange.endDate)) {
      final AppUsageRecord? record =
          _dataStore.getAppUsage(appName, currentDate);

      if (record != null && record.usagePeriods.isNotEmpty) {
        for (final period in record.usagePeriods) {
          if (period.duration > longestSession) {
            longestSession = period.duration;
          }
        }
      }

      currentDate = currentDate.add(const Duration(days: 1));
    }

    Duration totalUsage = Duration.zero;
    int daysWithUsage = 0;

    currentDate = dateRange.startDate;
    while (currentDate.isBefore(dateRange.endDate) ||
        currentDate.isAtSameMomentAs(dateRange.endDate)) {
      final AppUsageRecord? record =
          _dataStore.getAppUsage(appName, currentDate);

      if (record != null && record.timeSpent > Duration.zero) {
        totalUsage += record.timeSpent;
        daysWithUsage++;
      }

      currentDate = currentDate.add(const Duration(days: 1));
    }

    final Duration averageDailyUsage = daysWithUsage > 0
        ? Duration(seconds: totalUsage.inSeconds ~/ daysWithUsage)
        : Duration.zero;

    return UsageInsights(
      mostActiveHours: activeHours,
      longestSession: longestSession,
      averageDailyUsage: averageDailyUsage,
    );
  }

  Future<UsageComparisons> _fetchComparisonsData(
      String appName, String category, DateRange dateRange) async {
    Duration currentPeriodUsage = Duration.zero;

    DateTime currentDate = dateRange.startDate;
    while (currentDate.isBefore(dateRange.endDate) ||
        currentDate.isAtSameMomentAs(dateRange.endDate)) {
      final AppUsageRecord? record =
          _dataStore.getAppUsage(appName, currentDate);
      currentPeriodUsage += record?.timeSpent ?? Duration.zero;
      currentDate = currentDate.add(const Duration(days: 1));
    }

    final int periodLengthDays =
        dateRange.endDate.difference(dateRange.startDate).inDays + 1;
    final DateTime previousPeriodStart =
        dateRange.startDate.subtract(Duration(days: periodLengthDays));
    final DateTime previousPeriodEnd =
        dateRange.startDate.subtract(const Duration(days: 1));

    Duration previousPeriodUsage = Duration.zero;

    currentDate = previousPeriodStart;
    while (currentDate.isBefore(previousPeriodEnd) ||
        currentDate.isAtSameMomentAs(previousPeriodEnd)) {
      final AppUsageRecord? record =
          _dataStore.getAppUsage(appName, currentDate);
      previousPeriodUsage += record?.timeSpent ?? Duration.zero;
      currentDate = currentDate.add(const Duration(days: 1));
    }

    double growthPercentage = 0;
    if (previousPeriodUsage.inSeconds > 0) {
      growthPercentage =
          ((currentPeriodUsage.inSeconds - previousPeriodUsage.inSeconds) /
                  previousPeriodUsage.inSeconds) *
              100;
    }

    final List<CategoryAppComparison> similarAppsComparison = [];

    for (final name in _dataStore.allAppNames) {
      if (name != appName) {
        final AppMetadata? metadata = _dataStore.getAppMetadata(name);

        if (metadata != null && metadata.category == category) {
          Duration appTotalUsage = Duration.zero;

          currentDate = dateRange.startDate;
          while (currentDate.isBefore(dateRange.endDate) ||
              currentDate.isAtSameMomentAs(dateRange.endDate)) {
            final AppUsageRecord? record =
                _dataStore.getAppUsage(name, currentDate);
            appTotalUsage += record?.timeSpent ?? Duration.zero;
            currentDate = currentDate.add(const Duration(days: 1));
          }

          if (appTotalUsage > Duration.zero) {
            double percentage = 0;
            if (currentPeriodUsage.inSeconds > 0) {
              percentage =
                  (appTotalUsage.inSeconds / currentPeriodUsage.inSeconds) *
                      100;
            }

            similarAppsComparison.add(CategoryAppComparison(
              appName: name,
              usage: appTotalUsage,
              comparisonPercentage: percentage,
            ));
          }
        }
      }
    }

    similarAppsComparison.sort((a, b) => b.usage.compareTo(a.usage));

    return UsageComparisons(
      currentPeriodUsage: currentPeriodUsage,
      previousPeriodUsage: previousPeriodUsage,
      growthPercentage: growthPercentage,
      similarAppsComparison: similarAppsComparison,
    );
  }

  Future<SessionBreakdown> _fetchSessionBreakdown(
      String appName, DateRange dateRange) async {
    final List<Duration> sessionDurations = [];
    final Map<DateTime, int> dailyLaunches = {};
    DateTime? lastUsedTimestamp;

    DateTime currentDate = dateRange.startDate;
    while (currentDate.isBefore(dateRange.endDate) ||
        currentDate.isAtSameMomentAs(dateRange.endDate)) {
      final AppUsageRecord? record =
          _dataStore.getAppUsage(appName, currentDate);

      if (record != null) {
        for (final period in record.usagePeriods) {
          sessionDurations.add(period.duration);

          if (lastUsedTimestamp == null ||
              period.endTime.isAfter(lastUsedTimestamp)) {
            lastUsedTimestamp = period.endTime;
          }
        }

        dailyLaunches[currentDate] = record.openCount;
      }

      currentDate = currentDate.add(const Duration(days: 1));
    }

    Duration averageSessionDuration = Duration.zero;
    if (sessionDurations.isNotEmpty) {
      final int totalSeconds =
          sessionDurations.fold(0, (sum, duration) => sum + duration.inSeconds);
      averageSessionDuration =
          Duration(seconds: totalSeconds ~/ sessionDurations.length);
    }

    double averageLaunchesPerDay = 0;
    if (dailyLaunches.isNotEmpty) {
      final int totalLaunches =
          dailyLaunches.values.fold(0, (sum, launches) => sum + launches);
      averageLaunchesPerDay = totalLaunches / dailyLaunches.length;
    }

    return SessionBreakdown(
      averageSessionDuration: averageSessionDuration,
      longestSessionDuration: sessionDurations.isEmpty
          ? Duration.zero
          : sessionDurations.reduce((a, b) => a > b ? a : b),
      shortestSessionDuration: sessionDurations.isEmpty
          ? Duration.zero
          : sessionDurations.reduce((a, b) => a < b ? a : b),
      totalSessions: sessionDurations.length,
      averageLaunchesPerDay: averageLaunchesPerDay,
      maxLaunchesPerDay: dailyLaunches.isEmpty
          ? 0
          : dailyLaunches.values.reduce((a, b) => a > b ? a : b),
      lastUsedTimestamp: lastUsedTimestamp,
    );
  }
}

// // Data classes for basic app list
// class ApplicationBasicDetail {
//   final String name;
//   final String category;
//   final Duration screenTime;
//   final String formattedScreenTime; // New formatted time property
//   final bool isTracking;
//   final bool isHidden;

//   ApplicationBasicDetail({
//     required this.name,
//     required this.category,
//     required this.screenTime,
//     required this.isTracking,
//     required this.isHidden,
//   }) : formattedScreenTime = screenTime.toHourMinuteFormat();
// }

// // Data classes for detailed app info
// class ApplicationDetailedData {
//   final UsageTrendsData usageTrends;
//   final Map<int, Duration> hourlyBreakdown;
//   final Map<int, String> formattedHourlyBreakdown; // New formatted property
//   final Map<String, Duration> categoryUsage;
//   final Map<String, String> formattedCategoryUsage; // New formatted property
//   final UsageInsights usageInsights;
//   final UsageComparisons comparisons;
//   final SessionBreakdown sessionBreakdown;

//   ApplicationDetailedData({
//     required this.usageTrends,
//     required this.hourlyBreakdown,
//     required this.categoryUsage,
//     required this.usageInsights,
//     required this.comparisons,
//     required this.sessionBreakdown,
//   }) : 
//     formattedHourlyBreakdown = hourlyBreakdown.map((key, value) => MapEntry(key, value.toHourMinuteFormat())),
//     formattedCategoryUsage = categoryUsage.map((key, value) => MapEntry(key, value.toHourMinuteFormat()));
// }

// class UsageTrendsData {
//   final Map<String, Duration> daily;
//   final Map<String, Duration> weekly;
//   final Map<String, Duration> monthly;
//   final Map<String, String> formattedDaily; // New formatted properties
//   final Map<String, String> formattedWeekly;
//   final Map<String, String> formattedMonthly;

//   UsageTrendsData({
//     required this.daily,
//     required this.weekly,
//     required this.monthly,
//   }) : 
//     formattedDaily = daily.map((key, value) => MapEntry(key, value.toHourMinuteFormat())),
//     formattedWeekly = weekly.map((key, value) => MapEntry(key, value.toHourMinuteFormat())),
//     formattedMonthly = monthly.map((key, value) => MapEntry(key, value.toHourMinuteFormat()));
// }

// class UsageInsights {
//   final List<int> mostActiveHours;
//   final Duration longestSession;
//   final String formattedLongestSession; // New formatted property
//   final Duration averageDailyUsage;
//   final String formattedAverageDailyUsage; // New formatted property

//   UsageInsights({
//     required this.mostActiveHours,
//     required this.longestSession,
//     required this.averageDailyUsage,
//   }) : 
//     formattedLongestSession = longestSession.toHourMinuteFormat(),
//     formattedAverageDailyUsage = averageDailyUsage.toHourMinuteFormat();
// }

// class UsageComparisons {
//   final Duration currentPeriodUsage;
//   final String formattedCurrentPeriodUsage; // New formatted property
//   final Duration previousPeriodUsage;
//   final String formattedPreviousPeriodUsage; // New formatted property
//   final double growthPercentage;
//   final List<CategoryAppComparison> similarAppsComparison;

//   UsageComparisons({
//     required this.currentPeriodUsage,
//     required this.previousPeriodUsage,
//     required this.growthPercentage,
//     required this.similarAppsComparison,
//   }) : 
//     formattedCurrentPeriodUsage = currentPeriodUsage.toHourMinuteFormat(),
//     formattedPreviousPeriodUsage = previousPeriodUsage.toHourMinuteFormat();
// }

// class CategoryAppComparison {
//   final String appName;
//   final Duration usage;
//   final String formattedUsage; // New formatted property
//   final double comparisonPercentage;

//   CategoryAppComparison({
//     required this.appName,
//     required this.usage,
//     required this.comparisonPercentage,
//   }) : formattedUsage = usage.toHourMinuteFormat();
// }

// class SessionBreakdown {
//   final Duration averageSessionDuration;
//   final String formattedAverageSessionDuration; // New formatted property
//   final Duration longestSessionDuration;
//   final String formattedLongestSessionDuration; // New formatted property
//   final Duration shortestSessionDuration;
//   final String formattedShortestSessionDuration; // New formatted property
//   final int totalSessions;
//   final double averageLaunchesPerDay;
//   final int maxLaunchesPerDay;
//   final DateTime? lastUsedTimestamp;

//   SessionBreakdown({
//     required this.averageSessionDuration,
//     required this.longestSessionDuration,
//     required this.shortestSessionDuration,
//     required this.totalSessions,
//     required this.averageLaunchesPerDay,
//     required this.maxLaunchesPerDay,
//     required this.lastUsedTimestamp,
//   }) : 
//     formattedAverageSessionDuration = averageSessionDuration.toHourMinuteFormat(),
//     formattedLongestSessionDuration = longestSessionDuration.toHourMinuteFormat(),
//     formattedShortestSessionDuration = shortestSessionDuration.toHourMinuteFormat();
// }