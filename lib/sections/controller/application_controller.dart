// background_app_tracker.dart
import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:screentime/foreground_window_plugin.dart';
import 'package:screentime/sections/controller/notification_controller.dart';
import 'package:screentime/sections/controller/settings_data_controller.dart';
import 'package:screentime/l10n/app_localizations.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:window_focus/window_focus.dart';
import 'app_data_controller.dart';
import 'categories_controller.dart';

enum TrackingMode {
  polling, // Standard method: 1-minute polling (lightweight, less accurate)
  precise, // Precise method: Event-based tracking (resource-intensive, accurate)
}

class BackgroundAppTracker {
  // ============================================================
  // SINGLETON INSTANCE
  // ============================================================
  static final BackgroundAppTracker _instance =
      BackgroundAppTracker._internal();
  factory BackgroundAppTracker() => _instance;
  BackgroundAppTracker._internal();

  // ============================================================
  // CONTROLLERS
  // ============================================================
  final NotificationController _notificationController =
      NotificationController();

  // ============================================================
  // TRACKING MODE
  // ============================================================
  TrackingMode _trackingMode = TrackingMode.polling;

  // ============================================================
  // SHARED STATE (Used by both modes)
  // ============================================================
  bool _isTracking = false;
  bool _isUserActive = true;
  AppLocalizations? _localizations;
  String _currentLocale = 'en';
  AppDataStore? _appDataStore;

  // Stream controller to broadcast app updates
  final StreamController<String> _appUpdateController =
      StreamController<String>.broadcast();
  Stream<String> get appUpdates => _appUpdateController.stream;

  // ============================================================
  // WINDOW FOCUS PLUGIN
  // ============================================================
  WindowFocus? _windowFocusPlugin;

  // ============================================================
  // POLLING MODE STATE
  // ============================================================
  Timer? _pollingTimer;

  // ============================================================
  // PRECISE MODE STATE
  // ============================================================
  // NOTE: We no longer need _commitTimer or _appUsageBuffer here!
  // The AppDataStore now handles all buffering and committing internally
  // with its runtime cache + periodic Hive persistence

  String _currentApp = '';
  DateTime _currentAppStartTime = DateTime.now();
  Timer? _selfTrackingHeartbeat;
  Timer? _universalHeartbeat;

  static const String _selfAppName = 'Scolect - Track Screen Time & App Usage';

  // Metadata cache - shared by both modes for performance
  final Map<String, AppMetadata> _metadataCache = {};
  bool _metadataCacheLoaded = false;

  // ============================================================
  // GETTERS
  // ============================================================
  TrackingMode get trackingMode => _trackingMode;
  bool get isTracking => _isTracking;
  bool get isUserActive => _isUserActive;

  // ============================================================
  // PRECISE MODE HEARTBEAT (SELF-APP ONLY)
  // ============================================================
  void _startSelfTrackingHeartbeat() {
    _selfTrackingHeartbeat?.cancel();
    _selfTrackingHeartbeat = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _heartbeatSelfApp(),
    );
    debugPrint('💓 Self-tracking heartbeat started');
  }

  void _stopSelfTrackingHeartbeat() {
    _selfTrackingHeartbeat?.cancel();
    _selfTrackingHeartbeat = null;
    debugPrint('💓 Self-tracking heartbeat stopped');
  }

  void _startUniversalHeartbeat() {
    _universalHeartbeat?.cancel();
    _universalHeartbeat = Timer.periodic(
      const Duration(seconds: 60), // 👈 Every 60s, lightweight
      (_) => _heartbeatCurrentApp(),
    );
    debugPrint('💓 Universal heartbeat started (every 60s)');
  }

  void _stopUniversalHeartbeat() {
    _universalHeartbeat?.cancel();
    _universalHeartbeat = null;
  }

  void _heartbeatCurrentApp() {
    if (_trackingMode != TrackingMode.precise) return;
    if (!_isTracking) return;
    if (_currentApp.isEmpty) return;
    if (_currentApp == _selfAppName) return; // 👈 Self-heartbeat handles this

    bool idleDetectionEnabled =
        SettingsManager().getSetting("tracking.idleDetection") ?? true;

    if (idleDetectionEnabled && !_isUserActive) return;

    final metadata = _appDataStore?.getAppMetadata(_currentApp);
    if (metadata != null && (!metadata.isTracking || !metadata.isVisible))
      return;

    final now = DateTime.now();
    final elapsed = now.difference(_currentAppStartTime);

    if (elapsed.inSeconds <= 0) return;

    _appDataStore?.recordAppUsage(
      _currentApp,
      now,
      elapsed,
      0,
      [TimeRange(startTime: _currentAppStartTime, endTime: now)],
    );

    _currentAppStartTime = now;

    debugPrint('💓 Universal heartbeat: $_currentApp (+${elapsed.inSeconds}s)');
  }

  void _heartbeatSelfApp() {
    if (_trackingMode != TrackingMode.precise) return;
    if (!_isTracking) return;
    if (_currentApp != _selfAppName) return; // 👈 ONLY for our app

    bool idleDetectionEnabled =
        SettingsManager().getSetting("tracking.idleDetection") ?? true;

    if (idleDetectionEnabled && !_isUserActive) return;

    // 🔒 FIX #1: CHECK TRACKING STATUS BEFORE CALCULATING ELAPSED TIME
    final metadata = _appDataStore?.getAppMetadata(_currentApp);
    if (metadata != null && (!metadata.isTracking || !metadata.isVisible)) {
      debugPrint(
          '💓 Self-heartbeat skipped: tracking disabled for $_currentApp');
      return;
    }

    final now = DateTime.now();
    final elapsed = now.difference(_currentAppStartTime);

    if (elapsed.inSeconds <= 0) return;

    _appDataStore?.recordAppUsage(
      _currentApp,
      now,
      elapsed,
      0, // Continuation, not a new open
      [TimeRange(startTime: _currentAppStartTime, endTime: now)],
    );

    _currentAppStartTime = now;

    debugPrint('💓 Self-heartbeat: +${elapsed.inSeconds}s');
  }

  // ============================================================
  // INITIALIZATION
  // ============================================================
  Future<void> initializeTracking({String? locale}) async {
    try {
      _currentLocale =
          locale ?? SettingsManager().getSetting("language.selected") ?? 'en';
      await _loadLocalizations(_currentLocale);

      String modeString =
          SettingsManager().getSetting("tracking.mode") ?? 'polling';
      _trackingMode =
          modeString == 'precise' ? TrackingMode.precise : TrackingMode.polling;

      debugPrint('═══════════════════════════════════════════════════════');
      debugPrint('🚀 INITIALIZING BACKGROUND APP TRACKER');
      debugPrint('═══════════════════════════════════════════════════════');
      debugPrint('🌍 Locale: $_currentLocale');
      debugPrint('📊 Tracking mode: ${_trackingMode.name}');

      // Initialize AppDataStore (now with runtime cache!)
      await _initializeAppDataStore();

      // Load metadata cache early
      await _loadMetadataCache();

      // Initialize WindowFocus plugin
      await _initializeWindowFocusPlugin();

      // Start tracking based on mode
      if (_trackingMode == TrackingMode.polling) {
        debugPrint('🔄 Starting POLLING mode');
        await _startPollingMode();
      } else {
        debugPrint('🔄 Starting PRECISE mode');
        await _startPreciseMode();
      }

      _isTracking = true;

      debugPrint('═══════════════════════════════════════════════════════');
      debugPrint('✅ BACKGROUND TRACKER INITIALIZED');
      debugPrint('   Mode: ${_trackingMode.name}');
      debugPrint('   Runtime cache enabled: Yes');
      debugPrint('   Metadata cache: ${_metadataCache.length} apps');
      debugPrint('═══════════════════════════════════════════════════════');
    } catch (e) {
      debugPrint('❌ Tracking initialization error: $e');
    }
  }

  // ============================================================
  // APP DATA STORE INITIALIZATION
  // ============================================================
  Future<void> _initializeAppDataStore() async {
    if (_appDataStore == null) {
      _appDataStore = AppDataStore();
      await _appDataStore!.init();
      debugPrint('✅ AppDataStore initialized with runtime cache');

      // Log runtime cache stats
      final stats = _appDataStore!.getRuntimeCacheStats();
      debugPrint('   📊 Runtime cache stats:');
      debugPrint('      - Usage records: ${stats['usageRecordsInCache']}');
      debugPrint('      - Focus sessions: ${stats['focusSessionsInCache']}');
      debugPrint('      - Metadata: ${stats['metadataInCache']}');
      debugPrint(
          '      - Persistence interval: ${stats['persistenceIntervalSeconds']}s');
    }
  }

  // ============================================================
  // METADATA CACHE LOADING
  // ============================================================
  Future<void> _loadMetadataCache() async {
    if (_appDataStore == null) return;

    try {
      debugPrint('📦 Loading metadata cache...');

      final allApps = _appDataStore!.allAppNames;
      int loadedCount = 0;

      for (final appName in allApps) {
        final metadata = _appDataStore!.getAppMetadata(appName);
        if (metadata != null) {
          _metadataCache[appName] = metadata;
          loadedCount++;
        }
      }

      _metadataCacheLoaded = true;
      debugPrint('✅ Metadata cache loaded: $loadedCount apps');
    } catch (e) {
      debugPrint('❌ Error loading metadata cache: $e');
    }
  }

  // ============================================================
  // WINDOW FOCUS PLUGIN INITIALIZATION
  // ============================================================
  Future<void> _initializeWindowFocusPlugin() async {
    bool idleDetectionEnabled =
        SettingsManager().getSetting("tracking.idleDetection") ?? true;
    int idleTimeoutSeconds =
        SettingsManager().getSetting("tracking.idleTimeout") ?? 60;
    bool monitorAudio =
        SettingsManager().getSetting("tracking.monitorAudio") ?? false;
    bool monitorControllers =
        SettingsManager().getSetting("tracking.monitorControllers") ?? false;
    bool monitorHIDDevices =
        SettingsManager().getSetting("tracking.monitorHIDDevices") ?? false;
    bool monitorKeyboard =
        SettingsManager().getSetting("tracking.monitorKeyboard") ??
            !Platform.isMacOS;
    double audioThreshold =
        SettingsManager().getSetting("tracking.audioThreshold") ?? 0.001;

    debugPrint('🔧 Initializing WindowFocus plugin:');
    debugPrint('   - Idle Detection: $idleDetectionEnabled');
    debugPrint('   - Idle Timeout: ${idleTimeoutSeconds}s');

    _windowFocusPlugin = WindowFocus(
      debug: false,
      duration: Duration(seconds: idleTimeoutSeconds),
      monitorAudio: monitorAudio,
      monitorControllers: monitorControllers,
      monitorHIDDevices: monitorHIDDevices,
      audioThreshold: audioThreshold,
      monitorKeyboard: monitorKeyboard,
    );

    _windowFocusPlugin!.addFocusChangeListener(_handleFocusChange);
    debugPrint('✅ Focus change listener added');

    if (idleDetectionEnabled) {
      _windowFocusPlugin!.addUserActiveListener(_handleUserActivityChange);
      debugPrint('✅ User activity listener added');
    } else {
      _isUserActive = true;
      debugPrint('⚠️ Idle detection disabled');
    }

    debugPrint('✅ WindowFocus plugin initialized');
  }

  // ============================================================
  // MODE SWITCHING
  // ============================================================
  Future<void> setTrackingMode(TrackingMode mode) async {
    if (_trackingMode == mode) {
      debugPrint('ℹ️ Already in ${mode.name} mode');
      return;
    }

    debugPrint('═══════════════════════════════════════════════════════');
    debugPrint('🔄 SWITCHING TRACKING MODE');
    debugPrint('   From: ${_trackingMode.name} → To: ${mode.name}');
    debugPrint('═══════════════════════════════════════════════════════');

    await _stopCurrentMode();
    _trackingMode = mode;
    SettingsManager().updateSetting("tracking.mode", mode.name);

    if (mode == TrackingMode.polling) {
      await _startPollingMode();
    } else {
      await _startPreciseMode();
    }

    debugPrint('✅ TRACKING MODE CHANGED TO: ${mode.name}');
  }

  // ============================================================
  // STOP CURRENT MODE
  // ============================================================
  Future<void> _stopCurrentMode() async {
    if (_trackingMode == TrackingMode.polling) {
      _pollingTimer?.cancel();
      _pollingTimer = null;
      debugPrint('🛑 Polling timer stopped');
    } else {
      // In precise mode, just save the current app time
      // The AppDataStore runtime cache will handle everything else
      _saveCurrentAppTime();
      _stopSelfTrackingHeartbeat();
      _stopUniversalHeartbeat();

      _currentApp = '';
      _currentAppStartTime = DateTime.now();
      debugPrint('🛑 Precise mode stopped');
    }
  }

  // ============================================================
  // POLLING MODE
  // ============================================================
  Future<void> _startPollingMode() async {
    debugPrint('🔄 Starting polling mode (1-minute intervals)');

    _pollingTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _executePollingTracking(),
    );

    _executePollingTracking();
    debugPrint('✅ Polling timer started');
  }

  Future<void> _executePollingTracking() async {
    try {
      bool idleDetectionEnabled =
          SettingsManager().getSetting("tracking.idleDetection") ?? true;

      if (idleDetectionEnabled && !_isUserActive) {
        debugPrint('⏸️ Polling skipped: user is idle');
        return;
      }

      final Map<String, dynamic>? currentAppInfo =
          await _getCurrentActiveAppInfo();
      if (currentAppInfo == null) return;

      String appTitle = currentAppInfo['title'] ?? '';

      if (appTitle.contains("Windows Explorer")) {
        appTitle = "";
      }

      if (appTitle == "Productive ScreenTime" || appTitle == "screentime") {
        return;
      }

      if (appTitle == "loginwindow") {
        return;
      }

      AppMetadata? metadata = await _getOrCreateMetadata(appTitle);

      // 🔒 ALREADY HAS CORRECT CHECK: Only record if tracking is enabled
      if (metadata != null && metadata.isTracking && metadata.isVisible) {
        final now = DateTime.now();
        final startTime = now.subtract(const Duration(minutes: 1));

        // 🎯 DATA GOES TO RUNTIME CACHE INSTANTLY!
        // User can see it immediately, no waiting for Hive commit
        await _appDataStore?.recordAppUsage(
          appTitle,
          now,
          const Duration(minutes: 1),
          1,
          [TimeRange(startTime: startTime, endTime: now)],
        );

        debugPrint('📊 Polling recorded: $appTitle (1 min) → runtime cache');
      } else if (metadata != null && !metadata.isTracking) {
        debugPrint('⏭️ Polling skipped: $appTitle (tracking disabled)');
      }

      _notificationController.checkAndSendNotifications();
      _appUpdateController.add(appTitle);
    } catch (e) {
      debugPrint('❌ Polling tracking error: $e');
    }
  }

  /// Call this after clearing all data to re-anchor tracking state
  /// so the current app starts being tracked again immediately
  Future<void> reanchorTracking() async {
    if (!_isTracking) return;

    debugPrint(
        '🔄 Re-anchoring tracking state after 2 seconds by data clear...');
    // 👈 Wait 2 seconds so the UI has time to show the "empty" state
    await Future.delayed(const Duration(seconds: 2));

    if (_trackingMode == TrackingMode.precise) {
      // Don't save old time — data was just cleared, old elapsed is irrelevant
      // Just reset the start time to NOW
      _currentAppStartTime = DateTime.now();

      // Re-ensure metadata exists for the current app
      if (_currentApp.isNotEmpty) {
        await _getOrCreateMetadata(_currentApp);

        // Immediately record a small entry so the app shows up in the UI
        final now = DateTime.now();
        await _appDataStore?.recordAppUsage(
          _currentApp,
          now,
          Duration.zero,
          1,
          [],
        );

        debugPrint('✅ Re-anchored: $_currentApp (tracking from now)');
      }
    } else if (_trackingMode == TrackingMode.polling) {
      // Force an immediate poll so current app appears right away
      await _executePollingTracking();
      debugPrint('✅ Re-anchored: forced immediate poll');
    }

    _appUpdateController.add(_currentApp);
  }

  // ============================================================
  // PRECISE MODE
  // ============================================================
  Future<void> _startPreciseMode() async {
    debugPrint('🔄 Starting precise mode (event-based tracking)');

    if (!_metadataCacheLoaded) {
      await _loadMetadataCache();
    }
    _startUniversalHeartbeat();
    // NOTE: We no longer start a commit timer here!
    // The AppDataStore handles all periodic commits internally

    debugPrint('✅ Precise mode started');
    debugPrint('   ℹ️ Data commits handled by AppDataStore runtime cache');
  }

  // ============================================================
  // FOCUS CHANGE HANDLER
  // ============================================================
  void _handleFocusChange(AppWindowDto window) async {
    if (_trackingMode == TrackingMode.polling) {
      return;
    }
    if ((window.appName != "Widgets.exe" && window.windowTitle == "") ||
        (window.appName == "explorer.exe" &&
            window.windowTitle == "Program Manager")) {
      return;
    }
    String newApp = await _getCurrentActiveApp();
    if (newApp == "SearchHost" || newApp == "Application Frame Host") {
      newApp = window.windowTitle;
    }

    if (newApp == "Productive ScreenTime") {
      return;
    }

    if (newApp == "screentime") {
      newApp = "Scolect - Track Screen Time & App Usage";
    }

    if (newApp == "loginwindow") {
      return;
    }

    if (newApp != _currentApp) {
      // Save the current app's time before switching
      _saveCurrentAppTime();

      // 🔒 FIX #2: CHECK IF NEW APP SHOULD BE TRACKED
      _currentApp = newApp;
      _currentAppStartTime = DateTime.now();

      // Ensure metadata exists for the new app
      await _ensureMetadataExists(newApp);

      // Check if this app should be tracked
      final metadata = _appDataStore?.getAppMetadata(newApp);
      if (metadata != null && (!metadata.isTracking || !metadata.isVisible)) {
        debugPrint(
            '📱 App changed to: $newApp (tracking disabled - will not record)');
        _stopSelfTrackingHeartbeat(); // Don't heartbeat if not tracking
        _appUpdateController.add(_currentApp);
        return;
      }

      if (_currentApp == _selfAppName) {
        _startSelfTrackingHeartbeat();
      } else {
        _stopSelfTrackingHeartbeat();
      }

      debugPrint('📱 App changed to: $newApp (tracking enabled)');
      _appUpdateController.add(_currentApp);
    }
  }

  // ============================================================
  // USER ACTIVITY CHANGE HANDLER
  // ============================================================
  void _handleUserActivityChange(bool isActive) {
    debugPrint('👤 User activity: ${isActive ? "ACTIVE" : "IDLE"}');

    if (_trackingMode == TrackingMode.precise) {
      if (!isActive && _isUserActive) {
        _saveCurrentAppTime();
      }

      if (isActive && !_isUserActive) {
        _currentAppStartTime = DateTime.now();
      }
    }

    _isUserActive = isActive;
  }

  // ============================================================
  // PRECISE MODE: SAVE CURRENT APP TIME
  // ============================================================
  void _saveCurrentAppTime() {
    if (_trackingMode != TrackingMode.precise) return;

    bool idleDetectionEnabled =
        SettingsManager().getSetting("tracking.idleDetection") ?? true;

    if (idleDetectionEnabled && !_isUserActive) {
      debugPrint('⏸️ Skipping save: user is idle');
      return;
    }

    if (_currentApp.isEmpty) {
      return;
    }

    // ⭐ CRITICAL FIX: Get fresh metadata from AppDataStore, not stale local cache
    final metadata = _appDataStore?.getAppMetadata(_currentApp);

    if (metadata != null && (!metadata.isTracking || !metadata.isVisible)) {
      debugPrint(
          '⏭️ Skipping save: $_currentApp (tracking: ${metadata.isTracking}, visible: ${metadata.isVisible})');
      return;
    }

    final elapsed = DateTime.now().difference(_currentAppStartTime);
    final elapsedSeconds = elapsed.inSeconds;

    if (elapsedSeconds <= 0) {
      return;
    }

    // 🎯 SAVE DIRECTLY TO RUNTIME CACHE!
    // No intermediate buffer needed - AppDataStore handles it
    final now = DateTime.now();
    _appDataStore?.recordAppUsage(
      _currentApp,
      now,
      Duration(seconds: elapsedSeconds),
      1,
      [TimeRange(startTime: _currentAppStartTime, endTime: now)],
    ).then((_) {
      debugPrint('💾 Saved: $_currentApp (${elapsedSeconds}s) → runtime cache');
    }).catchError((e) {
      debugPrint('❌ Error saving to runtime cache: $e');
    });

    // Reset timer for next save
    _currentAppStartTime = now;

    // Check notifications
    _notificationController.checkAndSendNotifications();
  }

  // ============================================================
  // METADATA MANAGEMENT
  // ============================================================

  Future<AppMetadata?> _getOrCreateMetadata(String appTitle) async {
    // CRITICAL FIX: Always check AppDataStore first for fresh data
    // The local cache might be stale, especially after clearing data

    if (appTitle == "Productive ScreenTime" || appTitle == "screentime") {
      return null;
    }

    // First, check if AppDataStore has this metadata
    if (_appDataStore != null) {
      final existingMetadata = _appDataStore!.getAppMetadata(appTitle);

      if (existingMetadata != null) {
        // Update local cache with fresh data from AppDataStore
        _metadataCache[appTitle] = existingMetadata;
        return existingMetadata;
      }
    }

    // App doesn't exist in AppDataStore, create new metadata
    bool isProductive = true;
    String appCategory = 'Uncategorized';

    if (appTitle.isEmpty) {
      appCategory = 'Idle';
    } else {
      appCategory = _categorizeAppWithLocale(appTitle);
    }

    if (appCategory == "Social Media" ||
        appCategory == "Entertainment" ||
        appCategory == "Gaming" ||
        appCategory == "Uncategorized") {
      isProductive = false;
    }

    // Create metadata in AppDataStore
    if (_appDataStore != null) {
      await _appDataStore!.updateAppMetadata(
        appTitle,
        category: appCategory,
        isProductive: isProductive,
      );

      // Fetch the newly created metadata from AppDataStore
      final newMetadata = _appDataStore!.getAppMetadata(appTitle);
      if (newMetadata != null) {
        // Cache it locally
        _metadataCache[appTitle] = newMetadata;
        debugPrint(
            '✨ Created metadata: $appTitle ($appCategory, productive: $isProductive)');
        return newMetadata;
      }
    }

    return null;
  }

  Future<void> _ensureMetadataExists(String appTitle) async {
    await _getOrCreateMetadata(appTitle).then((metadata) {
      if (metadata != null) {
        debugPrint('✅ Metadata ready: $appTitle');
      }
    }).catchError((error) {
      debugPrint('⚠️ Error creating metadata for $appTitle: $error');
    });
  }

  Future<void> refreshMetadataCache() async {
    _metadataCache.clear();
    _metadataCacheLoaded = false;
    await _loadMetadataCache();
    debugPrint('🔄 Metadata cache refreshed');
  }

  /// Clear the metadata cache completely (call this after clearing all data)
  /// This should be called AFTER AppDataStore.clearAllData() to sync with empty database
  Future<void> clearMetadataCache() async {
    debugPrint('🗑️ Clearing BackgroundAppTracker metadata cache...');

    _metadataCache.clear();
    _metadataCacheLoaded = false;

    // Reload from AppDataStore (which should now be empty after clearAllData)
    await _loadMetadataCache();

    debugPrint('✅ Metadata cache cleared and reloaded');
    debugPrint(
        '   Cache size after clear: ${_metadataCache.length} (should be 0)');
  }

  Future<void> updateMetadataInCache(
      String appTitle, AppMetadata metadata) async {
    _metadataCache[appTitle] = metadata;

    if (_appDataStore != null) {
      await _appDataStore!.updateAppMetadata(
        appTitle,
        category: metadata.category,
        isProductive: metadata.isProductive,
        isTracking: metadata.isTracking,
        isVisible: metadata.isVisible,
        dailyLimit: metadata.dailyLimit,
        limitStatus: metadata.limitStatus,
      );
    }
  }

  // ============================================================
  // HELPER METHODS
  // ============================================================

  Future<Map<String, dynamic>?> _getCurrentActiveAppInfo() async {
    try {
      WindowInfo info = await ForegroundWindowPlugin.getForegroundWindowInfo();
      return {'title': info.programName};
    } catch (e) {
      debugPrint('❌ Error getting current app info: $e');
      return null;
    }
  }

  Future<String> _getCurrentActiveApp() async {
    try {
      WindowInfo info = await ForegroundWindowPlugin.getForegroundWindowInfo();
      return info.programName;
    } catch (e) {
      debugPrint('❌ Error getting current app: $e');
      return '';
    }
  }

  // ============================================================
  // LOCALIZATION
  // ============================================================

  Future<void> _loadLocalizations(String localeCode) async {
    try {
      final locale = ui.Locale(localeCode);
      _localizations = await AppLocalizations.delegate.load(locale);
      debugPrint('✅ Localizations loaded: $localeCode');
    } catch (e) {
      debugPrint('❌ Failed to load localizations: $e');
      final fallbackLocale = const ui.Locale('en');
      _localizations = await AppLocalizations.delegate.load(fallbackLocale);
    }
  }

  Future<void> updateLocale(String locale) async {
    _currentLocale = locale;
    await _loadLocalizations(locale);
    debugPrint('🌍 Locale updated: $_currentLocale');
  }

  // ============================================================
  // APP CATEGORIZATION
  // ============================================================

  String _categorizeAppWithLocale(String appTitle) {
    if (_localizations == null) {
      return _categorizeAppEnglishOnly(appTitle);
    }

    for (var category in AppCategories.categories) {
      if (category.apps
          .any((app) => appTitle.toLowerCase().contains(app.toLowerCase()))) {
        return category.name;
      }
    }

    for (var category in AppCategories.categories) {
      for (var app in category.apps) {
        String localizedAppName = _getLocalizedAppName(app);
        if (appTitle.toLowerCase().contains(localizedAppName.toLowerCase())) {
          return category.name;
        }
      }
    }

    return "Uncategorized";
  }

  String _categorizeAppEnglishOnly(String appTitle) {
    for (var category in AppCategories.categories) {
      if (category.apps
          .any((app) => appTitle.toLowerCase().contains(app.toLowerCase()))) {
        return category.name;
      }
    }
    return "Uncategorized";
  }

  String _getLocalizedAppName(String appName) {
    if (_localizations == null) return appName;

    try {
      switch (appName) {
        case "Microsoft Word":
          return _localizations!.appMicrosoftWord;
        case "Excel":
          return _localizations!.appExcel;
        case "PowerPoint":
          return _localizations!.appPowerPoint;
        case "Google Docs":
          return _localizations!.appGoogleDocs;
        case "Notion":
          return _localizations!.appNotion;
        case "Evernote":
          return _localizations!.appEvernote;
        case "Trello":
          return _localizations!.appTrello;
        case "Asana":
          return _localizations!.appAsana;
        case "Slack":
          return _localizations!.appSlack;
        case "Microsoft Teams":
          return _localizations!.appMicrosoftTeams;
        case "Zoom":
          return _localizations!.appZoom;
        case "Google Calendar":
          return _localizations!.appGoogleCalendar;
        case "Apple Calendar":
          return _localizations!.appAppleCalendar;
        case "Visual Studio Code":
          return _localizations!.appVisualStudioCode;
        case "Terminal":
          return _localizations!.appTerminal;
        case "Command Prompt":
          return _localizations!.appCommandPrompt;
        case "Chrome":
          return _localizations!.appChrome;
        case "Firefox":
          return _localizations!.appFirefox;
        case "Safari":
          return _localizations!.appSafari;
        case "Edge":
          return _localizations!.appEdge;
        case "Opera":
          return _localizations!.appOpera;
        case "Brave":
          return _localizations!.appBrave;
        case "Netflix":
          return _localizations!.appNetflix;
        case "YouTube":
          return _localizations!.appYouTube;
        case "Spotify":
          return _localizations!.appSpotify;
        case "Apple Music":
          return _localizations!.appAppleMusic;
        case "Calculator":
          return _localizations!.appCalculator;
        case "Notes":
          return _localizations!.appNotes;
        case "System Preferences":
          return _localizations!.appSystemPreferences;
        case "Task Manager":
          return _localizations!.appTaskManager;
        case "File Explorer":
          return _localizations!.appFileExplorer;
        case "Dropbox":
          return _localizations!.appDropbox;
        case "Google Drive":
          return _localizations!.appGoogleDrive;
        default:
          return appName;
      }
    } catch (e) {
      debugPrint('⚠️ Translation not found: $appName');
      return appName;
    }
  }

  // ============================================================
  // SETTINGS UPDATE METHODS
  // ============================================================

  Future<void> updateIdleDetection(bool enabled) async {
    SettingsManager().updateSetting("tracking.idleDetection", enabled);

    if (!enabled) {
      _isUserActive = true;
    }

    debugPrint('🔄 Idle detection ${enabled ? "enabled" : "disabled"}');
  }

  Future<void> updateIdleTimeout(int seconds) async {
    SettingsManager().updateSetting("tracking.idleTimeout", seconds);

    if (_windowFocusPlugin != null) {
      await _windowFocusPlugin!
          .setIdleThreshold(duration: Duration(seconds: seconds));
    }

    debugPrint('🔄 Idle timeout: ${seconds}s');
  }

  Future<void> updateAudioMonitoring(bool enabled) async {
    SettingsManager().updateSetting("tracking.monitorAudio", enabled);

    if (_windowFocusPlugin != null) {
      await _windowFocusPlugin!.setAudioMonitoring(enabled);
    }

    debugPrint('🔄 Audio monitoring ${enabled ? "enabled" : "disabled"}');
  }

  Future<void> updateControllerMonitoring(bool enabled) async {
    SettingsManager().updateSetting("tracking.monitorControllers", enabled);

    if (_windowFocusPlugin != null) {
      await _windowFocusPlugin!.setControllerMonitoring(enabled);
    }

    debugPrint('🔄 Controller monitoring ${enabled ? "enabled" : "disabled"}');
  }

  Future<void> updateHIDMonitoring(bool enabled) async {
    SettingsManager().updateSetting("tracking.monitorHIDDevices", enabled);

    if (_windowFocusPlugin != null) {
      await _windowFocusPlugin!.setHIDMonitoring(enabled);
    }

    debugPrint('🔄 HID monitoring ${enabled ? "enabled" : "disabled"}');
  }

  Future<void> updateKeyboardMonitoring(bool enabled) async {
    SettingsManager().updateSetting("tracking.monitorKeyboard", enabled);

    if (_windowFocusPlugin != null) {
      await _windowFocusPlugin!.setKeyboardMonitoring(enabled);
    }

    debugPrint('🔄 Keyboard monitoring ${enabled ? "enabled" : "disabled"}');
  }

  Future<void> updateAudioThreshold(double threshold) async {
    SettingsManager().updateSetting("tracking.audioThreshold", threshold);

    if (_windowFocusPlugin != null) {
      await _windowFocusPlugin!.setAudioThreshold(threshold);
    }

    debugPrint('🔄 Audio threshold: $threshold');
  }

  // ============================================================
  // PERMISSIONS
  // ============================================================

  Future<bool> checkInputMonitoringPermission() async {
    if (_windowFocusPlugin == null) return true;
    try {
      return await _windowFocusPlugin!.checkInputMonitoringPermission();
    } catch (e) {
      debugPrint('❌ Error checking input monitoring permission: $e');
      return false;
    }
  }

  Future<void> openInputMonitoringSettings() async {
    if (_windowFocusPlugin == null) return;
    try {
      await _windowFocusPlugin!.openInputMonitoringSettings();
    } catch (e) {
      debugPrint('❌ Error opening input monitoring settings: $e');
      rethrow;
    }
  }

  Future<PermissionStatus> checkAllPermissions() async {
    if (_windowFocusPlugin == null) {
      return PermissionStatus(screenRecording: true, inputMonitoring: true);
    }
    try {
      return await _windowFocusPlugin!.checkAllPermissions();
    } catch (e) {
      debugPrint('❌ Error checking permissions: $e');
      return PermissionStatus(screenRecording: false, inputMonitoring: false);
    }
  }

  // ============================================================
  // STOP & DISPOSE
  // ============================================================

  Future<void> stopTracking() async {
    debugPrint('═══════════════════════════════════════════════════════');
    debugPrint('🛑 STOPPING TRACKING');
    debugPrint('═══════════════════════════════════════════════════════');

    _isTracking = false;

    // Save any current app time in precise mode
    if (_trackingMode == TrackingMode.precise) {
      _saveCurrentAppTime();
    }

    await _stopCurrentMode();

    // Force commit any pending data to Hive
    if (_appDataStore != null) {
      await _appDataStore!.forceCommitToHive();
      debugPrint('💾 Forced commit to Hive before stopping');
    }

    if (_windowFocusPlugin != null) {
      _windowFocusPlugin!.dispose();
      _windowFocusPlugin = null;
      debugPrint('✅ WindowFocus plugin disposed');
    }

    _isUserActive = true;

    debugPrint('🛑 TRACKING FULLY STOPPED');
  }

  void dispose() {
    stopTracking();
    _appUpdateController.close();
    _appDataStore = null;
  }

  // ============================================================
  // DEBUG & INFO METHODS
  // ============================================================

  Map<String, dynamic> getTrackingInfo() {
    final baseInfo = {
      'trackingMode': _trackingMode.name,
      'isTracking': _isTracking,
      'currentApp': _currentApp,
      'isUserActive': _isUserActive,
      'currentAppElapsed':
          DateTime.now().difference(_currentAppStartTime).inSeconds,
      'metadataCacheSize': _metadataCache.length,
      'metadataCacheLoaded': _metadataCacheLoaded,
      'windowFocusPluginActive': _windowFocusPlugin != null,
      'pollingTimerActive': _pollingTimer != null,
    };

    // Add runtime cache stats if available
    if (_appDataStore != null) {
      final cacheStats = _appDataStore!.getRuntimeCacheStats();
      baseInfo.addAll({
        'runtimeCache': cacheStats,
      });
    }

    return baseInfo;
  }

  Map<String, AppMetadata> getMetadataCache() {
    return Map.unmodifiable(_metadataCache);
  }

  String getStatusSummary() {
    final info = getTrackingInfo();
    final cacheStats = info['runtimeCache'] as Map<String, dynamic>?;

    return '''
═══════════════════════════════════════════════════════
📊 BACKGROUND TRACKER STATUS
═══════════════════════════════════════════════════════
Mode: ${_trackingMode.name}
Is Tracking: $_isTracking
Is User Active: $_isUserActive
Current App: $_currentApp

WindowFocus: ${_windowFocusPlugin != null ? "Active" : "Inactive"}
Polling Timer: ${_pollingTimer != null ? "Active" : "Inactive"}

Metadata Cache: ${_metadataCache.length} apps

${cacheStats != null ? '''
Runtime Cache (AppDataStore):
  - Usage records: ${cacheStats['usageRecordsInCache']}
  - Focus sessions: ${cacheStats['focusSessionsInCache']}
  - Dirty usage: ${cacheStats['dirtyUsageRecords']}
  - Dirty focus: ${cacheStats['dirtyFocusSessions']}
  - Persistence: ${cacheStats['persistenceIntervalSeconds']}s
''' : ''}
═══════════════════════════════════════════════════════
''';
  }
}
