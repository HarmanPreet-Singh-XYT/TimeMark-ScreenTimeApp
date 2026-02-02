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

class BackgroundAppTracker {
  // Singleton instance
  static final BackgroundAppTracker _instance =
      BackgroundAppTracker._internal();
  factory BackgroundAppTracker() => _instance;
  BackgroundAppTracker._internal();

  final NotificationController _notificationController =
      NotificationController();

  // Window focus plugin for accurate tracking
  late WindowFocus _windowFocusPlugin;

  // Timer for periodic commits (every minute)
  Timer? _commitTimer;
  bool _isTracking = false;

  // Store localization instance for background operations
  AppLocalizations? _localizations;
  String _currentLocale = 'en';

  // In-memory tracking buffer
  final Map<String, int> _appUsageBuffer = {}; // appTitle -> seconds
  String _currentApp = '';
  DateTime _currentAppStartTime = DateTime.now();
  bool _isUserActive = true;

  // METADATA CACHE - Prevents constant DB reads
  final Map<String, AppMetadata> _metadataCache = {};
  bool _metadataCacheLoaded = false;

  // AppDataStore instance (reused, initialized once)
  AppDataStore? _appDataStore;

  // Stream controller to broadcast updates
  final StreamController<String> _appUpdateController =
      StreamController<String>.broadcast();
  Stream<String> get appUpdates => _appUpdateController.stream;

  // Initialize tracking with locale
  Future<void> initializeTracking({String? locale}) async {
    try {
      // Set locale from parameter or get from settings
      _currentLocale =
          locale ?? SettingsManager().getSetting("language.selected") ?? 'en';

      // Load localizations for the current locale
      await _loadLocalizations(_currentLocale);

      debugPrint(
          '🌍 Background tracker initialized with locale: $_currentLocale');

      // Initialize AppDataStore once
      await _initializeAppDataStore();

      // Load metadata cache from database
      await _loadMetadataCache();

      // Initialize window focus plugin
      await _initializeWindowFocusPlugin();

      // Start periodic commit (every minute)
      _startPeriodicCommit();

      _isTracking = true;

      debugPrint('✅ Background tracker fully initialized');
    } catch (e) {
      debugPrint('❌ Tracking initialization error: $e');
    }
  }

  // Initialize AppDataStore once and reuse
  Future<void> _initializeAppDataStore() async {
    if (_appDataStore == null) {
      _appDataStore = AppDataStore();
      await _appDataStore!.init();
      debugPrint('✅ AppDataStore initialized');
    }
  }

  // Load all metadata into cache to prevent repeated DB reads
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

  // Update metadata cache when settings change
  Future<void> updateMetadataInCache(
      String appTitle, AppMetadata metadata) async {
    _metadataCache[appTitle] = metadata;

    // Also update in database
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

  // Clear metadata cache (call when metadata changes externally)
  Future<void> refreshMetadataCache() async {
    _metadataCache.clear();
    _metadataCacheLoaded = false;
    await _loadMetadataCache();
    debugPrint('🔄 Metadata cache refreshed');
  }

  // Initialize window focus plugin with configurable settings
  Future<void> _initializeWindowFocusPlugin() async {
    // Get idle detection setting (default: enabled for backward compatibility)
    bool idleDetectionEnabled =
        SettingsManager().getSetting("tracking.idleDetection") ?? true;

    // Get idle timeout setting (default: 60 seconds)
    int idleTimeoutSeconds =
        SettingsManager().getSetting("tracking.idleTimeout") ?? 60;

    // Get advanced monitoring settings (default: disabled to save resources)
    bool monitorAudio =
        SettingsManager().getSetting("tracking.monitorAudio") ?? false;
    bool monitorControllers =
        SettingsManager().getSetting("tracking.monitorControllers") ?? false;
    bool monitorHIDDevices =
        SettingsManager().getSetting("tracking.monitorHIDDevices") ?? false;
    double audioThreshold =
        SettingsManager().getSetting("tracking.audioThreshold") ?? 0.001;

    debugPrint('🔧 Initializing WindowFocus with settings:');
    debugPrint('   - Idle Detection: $idleDetectionEnabled');
    debugPrint('   - Idle Timeout: ${idleTimeoutSeconds}s');
    debugPrint('   - Monitor Audio: $monitorAudio');
    debugPrint('   - Monitor Controllers: $monitorControllers');
    debugPrint('   - Monitor HID: $monitorHIDDevices');

    _windowFocusPlugin = WindowFocus(
      debug: false, // Set to true for debugging
      duration: Duration(seconds: idleTimeoutSeconds),
      monitorAudio: monitorAudio,
      monitorControllers: monitorControllers,
      monitorHIDDevices: monitorHIDDevices,
      audioThreshold: audioThreshold,
    );

    // Listen to window focus changes for accurate tracking
    _windowFocusPlugin.addFocusChangeListener(_handleFocusChange);

    // Listen to user activity changes (idle detection)
    if (idleDetectionEnabled) {
      _windowFocusPlugin.addUserActiveListener(_handleUserActivityChange);
    }

    debugPrint('✅ WindowFocus plugin initialized');
  }

  // Handle focus change (when user switches apps)
  void _handleFocusChange(AppWindowDto window) async {
    // Get the actual app title using ForegroundWindowPlugin
    String newApp = await _getCurrentActiveApp();

    // Ignore our own app
    if (newApp == "Productive ScreenTime" || newApp == "screentime") {
      return;
    }

    // Handle Windows Explorer as empty (idle)
    // if (newApp.contains("Windows Explorer")) {
    //   newApp = "";
    // }

    // If app changed, save the current app's time
    if (newApp != _currentApp) {
      _saveCurrentAppTime();

      // Update current app
      _currentApp = newApp;
      _currentAppStartTime = DateTime.now();

      debugPrint('📱 App changed to: $newApp');

      // 🔧 FIX: Eagerly create metadata for new apps
      _ensureMetadataExists(newApp);

      // Notify listeners
      _appUpdateController.add(_currentApp);
    }
  }

  // Get current active app using ForegroundWindowPlugin
  Future<String> _getCurrentActiveApp() async {
    try {
      WindowInfo info = await ForegroundWindowPlugin.getForegroundWindowInfo();
      return info.programName;
    } catch (e) {
      debugPrint('❌ Error getting current app: $e');
      return '';
    }
  }

  // 🆕 NEW METHOD: Ensure metadata exists immediately when app is detected
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

  // Handle user activity change (idle/active)
  void _handleUserActivityChange(bool isActive) {
    debugPrint('👤 User activity changed: ${isActive ? "ACTIVE" : "IDLE"}');

    // If transitioning from active to idle, save current app time
    if (!isActive && _isUserActive) {
      _saveCurrentAppTime();
    }

    // If transitioning from idle to active, restart timer
    if (isActive && !_isUserActive) {
      _currentAppStartTime = DateTime.now();
    }

    _isUserActive = isActive;
  }

  // Save current app's accumulated time to buffer
  void _saveCurrentAppTime() {
    // Only save if user is/was active and we have a valid app
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

  // Start periodic commit timer (runs every minute)
  void _startPeriodicCommit() {
    _commitTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _commitBufferedData(),
    );

    debugPrint('⏰ Periodic commit started (every 1 minute)');
  }

  // Commit buffered data to database (OPTIMIZED with concurrent writes)
  Future<void> _commitBufferedData() async {
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

      // OPTIMIZATION: Prepare all records first (without DB writes)
      final recordsToCommit = <Future<bool>>[];

      for (var entry in _appUsageBuffer.entries) {
        String appTitle = entry.key;
        int seconds = entry.value;

        // Skip if no time accumulated
        if (seconds <= 0) continue;

        // Get or create metadata (from cache, fast!)
        AppMetadata? metadata = await _getOrCreateMetadata(appTitle);

        // Only prepare if tracking is enabled and app is visible
        if (metadata != null && metadata.isTracking && metadata.isVisible) {
          final now = DateTime.now();
          final startTime = now.subtract(Duration(seconds: seconds));

          // Add to batch (don't await yet)
          recordsToCommit.add(_appDataStore!.recordAppUsage(
              appTitle,
              now,
              Duration(seconds: seconds),
              1,
              [TimeRange(startTime: startTime, endTime: now)]));
        } else {
          skippedCount++;
          debugPrint('⏭️ Skipped: $appTitle (tracking disabled or hidden)');
        }
      }

      // OPTIMIZATION: Execute all writes concurrently
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

      // Check notifications
      _notificationController.checkAndSendNotifications();
    } catch (e) {
      debugPrint('❌ Commit error: $e');
      // Don't clear buffer on error - will retry next minute
    }
  }

  // Load localizations without BuildContext
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

  // Update locale when user changes language
  Future<void> updateLocale(String locale) async {
    _currentLocale = locale;
    await _loadLocalizations(locale);
    debugPrint('🌍 Background tracker locale updated to: $_currentLocale');
  }

  // Categorize app with locale-aware matching
  String _categorizeAppWithLocale(String appTitle) {
    if (_localizations == null) {
      // Fallback to English-only if localizations aren't loaded
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

  // Fallback categorization (English only)
  String _categorizeAppEnglishOnly(String appTitle) {
    for (var category in AppCategories.categories) {
      if (category.apps
          .any((app) => appTitle.toLowerCase().contains(app.toLowerCase()))) {
        return category.name;
      }
    }
    return "Uncategorized";
  }

  // Get localized app name using the loaded localizations
  String _getLocalizedAppName(String appName) {
    if (_localizations == null) return appName;

    // Use the localization system to get translated app names
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

  // Update tracking settings dynamically
  Future<void> updateIdleDetection(bool enabled) async {
    SettingsManager().updateSetting("tracking.idleDetection", enabled);

    // Reinitialize plugin if tracking is active
    if (_isTracking) {
      await _reinitializePlugin();
    }

    debugPrint('🔄 Idle detection ${enabled ? "enabled" : "disabled"}');
  }

  Future<void> updateIdleTimeout(int seconds) async {
    SettingsManager().updateSetting("tracking.idleTimeout", seconds);

    if (_isTracking) {
      await _windowFocusPlugin.setIdleThreshold(
          duration: Duration(seconds: seconds));
    }

    debugPrint('🔄 Idle timeout set to ${seconds}s');
  }

  Future<void> updateAudioMonitoring(bool enabled) async {
    SettingsManager().updateSetting("tracking.monitorAudio", enabled);

    if (_isTracking) {
      await _windowFocusPlugin.setAudioMonitoring(enabled);
    }

    debugPrint('🔄 Audio monitoring ${enabled ? "enabled" : "disabled"}');
  }

  Future<void> updateControllerMonitoring(bool enabled) async {
    SettingsManager().updateSetting("tracking.monitorControllers", enabled);

    if (_isTracking) {
      await _windowFocusPlugin.setControllerMonitoring(enabled);
    }

    debugPrint('🔄 Controller monitoring ${enabled ? "enabled" : "disabled"}');
  }

  Future<void> updateHIDMonitoring(bool enabled) async {
    SettingsManager().updateSetting("tracking.monitorHIDDevices", enabled);

    if (_isTracking) {
      await _windowFocusPlugin.setHIDMonitoring(enabled);
    }

    debugPrint('🔄 HID monitoring ${enabled ? "enabled" : "disabled"}');
  }

  Future<void> updateAudioThreshold(double threshold) async {
    SettingsManager().updateSetting("tracking.audioThreshold", threshold);

    if (_isTracking) {
      await _windowFocusPlugin.setAudioThreshold(threshold);
    }

    debugPrint('🔄 Audio threshold set to $threshold');
  }

  // Reinitialize plugin (used when settings change)
  Future<void> _reinitializePlugin() async {
    _windowFocusPlugin.dispose();
    await _initializeWindowFocusPlugin();
  }

  // Stop tracking
  Future<void> stopTracking() async {
    _isTracking = false;

    // Save any remaining buffered data before stopping
    await _commitBufferedData();

    _commitTimer?.cancel();
    _commitTimer = null;

    _windowFocusPlugin.dispose();

    debugPrint('🛑 Tracking stopped');
  }

  // Close the controller when done
  void dispose() {
    stopTracking();
    _appUpdateController.close();
  }

  // Check if tracking is active
  bool isTracking() {
    return _isTracking;
  }

  // Get current buffer state (for debugging/UI)
  Map<String, int> getBufferState() {
    return Map.unmodifiable(_appUsageBuffer);
  }

  // Get current tracking info (for debugging/UI)
  Map<String, dynamic> getTrackingInfo() {
    return {
      'currentApp': _currentApp,
      'isUserActive': _isUserActive,
      'bufferSize': _appUsageBuffer.length,
      'currentAppElapsed':
          DateTime.now().difference(_currentAppStartTime).inSeconds,
      'metadataCacheSize': _metadataCache.length,
      'metadataCacheLoaded': _metadataCacheLoaded,
    };
  }

  // Get metadata cache (for debugging)
  Map<String, AppMetadata> getMetadataCache() {
    return Map.unmodifiable(_metadataCache);
  }
}
