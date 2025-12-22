import 'dart:async';
import 'dart:ui' as ui;
import 'package:screentime/foreground_window_plugin.dart';
import 'package:screentime/sections/controller/notification_controller.dart';
import 'package:screentime/sections/controller/settings_data_controller.dart';
import 'package:screentime/l10n/app_localizations.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'app_data_controller.dart';
import 'categories_controller.dart';

class BackgroundAppTracker {
  // Singleton instance
  static final BackgroundAppTracker _instance = BackgroundAppTracker._internal();
  factory BackgroundAppTracker() => _instance;
  BackgroundAppTracker._internal();
  final NotificationController _notificationController = NotificationController();
  
  // Timer for periodic tracking
  Timer? _trackingTimer;
  bool _isTracking = false;
  
  // Store localization instance for background operations
  AppLocalizations? _localizations;
  String _currentLocale = 'en';

  // Initialize tracking with locale
  Future<void> initializeTracking({String? locale}) async {
    try {
      // Set locale from parameter or get from settings
      _currentLocale = locale ?? SettingsManager().getSetting("language.selected") ?? 'en';
      
      // Load localizations for the current locale
      await _loadLocalizations(_currentLocale);
      
      debugPrint('🌍 Background tracker initialized with locale: $_currentLocale');
      
      // Start periodic tracking
      _startPeriodicTracking();
    } catch (e) {
      debugPrint('Tracking initialization error: $e');
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

  // Start periodic tracking with Timer
  void _startPeriodicTracking() {
    if (_isTracking) return;
    
    _isTracking = true;
    // Track every minute
    _trackingTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _executeTracking(),
    );
    
    // Execute tracking immediately
    _executeTracking();
  }
  
  // Add a stream controller to broadcast updates
  final StreamController<String> _appUpdateController = StreamController<String>.broadcast();
  Stream<String> get appUpdates => _appUpdateController.stream;

  // Method to execute tracking
  Future<void> _executeTracking() async {
    try {
      // Initialize AppDataStore
      final appDataStore = AppDataStore();
      await appDataStore.init();

      // Get current active application
      final Map<String, dynamic>? currentAppInfo = await _getCurrentActiveApp();
      
      if (currentAppInfo == null) return;

      String appTitle = currentAppInfo['title'] ?? '';
      if(appTitle.contains("Windows Explorer")) appTitle = "";
      
      // Check if app tracking is enabled
      AppMetadata? metadata = appDataStore.getAppMetadata(appTitle);
      
      // If metadata doesn't exist, create with default tracking
      if (metadata == null && appTitle != "Productive ScreenTime" && appTitle != "screentime") {
        bool isProductive = true;
        String appCategory = 'Uncategorized';
        
        if(appTitle == '') {
          appCategory = 'Idle';
        } else {
          // Categorize app with locale awareness
          appCategory = _categorizeAppWithLocale(appTitle);
        }
        
        // Determine if app is productive based on category
        if(appCategory == "Social Media" || 
           appCategory == "Entertainment" || 
           appCategory == "Gaming" || 
           appCategory == "Uncategorized") {
          isProductive = false;
        }
        
        await appDataStore.updateAppMetadata(
          appTitle,
          category: appCategory,
          isProductive: isProductive,
        );
        
        metadata = appDataStore.getAppMetadata(appTitle);
      }

      // Only record usage if tracking is enabled and app is visible
      if (metadata != null && 
          metadata.isTracking && 
          metadata.isVisible && 
          appTitle != "Productive ScreenTime" && 
          appTitle != "screentime") {
        // Record app usage
        await appDataStore.recordAppUsage(
          appTitle, 
          DateTime.now(), 
          const Duration(minutes: 1), 
          1, 
          [TimeRange(
            startTime: DateTime.now().subtract(const Duration(minutes: 1)), 
            endTime: DateTime.now()
          )]
        );
      }
      
      _notificationController.checkAndSendNotifications();
      
      // Notify listeners about the update
      _appUpdateController.add(appTitle);
    } catch (e) {
      debugPrint('Tracking error: $e');
    }
  }
  
  // Categorize app with locale-aware matching
  String _categorizeAppWithLocale(String appTitle) {
    if (_localizations == null) {
      // Fallback to English-only if localizations aren't loaded
      return _categorizeAppEnglishOnly(appTitle);
    }
    
    // Check against English names first (most common)
    for (var category in AppCategories.categories) {
      if (category.apps.any((app) => appTitle.toLowerCase().contains(app.toLowerCase()))) {
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
      if (category.apps.any((app) => appTitle.toLowerCase().contains(app.toLowerCase()))) {
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
  
  // Close the controller when done
  void dispose() {
    stopTracking();
    _appUpdateController.close();
  }

  // Get current active app
  Future<Map<String, dynamic>?> _getCurrentActiveApp() async {
    try {
      // Use your ForegroundWindowPlugin
      WindowInfo info = await ForegroundWindowPlugin.getForegroundWindowInfo();
      
      return {
        'title': info.programName,
      };
    } catch (e) {
      debugPrint('Error getting current app: $e');
      return null;
    }
  }

  // Stop tracking
  Future<void> stopTracking() async {
    _isTracking = false;
    _trackingTimer?.cancel();
    _trackingTimer = null;
  }
  
  // Check if tracking is active
  bool isTracking() {
    return _isTracking;
  }
}