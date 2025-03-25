import 'dart:async';
import 'package:ProductiveScreenTime/foreground_window_plugin.dart';
import 'package:ProductiveScreenTime/sections/controller/notification_controller.dart';
import 'app_data_controller.dart';
import 'categories_controller.dart';

class BackgroundAppTracker {
  // Singleton instance
  static final BackgroundAppTracker _instance = BackgroundAppTracker._internal();
  factory BackgroundAppTracker() => _instance;
  BackgroundAppTracker._internal();
  final NotificationController _notificationController = NotificationController();
  // Platform channel for native app tracking
  
  // Timer for periodic tracking
  Timer? _trackingTimer;
  bool _isTracking = false;

  // Initialize tracking
  Future<void> initializeTracking() async {
    try {
      // Request necessary permissions
      // await _requestTrackingPermissions();

      // Start periodic tracking
      _startPeriodicTracking();
    } catch (e) {
      print('Tracking initialization error: $e');
    }
  }

  // Request system permissions for tracking
  // Future<void> _requestTrackingPermissions() async {
  //   try {
  //     if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
  //       // Use platform-specific method to request app usage tracking permissions
  //       final bool? permissionGranted = await _platformChannel.invokeMethod('requestAppUsagePermission');
        
  //       if (permissionGranted != true) {
  //         throw Exception('App usage tracking permissions not granted');
  //       }
  //     }
  //   } catch (e) {
  //     print('Permission request error: $e');
  //   }
  // }

  // Start periodic tracking with Timer
  void _startPeriodicTracking() {
    if (_isTracking) return;
    
    _isTracking = true;
    // Track every 15 minutes
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

      // final String appTitle = currentAppInfo['title'] ?? 'Unknown';

      String extractLastPartOfTitle(Map<String, dynamic>? appInfo) {
        if (appInfo != null && appInfo.containsKey('title')) {
          String title = appInfo['title'];
          if (title.contains('-')) {
            List<String> parts = title.split('-');
            return parts.last.trim(); // Return the last part and remove any extra whitespace
          }
          return title; // Return the original title if no hyphen is found
        }
        return 'Unknown'; // Return empty string if title doesn't exist or appInfo is null
      }

      // Usage
      String appTitle = extractLastPartOfTitle(currentAppInfo);
      
      // Check if app tracking is enabled
      AppMetadata? metadata = appDataStore.getAppMetadata(appTitle);
      
      // If metadata doesn't exist, create with default tracking
      if (metadata == null && appTitle!="Productive ScreenTime" && appTitle!="screentime") {
        bool isProductive = true;
        String appCategory = 'Uncategorized';
        if(appTitle == '') {
          appCategory = 'Idle';
        }else{
          appCategory = AppCategories.categorizeApp(appTitle);
        }
        if(appCategory == "Social Media" || appCategory == "Entertainment" || appCategory == "Gaming" || appCategory == "Uncategorized") isProductive = false;
        await appDataStore.updateAppMetadata(
          appTitle,
          category: appCategory,
          isProductive: isProductive,
        );
        
        metadata = appDataStore.getAppMetadata(appTitle);
      }

      // Only record usage if tracking is enabled and app is visible
      if (metadata != null && metadata.isTracking && metadata.isVisible && appTitle!="Productive ScreenTime" && appTitle!="screentime") {
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
      print('Tracking error: $e');
    }
  }
  // close the controller when done
  // void dispose() {
  //   stopTracking();
  //   _appUpdateController.close();
  // }

  // Get current active app
  Future<Map<String, dynamic>?> _getCurrentActiveApp() async {
    try {
      // Use your ForegroundWindowPlugin
      WindowInfo info = await ForegroundWindowPlugin.getForegroundWindowInfo();
      // print(info);
      
      return {
        'title': info.windowTitle ?? 'Unknown',
        // 'processName': info.processName ?? 'Unknown',
        // 'processID': info.processId ?? 'Unknown',
      };
    } catch (e) {
      print('Error getting current app: $e');
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