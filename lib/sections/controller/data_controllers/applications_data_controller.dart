import 'package:intl/intl.dart';
import 'dart:math';
import '../app_data_controller.dart'; // Import the AppDataStore class

// Extension for formatting Duration objects
extension DurationFormatter on Duration {
  String toHourMinuteFormat() {
    final int hours = this.inHours;
    final int minutes = this.inMinutes % 60;
    
    if (hours > 0) {
      if (minutes > 0) {
        return "${hours}h ${minutes}m";
      } else {
        return "${hours}h";
      }
    } else if (minutes > 0) {
      return "${minutes}m";
    } else {
      final int seconds = this.inSeconds % 60;
      return "${seconds}s";
    }
  }
}

enum TimeRange {
  day,
  week,
  month
}

class DateRange {
  final DateTime startDate;
  final DateTime endDate;

  DateRange({required this.startDate, required this.endDate});
}

// Update ApplicationBasicDetail to include formatted screen time
class ApplicationBasicDetail {
  final String name;
  final String category;
  final Duration screenTime;
  final String formattedScreenTime; // New formatted time property
  final bool isTracking;
  final bool isHidden;

  ApplicationBasicDetail({
    required this.name,
    required this.category,
    required this.screenTime,
    required this.isTracking,
    required this.isHidden,
  }) : formattedScreenTime = screenTime.toHourMinuteFormat();
}

// Update UsageTrendsData to include formatted times
class UsageTrendsData {
  final Map<String, Duration> daily;
  final Map<String, Duration> weekly;
  final Map<String, Duration> monthly;
  final Map<String, String> formattedDaily; // New formatted time properties
  final Map<String, String> formattedWeekly;
  final Map<String, String> formattedMonthly;

  UsageTrendsData({
    required this.daily,
    required this.weekly,
    required this.monthly,
  }) : 
    formattedDaily = daily.map((key, value) => MapEntry(key, value.toHourMinuteFormat())),
    formattedWeekly = weekly.map((key, value) => MapEntry(key, value.toHourMinuteFormat())),
    formattedMonthly = monthly.map((key, value) => MapEntry(key, value.toHourMinuteFormat()));
}

// Update UsageInsights to include formatted times
class UsageInsights {
  final List<int> mostActiveHours;
  final Duration longestSession;
  final String formattedLongestSession; // New formatted time property
  final Duration averageDailyUsage;
  final String formattedAverageDailyUsage; // New formatted time property

  UsageInsights({
    required this.mostActiveHours,
    required this.longestSession,
    required this.averageDailyUsage,
  }) : 
    formattedLongestSession = longestSession.toHourMinuteFormat(),
    formattedAverageDailyUsage = averageDailyUsage.toHourMinuteFormat();
}

// Update CategoryAppComparison to include formatted time
class CategoryAppComparison {
  final String appName;
  final Duration usage;
  final String formattedUsage; // New formatted time property
  final double comparisonPercentage;

  CategoryAppComparison({
    required this.appName,
    required this.usage,
    required this.comparisonPercentage,
  }) : formattedUsage = usage.toHourMinuteFormat();
}

// Update UsageComparisons to include formatted times
class UsageComparisons {
  final Duration currentPeriodUsage;
  final String formattedCurrentPeriodUsage; // New formatted time property
  final Duration previousPeriodUsage;
  final String formattedPreviousPeriodUsage; // New formatted time property
  final double growthPercentage;
  final List<CategoryAppComparison> similarAppsComparison;

  UsageComparisons({
    required this.currentPeriodUsage,
    required this.previousPeriodUsage,
    required this.growthPercentage,
    required this.similarAppsComparison,
  }) : 
    formattedCurrentPeriodUsage = currentPeriodUsage.toHourMinuteFormat(),
    formattedPreviousPeriodUsage = previousPeriodUsage.toHourMinuteFormat();
}

// Update SessionBreakdown to include formatted times
class SessionBreakdown {
  final Duration averageSessionDuration;
  final String formattedAverageSessionDuration; // New formatted time property
  final Duration longestSessionDuration;
  final String formattedLongestSessionDuration; // New formatted time property
  final Duration shortestSessionDuration;
  final String formattedShortestSessionDuration; // New formatted time property
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
  }) : 
    formattedAverageSessionDuration = averageSessionDuration.toHourMinuteFormat(),
    formattedLongestSessionDuration = longestSessionDuration.toHourMinuteFormat(),
    formattedShortestSessionDuration = shortestSessionDuration.toHourMinuteFormat();
}

// Update ApplicationDetailedData to include the modified classes
class ApplicationDetailedData {
  final UsageTrendsData usageTrends;
  final Map<int, Duration> hourlyBreakdown;
  final Map<int, String> formattedHourlyBreakdown; // New formatted hourly breakdown
  final Map<String, Duration> categoryUsage;
  final Map<String, String> formattedCategoryUsage; // New formatted category usage
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
  }) : 
    formattedHourlyBreakdown = hourlyBreakdown.map((key, value) => MapEntry(key, value.toHourMinuteFormat())),
    formattedCategoryUsage = categoryUsage.map((key, value) => MapEntry(key, value.toHourMinuteFormat()));
}

class ApplicationsDataProvider {
  // Singleton instance
  static final ApplicationsDataProvider _instance = ApplicationsDataProvider._internal();
  factory ApplicationsDataProvider() => _instance;
  ApplicationsDataProvider._internal();

  // AppDataStore instance
  final AppDataStore _dataStore = AppDataStore();

  // Fetch all applications list with basic details
  Future<List<ApplicationBasicDetail>> fetchAllApplications() async {
    // Ensure AppDataStore is initialized
    await _dataStore.init();
    
    final List<ApplicationBasicDetail> applications = [];
    final DateTime today = DateTime.now();
    
    for (final appName in _dataStore.allAppNames) {
      final AppMetadata? metadata = _dataStore.getAppMetadata(appName);
      final AppUsageRecord? usageRecord = _dataStore.getAppUsage(appName, today);
      
      if (metadata != null) {
        applications.add(ApplicationBasicDetail(
          name: appName,
          category: metadata.category,
          screenTime: usageRecord?.timeSpent ?? Duration.zero,
          isTracking: metadata.isTracking,
          isHidden: !metadata.isVisible,
        ));
      }
    }
    
    // Sort applications by screen time in descending order
    applications.sort((a, b) => b.screenTime.compareTo(a.screenTime));
    
    return applications;
  }
  
  // Fetch detailed application data for graphs and charts
  Future<ApplicationDetailedData> fetchApplicationDetails(String appName, TimeRange timeRange) async {
    // Ensure AppDataStore is initialized
    await _dataStore.init();
    
    final AppMetadata? metadata = _dataStore.getAppMetadata(appName);
    if (metadata == null) {
      throw Exception('App metadata not found for: $appName');
    }
    
    // Get date range based on the selected time range
    final DateRange dateRange = _getDateRange(timeRange);
    
    // Fetch all the detailed data
    final usageTrendsData = await _fetchUsageTrendsData(appName, dateRange);
    final hourlyBreakdownData = await _fetchHourlyBreakdownData(appName, dateRange);
    final categoryUsageData = await _fetchCategoryUsageData(appName, metadata.category, dateRange);
    final usageInsights = await _fetchUsageInsights(appName, dateRange);
    final comparisonsData = await _fetchComparisonsData(appName, metadata.category, dateRange);
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
  
  // Convert TimeRange enum to actual DateRange
  DateRange _getDateRange(TimeRange timeRange) {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    
    switch (timeRange) {
      case TimeRange.day:
        return DateRange(
          startDate: today,
          endDate: today,
        );
      case TimeRange.week:
        return DateRange(
          startDate: today.subtract(Duration(days: 6)),
          endDate: today,
        );
      case TimeRange.month:
        return DateRange(
          startDate: today.subtract(Duration(days: 29)),
          endDate: today,
        );
    }
  }
  
  // Fetch usage trends data (daily/weekly/monthly)
  Future<UsageTrendsData> _fetchUsageTrendsData(String appName, DateRange dateRange) async {
    final Map<String, Duration> dailyUsage = {};
    
    // Loop through each day in the date range
    DateTime currentDate = dateRange.startDate;
    while (currentDate.isBefore(dateRange.endDate) || currentDate.isAtSameMomentAs(dateRange.endDate)) {
      final AppUsageRecord? record = _dataStore.getAppUsage(appName, currentDate);
      final String dateKey = DateFormat('MM/dd').format(currentDate);
      
      dailyUsage[dateKey] = record?.timeSpent ?? Duration.zero;
      currentDate = currentDate.add(Duration(days: 1));
    }
    
    // Calculate weekly data by grouping days
    final Map<String, Duration> weeklyUsage = {};
    if (dateRange.endDate.difference(dateRange.startDate).inDays >= 14) {
      currentDate = dateRange.startDate;
      int weekNum = 1;
      
      while (currentDate.isBefore(dateRange.endDate)) {
        final DateTime weekEnd = currentDate.add(Duration(days: 6));
        final DateTime actualEnd = weekEnd.isAfter(dateRange.endDate) ? dateRange.endDate : weekEnd;
        
        Duration weeklyTotal = Duration.zero;
        DateTime weekDay = currentDate;
        
        while (weekDay.isBefore(actualEnd) || weekDay.isAtSameMomentAs(actualEnd)) {
          final AppUsageRecord? record = _dataStore.getAppUsage(appName, weekDay);
          weeklyTotal += record?.timeSpent ?? Duration.zero;
          weekDay = weekDay.add(Duration(days: 1));
        }
        
        weeklyUsage['Week $weekNum'] = weeklyTotal;
        weekNum++;
        currentDate = currentDate.add(Duration(days: 7));
      }
    }
    
    // Calculate monthly data if range spans multiple months
    final Map<String, Duration> monthlyUsage = {};
    if (dateRange.endDate.difference(dateRange.startDate).inDays >= 28) {
      // Group by month
      final Map<String, List<Duration>> monthMap = {};
      
      currentDate = dateRange.startDate;
      while (currentDate.isBefore(dateRange.endDate) || currentDate.isAtSameMomentAs(dateRange.endDate)) {
        final String monthKey = DateFormat('MMM').format(currentDate);
        final AppUsageRecord? record = _dataStore.getAppUsage(appName, currentDate);
        
        if (!monthMap.containsKey(monthKey)) {
          monthMap[monthKey] = [];
        }
        
        monthMap[monthKey]!.add(record?.timeSpent ?? Duration.zero);
        currentDate = currentDate.add(Duration(days: 1));
      }
      
      // Sum durations for each month
      monthMap.forEach((month, durations) {
        Duration total = Duration.zero;
        for (var duration in durations) {
          total += duration;
        }
        monthlyUsage[month] = total;
      });
    }
    
    return UsageTrendsData(
      daily: dailyUsage,
      weekly: weeklyUsage,
      monthly: monthlyUsage,
    );
  }
  
  // Remaining methods remain the same, as we've updated the model classes
  // to automatically format durations when they're created
  
  // Fetch hourly breakdown data
  Future<Map<int, Duration>> _fetchHourlyBreakdownData(String appName, DateRange dateRange) async {
    // Implementation remains the same
    final Map<int, Duration> hourlyUsage = {};
    
    // Initialize all hours with zero duration
    for (int hour = 0; hour < 24; hour++) {
      hourlyUsage[hour] = Duration.zero;
    }
    
    // Loop through each day in the date range
    DateTime currentDate = dateRange.startDate;
    while (currentDate.isBefore(dateRange.endDate) || currentDate.isAtSameMomentAs(dateRange.endDate)) {
      final AppUsageRecord? record = _dataStore.getAppUsage(appName, currentDate);
      
      if (record != null && record.usagePeriods.isNotEmpty) {
        // Analyze each usage period and distribute time to hourly buckets
        for (final period in record.usagePeriods) {
          final DateTime startTime = period.startTime;
          final DateTime endTime = period.endTime;
          
          // If the period spans across multiple hours, split it
          DateTime currentHour = DateTime(
            startTime.year, 
            startTime.month, 
            startTime.day, 
            startTime.hour,
            0 // Reset minutes to start of hour
          );
          
          DateTime nextHour = currentHour.add(Duration(hours: 1));
          DateTime remaining = startTime;
          
          while (remaining.isBefore(endTime)) {
            final Duration timeInThisHour;
            
            if (endTime.isBefore(nextHour)) {
              // Session ends within this hour
              timeInThisHour = endTime.difference(remaining);
              remaining = endTime;
            } else {
              // Session continues to next hour
              timeInThisHour = nextHour.difference(remaining);
              remaining = nextHour;
              currentHour = nextHour;
              nextHour = currentHour.add(Duration(hours: 1));
            }
            
            hourlyUsage[currentHour.hour] = hourlyUsage[currentHour.hour]! + timeInThisHour;
          }
        }
      }
      
      currentDate = currentDate.add(Duration(days: 1));
    }
    
    return hourlyUsage;
  }
  
  // Fetch category-wise usage data
  Future<Map<String, Duration>> _fetchCategoryUsageData(String appName, String appCategory, DateRange dateRange) async {
    // Implementation remains the same
    final Map<String, Duration> categoryUsage = {};
    
    // Get all apps in the same category
    for (final name in _dataStore.allAppNames) {
      final AppMetadata? metadata = _dataStore.getAppMetadata(name);
      
      if (metadata != null && metadata.category == appCategory) {
        // Sum usage across the date range
        Duration totalUsage = Duration.zero;
        
        DateTime currentDate = dateRange.startDate;
        while (currentDate.isBefore(dateRange.endDate) || currentDate.isAtSameMomentAs(dateRange.endDate)) {
          final AppUsageRecord? record = _dataStore.getAppUsage(name, currentDate);
          totalUsage += record?.timeSpent ?? Duration.zero;
          currentDate = currentDate.add(Duration(days: 1));
        }
        
        if (totalUsage > Duration.zero) {
          categoryUsage[name] = totalUsage;
        }
      }
    }
    
    return categoryUsage;
  }
  
  // Fetch usage insights
  Future<UsageInsights> _fetchUsageInsights(String appName, DateRange dateRange) async {
    // Find most active hours
    final Map<int, Duration> hourlyData = await _fetchHourlyBreakdownData(appName, dateRange);
    final List<int> activeHours = [];
    
    // Find the top 3 most active hours
    final List<MapEntry<int, Duration>> sortedHours = hourlyData.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    for (int i = 0; i < min(3, sortedHours.length); i++) {
      if (sortedHours[i].value > Duration.zero) {
        activeHours.add(sortedHours[i].key);
      }
    }
    
    // Find longest session
    Duration longestSession = Duration.zero;
    
    DateTime currentDate = dateRange.startDate;
    while (currentDate.isBefore(dateRange.endDate) || currentDate.isAtSameMomentAs(dateRange.endDate)) {
      final AppUsageRecord? record = _dataStore.getAppUsage(appName, currentDate);
      
      if (record != null && record.usagePeriods.isNotEmpty) {
        for (final period in record.usagePeriods) {
          final Duration sessionDuration = period.duration;
          if (sessionDuration > longestSession) {
            longestSession = sessionDuration;
          }
        }
      }
      
      currentDate = currentDate.add(Duration(days: 1));
    }
    
    // Calculate average daily usage
    Duration totalUsage = Duration.zero;
    int daysWithUsage = 0;
    
    currentDate = dateRange.startDate;
    while (currentDate.isBefore(dateRange.endDate) || currentDate.isAtSameMomentAs(dateRange.endDate)) {
      final AppUsageRecord? record = _dataStore.getAppUsage(appName, currentDate);
      
      if (record != null && record.timeSpent > Duration.zero) {
        totalUsage += record.timeSpent;
        daysWithUsage++;
      }
      
      currentDate = currentDate.add(Duration(days: 1));
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
  
  // Fetch comparisons data
  Future<UsageComparisons> _fetchComparisonsData(String appName, String category, DateRange dateRange) async {
    // Get current period data
    Duration currentPeriodUsage = Duration.zero;
    
    DateTime currentDate = dateRange.startDate;
    while (currentDate.isBefore(dateRange.endDate) || currentDate.isAtSameMomentAs(dateRange.endDate)) {
      final AppUsageRecord? record = _dataStore.getAppUsage(appName, currentDate);
      currentPeriodUsage += record?.timeSpent ?? Duration.zero;
      currentDate = currentDate.add(Duration(days: 1));
    }
    
    // Get previous period data (same length as current period)
    final int periodLengthDays = dateRange.endDate.difference(dateRange.startDate).inDays + 1;
    final DateTime previousPeriodStart = dateRange.startDate.subtract(Duration(days: periodLengthDays));
    final DateTime previousPeriodEnd = dateRange.startDate.subtract(Duration(days: 1));
    
    Duration previousPeriodUsage = Duration.zero;
    
    currentDate = previousPeriodStart;
    while (currentDate.isBefore(previousPeriodEnd) || currentDate.isAtSameMomentAs(previousPeriodEnd)) {
      final AppUsageRecord? record = _dataStore.getAppUsage(appName, currentDate);
      previousPeriodUsage += record?.timeSpent ?? Duration.zero;
      currentDate = currentDate.add(Duration(days: 1));
    }
    
    // Calculate growth percentage
    double growthPercentage = 0;
    if (previousPeriodUsage.inSeconds > 0) {
      growthPercentage = ((currentPeriodUsage.inSeconds - previousPeriodUsage.inSeconds) / 
                         previousPeriodUsage.inSeconds) * 100;
    }
    
    // Compare with similar apps in the same category
    final Map<String, Duration> categoryAppsUsage = {};
    final List<CategoryAppComparison> similarAppsComparison = [];
    
    for (final name in _dataStore.allAppNames) {
      if (name != appName) {
        final AppMetadata? metadata = _dataStore.getAppMetadata(name);
        
        if (metadata != null && metadata.category == category) {
          Duration appTotalUsage = Duration.zero;
          
          currentDate = dateRange.startDate;
          while (currentDate.isBefore(dateRange.endDate) || currentDate.isAtSameMomentAs(dateRange.endDate)) {
            final AppUsageRecord? record = _dataStore.getAppUsage(name, currentDate);
            appTotalUsage += record?.timeSpent ?? Duration.zero;
            currentDate = currentDate.add(Duration(days: 1));
          }
          
          if (appTotalUsage > Duration.zero) {
            categoryAppsUsage[name] = appTotalUsage;
            
            double percentage = 0;
            if (currentPeriodUsage.inSeconds > 0) {
              percentage = (appTotalUsage.inSeconds / currentPeriodUsage.inSeconds) * 100;
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
    
    // Sort by usage
    similarAppsComparison.sort((a, b) => b.usage.compareTo(a.usage));
    
    return UsageComparisons(
      currentPeriodUsage: currentPeriodUsage,
      previousPeriodUsage: previousPeriodUsage,
      growthPercentage: growthPercentage,
      similarAppsComparison: similarAppsComparison,
    );
  }
  
  // Fetch session breakdown data
  Future<SessionBreakdown> _fetchSessionBreakdown(String appName, DateRange dateRange) async {
    // Initialize variables for session stats
    final List<Duration> sessionDurations = [];
    final Map<DateTime, int> dailyLaunches = {};
    DateTime? lastUsedTimestamp;
    
    // Process each day in the date range
    DateTime currentDate = dateRange.startDate;
    while (currentDate.isBefore(dateRange.endDate) || currentDate.isAtSameMomentAs(dateRange.endDate)) {
      final AppUsageRecord? record = _dataStore.getAppUsage(appName, currentDate);
      
      if (record != null) {
        // Collect session durations
        for (final period in record.usagePeriods) {
          sessionDurations.add(period.duration);
          
          // Track last used timestamp
          if (lastUsedTimestamp == null || period.endTime.isAfter(lastUsedTimestamp)) {
            lastUsedTimestamp = period.endTime;
          }
        }
        
        // Track launches per day
        dailyLaunches[currentDate] = record.openCount;
      }
      
      currentDate = currentDate.add(Duration(days: 1));
    }
    
    // Calculate average session duration
    Duration averageSessionDuration = Duration.zero;
    if (sessionDurations.isNotEmpty) {
      final int totalSeconds = sessionDurations.fold(
        0, (sum, duration) => sum + duration.inSeconds
      );
      averageSessionDuration = Duration(seconds: totalSeconds ~/ sessionDurations.length);
    }
    
    // Calculate average launches per day
    double averageLaunchesPerDay = 0;
    if (dailyLaunches.isNotEmpty) {
      final int totalLaunches = dailyLaunches.values.fold(
        0, (sum, launches) => sum + launches
      );
      averageLaunchesPerDay = totalLaunches / dailyLaunches.length;
    }
    
    return SessionBreakdown(
      averageSessionDuration: averageSessionDuration,
      longestSessionDuration: sessionDurations.isEmpty ? Duration.zero : sessionDurations.reduce((a, b) => a > b ? a : b),
      shortestSessionDuration: sessionDurations.isEmpty ? Duration.zero : sessionDurations.reduce((a, b) => a < b ? a : b),
      totalSessions: sessionDurations.length,
      averageLaunchesPerDay: averageLaunchesPerDay,
      maxLaunchesPerDay: dailyLaunches.isEmpty ? 0 : dailyLaunches.values.reduce((a, b) => a > b ? a : b),
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