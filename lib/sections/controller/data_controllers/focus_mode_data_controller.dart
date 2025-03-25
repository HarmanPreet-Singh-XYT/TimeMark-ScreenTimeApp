import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../app_data_controller.dart';

// Assuming these are defined in your existing codebase
// import 'app_data_store.dart';
// import 'models/focus_session_record.dart';

class FocusAnalyticsService {
  final AppDataStore _dataStore;
  
  // Singleton pattern
  static final FocusAnalyticsService _instance = FocusAnalyticsService._internal();
  
  factory FocusAnalyticsService() {
    return _instance;
  }
  
  FocusAnalyticsService._internal() : _dataStore = AppDataStore();
  
  // Get session counts by day for a specific period
  Map<String, int> getSessionCountByDay({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    if (!_dataStore.isInitialized) return {};
    
    try {
      final Map<String, int> result = {};
      
      // Get all sessions in the range
      final List<FocusSessionRecord> sessions = _dataStore.getFocusSessionsRange(startDate, endDate);
      
      // Initialize result with all days in the range
      DateTime current = DateTime(startDate.year, startDate.month, startDate.day);
      final DateTime end = DateTime(endDate.year, endDate.month, endDate.day);
      
      while (!current.isAfter(end)) {
        final String dateKey = _formatDate(current);
        result[dateKey] = 0;
        current = current.add(const Duration(days: 1));
      }
      
      // Count sessions by day
      for (final session in sessions) {
        if (session.completed) {
          final String dateKey = _formatDate(session.date);
          result[dateKey] = (result[dateKey] ?? 0) + 1;
        }
      }
      
      return result;
    } catch (e) {
      debugPrint("Error getting session count by day: $e");
      return {};
    }
  }
  
  // Get detailed session history for a specific period
  List<Map<String, dynamic>> getSessionHistory({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    if (!_dataStore.isInitialized) return [];
    
    try {
      final List<Map<String, dynamic>> result = [];
      final List<FocusSessionRecord> sessions = _dataStore.getFocusSessionsRange(startDate, endDate);
      
      for (final session in sessions) {
        if (session.completed) {
          // Calculate total duration including breaks
          final Duration totalDuration = session.duration + session.totalBreakTime;
          
          // Format time
          final String startTimeStr = DateFormat('yyyy-MM-dd HH:mm').format(session.startTime);
          final String durationStr = _formatDuration(totalDuration);
          
          // Calculate work time percentage
          final double workTimePercentage = session.duration.inSeconds / totalDuration.inSeconds * 100;
          
          result.add({
            'date': startTimeStr,
            'duration': durationStr,
            'totalMinutes': totalDuration.inMinutes,
            'workMinutes': session.duration.inMinutes,
            'breakMinutes': session.totalBreakTime.inMinutes,
            'breakCount': session.breakCount,
            'workTimePercentage': workTimePercentage.toStringAsFixed(1),
            'appsBlocked': session.appsBlocked,
            'rawSession': session, // Include the raw session for direct access if needed
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
  
  // Get time distribution between work and breaks for a specific period
  Map<String, dynamic> getTimeDistribution({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    if (!_dataStore.isInitialized) {
      return {
        'workTime': Duration.zero,
        'shortBreakTime': Duration.zero,
        'longBreakTime': Duration.zero,
        'workPercentage': 0.0,
        'shortBreakPercentage': 0.0,
        'longBreakPercentage': 0.0,
      };
    }
    
    try {
      final List<FocusSessionRecord> sessions = _dataStore.getFocusSessionsRange(startDate, endDate)
          .where((session) => session.completed)
          .toList();
      
      if (sessions.isEmpty) {
        return {
          'workTime': Duration.zero,
          'shortBreakTime': Duration.zero,
          'longBreakTime': Duration.zero,
          'workPercentage': 0.0,
          'shortBreakPercentage': 0.0,
          'longBreakPercentage': 0.0,
        };
      }
      
      // Calculate total work time
      final Duration workTime = sessions.fold(
          Duration.zero, (sum, session) => sum + session.duration);
      
      // For this example, we'll assume breaks less than 5 minutes are short breaks
      // and breaks 5 minutes or longer are long breaks
      Duration shortBreakTime = Duration.zero;
      Duration longBreakTime = Duration.zero;
      
      for (final session in sessions) {
        // This is an estimation since we don't have break durations individually
        // You may need to adjust this logic based on your actual data structure
        final Duration avgBreakTime = session.breakCount > 0
            ? session.totalBreakTime ~/ session.breakCount
            : Duration.zero;
        
        if (avgBreakTime.inMinutes < 5) {
          shortBreakTime += session.totalBreakTime;
        } else {
          longBreakTime += session.totalBreakTime;
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
      return {
        'workTime': Duration.zero,
        'shortBreakTime': Duration.zero,
        'longBreakTime': Duration.zero,
        'workPercentage': 0.0,
        'shortBreakPercentage': 0.0,
        'longBreakPercentage': 0.0,
      };
    }
  }
  
  // Get focus session trends over specified periods
  Map<String, dynamic> getFocusTrends({
    int months = 3, // Default to last 3 months
    bool useLifetimeIfLess = true, // Use all available data if less than months
  }) {
    if (!_dataStore.isInitialized) {
      return {
        'periods': <String>[],
        'sessionCounts': <int>[],
        'avgDuration': <double>[],
        'totalFocusTime': <int>[],
        'percentageChange': 0.0,
      };
    }
    
    try {
      // Determine start date based on available data
      final DateTime now = DateTime.now();
      final DateTime endDate = DateTime(now.year, now.month, now.day);
      
      // For demonstration, we'll just go back to the first day of months ago
      // In a real app, you might want to query your data store to find the earliest record
      DateTime startDate = DateTime(now.year, now.month - months, 1);
      
      if (useLifetimeIfLess) {
        // In a real implementation, you would query for the earliest record date
        // For demonstration, we'll just use a fixed date if it's recent
        final DateTime earliestPossible = DateTime(now.year - 1, now.month, 1);
        if (earliestPossible.isAfter(startDate)) {
          startDate = earliestPossible;
        }
      }
      
      final List<String> periods = [];
      final List<int> sessionCounts = [];
      final List<double> avgDuration = [];
      final List<int> totalFocusTime = [];
      
      // Calculate data for each month
      DateTime currentStart = DateTime(startDate.year, startDate.month, 1);
      
      while (!currentStart.isAfter(endDate)) {
        // Calculate end of the month
        final DateTime nextMonth = DateTime(currentStart.year, currentStart.month + 1, 1);
        final DateTime currentEnd = nextMonth.subtract(const Duration(days: 1));
        
        // Ensure we don't go beyond today
        final DateTime adjustedEnd = currentEnd.isAfter(endDate) ? endDate : currentEnd;
        
        // Get sessions for this period
        final List<FocusSessionRecord> periodSessions = _dataStore
            .getFocusSessionsRange(currentStart, adjustedEnd)
            .where((session) => session.completed)
            .toList();
        
        // Calculate metrics
        final int count = periodSessions.length;
        final Duration total = periodSessions.fold(
            Duration.zero, (sum, session) => sum + session.duration);
        final double avg = count > 0 ? total.inMinutes / count : 0;
        
        // Add to result lists
        periods.add(DateFormat('MMM yyyy').format(currentStart));
        sessionCounts.add(count);
        avgDuration.add(avg);
        totalFocusTime.add(total.inMinutes);
        
        // Move to next month
        currentStart = nextMonth;
      }
      
      // Calculate percentage change (comparing last two periods)
      double percentageChange = 0.0;
      if (totalFocusTime.length >= 2 && totalFocusTime[totalFocusTime.length - 2] > 0) {
        final int current = totalFocusTime.last;
        final int previous = totalFocusTime[totalFocusTime.length - 2];
        percentageChange = (current - previous) / previous * 100;
      }
      
      return {
        'periods': periods,
        'sessionCounts': sessionCounts,
        'avgDuration': avgDuration,
        'totalFocusTime': totalFocusTime,
        'percentageChange': percentageChange,
      };
    } catch (e) {
      debugPrint("Error getting focus trends: $e");
      return {
        'periods': <String>[],
        'sessionCounts': <int>[],
        'avgDuration': <double>[],
        'totalFocusTime': <int>[],
        'percentageChange': 0.0,
      };
    }
  }
  
  // Get weekly summary for the current or specified week
  Map<String, dynamic> getWeeklySummary({DateTime? targetDate}) {
    final DateTime now = targetDate ?? DateTime.now();
    
    // Find start of week (Monday) and end of week (Sunday)
    final int weekday = now.weekday;
    final DateTime startOfWeek = now.subtract(Duration(days: weekday - 1));
    final DateTime endOfWeek = startOfWeek.add(const Duration(days: 6));
    
    // Get session count by day
    final Map<String, int> sessionsByDay = getSessionCountByDay(
      startDate: startOfWeek,
      endDate: endOfWeek,
    );
    
    // Get time distribution
    final Map<String, dynamic> timeDistribution = getTimeDistribution(
      startDate: startOfWeek,
      endDate: endOfWeek,
    );
    
    // Get detailed sessions
    final List<Map<String, dynamic>> sessions = getSessionHistory(
      startDate: startOfWeek,
      endDate: endOfWeek,
    );
    
    // Calculate total sessions for the week
    final int totalSessions = sessionsByDay.values.fold(0, (sum, count) => sum + count);
    
    // Calculate average daily sessions
    final double avgDailySessions = totalSessions / 7;
    
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
    
    return {
      'weekStart': startOfWeek,
      'weekEnd': endOfWeek,
      'totalSessions': totalSessions,
      'avgDailySessions': avgDailySessions,
      'mostProductiveDay': mostProductiveDay,
      'sessionsByDay': sessionsByDay,
      'timeDistribution': timeDistribution,
      'sessions': sessions,
    };
  }
  
  // Helper methods
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
  
  // Create a new focus session
  Future<bool> createFocusSession({
    required DateTime startTime,
    required Duration duration,
    required List<String> appsBlocked,
  }) async {
    if (!_dataStore.isInitialized) return false;
    
    try {
      final DateTime date = DateTime(startTime.year, startTime.month, startTime.day);
      
      final FocusSessionRecord session = FocusSessionRecord(
        date: date,
        startTime: startTime,
        duration: duration,
        appsBlocked: appsBlocked,
        completed: true, // Will be marked as completed when the session ends
        breakCount: 0,
        totalBreakTime: Duration.zero,
      );
      
      return await _dataStore.recordFocusSession(session);
    } catch (e) {
      debugPrint("Error creating focus session: $e");
      return false;
    }
  }
  
  // Update an existing focus session (e.g., when it's completed)
  Future<bool> updateFocusSession({
    required String sessionKey,
    required bool completed,
    required int breakCount,
    required Duration totalBreakTime,
  }) async {
    if (!_dataStore.isInitialized) return false;
    
    try {
      // In a real implementation, you would need a way to get the existing session
      // The AppDataStore doesn't currently have a method to get a session by key
      // You might need to extend it to add this functionality
      
      // For demonstration, we'll create a mock implementation
      // Fetch the session from storage, update it, and save it back
      
      // 1. Get the session (mock)
      // In reality, you'd need to implement a method like:
      // final FocusSessionRecord? existingSession = _dataStore.getFocusSessionByKey(sessionKey);
      
      // 2. Update the session and save it (mock)
      // This is just a placeholder - you'd need to implement this in AppDataStore
      debugPrint("Mock implementation: updating session $sessionKey");
      debugPrint("completed: $completed, breakCount: $breakCount, breakTime: $totalBreakTime");
      
      // For now, return false to indicate this isn't implemented yet
      return false;
      
      // In a real implementation, you'd do something like:
      /*
      if (existingSession != null) {
        final FocusSessionRecord updatedSession = FocusSessionRecord(
          date: existingSession.date,
          startTime: existingSession.startTime,
          duration: existingSession.duration,
          appsBlocked: existingSession.appsBlocked,
          completed: completed,
          breakCount: breakCount,
          totalBreakTime: totalBreakTime,
        );
        
        // Delete the old session and add the updated one
        await _dataStore.deleteFocusSession(sessionKey);
        return await _dataStore.recordFocusSession(updatedSession);
      }
      return false;
      */
    } catch (e) {
      debugPrint("Error updating focus session: $e");
      return false;
    }
  }
  
  // Delete a focus session
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