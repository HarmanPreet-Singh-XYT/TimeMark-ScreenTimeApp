import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:async';

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

  AppMetadata({
    required this.category,
    required this.isProductive,
    this.isTracking = true,
    this.isVisible = true,
    this.dailyLimit = Duration.zero,
  });
}

class AppDataStore extends ChangeNotifier {
  static final AppDataStore _instance = AppDataStore._internal();
  static const String _usageBoxName = 'app_usage_box';
  static const String _focusBoxName = 'focus_session_box';
  static const String _metadataBoxName = 'app_metadata_box';
  
  late Box<AppUsageRecord> _usageBox;
  late Box<FocusSessionRecord> _focusBox;
  late Box<AppMetadata> _metadataBox;
  
  bool _isInitialized = false;

  // Factory constructor to return the singleton instance
  factory AppDataStore() {
    return _instance;
  }

  // Private constructor
  AppDataStore._internal();

  // Initialize Hive
  Future<void> init() async {
    if (_isInitialized) return;
    
    // Initialize Hive
    await Hive.initFlutter();
    
    // Register adapters
    Hive.registerAdapter(AppUsageRecordAdapter());
    Hive.registerAdapter(TimeRangeAdapter());
    Hive.registerAdapter(FocusSessionRecordAdapter());
    Hive.registerAdapter(AppMetadataAdapter());
    Hive.registerAdapter(DurationAdapter());
    
    // Open boxes
    _usageBox = await Hive.openBox<AppUsageRecord>(_usageBoxName);
    _focusBox = await Hive.openBox<FocusSessionRecord>(_focusBoxName);
    _metadataBox = await Hive.openBox<AppMetadata>(_metadataBoxName);
    
    _isInitialized = true;
    notifyListeners();
  }

  // METADATA OPERATIONS
  
  // Get all app names
  List<String> get allAppNames => _metadataBox.keys.cast<String>().toList();
  
  // Add or update app metadata
  Future<void> updateAppMetadata(String appName, {
    String? category,
    bool? isProductive,
    bool? isTracking,
    bool? isVisible,
    Duration? dailyLimit,
  }) async {
    final AppMetadata existing = _metadataBox.get(appName) ?? AppMetadata(
      category: 'Uncategorized',
      isProductive: false,
    );
    
    final AppMetadata updated = AppMetadata(
      category: category ?? existing.category,
      isProductive: isProductive ?? existing.isProductive,
      isTracking: isTracking ?? existing.isTracking,
      isVisible: isVisible ?? existing.isVisible,
      dailyLimit: dailyLimit ?? existing.dailyLimit,
    );
    
    await _metadataBox.put(appName, updated);
    notifyListeners();
  }
  
  // Get app metadata
  AppMetadata? getAppMetadata(String appName) {
    return _metadataBox.get(appName);
  }
  
  // Delete app metadata
  Future<void> deleteAppMetadata(String appName) async {
    await _metadataBox.delete(appName);
    notifyListeners();
  }

  // APP USAGE OPERATIONS
  
  // Record app usage
  Future<void> recordAppUsage(String appName, DateTime date, Duration timeSpent, int openCount, List<TimeRange> usagePeriods) async {
    final String key = '$appName:${_formatDateKey(date)}';
    final AppUsageRecord? existing = _usageBox.get(key);
    
    if (existing != null) {
      // Update existing record
      final Duration newTimeSpent = existing.timeSpent + timeSpent;
      final int newOpenCount = existing.openCount + openCount;
      final List<TimeRange> newUsagePeriods = [...existing.usagePeriods, ...usagePeriods];
      
      final AppUsageRecord updated = AppUsageRecord(
        date: date,
        timeSpent: newTimeSpent,
        openCount: newOpenCount,
        usagePeriods: newUsagePeriods,
      );
      
      await _usageBox.put(key, updated);
    } else {
      // Create new record
      final AppUsageRecord record = AppUsageRecord(
        date: date,
        timeSpent: timeSpent,
        openCount: openCount,
        usagePeriods: usagePeriods,
      );
      
      await _usageBox.put(key, record);
    }
    
    notifyListeners();
  }
  
  // Get app usage for a specific day
  AppUsageRecord? getAppUsage(String appName, DateTime date) {
    final String key = '$appName:${_formatDateKey(date)}';
    return _usageBox.get(key);
  }
  
  // Get app usage for a date range
  List<AppUsageRecord> getAppUsageRange(String appName, DateTime startDate, DateTime endDate) {
    final List<AppUsageRecord> result = [];
    final DateTime currentDate = startDate;
    
    while (currentDate.isBefore(endDate) || currentDate.isAtSameMomentAs(endDate)) {
      final AppUsageRecord? record = getAppUsage(appName, currentDate);
      if (record != null) {
        result.add(record);
      }
      currentDate.add(Duration(days: 1));
    }
    
    return result;
  }
  
  // FOCUS SESSION OPERATIONS
  
  // Record focus session
  Future<void> recordFocusSession(FocusSessionRecord session) async {
    final String key = '${_formatDateKey(session.date)}:${session.startTime.millisecondsSinceEpoch}';
    await _focusBox.put(key, session);
    notifyListeners();
  }
  
  // Get focus sessions for a specific day
  List<FocusSessionRecord> getFocusSessions(DateTime date) {
    final String dateKey = _formatDateKey(date);
    final List<FocusSessionRecord> result = [];
    
    for (final key in _focusBox.keys) {
      if (key.toString().startsWith(dateKey)) {
        final FocusSessionRecord? session = _focusBox.get(key);
        if (session != null) {
          result.add(session);
        }
      }
    }
    
    return result;
  }
  
  // Get focus sessions for a date range
  List<FocusSessionRecord> getFocusSessionsRange(DateTime startDate, DateTime endDate) {
    final List<FocusSessionRecord> result = [];
    final DateTime currentDate = startDate;
    
    while (currentDate.isBefore(endDate) || currentDate.isAtSameMomentAs(endDate)) {
      result.addAll(getFocusSessions(currentDate));
      currentDate.add(Duration(days: 1));
    }
    
    return result;
  }
  
  // Delete focus session
  Future<void> deleteFocusSession(String key) async {
    await _focusBox.delete(key);
    notifyListeners();
  }
  
  // ANALYTICS & DERIVED DATA
  
  // Get total screen time for a specific day
  Duration getTotalScreenTime(DateTime date) {
    Duration total = Duration.zero;
    
    for (final appName in allAppNames) {
      final AppUsageRecord? record = getAppUsage(appName, date);
      if (record != null) {
        total += record.timeSpent;
      }
    }
    
    return total;
  }
  
  // Get productive time for a specific day
  Duration getProductiveTime(DateTime date) {
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
  }
  
  // Get most used app for a specific day
  String getMostUsedApp(DateTime date) {
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
  }
  
  // Get focus sessions count for a specific day
  int getFocusSessionsCount(DateTime date) {
    return getFocusSessions(date).where((session) => session.completed).length;
  }
  
  // Get total focus time for a specific day
  Duration getTotalFocusTime(DateTime date) {
    Duration total = Duration.zero;
    
    for (final session in getFocusSessions(date)) {
      if (session.completed) {
        total += session.focusTime;
      }
    }
    
    return total;
  }
  
  // Get category breakdown for a specific day
  Map<String, Duration> getCategoryBreakdown(DateTime date) {
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
  }
  
  // Calculate productivity score (0-100) for a specific day
  double getProductivityScore(DateTime date) {
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
  }
  
  // Get average screen time for a date range
  Duration getAverageScreenTime(DateTime startDate, DateTime endDate) {
    final List<Duration> dailyTotals = [];
    final DateTime currentDate = startDate;
    
    while (currentDate.isBefore(endDate) || currentDate.isAtSameMomentAs(endDate)) {
      dailyTotals.add(getTotalScreenTime(currentDate));
      currentDate.add(Duration(days: 1));
    }
    
    if (dailyTotals.isEmpty) return Duration.zero;
    
    final int totalMicroseconds = dailyTotals.fold(0, (sum, duration) => sum + duration.inMicroseconds);
    return Duration(microseconds: totalMicroseconds ~/ dailyTotals.length);
  }
  
  // Get focus trend (positive or negative percentage)
  double getFocusTrend(DateTime currentWeekStart, DateTime previousWeekStart) {
    final DateTime currentWeekEnd = currentWeekStart.add(Duration(days: 6));
    final DateTime previousWeekEnd = previousWeekStart.add(Duration(days: 6));
    
    final Duration currentWeekFocus = getFocusSessionsRange(currentWeekStart, currentWeekEnd)
        .where((session) => session.completed)
        .fold(Duration.zero, (sum, session) => sum + session.focusTime);
    
    final Duration previousWeekFocus = getFocusSessionsRange(previousWeekStart, previousWeekEnd)
        .where((session) => session.completed)
        .fold(Duration.zero, (sum, session) => sum + session.focusTime);
    
    if (previousWeekFocus.inSeconds == 0) return 0.0;
    
    return (currentWeekFocus.inSeconds - previousWeekFocus.inSeconds) / previousWeekFocus.inSeconds * 100;
  }
  
  // Helper method to format date as a consistent string key
  String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
  
  // Clear all data
  Future<void> clearAllData() async {
    await _usageBox.clear();
    await _focusBox.clear();
    await _metadataBox.clear();
    notifyListeners();
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
    );
  }

  @override
  void write(BinaryWriter writer, AppMetadata obj) {
    writer.writeByte(5);
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
  }
}