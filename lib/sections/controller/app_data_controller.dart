import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
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

  // Helper method to merge two records
  AppUsageRecord merge(AppUsageRecord other) {
    return AppUsageRecord(
      date: date,
      timeSpent: timeSpent + other.timeSpent,
      openCount: openCount + other.openCount,
      usagePeriods: [...usagePeriods, ...other.usagePeriods],
    );
  }

  // Helper method to create a copy
  AppUsageRecord copyWith({
    DateTime? date,
    Duration? timeSpent,
    int? openCount,
    List<TimeRange>? usagePeriods,
  }) {
    return AppUsageRecord(
      date: date ?? this.date,
      timeSpent: timeSpent ?? this.timeSpent,
      openCount: openCount ?? this.openCount,
      usagePeriods: usagePeriods ?? this.usagePeriods,
    );
  }
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
  final Lock _runtimeCacheLock = Lock();

  // ============================================================
  // RUNTIME CACHE - The key addition for instant data access
  // ============================================================
  // This cache holds ALL data in memory and is updated immediately
  // Hive is only used for persistence (loading on startup, saving periodically)

  /// Runtime cache for app usage records: "appName:YYYY-MM-DD" -> AppUsageRecord
  final Map<String, AppUsageRecord> _usageRuntimeCache = {};

  /// Runtime cache for focus sessions: "YYYY-MM-DD:timestamp" -> FocusSessionRecord
  final Map<String, FocusSessionRecord> _focusRuntimeCache = {};

  /// Metadata cache (already existed, but now explicitly part of runtime cache)
  final Map<String, AppMetadata> _metadataCache = {};

  /// Track which usage records have been modified since last Hive commit
  final Set<String> _dirtyUsageKeys = {};

  /// Track which focus sessions have been modified since last Hive commit
  final Set<String> _dirtyFocusKeys = {};

  /// Timer for periodic Hive commits
  Timer? _persistenceTimer;

  /// How often to commit to Hive (default: 1 minute)
  final Duration _persistenceInterval = const Duration(minutes: 1);

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
        // Only use custom path for macOS
        if (Platform.isMacOS) {
          final directory = await getApplicationSupportDirectory();
          final hivePath = '${directory.path}/harman_screentime';

          final dir = Directory(hivePath);
          if (!await dir.exists()) {
            await dir.create(recursive: true);
          }

          Hive.init(hivePath);
        } else {
          // Default behavior for all other platforms
          await Hive.initFlutter();
        }

        // Register adapters
        if (!Hive.isAdapterRegistered(1))
          Hive.registerAdapter(AppUsageRecordAdapter());
        if (!Hive.isAdapterRegistered(2))
          Hive.registerAdapter(TimeRangeAdapter());
        if (!Hive.isAdapterRegistered(3))
          Hive.registerAdapter(FocusSessionRecordAdapter());
        if (!Hive.isAdapterRegistered(4))
          Hive.registerAdapter(AppMetadataAdapter());
        if (!Hive.isAdapterRegistered(5))
          Hive.registerAdapter(DurationAdapter());

        // Open boxes with retry logic
        _usageBox = await _openBoxWithRetry<AppUsageRecord>(_usageBoxName);
        _focusBox = await _openBoxWithRetry<FocusSessionRecord>(_focusBoxName);
        _metadataBox = await _openBoxWithRetry<AppMetadata>(_metadataBoxName);

        if (_usageBox == null || _focusBox == null || _metadataBox == null) {
          _lastError =
              "Failed to open one or more Hive boxes after multiple attempts";
          return false;
        }

        // ============================================================
        // LOAD RUNTIME CACHE FROM HIVE
        // ============================================================
        await _loadRuntimeCacheFromHive();

        _isInitialized = true;

        // Start periodic persistence timer
        _startPeriodicPersistence();

        _schedulePeriodicMaintenance();
        notifyListeners();

        debugPrint('═══════════════════════════════════════════════════════');
        debugPrint('✅ AppDataStore initialized with runtime cache');
        debugPrint('   Usage records in cache: ${_usageRuntimeCache.length}');
        debugPrint('   Focus sessions in cache: ${_focusRuntimeCache.length}');
        debugPrint('   Metadata in cache: ${_metadataCache.length}');
        debugPrint(
            '   Persistence interval: ${_persistenceInterval.inSeconds}s');
        debugPrint('═══════════════════════════════════════════════════════');

        return true;
      } catch (e) {
        _lastError = "Error initializing AppDataStore: $e";
        debugPrint(_lastError);
        return false;
      }
    });
  }

  // ============================================================
  // RUNTIME CACHE INITIALIZATION
  // ============================================================
  Future<void> _loadRuntimeCacheFromHive() async {
    debugPrint('📦 Loading runtime cache from Hive...');
    final stopwatch = Stopwatch()..start();

    try {
      // Load all usage records into runtime cache
      if (_usageBox != null) {
        for (var key in _usageBox!.keys) {
          final record = _usageBox!.get(key);
          if (record != null) {
            _usageRuntimeCache[key.toString()] = record;
          }
        }
        debugPrint('   ✓ Loaded ${_usageRuntimeCache.length} usage records');
      }

      // Load all focus sessions into runtime cache
      if (_focusBox != null) {
        for (var key in _focusBox!.keys) {
          final record = _focusBox!.get(key);
          if (record != null) {
            _focusRuntimeCache[key.toString()] = record;
          }
        }
        debugPrint('   ✓ Loaded ${_focusRuntimeCache.length} focus sessions');
      }

      // Load all metadata into runtime cache
      if (_metadataBox != null) {
        for (var key in _metadataBox!.keys) {
          final metadata = _metadataBox!.get(key);
          if (metadata != null) {
            _metadataCache[key.toString()] = metadata;
          }
        }
        debugPrint('   ✓ Loaded ${_metadataCache.length} metadata entries');
      }

      stopwatch.stop();
      debugPrint(
          '✅ Runtime cache loaded in ${stopwatch.elapsedMilliseconds}ms');
    } catch (e) {
      debugPrint('❌ Error loading runtime cache: $e');
    }
  }

  // ============================================================
  // PERIODIC PERSISTENCE TO HIVE
  // ============================================================
  void _startPeriodicPersistence() {
    _persistenceTimer?.cancel();
    _persistenceTimer = Timer.periodic(_persistenceInterval, (_) {
      _commitRuntimeCacheToHive();
    });
    debugPrint(
        '⏰ Periodic Hive persistence started (every ${_persistenceInterval.inSeconds}s)');
  }

  /// Commit only dirty (modified) records to Hive
  Future<void> _commitRuntimeCacheToHive() async {
    if (!_isInitialized) return;

    try {
      final stopwatch = Stopwatch()..start();
      int usageCommitted = 0;
      int focusCommitted = 0;

      await _runtimeCacheLock.synchronized(() async {
        // Commit dirty usage records
        if (_dirtyUsageKeys.isNotEmpty && _usageBox != null) {
          for (var key in _dirtyUsageKeys) {
            final record = _usageRuntimeCache[key];
            if (record != null) {
              await _usageBox!.put(key, record);
              usageCommitted++;
            }
          }
          _dirtyUsageKeys.clear();
        }

        // Commit dirty focus sessions
        if (_dirtyFocusKeys.isNotEmpty && _focusBox != null) {
          for (var key in _dirtyFocusKeys) {
            final record = _focusRuntimeCache[key];
            if (record != null) {
              await _focusBox!.put(key, record);
              focusCommitted++;
            }
          }
          _dirtyFocusKeys.clear();
        }
      });

      stopwatch.stop();

      if (usageCommitted > 0 || focusCommitted > 0) {
        debugPrint(
            '💾 Hive commit: $usageCommitted usage, $focusCommitted focus (${stopwatch.elapsedMilliseconds}ms)');
      }
    } catch (e) {
      debugPrint('❌ Error committing to Hive: $e');
    }
  }

  /// Force immediate commit (useful before app closes)
  Future<void> forceCommitToHive() async {
    debugPrint('🔄 Force committing all data to Hive...');
    await _commitRuntimeCacheToHive();
  }

  // Helper method to open a box with retry logic
  Future<Box<T>?> _openBoxWithRetry<T>(String boxName,
      {int maxRetries = 3}) async {
    int attempts = 0;

    while (attempts < maxRetries) {
      try {
        return await Hive.openBox<T>(
          boxName,
          compactionStrategy: (entries, deletedEntries) {
            return deletedEntries > 15 && deletedEntries / entries > 0.15;
          },
        );
      } catch (e) {
        attempts++;
        debugPrint("Box opening attempt $attempts failed: $e");

        if (attempts >= maxRetries) {
          _lastError =
              "Failed to open box $boxName after $maxRetries attempts: $e";
          debugPrint(_lastError);
          return null;
        }

        if (e.toString().contains('corrupted') ||
            e.toString().contains('not found') ||
            e.toString().contains('lock') ||
            e.toString().contains('permission')) {
          try {
            debugPrint("Attempting to delete and recreate box: $boxName");
            try {
              final box = Hive.box(boxName);
              if (box.isOpen) await box.close();
            } catch (_) {}
            await Hive.deleteBoxFromDisk(boxName);
            debugPrint("Deleted corrupted box: $boxName, retrying...");
          } catch (deleteError) {
            debugPrint("Error deleting box: $deleteError");
          }
        }

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
        {
          'name': _metadataBoxName,
          'box': _metadataBox,
          'lock': _metadataBoxLock
        },
      ]) {
        final String boxName = boxInfo['name'] as String;
        final Box? box = boxInfo['box'] as Box?;
        final Lock lock = boxInfo['lock'] as Lock;

        await lock.synchronized(() async {
          try {
            if (box != null && box.isOpen) {
              try {
                box.keys.take(1).toList();
                debugPrint("Box $boxName is healthy");
              } catch (e) {
                debugPrint("Box $boxName is corrupted, repairing: $e");

                try {
                  await box.close();
                } catch (_) {}

                try {
                  await Hive.deleteBoxFromDisk(boxName);
                } catch (deleteError) {
                  debugPrint("Error deleting box: $deleteError");
                }

                if (boxName == _usageBoxName) {
                  _usageBox = await _openBoxWithRetry<AppUsageRecord>(boxName);
                } else if (boxName == _focusBoxName) {
                  _focusBox =
                      await _openBoxWithRetry<FocusSessionRecord>(boxName);
                } else if (boxName == _metadataBoxName) {
                  _metadataBox = await _openBoxWithRetry<AppMetadata>(boxName);
                }
              }
            } else {
              debugPrint("Box $boxName is not open, attempting to open");
              if (boxName == _usageBoxName) {
                _usageBox = await _openBoxWithRetry<AppUsageRecord>(boxName);
              } else if (boxName == _focusBoxName) {
                _focusBox =
                    await _openBoxWithRetry<FocusSessionRecord>(boxName);
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
    final now = DateTime.now();
    if (_lastMaintenanceDate == null ||
        now.difference(_lastMaintenanceDate!).inHours > 24) {
      checkAndRepairBoxes();
    }
  }

  // Ensure boxes are initialized
  bool _ensureInitialized() {
    if (!_isInitialized ||
        _usageBox == null ||
        _focusBox == null ||
        _metadataBox == null) {
      _lastError = "AppDataStore not initialized. Call init() first.";
      debugPrint(_lastError);
      return false;
    }
    return true;
  }

  // ============================================================
  // METADATA OPERATIONS (Using runtime cache)
  // ============================================================

  List<String> get allAppNames {
    if (!_ensureInitialized()) return [];
    try {
      return _metadataCache.keys.toList();
    } catch (e) {
      _lastError = "Error getting app names: $e";
      debugPrint(_lastError);
      return [];
    }
  }

  Future<bool> updateAppMetadata(
    String appName, {
    String? category,
    bool? isProductive,
    bool? isTracking,
    bool? isVisible,
    Duration? dailyLimit,
    bool? limitStatus,
  }) async {
    if (!_ensureInitialized()) return false;

    try {
      AppMetadata? existing = _metadataCache[appName];

      String defaultCategory =
          appName.startsWith(':') ? 'Idle' : 'Uncategorized';

      final AppMetadata updated = AppMetadata(
        category: category ?? existing?.category ?? defaultCategory,
        isProductive: isProductive ?? existing?.isProductive ?? false,
        isTracking: isTracking ?? existing?.isTracking ?? true,
        isVisible: isVisible ?? existing?.isVisible ?? true,
        dailyLimit: dailyLimit ?? existing?.dailyLimit ?? Duration.zero,
        limitStatus: limitStatus ?? existing?.limitStatus ?? false,
      );

      // Update runtime cache immediately
      _metadataCache[appName] = updated;

      // Update Hive asynchronously (don't wait)
      _metadataBox!.put(appName, updated).catchError((e) {
        debugPrint('⚠️ Error saving metadata to Hive: $e');
      });

      notifyListeners();
      return true;
    } catch (e) {
      _lastError = "Error updating app metadata for $appName: $e";
      debugPrint(_lastError);
      return false;
    }
  }

  AppMetadata? getAppMetadata(String appName) {
    if (!_ensureInitialized()) return null;
    try {
      return _metadataCache[appName];
    } catch (e) {
      _lastError = "Error getting metadata for $appName: $e";
      debugPrint(_lastError);
      return null;
    }
  }

  Future<bool> deleteAppMetadata(String appName) async {
    if (!_ensureInitialized()) return false;

    try {
      // Remove from runtime cache immediately
      _metadataCache.remove(appName);

      // Remove from Hive asynchronously
      if (_metadataBox!.containsKey(appName)) {
        _metadataBox!.delete(appName).catchError((e) {
          debugPrint('⚠️ Error deleting metadata from Hive: $e');
        });
      }

      notifyListeners();
      return true;
    } catch (e) {
      _lastError = "Error deleting metadata for $appName: $e";
      debugPrint(_lastError);
      return false;
    }
  }

  // ============================================================
  // APP USAGE OPERATIONS (Using runtime cache)
  // ============================================================

  String _makeUsageKey(String appName, DateTime date) {
    // Date part is always "YYYY-MM-DD" = 10 chars, plus ":" separator = 11 chars
    // Leave room: 255 - 11 = 244 chars max for appName
    final safeName = appName.length > 244 ? appName.substring(0, 244) : appName;
    return '$safeName:${_formatDateKey(date)}';
  }

  String _makeFocusKey(DateTime date, int millisecondsSinceEpoch) {
    // "YYYY-MM-DD:1234567890123" - always well under 255
    return '${_formatDateKey(date)}:$millisecondsSinceEpoch';
  }
  Future<bool> recordAppUsage(String appName, DateTime date, Duration timeSpent,
      int openCount, List<TimeRange> usagePeriods) async {
    if (!_ensureInitialized()) return false;

    try {
      return await _runtimeCacheLock.synchronized(() async {
        final String key = _makeUsageKey(appName, date);
        AppUsageRecord? existing = _usageRuntimeCache[key];

        if (existing != null) {
          final List<TimeRange> optimizedUsagePeriods = _optimizeUsagePeriods(
              [...existing.usagePeriods, ...usagePeriods]);

          final AppUsageRecord updated = AppUsageRecord(
            date: date,
            timeSpent: existing.timeSpent + timeSpent,
            openCount: existing.openCount + openCount,
            usagePeriods: optimizedUsagePeriods,
          );

          // Update runtime cache immediately
          _usageRuntimeCache[key] = updated;
          _dirtyUsageKeys.add(key);
        } else {
          final AppUsageRecord record = AppUsageRecord(
            date: date,
            timeSpent: timeSpent,
            openCount: openCount,
            usagePeriods: usagePeriods,
          );

          // Add to runtime cache immediately
          _usageRuntimeCache[key] = record;
          _dirtyUsageKeys.add(key);
        }

        // Notify listeners immediately (UI updates instantly!)
        notifyListeners();
        return true;
      });
    } catch (e) {
      _lastError = "Error recording app usage for $appName: $e";
      debugPrint(_lastError);
      return false;
    }
  }

  List<TimeRange> _optimizeUsagePeriods(List<TimeRange> periods) {
    if (periods.length <= 10) return periods;

    periods.sort((a, b) => a.startTime.compareTo(b.startTime));

    List<TimeRange> optimizedPeriods = [];
    TimeRange current = periods.first;

    for (int i = 1; i < periods.length; i++) {
      TimeRange next = periods[i];

      if (next.startTime.difference(current.endTime).inSeconds <= 5) {
        current =
            TimeRange(startTime: current.startTime, endTime: next.endTime);
      } else {
        optimizedPeriods.add(current);
        current = next;
      }
    }

    optimizedPeriods.add(current);

    if (optimizedPeriods.length > 10) {
      return optimizedPeriods.sublist(optimizedPeriods.length - 10);
    }

    return optimizedPeriods;
  }

  /// Get app usage from runtime cache (instant!)
  AppUsageRecord? getAppUsage(String appName, DateTime date) {
    if (!_ensureInitialized()) return null;

    try {
      final String key = _makeUsageKey(appName, date);
      return _usageRuntimeCache[key];
    } catch (e) {
      _lastError =
          "Error getting app usage for $appName on ${_formatDateKey(date)}: $e";
      debugPrint(_lastError);
      return null;
    }
  }

  /// Get app usage for a date range from runtime cache
  List<AppUsageRecord> getAppUsageRange(
      String appName, DateTime startDate, DateTime endDate) {
    if (!_ensureInitialized()) return [];

    try {
      final List<AppUsageRecord> result = [];
      DateTime currentDate =
          DateTime(startDate.year, startDate.month, startDate.day);
      final DateTime endOfRange =
          DateTime(endDate.year, endDate.month, endDate.day);

      while (currentDate.isBefore(endOfRange) ||
          currentDate.day == endOfRange.day) {
        final AppUsageRecord? record = getAppUsage(appName, currentDate);
        if (record != null) {
          result.add(record);
        }
        currentDate = currentDate.add(const Duration(days: 1));
      }

      return result;
    } catch (e) {
      _lastError = "Error getting app usage range for $appName: $e";
      debugPrint(_lastError);
      return [];
    }
  }

  // ============================================================
  // FOCUS SESSION OPERATIONS (Using runtime cache)
  // ============================================================

  Future<bool> recordFocusSession(FocusSessionRecord session) async {
    if (!_ensureInitialized()) return false;

    try {
      return await _runtimeCacheLock.synchronized(() async {
        final String key =
            '${_formatDateKey(session.date)}:${session.startTime.millisecondsSinceEpoch}';

        // Add to runtime cache immediately
        _focusRuntimeCache[key] = session;
        _dirtyFocusKeys.add(key);

        // Notify listeners immediately
        notifyListeners();
        return true;
      });
    } catch (e) {
      _lastError = "Error recording focus session: $e";
      debugPrint(_lastError);
      return false;
    }
  }

  /// Get focus sessions from runtime cache
  List<FocusSessionRecord> getFocusSessions(DateTime date) {
    if (!_ensureInitialized()) return [];

    try {
      final String dateKey = _formatDateKey(date);
      final List<FocusSessionRecord> result = [];

      for (final entry in _focusRuntimeCache.entries) {
        if (entry.key.startsWith(dateKey)) {
          result.add(entry.value);
        }
      }

      return result;
    } catch (e) {
      _lastError =
          "Error getting focus sessions for ${_formatDateKey(date)}: $e";
      debugPrint(_lastError);
      return [];
    }
  }

  List<FocusSessionRecord> getFocusSessionsRange(
      DateTime startDate, DateTime endDate) {
    if (!_ensureInitialized()) return [];

    try {
      final List<FocusSessionRecord> result = [];
      DateTime currentDate =
          DateTime(startDate.year, startDate.month, startDate.day);
      final DateTime endOfRange =
          DateTime(endDate.year, endDate.month, endDate.day);

      while (currentDate.isBefore(endOfRange) ||
          currentDate.day == endOfRange.day) {
        result.addAll(getFocusSessions(currentDate));
        currentDate = currentDate.add(const Duration(days: 1));
      }

      return result;
    } catch (e) {
      _lastError = "Error getting focus sessions range: $e";
      debugPrint(_lastError);
      return [];
    }
  }

  Future<bool> deleteFocusSession(String key) async {
    if (!_ensureInitialized()) return false;

    try {
      return await _runtimeCacheLock.synchronized(() async {
        // Remove from runtime cache immediately
        final removed = _focusRuntimeCache.remove(key);

        if (removed != null) {
          // Also remove from dirty keys
          _dirtyFocusKeys.remove(key);

          // Delete from Hive asynchronously
          if (_focusBox!.containsKey(key)) {
            _focusBox!.delete(key).catchError((e) {
              debugPrint('⚠️ Error deleting focus session from Hive: $e');
            });
          }

          notifyListeners();
          return true;
        }
        return false;
      });
    } catch (e) {
      _lastError = "Error deleting focus session for key $key: $e";
      debugPrint(_lastError);
      return false;
    }
  }

  // ============================================================
  // ANALYTICS & DERIVED DATA (All use runtime cache now)
  // ============================================================

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
      _lastError =
          "Error calculating total screen time for ${_formatDateKey(date)}: $e";
      debugPrint(_lastError);
      return Duration.zero;
    }
  }

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
      _lastError =
          "Error calculating productive time for ${_formatDateKey(date)}: $e";
      debugPrint(_lastError);
      return Duration.zero;
    }
  }

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
      _lastError =
          "Error finding most used app for ${_formatDateKey(date)}: $e";
      debugPrint(_lastError);
      return "Error";
    }
  }

  int getFocusSessionsCount(DateTime date) {
    if (!_ensureInitialized()) return 0;

    try {
      return getFocusSessions(date)
          .where((session) => session.completed)
          .length;
    } catch (e) {
      _lastError =
          "Error counting focus sessions for ${_formatDateKey(date)}: $e";
      debugPrint(_lastError);
      return 0;
    }
  }

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
      _lastError =
          "Error calculating total focus time for ${_formatDateKey(date)}: $e";
      debugPrint(_lastError);
      return Duration.zero;
    }
  }

  Map<String, Duration> getCategoryBreakdown(DateTime date) {
    if (!_ensureInitialized()) return {};

    try {
      final Map<String, Duration> result = {};

      for (final appName in allAppNames) {
        final AppMetadata? metadata = getAppMetadata(appName);
        final AppUsageRecord? record = getAppUsage(appName, date);

        if (metadata != null && record != null) {
          final String category = metadata.category;
          result[category] =
              (result[category] ?? Duration.zero) + record.timeSpent;
        }
      }

      return result;
    } catch (e) {
      _lastError =
          "Error calculating category breakdown for ${_formatDateKey(date)}: $e";
      debugPrint(_lastError);
      return {};
    }
  }

  double getProductivityScore(DateTime date) {
    if (!_ensureInitialized()) return 0.0;

    try {
      final total = getTotalScreenTime(date);
      final productive = getProductiveTime(date);
      final sessions = getFocusSessionsCount(date);

      if (total.inMinutes < 10) {
        return 0.0;
      }

      final productiveRatio = productive.inSeconds / total.inSeconds;
      final sessionBonus = (sessions * 0.5).clamp(0.0, 10.0);
      final rawScore = (productiveRatio * 80) + sessionBonus;

      return rawScore.clamp(0.0, 100.0);
    } catch (e) {
      _lastError =
          "Error calculating productivity score for ${_formatDateKey(date)}: $e";
      debugPrint(_lastError);
      return 0.0;
    }
  }

  Duration getAverageScreenTime(DateTime startDate, DateTime endDate) {
    if (!_ensureInitialized()) return Duration.zero;

    try {
      int totalSeconds = 0;
      int daysWithData = 0;

      DateTime current = DateTime(
        startDate.year,
        startDate.month,
        startDate.day,
      );

      final DateTime end = DateTime(
        endDate.year,
        endDate.month,
        endDate.day,
      );

      while (!current.isAfter(end)) {
        final Duration dayTotal = getTotalScreenTime(current);

        if (dayTotal.inSeconds > 0) {
          totalSeconds += dayTotal.inSeconds;
          daysWithData++;
        }

        current = current.add(const Duration(days: 1));
      }

      if (daysWithData == 0) {
        return Duration.zero;
      }

      return Duration(
        seconds: totalSeconds ~/ daysWithData,
      );
    } catch (e) {
      _lastError = "Error calculating average screen time: $e";
      debugPrint(_lastError);
      return Duration.zero;
    }
  }

  double getFocusTrend(DateTime currentWeekStart, DateTime previousWeekStart) {
    if (!_ensureInitialized()) return 0.0;

    try {
      final DateTime currentWeekEnd =
          currentWeekStart.add(const Duration(days: 6));
      final DateTime previousWeekEnd =
          previousWeekStart.add(const Duration(days: 6));

      final Duration currentWeekFocus =
          getFocusSessionsRange(currentWeekStart, currentWeekEnd)
              .where((session) => session.completed)
              .fold(Duration.zero, (sum, session) => sum + session.focusTime);

      final Duration previousWeekFocus =
          getFocusSessionsRange(previousWeekStart, previousWeekEnd)
              .where((session) => session.completed)
              .fold(Duration.zero, (sum, session) => sum + session.focusTime);

      if (previousWeekFocus.inSeconds == 0) return 0.0;

      return (currentWeekFocus.inSeconds - previousWeekFocus.inSeconds) /
          previousWeekFocus.inSeconds *
          100;
    } catch (e) {
      _lastError = "Error calculating focus trend: $e";
      debugPrint(_lastError);
      return 0.0;
    }
  }

  String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // ============================================================
  // CLEAR ALL DATA
  // ============================================================
  Future<bool> clearAllData({Function(double)? progressCallback}) async {
    return await _initLock.synchronized(() async {
      if (!(_ensureInitialized())) return false;

      try {
        debugPrint('🗑️ Clearing all data...');

        if (progressCallback != null) progressCallback(0.1);

        // Clear runtime caches first
        await _runtimeCacheLock.synchronized(() async {
          _usageRuntimeCache.clear();
          _focusRuntimeCache.clear();
          _metadataCache.clear();
          _dirtyUsageKeys.clear();
          _dirtyFocusKeys.clear();
          debugPrint('   ✓ Runtime caches cleared');
        });

        if (progressCallback != null) progressCallback(0.2);

        // Close all boxes
        if (_usageBox != null && _usageBox!.isOpen) await _usageBox!.close();
        if (_focusBox != null && _focusBox!.isOpen) await _focusBox!.close();
        if (_metadataBox != null && _metadataBox!.isOpen)
          await _metadataBox!.close();

        if (progressCallback != null) progressCallback(0.4);

        // Delete boxes from disk
        await Hive.deleteBoxFromDisk(_usageBoxName);
        debugPrint('   ✓ Usage box deleted');
        if (progressCallback != null) progressCallback(0.6);

        await Hive.deleteBoxFromDisk(_focusBoxName);
        debugPrint('   ✓ Focus box deleted');
        if (progressCallback != null) progressCallback(0.8);

        await Hive.deleteBoxFromDisk(_metadataBoxName);
        debugPrint('   ✓ Metadata box deleted');
        if (progressCallback != null) progressCallback(0.9);

        // Reinitialize boxes
        _usageBox = await _openBoxWithRetry<AppUsageRecord>(_usageBoxName);
        _focusBox = await _openBoxWithRetry<FocusSessionRecord>(_focusBoxName);
        _metadataBox = await _openBoxWithRetry<AppMetadata>(_metadataBoxName);

        if (progressCallback != null) progressCallback(1.0);

        debugPrint('✅ All data cleared successfully');
        debugPrint('   📊 Final state:');
        debugPrint('      - Usage cache: ${_usageRuntimeCache.length}');
        debugPrint('      - Focus cache: ${_focusRuntimeCache.length}');
        debugPrint('      - Metadata cache: ${_metadataCache.length}');

        // Notify all listeners that data has been cleared
        notifyListeners();

        return true;
      } catch (e) {
        _lastError = "Error clearing data: $e";
        debugPrint(_lastError);
        return false;
      }
    });
  }

  // ============================================================
  // CLOSE & DISPOSE
  // ============================================================
  Future<void> closeHive() async {
    return await _initLock.synchronized(() async {
      try {
        // Commit any pending changes before closing
        await forceCommitToHive();

        // Stop persistence timer
        _persistenceTimer?.cancel();
        _persistenceTimer = null;

        if (_usageBox != null && _usageBox!.isOpen) await _usageBox!.close();
        if (_focusBox != null && _focusBox!.isOpen) await _focusBox!.close();
        if (_metadataBox != null && _metadataBox!.isOpen)
          await _metadataBox!.close();

        await Hive.close();
        _isInitialized = false;
      } catch (e) {
        _lastError = "Error closing Hive: $e";
        debugPrint(_lastError);
      }
    });
  }

  @override
  Future<void> dispose() async {
    await _initLock.synchronized(() async {
      try {
        // Commit any pending changes before disposing
        await forceCommitToHive();

        // Stop persistence timer
        _persistenceTimer?.cancel();
        _persistenceTimer = null;

        if (_usageBox != null && _usageBox!.isOpen) await _usageBox!.close();
        if (_focusBox != null && _focusBox!.isOpen) await _focusBox!.close();
        if (_metadataBox != null && _metadataBox!.isOpen)
          await _metadataBox!.close();

        _isInitialized = false;
      } catch (e) {
        debugPrint("Error closing Hive boxes: $e");
      }
    });

    super.dispose();
  }

  void handleAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      debugPrint("App going to background, committing data to Hive");
      forceCommitToHive();
    } else if (state == AppLifecycleState.resumed) {
      debugPrint("App resumed, checking database health");
      checkAndRepairBoxes();
    }
  }

  // ============================================================
  // DEBUG INFO
  // ============================================================
  Map<String, dynamic> getRuntimeCacheStats() {
    return {
      'usageRecordsInCache': _usageRuntimeCache.length,
      'focusSessionsInCache': _focusRuntimeCache.length,
      'metadataInCache': _metadataCache.length,
      'dirtyUsageRecords': _dirtyUsageKeys.length,
      'dirtyFocusSessions': _dirtyFocusKeys.length,
      'persistenceIntervalSeconds': _persistenceInterval.inSeconds,
      'persistenceTimerActive': _persistenceTimer != null,
    };
  }
}

// ============================================================
// HIVE TYPE ADAPTERS
// ============================================================

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
