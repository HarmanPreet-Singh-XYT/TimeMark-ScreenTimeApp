import '../app_data_controller.dart';

class DailyOverviewData {
  static final DailyOverviewData _instance = DailyOverviewData._internal();
  factory DailyOverviewData() => _instance;
  DailyOverviewData._internal();

  final AppDataStore _dataStore = AppDataStore();

  /// Fetch today's overview data - OPTIMIZED
  Future<OverviewData> fetchTodayOverview() async {
    await _dataStore.init();

    final DateTime today = DateTime.now();
    final DateTime weekAgo = today.subtract(const Duration(days: 7));

    // Calculate total screen time
    final Duration todayScreenTime = _dataStore.getTotalScreenTime(today);
    final Duration averageWeekScreenTime =
        _dataStore.getAverageScreenTime(weekAgo, today);

    // Calculate productive time
    final Duration todayProductiveTime = _dataStore.getProductiveTime(today);
    final double todayProductivityScore =
        _dataStore.getProductivityScore(today);

    // Most used app
    final String mostUsedApp = _dataStore.getMostUsedApp(today);

    // Focus sessions
    final int focusSessionsCount = _dataStore.getFocusSessionsCount(today);
    final Duration totalFocusTime = _dataStore.getTotalFocusTime(today);

    // 🚀 OPTIMIZED: Use batch operations
    final List<ApplicationDetail> topApplications =
        _calculateTopApplications(today);
    final List<CategoryDetail> categoryBreakdown =
        _calculateCategoryBreakdown(today);
    final List<ApplicationLimitDetail> applicationLimits =
        _calculateApplicationLimits(today);

    return OverviewData(
      totalScreenTime: todayScreenTime,
      averageScreenTime: averageWeekScreenTime,
      screenTimePercentage:
          _calculatePercentage(todayScreenTime, averageWeekScreenTime),
      productiveTime: todayProductiveTime,
      productivityScore: todayProductivityScore,
      mostUsedApp: mostUsedApp,
      focusSessions: focusSessionsCount,
      totalFocusTime: totalFocusTime,
      topApplications: topApplications,
      categoryBreakdown: categoryBreakdown,
      applicationLimits: applicationLimits,
    );
  }

  /// OPTIMIZED: Single pass through apps
  List<ApplicationDetail> _calculateTopApplications(DateTime date) {
    final List<ApplicationDetail> applications = [];
    final Duration totalScreenTime = _dataStore.getTotalScreenTime(date);

    // 🚀 Single loop - check cache/hive once per app
    for (final appName in _dataStore.allAppNames) {
      final AppUsageRecord? usageRecord = _dataStore.getAppUsage(appName, date);
      final AppMetadata? metadata = _dataStore.getAppMetadata(appName);

      if (usageRecord != null && metadata != null) {
        final double percentageOfTotalTime = totalScreenTime.inSeconds > 0
            ? (usageRecord.timeSpent.inSeconds / totalScreenTime.inSeconds) *
                100
            : 0.0;

        applications.add(ApplicationDetail(
          name: appName,
          category: metadata.category,
          screenTime: usageRecord.timeSpent,
          percentageOfTotalTime: percentageOfTotalTime,
          isVisible: metadata.isVisible,
        ));
      }
    }

    applications.sort((a, b) => b.screenTime.compareTo(a.screenTime));
    return applications;
  }

  /// Already optimized - uses getCategoryBreakdown which is cached
  List<CategoryDetail> _calculateCategoryBreakdown(DateTime date) {
    final Map<String, Duration> categoryBreakdown =
        _dataStore.getCategoryBreakdown(date);
    final Duration totalScreenTime = _dataStore.getTotalScreenTime(date);

    if (totalScreenTime.inSeconds == 0) return [];

    return categoryBreakdown.entries.map((entry) {
      return CategoryDetail(
        name: entry.key,
        totalScreenTime: entry.value,
        percentageOfTotalTime:
            (entry.value.inSeconds / totalScreenTime.inSeconds) * 100,
      );
    }).toList()
      ..sort((a, b) => b.totalScreenTime.compareTo(a.totalScreenTime));
  }

  /// OPTIMIZED: Single pass through apps
  List<ApplicationLimitDetail> _calculateApplicationLimits(DateTime date) {
    final List<ApplicationLimitDetail> limitDetails = [];
    final Duration totalScreenTime = _dataStore.getTotalScreenTime(date);

    // 🚀 Single loop through all apps
    for (final appName in _dataStore.allAppNames) {
      final AppMetadata? metadata = _dataStore.getAppMetadata(appName);

      if (metadata != null && metadata.limitStatus) {
        final AppUsageRecord? usageRecord =
            _dataStore.getAppUsage(appName, date);
        final Duration timeSpent = usageRecord?.timeSpent ?? Duration.zero;

        double percentageOfLimit = 0.0;
        if (metadata.dailyLimit != Duration.zero) {
          percentageOfLimit =
              (timeSpent.inSeconds / metadata.dailyLimit.inSeconds) * 100;
        }

        double percentageOfTotalTime = 0.0;
        if (totalScreenTime.inSeconds > 0) {
          percentageOfTotalTime =
              (timeSpent.inSeconds / totalScreenTime.inSeconds) * 100;
        }

        limitDetails.add(ApplicationLimitDetail(
          name: appName,
          category: metadata.category,
          dailyLimit: metadata.dailyLimit,
          actualUsage: timeSpent,
          percentageOfLimit: percentageOfLimit,
          percentageOfTotalTime: percentageOfTotalTime,
        ));
      }
    }

    return limitDetails
      ..sort((a, b) => b.percentageOfLimit.compareTo(a.percentageOfLimit));
  }

  double _calculatePercentage(Duration current, Duration average) {
    if (average.inSeconds < 300) {
      return 100.0;
    }
    return ((current.inSeconds / average.inSeconds) * 100).clamp(0.0, 200.0);
  }

  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m';
    } else {
      final seconds = duration.inSeconds.remainder(60);
      return '${seconds}s';
    }
  }
}

// Data classes (unchanged)
class OverviewData {
  final Duration totalScreenTime;
  final Duration averageScreenTime;
  final double screenTimePercentage;
  final Duration productiveTime;
  final double productivityScore;
  final String mostUsedApp;
  final int focusSessions;
  final Duration totalFocusTime;
  final List<ApplicationDetail> topApplications;
  final List<CategoryDetail> categoryBreakdown;
  final List<ApplicationLimitDetail> applicationLimits;

  final String formattedTotalScreenTime;
  final String formattedAverageScreenTime;
  final String formattedProductiveTime;
  final String formattedTotalFocusTime;

  OverviewData({
    required this.totalScreenTime,
    required this.averageScreenTime,
    required this.screenTimePercentage,
    required this.productiveTime,
    required this.productivityScore,
    required this.mostUsedApp,
    required this.focusSessions,
    required this.totalFocusTime,
    required this.topApplications,
    required this.categoryBreakdown,
    required this.applicationLimits,
  })  : formattedTotalScreenTime =
            DailyOverviewData.formatDuration(totalScreenTime),
        formattedAverageScreenTime =
            DailyOverviewData.formatDuration(averageScreenTime),
        formattedProductiveTime =
            DailyOverviewData.formatDuration(productiveTime),
        formattedTotalFocusTime =
            DailyOverviewData.formatDuration(totalFocusTime);
}

class ApplicationDetail {
  final String name;
  final String category;
  final Duration screenTime;
  final double percentageOfTotalTime;
  final String formattedScreenTime;
  final bool isVisible;

  ApplicationDetail({
    required this.name,
    required this.category,
    required this.screenTime,
    required this.percentageOfTotalTime,
    required this.isVisible,
  }) : formattedScreenTime = DailyOverviewData.formatDuration(screenTime);
}

class CategoryDetail {
  final String name;
  final Duration totalScreenTime;
  final double percentageOfTotalTime;
  final String formattedTotalScreenTime;

  CategoryDetail({
    required this.name,
    required this.totalScreenTime,
    required this.percentageOfTotalTime,
  }) : formattedTotalScreenTime =
            DailyOverviewData.formatDuration(totalScreenTime);
}

class ApplicationLimitDetail {
  final String name;
  final String category;
  final Duration dailyLimit;
  final Duration actualUsage;
  final double percentageOfLimit;
  final double percentageOfTotalTime;
  final String formattedDailyLimit;
  final String formattedActualUsage;

  ApplicationLimitDetail({
    required this.name,
    required this.category,
    required this.dailyLimit,
    required this.actualUsage,
    required this.percentageOfLimit,
    required this.percentageOfTotalTime,
  })  : formattedDailyLimit = DailyOverviewData.formatDuration(dailyLimit),
        formattedActualUsage = DailyOverviewData.formatDuration(actualUsage);
}
