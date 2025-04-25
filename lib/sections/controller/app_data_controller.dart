import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:async';
import 'package:synchronized/synchronized.dart'; 
// TypeAdapters for complex types
@HiveType(typeId: 1)
class AppUsageRecord {
  @HiveField(0)
  final DateTime date;
  
  @HiveField(1)
  final Duration timeSpent;
  
  @HiveField(2)
  final int openCount;
  
  @HiveField(3)
  final List<TimeRange> usagePeriods;

  AppUsageRecord({
    required this.date,
    required this.timeSpent,
    required this.openCount,
    required this.usagePeriods,
  });
}

@HiveType(typeId: 2)
class TimeRange {
  @HiveField(0)
  final DateTime startTime;
  
  @HiveField(1)
  final DateTime endTime;

  TimeRange({
    required this.startTime,
    required this.endTime,
  });
  
  Duration get duration => endTime.difference(startTime);
}

@HiveType(typeId: 3)
class FocusSessionRecord {
  @HiveField(0)
  final DateTime date;
  
  @HiveField(1)
  final DateTime startTime;
  
  @HiveField(2)
  final Duration duration;
  
  @HiveField(3)
  final List<String> appsBlocked;
  
  @HiveField(4)
  final bool completed;
  
  @HiveField(5)
  final int breakCount;
  
  @HiveField(6)
  final Duration totalBreakTime;

  FocusSessionRecord({
    required this.date,
    required this.startTime,
    required this.duration,
    required this.appsBlocked,
    required this.completed,
    required this.breakCount,
    required this.totalBreakTime,
  });
  
  Duration get focusTime => duration - totalBreakTime;
}

@HiveType(typeId: 4)
class AppMetadata {
  @HiveField(0)
  final String category;
  
  @HiveField(1)
  final bool isProductive;
  
  @HiveField(2)
  final bool isTracking;
  
  @HiveField(3)
  final bool isVisible;
  
  @HiveField(4)
  final Duration dailyLimit;

  @HiveField(5)
  final bool limitStatus;

  AppMetadata({
    required this.category,
    required this.isProductive,
    this.isTracking = true,
    this.isVisible = true,
    this.dailyLimit = Duration.zero,
    this.limitStatus = false,
  });
}

class AppDataStore extends ChangeNotifier {
  static final AppDataStore _instance = AppDataStore._internal();
  static const String _usageBoxName = 'harman_screentime_app_usage_box';
  static const String _focusBoxName = 'harman_screentime_focus_session_box';
  static const String _metadataBoxName = 'harman_screentime_app_metadata_box';
  
  Box<AppUsageRecord>? _usageBox;
  Box<FocusSessionRecord>? _focusBox;
  Box<AppMetadata>? _metadataBox;
  
  bool _isInitialized = false;
  String? _lastError;
  DateTime? _lastMaintenanceDate;

  // Add locks for box operations
  final Lock _initLock = Lock();
  final Lock _usageBoxLock = Lock();
  final Lock _focusBoxLock = Lock();
  final Lock _metadataBoxLock = Lock();

  // Factory constructor to return the singleton instance
  factory AppDataStore() {
    return _instance;
  }

  // Private constructor
  AppDataStore._internal();

  bool get isInitialized => _isInitialized;
  String? get lastError => _lastError;

  // Initialize Hive with proper error handling
  Future<bool> init() async {
    return await _initLock.synchronized(() async {
      if (_isInitialized) return true;
      
      try {
        // Initialize Hive
        await Hive.initFlutter();
        
        // Register adapters
        if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(AppUsageRecordAdapter());
        if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(TimeRangeAdapter());
        if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(FocusSessionRecordAdapter());
        if (!Hive.isAdapterRegistered(4)) Hive.registerAdapter(AppMetadataAdapter());
        if (!Hive.isAdapterRegistered(5)) Hive.registerAdapter(DurationAdapter());
        
        // Open boxes with retry logic
        _usageBox = await _openBoxWithRetry<AppUsageRecord>(_usageBoxName);
        _focusBox = await _openBoxWithRetry<FocusSessionRecord>(_focusBoxName);
        _metadataBox = await _openBoxWithRetry<AppMetadata>(_metadataBoxName);
        
        if (_usageBox == null || _focusBox == null || _metadataBox == null) {
          _lastError = "Failed to open one or more Hive boxes after multiple attempts";
          return false;
        }
        
        _isInitialized = true;
        
        // Schedule periodic maintenance
        _schedulePeriodicMaintenance();
        
        notifyListeners();
        return true;
      } catch (e) {
        _lastError = "Error initializing AppDataStore: $e";
        debugPrint(_lastError);
        return false;
      }
    });
  }

  // Helper method to open a box with retry logic
  Future<Box<T>?> _openBoxWithRetry<T>(String boxName, {int maxRetries = 3}) async {
    int attempts = 0;
    
    while (attempts < maxRetries) {
      try {
        // Add additional parameters for better robustness
        return await Hive.openBox<T>(
          boxName,
          compactionStrategy: (entries, deletedEntries) {
            // Compact when deletions exceed 15% of total entries
            return deletedEntries > 15 && deletedEntries / entries > 0.15;
          },
        );
      } catch (e) {
        attempts++;
        
        debugPrint("Box opening attempt $attempts failed: $e");
        
        if (attempts >= maxRetries) {
          _lastError = "Failed to open box $boxName after $maxRetries attempts: $e";
          debugPrint(_lastError);
          return null;
        }
        
        // Check if box is corrupted or lock file is missing
        if (e.toString().contains('corrupted') || 
            e.toString().contains('not found') || 
            e.toString().contains('lock') ||
            e.toString().contains('permission')) {
          try {
            debugPrint("Attempting to delete and recreate box: $boxName");
            
            // Force close any open instances
            try {
              final box = await Hive.box(boxName);
              if (box.isOpen) await box.close();
            } catch (_) {
              // Ignore errors during force close
            }
            
            // Delete the box completely from disk
            await Hive.deleteBoxFromDisk(boxName);
            debugPrint("Deleted corrupted box: $boxName, retrying...");
          } catch (deleteError) {
            debugPrint("Error deleting box: $deleteError");
          }
        }
        
        // Exponential backoff before retry
        await Future.delayed(Duration(milliseconds: 200 * (1 << attempts)));
      }
    }
    
    return null;
  }

  // New method to periodically check and repair boxes
  Future<void> checkAndRepairBoxes() async {
    debugPrint("Running database maintenance check...");
    
    await _initLock.synchronized(() async {
      for (final boxInfo in [
        {'name': _usageBoxName, 'box': _usageBox, 'lock': _usageBoxLock},
        {'name': _focusBoxName, 'box': _focusBox, 'lock': _focusBoxLock},
        {'name': _metadataBoxName, 'box': _metadataBox, 'lock': _metadataBoxLock},
      ]) {
        final String boxName = boxInfo['name'] as String;
        final Box? box = boxInfo['box'] as Box?;
        final Lock lock = boxInfo['lock'] as Lock;
        
        await lock.synchronized(() async {
          try {
            // Check if box is open and valid
            if (box != null && box.isOpen) {
              try {
                // Test read operation to verify box integrity
                box.keys.take(1).toList();
                debugPrint("Box $boxName is healthy");
              } catch (e) {
                debugPrint("Box $boxName is corrupted, repairing: $e");
                
                // Close and reopen
                try {
                  await box.close();
                } catch (_) {
                  // Ignore close errors
                }
                
                try {
                  await Hive.deleteBoxFromDisk(boxName);
                } catch (deleteError) {
                  debugPrint("Error deleting box: $deleteError");
                }
                
                // Reopen using type-specific locks
                if (boxName == _usageBoxName) {
                  _usageBox = await _openBoxWithRetry<AppUsageRecord>(boxName);
                } else if (boxName == _focusBoxName) {
                  _focusBox = await _openBoxWithRetry<FocusSessionRecord>(boxName);
                } else if (boxName == _metadataBoxName) {
                  _metadataBox = await _openBoxWithRetry<AppMetadata>(boxName);
                }
              }
            } else {
              debugPrint("Box $boxName is not open, attempting to open");
              // Reopen using type-specific locks
              if (boxName == _usageBoxName) {
                _usageBox = await _openBoxWithRetry<AppUsageRecord>(boxName);
              } else if (boxName == _focusBoxName) {
                _focusBox = await _openBoxWithRetry<FocusSessionRecord>(boxName);
              } else if (boxName == _metadataBoxName) {
                _metadataBox = await _openBoxWithRetry<AppMetadata>(boxName);
              }
            }
          } catch (e) {
            debugPrint("Error checking box $boxName: $e");
          }
        });
      }
      
      _lastMaintenanceDate = DateTime.now();
    });
  }

  // Schedule daily maintenance
  void _schedulePeriodicMaintenance() {
    // Check if maintenance is needed (daily)
    final now = DateTime.now();
    if (_lastMaintenanceDate == null || 
        now.difference(_lastMaintenanceDate!).inHours > 24) {
      checkAndRepairBoxes();
    }
  }

  // Generic method to perform operations with a box safely
  Future<T> _withBox<T, B>(
    B? box, 
    Lock lock,
    Future<T> Function(B box) operation, 
    T defaultValue
  ) async {
    if (!(await _ensureInitialized()) || box == null) return defaultValue;
    
    return await lock.synchronized(() async {
      try {
        return await operation(box);
      } catch (e) {
        _lastError = "Error performing box operation: $e";
        debugPrint(_lastError);
        return defaultValue;
      }
    });
  }

  // Ensure boxes are initialized
  bool _ensureInitialized() {
    if (!_isInitialized || _usageBox == null || _focusBox == null || _metadataBox == null) {
      _lastError = "AppDataStore not initialized. Call init() first.";
      debugPrint(_lastError);
      return false;
    }
    return true;
  }

  // METADATA OPERATIONS
  
  // Get all app names with error handling
  List<String> get allAppNames {
    if (!_ensureInitialized() || _metadataBox == null) return [];
    
    try {
      return _metadataBox!.keys.cast<String>().toList();
    } catch (e) {
      _lastError = "Error getting app names: $e";
      debugPrint(_lastError);
      return [];
    }
  }
  
  // Add or update app metadata with error handling
  Future<bool> updateAppMetadata(String appName, {
    String? category,
    bool? isProductive,
    bool? isTracking,
    bool? isVisible,
    Duration? dailyLimit,
    bool? limitStatus,
  }) async {
    if (!_ensureInitialized() || _metadataBox == null) return false;
    
    try {
      AppMetadata? existing;
      
      try {
        existing = _metadataBox!.get(appName);
      } catch (e) {
        debugPrint("Error fetching existing metadata for $appName: $e");
        // Continue with null existing
      }
      String defaultCategory = appName.startsWith(':') ? 'Idle' : 'Uncategorized';
      final AppMetadata updated = AppMetadata(
        category: category ?? existing?.category ?? defaultCategory,
        isProductive: isProductive ?? existing?.isProductive ?? false,
        isTracking: isTracking ?? existing?.isTracking ?? true,
        isVisible: isVisible ?? existing?.isVisible ?? true,
        dailyLimit: dailyLimit ?? existing?.dailyLimit ?? Duration.zero,
        limitStatus: limitStatus ?? existing?.limitStatus ?? false,
      );
      
      await _metadataBox!.put(appName, updated);
      notifyListeners();
      return true;
    } catch (e) {
      _lastError = "Error updating app metadata for $appName: $e";
      debugPrint(_lastError);
      return false;
    }
  }
  
  // Get app metadata with error handling
  AppMetadata? getAppMetadata(String appName) {
    if (!_ensureInitialized() || _metadataBox == null) return null;
    
    try {
      return _metadataBox!.get(appName);
    } catch (e) {
      _lastError = "Error getting metadata for $appName: $e";
      debugPrint(_lastError);
      return null;
    }
  }
  
  // Delete app metadata with error handling
  Future<bool> deleteAppMetadata(String appName) async {
    if (!_ensureInitialized() || _metadataBox == null) return false;
    
    try {
      if (_metadataBox!.containsKey(appName)) {
        await _metadataBox!.delete(appName);
        notifyListeners();
        return true;
      } else {
        return false; // Nothing to delete
      }
    } catch (e) {
      _lastError = "Error deleting metadata for $appName: $e";
      debugPrint(_lastError);
      return false;
    }
  }

  // APP USAGE OPERATIONS
  
  // Record app usage with error handling
  Future<bool> recordAppUsage(String appName, DateTime date, Duration timeSpent, int openCount, List<TimeRange> usagePeriods) async {
    return await _withBox<bool, Box<AppUsageRecord>>(
      _usageBox, 
      _usageBoxLock,
      (box) async {
        final String key = '$appName:${_formatDateKey(date)}';
        AppUsageRecord? existing;
        
        try {
          existing = box.get(key);
        } catch (e) {
          debugPrint("Error fetching existing usage record for $key: $e");
        }
        
        if (existing != null) {
          final List<TimeRange> optimizedUsagePeriods = _optimizeUsagePeriods(
            [...existing.usagePeriods, ...usagePeriods]
          );
          
          final AppUsageRecord updated = AppUsageRecord(
            date: date,
            timeSpent: existing.timeSpent + timeSpent,
            openCount: existing.openCount + openCount,
            usagePeriods: optimizedUsagePeriods,
          );
          
          await box.put(key, updated);
        } else {
          final AppUsageRecord record = AppUsageRecord(
            date: date,
            timeSpent: timeSpent,
            openCount: openCount,
            usagePeriods: usagePeriods,
          );
          
          await box.put(key, record);
        }
        
        notifyListeners();
        return true;
      },
      false
    );
  }

  // Helper method to optimize usage periods
  List<TimeRange> _optimizeUsagePeriods(List<TimeRange> periods) {
    if (periods.length <= 10) return periods;
    
    // Sort periods by start time
    periods.sort((a, b) => a.startTime.compareTo(b.startTime));
    
    // Group and merge very close periods (within 5 seconds)
    List<TimeRange> optimizedPeriods = [];
    TimeRange current = periods.first;
    
    for (int i = 1; i < periods.length; i++) {
      TimeRange next = periods[i];
      
      // If periods are very close, merge them
      if (next.startTime.difference(current.endTime).inSeconds <= 5) {
        current = TimeRange(
          startTime: current.startTime,
          endTime: next.endTime
        );
      } else {
        // Add current period and move to next
        optimizedPeriods.add(current);
        current = next;
      }
    }
    
    // Add the last period
    optimizedPeriods.add(current);
    
    // If still too many periods, keep only the most recent ones
    if (optimizedPeriods.length > 10) {
      return optimizedPeriods.sublist(optimizedPeriods.length - 10);
    }
    
    return optimizedPeriods;
  }
  
  // Get app usage for a specific day with error handling
  AppUsageRecord? getAppUsage(String appName, DateTime date) {
    if (!_ensureInitialized() || _usageBox == null) return null;
    
    try {
      final String key = '$appName:${_formatDateKey(date)}';
      return _usageBox!.get(key);
    } catch (e) {
      _lastError = "Error getting app usage for $appName on ${_formatDateKey(date)}: $e";
      debugPrint(_lastError);
      return null;
    }
  }
  
  // Get app usage for a date range with error handling
  List<AppUsageRecord> getAppUsageRange(String appName, DateTime startDate, DateTime endDate) {
    if (!_ensureInitialized() || _usageBox == null) return [];
    
    try {
      final List<AppUsageRecord> result = [];
      DateTime currentDate = DateTime(startDate.year, startDate.month, startDate.day);
      final DateTime endOfRange = DateTime(endDate.year, endDate.month, endDate.day);
      
      while (currentDate.isBefore(endOfRange) || currentDate.day == endOfRange.day) {
        final AppUsageRecord? record = getAppUsage(appName, currentDate);
        if (record != null) {
          result.add(record);
        }
        // Properly add one day to currentDate
        currentDate = currentDate.add(const Duration(days: 1));
      }
      
      return result;
    } catch (e) {
      _lastError = "Error getting app usage range for $appName: $e";
      debugPrint(_lastError);
      return [];
    }
  }
  
  // FOCUS SESSION OPERATIONS
  
  // Record focus session with error handling
  Future<bool> recordFocusSession(FocusSessionRecord session) async {
    if (!_ensureInitialized() || _focusBox == null) return false;
    
    try {
      final String key = '${_formatDateKey(session.date)}:${session.startTime.millisecondsSinceEpoch}';
      await _focusBox!.put(key, session);
      notifyListeners();
      return true;
    } catch (e) {
      _lastError = "Error recording focus session: $e";
      debugPrint(_lastError);
      return false;
    }
  }
  
  // Get focus sessions for a specific day with error handling
  List<FocusSessionRecord> getFocusSessions(DateTime date) {
    if (!_ensureInitialized() || _focusBox == null) return [];
    
    try {
      final String dateKey = _formatDateKey(date);
      final List<FocusSessionRecord> result = [];
      
      for (final key in _focusBox!.keys) {
        if (key.toString().startsWith(dateKey)) {
          try {
            final FocusSessionRecord? session = _focusBox!.get(key);
            if (session != null) {
              result.add(session);
            }
          } catch (e) {
            debugPrint("Error getting focus session for key $key: $e");
            // Continue with the next key
          }
        }
      }
      
      return result;
    } catch (e) {
      _lastError = "Error getting focus sessions for ${_formatDateKey(date)}: $e";
      debugPrint(_lastError);
      return [];
    }
  }
  
  // Get focus sessions for a date range with error handling
  List<FocusSessionRecord> getFocusSessionsRange(DateTime startDate, DateTime endDate) {
    if (!_ensureInitialized() || _focusBox == null) return [];
    
    try {
      final List<FocusSessionRecord> result = [];
      DateTime currentDate = DateTime(startDate.year, startDate.month, startDate.day);
      final DateTime endOfRange = DateTime(endDate.year, endDate.month, endDate.day);
      
      while (currentDate.isBefore(endOfRange) || currentDate.day == endOfRange.day) {
        result.addAll(getFocusSessions(currentDate));
        // Properly add one day to currentDate
        currentDate = currentDate.add(const Duration(days: 1));
      }
      
      return result;
    } catch (e) {
      _lastError = "Error getting focus sessions range: $e";
      debugPrint(_lastError);
      return [];
    }
  }
  
  // Delete focus session with error handling
  Future<bool> deleteFocusSession(String key) async {
    if (!_ensureInitialized() || _focusBox == null) return false;
    
    try {
      if (_focusBox!.containsKey(key)) {
        await _focusBox!.delete(key);
        notifyListeners();
        return true;
      } else {
        return false; // Nothing to delete
      }
    } catch (e) {
      _lastError = "Error deleting focus session for key $key: $e";
      debugPrint(_lastError);
      return false;
    }
  }
  
  // ANALYTICS & DERIVED DATA
  
  // Get total screen time for a specific day with error handling
  Duration getTotalScreenTime(DateTime date) {
    if (!_ensureInitialized()) return Duration.zero;
    
    try {
      Duration total = Duration.zero;
      
      for (final appName in allAppNames) {
        final AppUsageRecord? record = getAppUsage(appName, date);
        if (record != null) {
          total += record.timeSpent;
        }
      }
      
      return total;
    } catch (e) {
      _lastError = "Error calculating total screen time for ${_formatDateKey(date)}: $e";
      debugPrint(_lastError);
      return Duration.zero;
    }
  }
  
  // Get productive time for a specific day with error handling
  Duration getProductiveTime(DateTime date) {
    if (!_ensureInitialized()) return Duration.zero;
    
    try {
      Duration total = Duration.zero;
      
      for (final appName in allAppNames) {
        final AppMetadata? metadata = getAppMetadata(appName);
        if (metadata != null && metadata.isProductive) {
          final AppUsageRecord? record = getAppUsage(appName, date);
          if (record != null) {
            total += record.timeSpent;
          }
        }
      }
      
      return total;
    } catch (e) {
      _lastError = "Error calculating productive time for ${_formatDateKey(date)}: $e";
      debugPrint(_lastError);
      return Duration.zero;
    }
  }
  
  // Get most used app for a specific day with error handling
  String getMostUsedApp(DateTime date) {
    if (!_ensureInitialized()) return "None";
    
    try {
      String mostUsed = "None";
      Duration maxTime = Duration.zero;
      
      for (final appName in allAppNames) {
        final AppUsageRecord? record = getAppUsage(appName, date);
        if (record != null && record.timeSpent > maxTime) {
          maxTime = record.timeSpent;
          mostUsed = appName;
        }
      }
      
      return mostUsed;
    } catch (e) {
      _lastError = "Error finding most used app for ${_formatDateKey(date)}: $e";
      debugPrint(_lastError);
      return "Error";
    }
  }
  
  // Get focus sessions count for a specific day with error handling
  int getFocusSessionsCount(DateTime date) {
    if (!_ensureInitialized()) return 0;
    
    try {
      return getFocusSessions(date).where((session) => session.completed).length;
    } catch (e) {
      _lastError = "Error counting focus sessions for ${_formatDateKey(date)}: $e";
      debugPrint(_lastError);
      return 0;
    }
  }
  
  // Get total focus time for a specific day with error handling
  Duration getTotalFocusTime(DateTime date) {
    if (!_ensureInitialized()) return Duration.zero;
    
    try {
      Duration total = Duration.zero;
      
      for (final session in getFocusSessions(date)) {
        if (session.completed) {
          total += session.focusTime;
        }
      }
      
      return total;
    } catch (e) {
      _lastError = "Error calculating total focus time for ${_formatDateKey(date)}: $e";
      debugPrint(_lastError);
      return Duration.zero;
    }
  }
  
  // Get category breakdown for a specific day with error handling
  Map<String, Duration> getCategoryBreakdown(DateTime date) {
    if (!_ensureInitialized()) return {};
    
    try {
      final Map<String, Duration> result = {};
      
      for (final appName in allAppNames) {
        final AppMetadata? metadata = getAppMetadata(appName);
        final AppUsageRecord? record = getAppUsage(appName, date);
        
        if (metadata != null && record != null) {
          final String category = metadata.category;
          result[category] = (result[category] ?? Duration.zero) + record.timeSpent;
        }
      }
      
      return result;
    } catch (e) {
      _lastError = "Error calculating category breakdown for ${_formatDateKey(date)}: $e";
      debugPrint(_lastError);
      return {};
    }
  }
  
  // Calculate productivity score (0-100) for a specific day with error handling
  double getProductivityScore(DateTime date) {
    if (!_ensureInitialized()) return 0.0;
    
    try {
      final Duration totalScreenTime = getTotalScreenTime(date);
      final Duration productiveTime = getProductiveTime(date);
      final int focusSessions = getFocusSessionsCount(date);
      
      if (totalScreenTime.inSeconds == 0) {
        return 0.0;
      }
      
      final double productiveRatio = productiveTime.inSeconds / totalScreenTime.inSeconds;
      final double sessionBonus = focusSessions * 0.5; // Each completed session adds 0.5 points
      
      // Calculate score from 0-100
      final double rawScore = (productiveRatio * 80) + sessionBonus;
      return rawScore > 100 ? 100 : rawScore;
    } catch (e) {
      _lastError = "Error calculating productivity score for ${_formatDateKey(date)}: $e";
      debugPrint(_lastError);
      return 0.0;
    }
  }
  
  // Get average screen time for a date range with error handling
  Duration getAverageScreenTime(DateTime startDate, DateTime endDate) {
    if (!_ensureInitialized()) return Duration.zero;
    
    try {
      final List<Duration> dailyTotals = [];
      DateTime currentDate = DateTime(startDate.year, startDate.month, startDate.day);
      final DateTime endOfRange = DateTime(endDate.year, endDate.month, endDate.day);
      
      while (currentDate.isBefore(endOfRange) || currentDate.day == endOfRange.day) {
        dailyTotals.add(getTotalScreenTime(currentDate));
        // Properly add one day to currentDate
        currentDate = currentDate.add(const Duration(days: 1));
      }
      
      if (dailyTotals.isEmpty) return Duration.zero;
      
      final int totalMicroseconds = dailyTotals.fold(0, (sum, duration) => sum + duration.inMicroseconds);
      return Duration(microseconds: totalMicroseconds ~/ dailyTotals.length);
    } catch (e) {
      _lastError = "Error calculating average screen time: $e";
      debugPrint(_lastError);
      return Duration.zero;
    }
  }
  
  // Get focus trend (positive or negative percentage) with error handling
  double getFocusTrend(DateTime currentWeekStart, DateTime previousWeekStart) {
    if (!_ensureInitialized()) return 0.0;
    
    try {
      final DateTime currentWeekEnd = currentWeekStart.add(const Duration(days: 6));
      final DateTime previousWeekEnd = previousWeekStart.add(const Duration(days: 6));
      
      final Duration currentWeekFocus = getFocusSessionsRange(currentWeekStart, currentWeekEnd)
          .where((session) => session.completed)
          .fold(Duration.zero, (sum, session) => sum + session.focusTime);
      
      final Duration previousWeekFocus = getFocusSessionsRange(previousWeekStart, previousWeekEnd)
          .where((session) => session.completed)
          .fold(Duration.zero, (sum, session) => sum + session.focusTime);
      
      if (previousWeekFocus.inSeconds == 0) return 0.0;
      
      return (currentWeekFocus.inSeconds - previousWeekFocus.inSeconds) / previousWeekFocus.inSeconds * 100;
    } catch (e) {
      _lastError = "Error calculating focus trend: $e";
      debugPrint(_lastError);
      return 0.0;
    }
  }
  
  // Helper method to format date as a consistent string key
  String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
  
  /// Clear all data with improved performance and error handling
  Future<bool> clearAllData({Function(double)? progressCallback}) async {
    return await _initLock.synchronized(() async {
      if (!(await _ensureInitialized())) return false;

      try {
        if (progressCallback != null) progressCallback(0.1);
        
        // Close all boxes first
        if (_usageBox != null && _usageBox!.isOpen) await _usageBox!.close();
        if (_focusBox != null && _focusBox!.isOpen) await _focusBox!.close();
        if (_metadataBox != null && _metadataBox!.isOpen) await _metadataBox!.close();
        
        if (progressCallback != null) progressCallback(0.3);
        
        // Delete boxes from disk
        await Hive.deleteBoxFromDisk(_usageBoxName);
        if (progressCallback != null) progressCallback(0.5);
        
        await Hive.deleteBoxFromDisk(_focusBoxName);
        if (progressCallback != null) progressCallback(0.7);
        
        await Hive.deleteBoxFromDisk(_metadataBoxName);
        if (progressCallback != null) progressCallback(0.9);
        
        // Reinitialize boxes
        _usageBox = await _openBoxWithRetry<AppUsageRecord>(_usageBoxName);
        _focusBox = await _openBoxWithRetry<FocusSessionRecord>(_focusBoxName);
        _metadataBox = await _openBoxWithRetry<AppMetadata>(_metadataBoxName);
        
        if (progressCallback != null) progressCallback(1.0);
        
        notifyListeners();
        return true;
      } catch (e) {
        _lastError = "Error clearing data: $e";
        debugPrint(_lastError);
        return false;
      }
    });
  }

  Future<void> closeHive() async {
    return await _initLock.synchronized(() async {
      try {
        if (_usageBox != null && _usageBox!.isOpen) await _usageBox!.close();
        if (_focusBox != null && _focusBox!.isOpen) await _focusBox!.close();
        if (_metadataBox != null && _metadataBox!.isOpen) await _metadataBox!.close();
        
        await Hive.close();
        _isInitialized = false;
      } catch (e) {
        _lastError = "Error closing Hive: $e";
        debugPrint(_lastError);
      }
    });
  }
  // Close boxes when app terminates
  @override
  Future<void> dispose() async {
    await _initLock.synchronized(() async {
      try {
        if (_usageBox != null && _usageBox!.isOpen) await _usageBox!.close();
        if (_focusBox != null && _focusBox!.isOpen) await _focusBox!.close();
        if (_metadataBox != null && _metadataBox!.isOpen) await _metadataBox!.close();
        
        _isInitialized = false;
      } catch (e) {
        debugPrint("Error closing Hive boxes: $e");
      }
    });
    
    super.dispose();
  }
  // Helper method to implement app lifecycle events
  void handleAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || 
        state == AppLifecycleState.detached) {
      debugPrint("App going to background, ensuring data is flushed");
      _flushBoxes();
    } else if (state == AppLifecycleState.resumed) {
      debugPrint("App resumed, checking database health");
      checkAndRepairBoxes();
    }
  }
  
  // Flush boxes to ensure data is written to disk
  Future<void> _flushBoxes() async {
    await _initLock.synchronized(() async {
      try {
        if (_usageBox != null && _usageBox!.isOpen) await _usageBox!.flush();
        if (_focusBox != null && _focusBox!.isOpen) await _focusBox!.flush();
        if (_metadataBox != null && _metadataBox!.isOpen) await _metadataBox!.flush();
      } catch (e) {
        debugPrint("Error flushing Hive boxes: $e");
      }
    });
  }
}

// Hive type adapters
class DurationAdapter extends TypeAdapter<Duration> {
  @override
  final int typeId = 5;

  @override
  Duration read(BinaryReader reader) {
    return Duration(microseconds: reader.readInt());
  }

  @override
  void write(BinaryWriter writer, Duration obj) {
    writer.writeInt(obj.inMicroseconds);
  }
}

class AppUsageRecordAdapter extends TypeAdapter<AppUsageRecord> {
  @override
  final int typeId = 1;

  @override
  AppUsageRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      final key = reader.readByte();
      fields[key] = reader.read();
    }
    return AppUsageRecord(
      date: fields[0] as DateTime,
      timeSpent: fields[1] as Duration,
      openCount: fields[2] as int,
      usagePeriods: (fields[3] as List).cast<TimeRange>(),
    );
  }

  @override
  void write(BinaryWriter writer, AppUsageRecord obj) {
    writer.writeByte(4);
    writer.writeByte(0);
    writer.write(obj.date);
    writer.writeByte(1);
    writer.write(obj.timeSpent);
    writer.writeByte(2);
    writer.write(obj.openCount);
    writer.writeByte(3);
    writer.write(obj.usagePeriods);
  }
}

class TimeRangeAdapter extends TypeAdapter<TimeRange> {
  @override
  final int typeId = 2;

  @override
  TimeRange read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      final key = reader.readByte();
      fields[key] = reader.read();
    }
    return TimeRange(
      startTime: fields[0] as DateTime,
      endTime: fields[1] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, TimeRange obj) {
    writer.writeByte(2);
    writer.writeByte(0);
    writer.write(obj.startTime);
    writer.writeByte(1);
    writer.write(obj.endTime);
  }
}

class FocusSessionRecordAdapter extends TypeAdapter<FocusSessionRecord> {
  @override
  final int typeId = 3;

  @override
  FocusSessionRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      final key = reader.readByte();
      fields[key] = reader.read();
    }
    return FocusSessionRecord(
      date: fields[0] as DateTime,
      startTime: fields[1] as DateTime,
      duration: fields[2] as Duration,
      appsBlocked: (fields[3] as List).cast<String>(),
      completed: fields[4] as bool,
      breakCount: fields[5] as int,
      totalBreakTime: fields[6] as Duration,
    );
  }

  @override
  void write(BinaryWriter writer, FocusSessionRecord obj) {
    writer.writeByte(7);
    writer.writeByte(0);
    writer.write(obj.date);
    writer.writeByte(1);
    writer.write(obj.startTime);
    writer.writeByte(2);
    writer.write(obj.duration);
    writer.writeByte(3);
    writer.write(obj.appsBlocked);
    writer.writeByte(4);
    writer.write(obj.completed);
    writer.writeByte(5);
    writer.write(obj.breakCount);
    writer.writeByte(6);
    writer.write(obj.totalBreakTime);
  }
}

class AppMetadataAdapter extends TypeAdapter<AppMetadata> {
  @override
  final int typeId = 4;

  @override
  AppMetadata read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      final key = reader.readByte();
      fields[key] = reader.read();
    }
    return AppMetadata(
      category: fields[0] as String,
      isProductive: fields[1] as bool,
      isTracking: fields[2] as bool,
      isVisible: fields[3] as bool,
      dailyLimit: fields[4] as Duration,
      limitStatus: fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, AppMetadata obj) {
    writer.writeByte(6);
    writer.writeByte(0);
    writer.write(obj.category);
    writer.writeByte(1);
    writer.write(obj.isProductive);
    writer.writeByte(2);
    writer.write(obj.isTracking);
    writer.writeByte(3);
    writer.write(obj.isVisible);
    writer.writeByte(4);
    writer.write(obj.dailyLimit);
    writer.writeByte(5);
    writer.write(obj.limitStatus);
  }
}