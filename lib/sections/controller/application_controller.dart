// background_app_tracker.dart
import 'dart:async';
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
  bool _isUserActive = true; // Updated by activity listener
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
  Timer? _commitTimer;
  final Map<String, int> _appUsageBuffer = {}; // appTitle -> seconds
  String _currentApp = '';
  DateTime _currentAppStartTime = DateTime.now();

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
  // INITIALIZATION
  // ============================================================
  Future<void> initializeTracking({String? locale}) async {
    try {
      // Set locale from parameter or get from settings
      _currentLocale =
          locale ?? SettingsManager().getSetting("language.selected") ?? 'en';
      await _loadLocalizations(_currentLocale);

      // Get tracking mode from settings (default to polling for backward compatibility)
      String modeString =
          SettingsManager().getSetting("tracking.mode") ?? 'polling';
      _trackingMode =
          modeString == 'precise' ? TrackingMode.precise : TrackingMode.polling;

      debugPrint('═══════════════════════════════════════════════════════');
      debugPrint('🚀 INITIALIZING BACKGROUND APP TRACKER');
      debugPrint('═══════════════════════════════════════════════════════');
      debugPrint('🌍 Locale: $_currentLocale');
      debugPrint('📊 Tracking mode from settings: "$modeString"');
      debugPrint('📊 Resolved tracking mode: ${_trackingMode.name}');

      // Initialize AppDataStore (shared by both modes)
      await _initializeAppDataStore();

      // Load metadata cache early (shared by both modes)
      await _loadMetadataCache();

      // Initialize WindowFocus plugin (monitoring settings are respected regardless of mode)
      await _initializeWindowFocusPlugin();

      // Start tracking based on mode
      if (_trackingMode == TrackingMode.polling) {
        debugPrint(
            '🔄 Starting in POLLING mode (lightweight, 1-min intervals)');
        await _startPollingMode();
      } else {
        debugPrint(
            '🔄 Starting in PRECISE mode (event-based, resource-intensive)');
        await _startPreciseMode();
      }

      _isTracking = true;

      debugPrint('═══════════════════════════════════════════════════════');
      debugPrint('✅ BACKGROUND TRACKER INITIALIZED SUCCESSFULLY');
      debugPrint('   Mode: ${_trackingMode.name}');
      debugPrint(
          '   Idle Detection: ${_windowFocusPlugin != null ? "Active" : "Inactive"}');
      debugPrint('   Metadata Cache: ${_metadataCache.length} apps loaded');
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
      debugPrint('✅ AppDataStore initialized');
    }
  }

  // ============================================================
  // METADATA CACHE LOADING (Shared by both modes)
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
  // ALL monitoring settings are respected regardless of mode
  // ============================================================
  Future<void> _initializeWindowFocusPlugin() async {
    // Get idle detection setting (default: enabled)
    bool idleDetectionEnabled =
        SettingsManager().getSetting("tracking.idleDetection") ?? true;

    // Get idle timeout setting (default: 60 seconds)
    int idleTimeoutSeconds =
        SettingsManager().getSetting("tracking.idleTimeout") ?? 60;

    // Get advanced monitoring settings (user controls these, mode doesn't override)
    bool monitorAudio =
        SettingsManager().getSetting("tracking.monitorAudio") ?? false;
    bool monitorControllers =
        SettingsManager().getSetting("tracking.monitorControllers") ?? false;
    bool monitorHIDDevices =
        SettingsManager().getSetting("tracking.monitorHIDDevices") ?? false;
    double audioThreshold =
        SettingsManager().getSetting("tracking.audioThreshold") ?? 0.001;

    debugPrint('🔧 Initializing WindowFocus plugin:');
    debugPrint('   - Tracking Mode: ${_trackingMode.name}');
    debugPrint('   - Idle Detection: $idleDetectionEnabled');
    debugPrint('   - Idle Timeout: ${idleTimeoutSeconds}s');
    debugPrint('   - Monitor Audio: $monitorAudio');
    debugPrint('   - Monitor Controllers: $monitorControllers');
    debugPrint('   - Monitor HID Devices: $monitorHIDDevices');
    debugPrint('   - Audio Threshold: $audioThreshold');

    // Create WindowFocus plugin with ALL user settings respected
    _windowFocusPlugin = WindowFocus(
      debug: false,
      duration: Duration(seconds: idleTimeoutSeconds),
      monitorAudio: monitorAudio,
      monitorControllers: monitorControllers,
      monitorHIDDevices: monitorHIDDevices,
      audioThreshold: audioThreshold,
    );

    // Add focus change listener (always active, mode determines what happens with events)
    _windowFocusPlugin!.addFocusChangeListener(_handleFocusChange);
    debugPrint('✅ Focus change listener added');

    // Add user activity listener for idle detection
    if (idleDetectionEnabled) {
      _windowFocusPlugin!.addUserActiveListener(_handleUserActivityChange);
      debugPrint('✅ User activity listener added');
    } else {
      _isUserActive = true; // Assume always active if idle detection disabled
      debugPrint('⚠️ Idle detection disabled - user assumed always active');
    }

    debugPrint('✅ WindowFocus plugin initialized');
  }

  // ============================================================
  // MODE SWITCHING
  // ============================================================
  Future<void> setTrackingMode(TrackingMode mode) async {
    if (_trackingMode == mode) {
      debugPrint('ℹ️ Already in ${mode.name} mode, no change needed');
      return;
    }

    debugPrint('═══════════════════════════════════════════════════════');
    debugPrint('🔄 SWITCHING TRACKING MODE');
    debugPrint('   From: ${_trackingMode.name}');
    debugPrint('   To: ${mode.name}');
    debugPrint('═══════════════════════════════════════════════════════');

    // Stop current mode-specific components
    await _stopCurrentMode();

    // Update mode
    _trackingMode = mode;
    SettingsManager().updateSetting("tracking.mode", mode.name);

    // NOTE: We do NOT change any monitoring settings
    // User preferences are respected regardless of mode

    // Start new mode
    if (mode == TrackingMode.polling) {
      await _startPollingMode();
    } else {
      await _startPreciseMode();
    }

    debugPrint('═══════════════════════════════════════════════════════');
    debugPrint('✅ TRACKING MODE CHANGED TO: ${mode.name}');
    debugPrint('   Monitoring settings unchanged (user preferences respected)');
    debugPrint('═══════════════════════════════════════════════════════');
  }

  // ============================================================
  // STOP CURRENT MODE
  // ============================================================
  Future<void> _stopCurrentMode() async {
    if (_trackingMode == TrackingMode.polling) {
      // ============ STOP POLLING MODE ============
      _pollingTimer?.cancel();
      _pollingTimer = null;
      debugPrint('🛑 Polling timer stopped');
    } else {
      // ============ STOP PRECISE MODE ============

      // 1. Commit any remaining buffered data
      await _commitBufferedData();

      // 2. Cancel commit timer
      _commitTimer?.cancel();
      _commitTimer = null;
      debugPrint('🛑 Commit timer stopped');

      // 3. Clear ONLY buffer state (keep metadata cache!)
      _appUsageBuffer.clear();
      _currentApp = '';
      _currentAppStartTime = DateTime.now();

      debugPrint('🛑 Precise mode buffer cleared (metadata cache preserved)');
    }

    // Note: WindowFocus plugin stays active with ALL user settings intact
  }

  // ============================================================
  // POLLING MODE (LIGHTWEIGHT)
  // ============================================================
  Future<void> _startPollingMode() async {
    debugPrint('🔄 Starting polling mode (1-minute intervals)');

    _pollingTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _executePollingTracking(),
    );

    // Execute immediately on start
    _executePollingTracking();

    debugPrint('✅ Polling timer started');
  }

  Future<void> _executePollingTracking() async {
    try {
      // CHECK: Skip if user is idle (only if idle detection is enabled)
      bool idleDetectionEnabled =
          SettingsManager().getSetting("tracking.idleDetection") ?? true;

      if (idleDetectionEnabled && !_isUserActive) {
        debugPrint('⏸️ Polling skipped: user is idle');
        return;
      }

      // Get current foreground app
      final Map<String, dynamic>? currentAppInfo =
          await _getCurrentActiveAppInfo();
      if (currentAppInfo == null) {
        debugPrint('⚠️ Could not get current app info');
        return;
      }

      String appTitle = currentAppInfo['title'] ?? '';

      // Handle Windows Explorer as idle
      if (appTitle.contains("Windows Explorer")) {
        appTitle = "";
      }

      // Skip our own app
      if (appTitle == "Productive ScreenTime" || appTitle == "screentime") {
        debugPrint('⏭️ Skipping own app');
        return;
      }

      // Skip login window
      if (appTitle == "loginwindow") {
        debugPrint('⏭️ Skipping login window');
        return;
      }

      // Get or create metadata for the app (using shared cache)
      AppMetadata? metadata = await _getOrCreateMetadata(appTitle);

      // Record usage if tracking is enabled for this app
      if (metadata != null && metadata.isTracking && metadata.isVisible) {
        final now = DateTime.now();
        final startTime = now.subtract(const Duration(minutes: 1));

        await _appDataStore?.recordAppUsage(
          appTitle,
          now,
          const Duration(minutes: 1),
          1,
          [TimeRange(startTime: startTime, endTime: now)],
        );

        debugPrint('📊 Polling recorded: $appTitle (1 min)');
      } else if (metadata != null) {
        debugPrint(
            '⏭️ Skipped: $appTitle (tracking: ${metadata.isTracking}, visible: ${metadata.isVisible})');
      }

      // Check and send notifications
      _notificationController.checkAndSendNotifications();

      // Notify listeners of current app
      _appUpdateController.add(appTitle);
    } catch (e) {
      debugPrint('❌ Polling tracking error: $e');
    }
  }

  // ============================================================
  // PRECISE MODE (RESOURCE-INTENSIVE)
  // ============================================================
  Future<void> _startPreciseMode() async {
    debugPrint('🔄 Starting precise mode (event-based tracking)');

    // Metadata cache is already loaded during initialization
    if (!_metadataCacheLoaded) {
      debugPrint('⚠️ Metadata cache not loaded, loading now...');
      await _loadMetadataCache();
    }

    // Start periodic commit timer (commits buffered data every minute)
    _startPeriodicCommit();

    debugPrint('✅ Precise mode started');
  }

  // Start periodic commit timer (runs every minute)
  void _startPeriodicCommit() {
    _commitTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _commitBufferedData(),
    );
    debugPrint('⏰ Periodic commit timer started (every 1 minute)');
  }

  // ============================================================
  // FOCUS CHANGE HANDLER
  // Processes events based on current mode
  // ============================================================
  void _handleFocusChange(AppWindowDto window) async {
    // In POLLING mode: ignore focus events (polling handles tracking)
    if (_trackingMode == TrackingMode.polling) {
      return;
    }

    // In PRECISE mode: process focus events for accurate tracking
    // Get the actual app title using ForegroundWindowPlugin
    String newApp = await _getCurrentActiveApp();

    // Ignore our own app
    if (newApp == "Productive ScreenTime" || newApp == "screentime") {
      return;
    }

    // Ignore login window
    if (newApp == "loginwindow") {
      return;
    }

    // If app changed, save the current app's time
    if (newApp != _currentApp) {
      _saveCurrentAppTime();

      // Update current app
      _currentApp = newApp;
      _currentAppStartTime = DateTime.now();

      debugPrint('📱 App changed to: $newApp');

      // Eagerly create metadata for new apps
      _ensureMetadataExists(newApp);

      // Notify listeners
      _appUpdateController.add(_currentApp);
    }
  }

  // ============================================================
  // USER ACTIVITY CHANGE HANDLER
  // Used by BOTH modes for idle detection
  // ============================================================
  void _handleUserActivityChange(bool isActive) {
    debugPrint('👤 User activity changed: ${isActive ? "ACTIVE" : "IDLE"}');

    // Handle state changes for precise mode buffering
    if (_trackingMode == TrackingMode.precise) {
      // If transitioning from active to idle, save current app time
      if (!isActive && _isUserActive) {
        _saveCurrentAppTime();
      }

      // If transitioning from idle to active, restart timer
      if (isActive && !_isUserActive) {
        _currentAppStartTime = DateTime.now();
      }
    }

    // Update the flag (used by both modes to check idle state)
    _isUserActive = isActive;
  }

  // ============================================================
  // PRECISE MODE: SAVE CURRENT APP TIME
  // ============================================================
  void _saveCurrentAppTime() {
    // Only relevant in precise mode
    if (_trackingMode != TrackingMode.precise) return;

    // Check if idle detection is enabled
    bool idleDetectionEnabled =
        SettingsManager().getSetting("tracking.idleDetection") ?? true;

    // Skip if idle detection is enabled and user is idle
    if (idleDetectionEnabled && !_isUserActive) {
      debugPrint('⏸️ Skipping save: user is idle');
      return;
    }

    if (_currentApp.isEmpty) {
      return;
    }

    // Calculate elapsed time
    final elapsed = DateTime.now().difference(_currentAppStartTime);
    final elapsedSeconds = elapsed.inSeconds;

    if (elapsedSeconds <= 0) {
      return;
    }

    // Add to buffer
    _appUsageBuffer[_currentApp] =
        (_appUsageBuffer[_currentApp] ?? 0) + elapsedSeconds;

    debugPrint(
        '💾 Buffered: $_currentApp += ${elapsedSeconds}s (total: ${_appUsageBuffer[_currentApp]}s)');
  }

  // ============================================================
  // PRECISE MODE: COMMIT BUFFERED DATA
  // ============================================================
  Future<void> _commitBufferedData() async {
    // Only relevant in precise mode
    if (_trackingMode != TrackingMode.precise) return;

    try {
      // First, save the current app's time to buffer
      _saveCurrentAppTime();

      // If buffer is empty, nothing to commit
      if (_appUsageBuffer.isEmpty) {
        debugPrint('📊 Nothing to commit (buffer empty)');
        return;
      }

      debugPrint('💿 Committing buffered data to database...');
      debugPrint('   Buffer size: ${_appUsageBuffer.length} apps');

      // Ensure AppDataStore is initialized
      if (_appDataStore == null) {
        await _initializeAppDataStore();
      }

      int committedCount = 0;
      int skippedCount = 0;

      // Prepare all records for concurrent writes
      final recordsToCommit = <Future<bool>>[];

      for (var entry in _appUsageBuffer.entries) {
        String appTitle = entry.key;
        int seconds = entry.value;

        // Skip if no time accumulated
        if (seconds <= 0) continue;

        // Get or create metadata (from cache, fast!)
        AppMetadata? metadata = await _getOrCreateMetadata(appTitle);

        // Only commit if tracking is enabled and app is visible
        if (metadata != null && metadata.isTracking && metadata.isVisible) {
          final now = DateTime.now();
          final startTime = now.subtract(Duration(seconds: seconds));

          // Add to batch (don't await yet)
          recordsToCommit.add(_appDataStore!.recordAppUsage(
            appTitle,
            now,
            Duration(seconds: seconds),
            1,
            [TimeRange(startTime: startTime, endTime: now)],
          ));
        } else {
          skippedCount++;
          debugPrint('⏭️ Skipped: $appTitle (tracking disabled or hidden)');
        }
      }

      // Execute all writes concurrently for better performance
      if (recordsToCommit.isNotEmpty) {
        final stopwatch = Stopwatch()..start();

        final results = await Future.wait(recordsToCommit);

        stopwatch.stop();

        // Count successes
        committedCount = results.where((success) => success).length;

        debugPrint(
            '✅ Batch committed: $committedCount/${recordsToCommit.length} records in ${stopwatch.elapsedMilliseconds}ms');
      }

      debugPrint(
          '📊 Commit summary: $committedCount saved, $skippedCount skipped');

      // Clear buffer after successful commit
      _appUsageBuffer.clear();
      debugPrint('🧹 Buffer cleared');

      // Restart timer for current app
      _currentAppStartTime = DateTime.now();

      // Check and send notifications
      _notificationController.checkAndSendNotifications();
    } catch (e) {
      debugPrint('❌ Commit error: $e');
      // Don't clear buffer on error - will retry next minute
    }
  }

  // ============================================================
  // METADATA MANAGEMENT (Shared by both modes)
  // ============================================================

  // Get metadata from cache (fast) or create new (with cache update)
  Future<AppMetadata?> _getOrCreateMetadata(String appTitle) async {
    // Return from cache if exists
    if (_metadataCache.containsKey(appTitle)) {
      return _metadataCache[appTitle];
    }

    // Check if it's our own app
    if (appTitle == "Productive ScreenTime" || appTitle == "screentime") {
      return null;
    }

    // Create new metadata
    bool isProductive = true;
    String appCategory = 'Uncategorized';

    if (appTitle.isEmpty) {
      appCategory = 'Idle';
    } else {
      // Categorize app with locale awareness
      appCategory = _categorizeAppWithLocale(appTitle);
    }

    // Determine if app is productive based on category
    if (appCategory == "Social Media" ||
        appCategory == "Entertainment" ||
        appCategory == "Gaming" ||
        appCategory == "Uncategorized") {
      isProductive = false;
    }

    // Create metadata in database
    if (_appDataStore != null) {
      await _appDataStore!.updateAppMetadata(
        appTitle,
        category: appCategory,
        isProductive: isProductive,
      );

      // Fetch and cache the newly created metadata
      final newMetadata = _appDataStore!.getAppMetadata(appTitle);
      if (newMetadata != null) {
        _metadataCache[appTitle] = newMetadata;
        debugPrint('✨ Created and cached metadata for: $appTitle');
        return newMetadata;
      }
    }

    return null;
  }

  // Ensure metadata exists immediately when app is detected
  void _ensureMetadataExists(String appTitle) {
    // Don't block the UI thread, run asynchronously
    _getOrCreateMetadata(appTitle).then((metadata) {
      if (metadata != null) {
        debugPrint('✅ Metadata ready for: $appTitle');
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
      debugPrint('✅ Localizations loaded for: $localeCode');
    } catch (e) {
      debugPrint('❌ Failed to load localizations for $localeCode: $e');
      // Fallback to English
      final fallbackLocale = const ui.Locale('en');
      _localizations = await AppLocalizations.delegate.load(fallbackLocale);
    }
  }

  Future<void> updateLocale(String locale) async {
    _currentLocale = locale;
    await _loadLocalizations(locale);
    debugPrint('🌍 Background tracker locale updated to: $_currentLocale');
  }

  // ============================================================
  // APP CATEGORIZATION
  // ============================================================

  String _categorizeAppWithLocale(String appTitle) {
    if (_localizations == null) {
      return _categorizeAppEnglishOnly(appTitle);
    }

    // Check against English names first (most common)
    for (var category in AppCategories.categories) {
      if (category.apps
          .any((app) => appTitle.toLowerCase().contains(app.toLowerCase()))) {
        return category.name;
      }
    }

    // Check against localized names
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
      debugPrint('⚠️ Translation not found for: $appName');
      return appName;
    }
  }

  // ============================================================
  // SETTINGS UPDATE METHODS
  // These now NEVER disable monitoring based on mode
  // ============================================================

  Future<void> updateIdleDetection(bool enabled) async {
    SettingsManager().updateSetting("tracking.idleDetection", enabled);

    // If disabling, assume user is always active
    if (!enabled) {
      _isUserActive = true;
    }

    debugPrint('🔄 Idle detection ${enabled ? "enabled" : "disabled"}');
    debugPrint('   Note: Full effect requires app restart');
  }

  Future<void> updateIdleTimeout(int seconds) async {
    SettingsManager().updateSetting("tracking.idleTimeout", seconds);

    if (_windowFocusPlugin != null) {
      await _windowFocusPlugin!
          .setIdleThreshold(duration: Duration(seconds: seconds));
    }

    debugPrint('🔄 Idle timeout set to ${seconds}s');
  }

  Future<void> updateAudioMonitoring(bool enabled) async {
    SettingsManager().updateSetting("tracking.monitorAudio", enabled);

    if (_windowFocusPlugin != null) {
      await _windowFocusPlugin!.setAudioMonitoring(enabled);
    }

    debugPrint('🔄 Audio monitoring ${enabled ? "enabled" : "disabled"}');
    debugPrint('   Available in both polling and precise modes');
  }

  Future<void> updateControllerMonitoring(bool enabled) async {
    SettingsManager().updateSetting("tracking.monitorControllers", enabled);

    if (_windowFocusPlugin != null) {
      await _windowFocusPlugin!.setControllerMonitoring(enabled);
    }

    debugPrint('🔄 Controller monitoring ${enabled ? "enabled" : "disabled"}');
    debugPrint('   Available in both polling and precise modes');
  }

  Future<void> updateHIDMonitoring(bool enabled) async {
    SettingsManager().updateSetting("tracking.monitorHIDDevices", enabled);

    if (_windowFocusPlugin != null) {
      await _windowFocusPlugin!.setHIDMonitoring(enabled);
    }

    debugPrint('🔄 HID monitoring ${enabled ? "enabled" : "disabled"}');
    debugPrint('   Available in both polling and precise modes');
  }

  Future<void> updateAudioThreshold(double threshold) async {
    SettingsManager().updateSetting("tracking.audioThreshold", threshold);

    if (_windowFocusPlugin != null) {
      await _windowFocusPlugin!.setAudioThreshold(threshold);
    }

    debugPrint('🔄 Audio threshold set to $threshold');
    debugPrint('   Available in both polling and precise modes');
  }

  // ============================================================
  // PERMISSIONS (macOS specific)
  // ============================================================

  /// Checks if Input Monitoring permission is granted
  Future<bool> checkInputMonitoringPermission() async {
    if (_windowFocusPlugin == null) {
      return true;
    }
    try {
      return await _windowFocusPlugin!.checkInputMonitoringPermission();
    } catch (e) {
      debugPrint('❌ Error checking input monitoring permission: $e');
      return false;
    }
  }

  /// Opens macOS System Settings to the Input Monitoring section
  Future<void> openInputMonitoringSettings() async {
    if (_windowFocusPlugin == null) return;
    try {
      await _windowFocusPlugin!.openInputMonitoringSettings();
    } catch (e) {
      debugPrint('❌ Error opening input monitoring settings: $e');
      rethrow;
    }
  }

  /// Checks all required permissions (Screen Recording + Input Monitoring)
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

    // Stop current mode
    await _stopCurrentMode();

    // Dispose WindowFocus plugin
    if (_windowFocusPlugin != null) {
      _windowFocusPlugin!.dispose();
      _windowFocusPlugin = null;
      debugPrint('✅ WindowFocus plugin disposed');
    }

    // Reset state
    _isUserActive = true;

    debugPrint('═══════════════════════════════════════════════════════');
    debugPrint('🛑 TRACKING FULLY STOPPED');
    debugPrint('═══════════════════════════════════════════════════════');
  }

  void dispose() {
    stopTracking();
    _appUpdateController.close();
    _appDataStore = null;
  }

  // ============================================================
  // DEBUG & INFO METHODS
  // ============================================================

  /// Get current buffer state (for debugging/UI)
  Map<String, int> getBufferState() {
    return Map.unmodifiable(_appUsageBuffer);
  }

  /// Get current tracking info (for debugging/UI)
  Map<String, dynamic> getTrackingInfo() {
    return {
      'trackingMode': _trackingMode.name,
      'isTracking': _isTracking,
      'currentApp': _currentApp,
      'isUserActive': _isUserActive,
      'bufferSize': _appUsageBuffer.length,
      'currentAppElapsed':
          DateTime.now().difference(_currentAppStartTime).inSeconds,
      'metadataCacheSize': _metadataCache.length,
      'metadataCacheLoaded': _metadataCacheLoaded,
      'windowFocusPluginActive': _windowFocusPlugin != null,
      'pollingTimerActive': _pollingTimer != null,
      'commitTimerActive': _commitTimer != null,
    };
  }

  /// Get metadata cache (for debugging)
  Map<String, AppMetadata> getMetadataCache() {
    return Map.unmodifiable(_metadataCache);
  }

  /// Get a summary string for logging
  String getStatusSummary() {
    return '''
═══════════════════════════════════════════════════════
📊 BACKGROUND TRACKER STATUS
═══════════════════════════════════════════════════════
Mode: ${_trackingMode.name}
Is Tracking: $_isTracking
Is User Active: $_isUserActive
Current App: $_currentApp
Locale: $_currentLocale

WindowFocus Plugin: ${_windowFocusPlugin != null ? "Active" : "Inactive"}
Polling Timer: ${_pollingTimer != null ? "Active" : "Inactive"}
Commit Timer: ${_commitTimer != null ? "Active" : "Inactive"}

Buffer Size: ${_appUsageBuffer.length} apps
Metadata Cache: ${_metadataCache.length} apps (loaded: $_metadataCacheLoaded)
═══════════════════════════════════════════════════════
''';
  }
}
