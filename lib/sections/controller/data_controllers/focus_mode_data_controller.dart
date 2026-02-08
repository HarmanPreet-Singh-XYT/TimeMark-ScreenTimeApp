import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../app_data_controller.dart';

// Assuming these are defined in your existing codebase
// import 'app_data_store.dart';
// import 'models/focus_session_record.dart';

class FocusAnalyticsService {
  final AppDataStore _dataStore;

  // Singleton pattern
  static final FocusAnalyticsService _instance =
      FocusAnalyticsService._internal();

  factory FocusAnalyticsService() {
    return _instance;
  }

  FocusAnalyticsService._internal() : _dataStore = AppDataStore();

  // ═══════════════════════════════════════════════════════════════════════════
  // HELPER: Extract session type from appsBlocked
  // ═══════════════════════════════════════════════════════════════════════════

  String _getSessionType(List<String> appsBlocked) {
    const List<String> pomodoroTags = [
      'POMODORO_WORK',
      'POMODORO_SHORT_BREAK',
      'POMODORO_LONG_BREAK',
    ];

    for (final tag in pomodoroTags) {
      if (appsBlocked.contains(tag)) {
        return tag;
      }
    }

    return 'REGULAR_FOCUS'; // Non-pomodoro focus session
  }

  String _getSessionTypeLabel(String sessionType) {
    switch (sessionType) {
      case 'POMODORO_WORK':
        return 'Work Session';
      case 'POMODORO_SHORT_BREAK':
        return 'Short Break';
      case 'POMODORO_LONG_BREAK':
        return 'Long Break';
      default:
        return 'Focus Session';
    }
  }

  bool _isPomodoroPhase(String sessionType) {
    return sessionType == 'POMODORO_WORK' ||
        sessionType == 'POMODORO_SHORT_BREAK' ||
        sessionType == 'POMODORO_LONG_BREAK';
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TIME DISTRIBUTION - Fixed to use session type tags
  // ═══════════════════════════════════════════════════════════════════════════

  Map<String, dynamic> getTimeDistribution({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    if (!_dataStore.isInitialized) {
      return _emptyTimeDistribution();
    }

    try {
      final List<FocusSessionRecord> sessions = _dataStore
          .getFocusSessionsRange(startDate, endDate)
          .where((session) => session.completed)
          .toList();

      if (sessions.isEmpty) {
        return _emptyTimeDistribution();
      }

      Duration workTime = Duration.zero;
      Duration shortBreakTime = Duration.zero;
      Duration longBreakTime = Duration.zero;

      for (final session in sessions) {
        final String sessionType = _getSessionType(session.appsBlocked);

        switch (sessionType) {
          case 'POMODORO_WORK':
            workTime += session.duration;
            break;
          case 'POMODORO_SHORT_BREAK':
            shortBreakTime += session.duration;
            break;
          case 'POMODORO_LONG_BREAK':
            longBreakTime += session.duration;
            break;
          default:
            // Regular focus sessions count as work
            workTime += session.duration;
            break;
        }
      }

      final Duration totalTime = workTime + shortBreakTime + longBreakTime;

      final double workPercentage = totalTime.inSeconds > 0
          ? workTime.inSeconds / totalTime.inSeconds * 100
          : 0.0;
      final double shortBreakPercentage = totalTime.inSeconds > 0
          ? shortBreakTime.inSeconds / totalTime.inSeconds * 100
          : 0.0;
      final double longBreakPercentage = totalTime.inSeconds > 0
          ? longBreakTime.inSeconds / totalTime.inSeconds * 100
          : 0.0;

      return {
        'workTime': workTime,
        'shortBreakTime': shortBreakTime,
        'longBreakTime': longBreakTime,
        'totalTime': totalTime,
        'workPercentage': workPercentage,
        'shortBreakPercentage': shortBreakPercentage,
        'longBreakPercentage': longBreakPercentage,
        'formattedWorkTime': _formatDuration(workTime),
        'formattedShortBreakTime': _formatDuration(shortBreakTime),
        'formattedLongBreakTime': _formatDuration(longBreakTime),
        'formattedTotalTime': _formatDuration(totalTime),
      };
    } catch (e) {
      debugPrint("Error getting time distribution: $e");
      return _emptyTimeDistribution();
    }
  }

  Map<String, dynamic> _emptyTimeDistribution() {
    return {
      'workTime': Duration.zero,
      'shortBreakTime': Duration.zero,
      'longBreakTime': Duration.zero,
      'totalTime': Duration.zero,
      'workPercentage': 0.0,
      'shortBreakPercentage': 0.0,
      'longBreakPercentage': 0.0,
      'formattedWorkTime': '0 min',
      'formattedShortBreakTime': '0 min',
      'formattedLongBreakTime': '0 min',
      'formattedTotalTime': '0 min',
    };
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SESSION COUNTING - Count COMPLETE Pomodoro sessions (not individual phases)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Count complete Pomodoro sessions (a session ends with a long break)
  int getCompletePomodoroSessionCount({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    if (!_dataStore.isInitialized) return 0;

    try {
      final List<FocusSessionRecord> sessions = _dataStore
          .getFocusSessionsRange(startDate, endDate)
          .where((session) => session.completed)
          .toList();

      // Count long breaks = count of complete sessions
      int completeSessionCount = 0;
      for (final session in sessions) {
        final String sessionType = _getSessionType(session.appsBlocked);
        if (sessionType == 'POMODORO_LONG_BREAK') {
          completeSessionCount++;
        }
      }

      return completeSessionCount;
    } catch (e) {
      debugPrint("Error counting complete sessions: $e");
      return 0;
    }
  }

  /// Count work phases completed (for progress tracking)
  int getWorkPhaseCount({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    if (!_dataStore.isInitialized) return 0;

    try {
      final List<FocusSessionRecord> sessions = _dataStore
          .getFocusSessionsRange(startDate, endDate)
          .where((session) => session.completed)
          .toList();

      int workCount = 0;
      for (final session in sessions) {
        final String sessionType = _getSessionType(session.appsBlocked);
        if (sessionType == 'POMODORO_WORK') {
          workCount++;
        }
      }

      return workCount;
    } catch (e) {
      debugPrint("Error counting work phases: $e");
      return 0;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SESSION COUNT BY DAY - Count complete sessions per day
  // ═══════════════════════════════════════════════════════════════════════════

  Map<String, int> getSessionCountByDay({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    if (!_dataStore.isInitialized) return {};

    try {
      final Map<String, int> result = {};
      final List<FocusSessionRecord> sessions =
          _dataStore.getFocusSessionsRange(startDate, endDate);

      // Initialize result with all days in the range
      DateTime current =
          DateTime(startDate.year, startDate.month, startDate.day);
      final DateTime end = DateTime(endDate.year, endDate.month, endDate.day);

      while (!current.isAfter(end)) {
        final String dateKey = _formatDate(current);
        result[dateKey] = 0;
        current = current.add(const Duration(days: 1));
      }

      // Count COMPLETE sessions by day (only count long breaks as session completion)
      for (final session in sessions) {
        if (session.completed) {
          final String sessionType = _getSessionType(session.appsBlocked);

          // Only count complete Pomodoro sessions (marked by long break completion)
          if (sessionType == 'POMODORO_LONG_BREAK') {
            final String dateKey = _formatDate(session.date);
            result[dateKey] = (result[dateKey] ?? 0) + 1;
          }
        }
      }

      return result;
    } catch (e) {
      debugPrint("Error getting session count by day: $e");
      return {};
    }
  }

  /// Alternative: Get work phase count by day (if you want to show work periods instead)
  Map<String, int> getWorkPhaseCountByDay({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    if (!_dataStore.isInitialized) return {};

    try {
      final Map<String, int> result = {};
      final List<FocusSessionRecord> sessions =
          _dataStore.getFocusSessionsRange(startDate, endDate);

      // Initialize result with all days in the range
      DateTime current =
          DateTime(startDate.year, startDate.month, startDate.day);
      final DateTime end = DateTime(endDate.year, endDate.month, endDate.day);

      while (!current.isAfter(end)) {
        final String dateKey = _formatDate(current);
        result[dateKey] = 0;
        current = current.add(const Duration(days: 1));
      }

      // Count work phases by day
      for (final session in sessions) {
        if (session.completed) {
          final String sessionType = _getSessionType(session.appsBlocked);

          if (sessionType == 'POMODORO_WORK') {
            final String dateKey = _formatDate(session.date);
            result[dateKey] = (result[dateKey] ?? 0) + 1;
          }
        }
      }

      return result;
    } catch (e) {
      debugPrint("Error getting work phase count by day: $e");
      return {};
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SESSION HISTORY - Show grouped Pomodoro cycles OR individual phases
  // ═══════════════════════════════════════════════════════════════════════════

  /// Get detailed history showing each phase with its type
  List<Map<String, dynamic>> getSessionHistory({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    if (!_dataStore.isInitialized) return [];

    try {
      final List<Map<String, dynamic>> result = [];
      final List<FocusSessionRecord> sessions =
          _dataStore.getFocusSessionsRange(startDate, endDate);

      for (final session in sessions) {
        if (session.completed) {
          final String sessionType = _getSessionType(session.appsBlocked);
          final String sessionTypeLabel = _getSessionTypeLabel(sessionType);

          final String startTimeStr =
              DateFormat('yyyy-MM-dd HH:mm').format(session.startTime);
          final String durationStr = _formatDuration(session.duration);

          result.add({
            'date': startTimeStr,
            'duration': durationStr,
            'totalMinutes': session.duration.inMinutes,
            'sessionType': sessionType,
            'sessionTypeLabel': sessionTypeLabel,
            'isPomodoroPhase': _isPomodoroPhase(sessionType),
            'appsBlocked': session.appsBlocked,
            'rawSession': session,
          });
        }
      }

      // Sort by date (newest first)
      result.sort((a, b) => b['date'].compareTo(a['date']));

      return result;
    } catch (e) {
      debugPrint("Error getting session history: $e");
      return [];
    }
  }

  /// Get grouped Pomodoro sessions (each complete cycle as one entry)
  List<Map<String, dynamic>> getGroupedPomodoroSessions({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    if (!_dataStore.isInitialized) return [];

    try {
      final List<FocusSessionRecord> allSessions = _dataStore
          .getFocusSessionsRange(startDate, endDate)
          .where((session) => session.completed)
          .toList();

      // Sort by start time
      allSessions.sort((a, b) => a.startTime.compareTo(b.startTime));

      final List<Map<String, dynamic>> groupedSessions = [];
      List<FocusSessionRecord> currentGroup = [];

      for (final session in allSessions) {
        final String sessionType = _getSessionType(session.appsBlocked);

        if (!_isPomodoroPhase(sessionType)) {
          // Non-Pomodoro session, add as standalone
          groupedSessions.add({
            'type': 'regular_focus',
            'startTime': session.startTime,
            'totalDuration': session.duration,
            'workDuration': session.duration,
            'breakDuration': Duration.zero,
            'phases': 1,
            'isComplete': true,
          });
          continue;
        }

        currentGroup.add(session);

        // If we hit a long break, this completes a Pomodoro session
        if (sessionType == 'POMODORO_LONG_BREAK') {
          final groupedSession = _summarizeGroup(currentGroup);
          groupedSessions.add(groupedSession);
          currentGroup = [];
        }
      }

      // Handle incomplete session (no long break yet)
      if (currentGroup.isNotEmpty) {
        final groupedSession = _summarizeGroup(currentGroup, isComplete: false);
        groupedSessions.add(groupedSession);
      }

      // Sort newest first
      groupedSessions.sort((a, b) =>
          (b['startTime'] as DateTime).compareTo(a['startTime'] as DateTime));

      return groupedSessions;
    } catch (e) {
      debugPrint("Error getting grouped sessions: $e");
      return [];
    }
  }

  Map<String, dynamic> _summarizeGroup(List<FocusSessionRecord> group,
      {bool isComplete = true}) {
    if (group.isEmpty) {
      return {
        'type': 'pomodoro',
        'startTime': DateTime.now(),
        'totalDuration': Duration.zero,
        'workDuration': Duration.zero,
        'breakDuration': Duration.zero,
        'phases': 0,
        'isComplete': false,
      };
    }

    Duration workDuration = Duration.zero;
    Duration breakDuration = Duration.zero;
    int workPhases = 0;
    int breakPhases = 0;

    for (final session in group) {
      final String sessionType = _getSessionType(session.appsBlocked);

      switch (sessionType) {
        case 'POMODORO_WORK':
          workDuration += session.duration;
          workPhases++;
          break;
        case 'POMODORO_SHORT_BREAK':
        case 'POMODORO_LONG_BREAK':
          breakDuration += session.duration;
          breakPhases++;
          break;
      }
    }

    return {
      'type': 'pomodoro',
      'startTime': group.first.startTime,
      'endTime': group.last.startTime.add(group.last.duration),
      'totalDuration': workDuration + breakDuration,
      'workDuration': workDuration,
      'breakDuration': breakDuration,
      'workPhases': workPhases,
      'breakPhases': breakPhases,
      'phases': group.length,
      'isComplete': isComplete,
      'formattedTotalDuration': _formatDuration(workDuration + breakDuration),
      'formattedWorkDuration': _formatDuration(workDuration),
      'formattedBreakDuration': _formatDuration(breakDuration),
    };
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // WEEKLY SUMMARY - Fixed to count complete sessions
  // ═══════════════════════════════════════════════════════════════════════════

  Map<String, dynamic> getWeeklySummary({DateTime? targetDate}) {
    final DateTime now = targetDate ?? DateTime.now();

    // Find start of week (Monday) and end of week (Sunday)
    final int weekday = now.weekday;
    final DateTime startOfWeek = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: weekday - 1));
    final DateTime endOfWeek = startOfWeek
        .add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));

    // Get complete session count by day
    final Map<String, int> sessionsByDay = getSessionCountByDay(
      startDate: startOfWeek,
      endDate: endOfWeek,
    );

    // Get time distribution
    final Map<String, dynamic> timeDistribution = getTimeDistribution(
      startDate: startOfWeek,
      endDate: endOfWeek,
    );

    // Get grouped sessions for detailed view
    final List<Map<String, dynamic>> groupedSessions =
        getGroupedPomodoroSessions(
      startDate: startOfWeek,
      endDate: endOfWeek,
    );

    // Calculate totals from TIME DISTRIBUTION (more accurate)
    final Duration totalWorkTime =
        timeDistribution['workTime'] as Duration? ?? Duration.zero;
    final Duration totalShortBreakTime =
        timeDistribution['shortBreakTime'] as Duration? ?? Duration.zero;
    final Duration totalLongBreakTime =
        timeDistribution['longBreakTime'] as Duration? ?? Duration.zero;
    final Duration totalBreakTime = totalShortBreakTime + totalLongBreakTime;
    final Duration totalTime = totalWorkTime + totalBreakTime;

    // Count complete sessions
    final int totalCompleteSessions = groupedSessions
        .where((s) => s['isComplete'] == true && s['type'] == 'pomodoro')
        .length;

    // Count work phases
    final int totalWorkPhases = getWorkPhaseCount(
      startDate: startOfWeek,
      endDate: endOfWeek,
    );

    // Calculate average session length (TOTAL time per complete session)
    final int avgSessionMinutes = totalCompleteSessions > 0
        ? (totalTime.inMinutes / totalCompleteSessions).round()
        : 0;

    // Calculate average WORK time per complete session
    final int avgWorkMinutes = totalCompleteSessions > 0
        ? (totalWorkTime.inMinutes / totalCompleteSessions).round()
        : 0;

    // Find most productive day
    String mostProductiveDay = "None";
    int maxSessions = 0;

    sessionsByDay.forEach((day, count) {
      if (count > maxSessions) {
        maxSessions = count;
        mostProductiveDay = day;
      }
    });

    // Format most productive day
    if (mostProductiveDay != "None") {
      try {
        final DateTime date = DateFormat('yyyy-MM-dd').parse(mostProductiveDay);
        mostProductiveDay = DateFormat('EEEE').format(date);
      } catch (e) {
        debugPrint("Error formatting most productive day: $e");
      }
    }

    return {
      // Week range
      'weekStart': startOfWeek,
      'weekEnd': endOfWeek,

      // Session counts
      'totalSessions': totalCompleteSessions, // Complete Pomodoro cycles
      'totalWorkPhases': totalWorkPhases, // Individual work periods

      // Time values (as Duration)
      'totalTime': totalTime,
      'totalWorkTime': totalWorkTime,
      'totalBreakTime': totalBreakTime,

      // Time values (as int minutes) - THESE ARE WHAT YOUR UI NEEDS
      'totalMinutes': totalTime.inMinutes,
      'totalWorkMinutes': totalWorkTime.inMinutes,
      'totalBreakMinutes': totalBreakTime.inMinutes,

      // Averages
      'avgSessionMinutes': avgSessionMinutes, // Avg TOTAL time per session
      'avgWorkMinutes': avgWorkMinutes, // Avg WORK time per session

      // Formatted strings for display
      'formattedTotalTime': _formatDuration(totalTime),
      'formattedTotalWorkTime': _formatDuration(totalWorkTime),
      'formattedTotalBreakTime': _formatDuration(totalBreakTime),

      // Other data
      'mostProductiveDay': mostProductiveDay,
      'sessionsByDay': sessionsByDay,
      'timeDistribution': timeDistribution,
      'sessions': groupedSessions,
    };
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // FOCUS TRENDS - Fixed to count complete sessions
  // ═══════════════════════════════════════════════════════════════════════════

  Map<String, dynamic> getFocusTrends({
    int months = 3,
    bool useLifetimeIfLess = true,
  }) {
    if (!_dataStore.isInitialized) {
      return _emptyTrends();
    }

    try {
      final DateTime now = DateTime.now();
      final DateTime endDate = DateTime(now.year, now.month, now.day);
      DateTime startDate = DateTime(now.year, now.month - months, 1);

      if (useLifetimeIfLess) {
        final DateTime earliestPossible = DateTime(now.year - 1, now.month, 1);
        if (earliestPossible.isAfter(startDate)) {
          startDate = earliestPossible;
        }
      }

      final List<String> periods = [];
      final List<int> sessionCounts = []; // Complete sessions
      final List<int> workPhaseCounts = []; // Work phases
      final List<double> avgDuration = [];
      final List<int> totalFocusTime = []; // Work time only

      DateTime currentStart = DateTime(startDate.year, startDate.month, 1);

      while (!currentStart.isAfter(endDate)) {
        final DateTime nextMonth =
            DateTime(currentStart.year, currentStart.month + 1, 1);
        final DateTime currentEnd = nextMonth.subtract(const Duration(days: 1));
        final DateTime adjustedEnd =
            currentEnd.isAfter(endDate) ? endDate : currentEnd;

        // Get complete sessions for this period
        final int completeSessionCount = getCompletePomodoroSessionCount(
          startDate: currentStart,
          endDate: adjustedEnd,
        );

        // Get work phase count
        final int workPhaseCount = getWorkPhaseCount(
          startDate: currentStart,
          endDate: adjustedEnd,
        );

        // Get time distribution for work time
        final timeDistribution = getTimeDistribution(
          startDate: currentStart,
          endDate: adjustedEnd,
        );

        final Duration workTime =
            timeDistribution['workTime'] as Duration? ?? Duration.zero;
        final double avg = completeSessionCount > 0
            ? workTime.inMinutes / completeSessionCount
            : 0;

        periods.add(DateFormat('MMM yyyy').format(currentStart));
        sessionCounts.add(completeSessionCount);
        workPhaseCounts.add(workPhaseCount);
        avgDuration.add(avg);
        totalFocusTime.add(workTime.inMinutes);

        currentStart = nextMonth;
      }

      // Calculate percentage change
      double percentageChange = 0.0;
      if (totalFocusTime.length >= 2 &&
          totalFocusTime[totalFocusTime.length - 2] > 0) {
        final int current = totalFocusTime.last;
        final int previous = totalFocusTime[totalFocusTime.length - 2];
        percentageChange = (current - previous) / previous * 100;
      }

      return {
        'periods': periods,
        'sessionCounts': sessionCounts, // Complete Pomodoro sessions
        'workPhaseCounts': workPhaseCounts, // Individual work phases
        'avgDuration': avgDuration,
        'totalFocusTime': totalFocusTime,
        'percentageChange': percentageChange,
      };
    } catch (e) {
      debugPrint("Error getting focus trends: $e");
      return _emptyTrends();
    }
  }

  Map<String, dynamic> _emptyTrends() {
    return {
      'periods': <String>[],
      'sessionCounts': <int>[],
      'workPhaseCounts': <int>[],
      'avgDuration': <double>[],
      'totalFocusTime': <int>[],
      'percentageChange': 0.0,
    };
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HELPER METHODS
  // ═══════════════════════════════════════════════════════════════════════════

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  String _formatDuration(Duration duration) {
    final int hours = duration.inHours;
    final int minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '$hours hr ${minutes > 0 ? '$minutes min' : ''}';
    } else {
      return '$minutes min';
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CREATE/DELETE SESSIONS
  // ═══════════════════════════════════════════════════════════════════════════

  Future<bool> createFocusSession({
    required DateTime startTime,
    required Duration duration,
    required List<String> appsBlocked,
  }) async {
    if (!_dataStore.isInitialized) return false;

    try {
      final DateTime date =
          DateTime(startTime.year, startTime.month, startTime.day);

      final FocusSessionRecord session = FocusSessionRecord(
        date: date,
        startTime: startTime,
        duration: duration,
        appsBlocked: appsBlocked,
        completed: true,
        breakCount: 0,
        totalBreakTime: Duration.zero,
      );

      return await _dataStore.recordFocusSession(session);
    } catch (e) {
      debugPrint("Error creating focus session: $e");
      return false;
    }
  }

  Future<bool> deleteFocusSession(String sessionKey) async {
    if (!_dataStore.isInitialized) return false;

    try {
      return await _dataStore.deleteFocusSession(sessionKey);
    } catch (e) {
      debugPrint("Error deleting focus session: $e");
      return false;
    }
  }
}
