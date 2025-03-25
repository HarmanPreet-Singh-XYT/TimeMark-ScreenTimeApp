import 'dart:async';
import 'package:flutter/material.dart';
import 'package:local_notifier/local_notifier.dart';
import 'package:productive_screentime/sections/controller/settings_data_controller.dart';

import 'data_controllers/alerts_limits_data_controller.dart';

class NotificationController with ChangeNotifier {
  // Singleton instance
  static final NotificationController _instance = NotificationController._internal();
  
  // Factory constructor to return the same instance
  factory NotificationController() {
    return _instance;
  }
  
  // Private constructor
  NotificationController._internal();
  
  // Reference to settings manager
  final _settingsManager = SettingsManager();
  final ScreenTimeDataController _screenTimeController = ScreenTimeDataController();
  
  // Reminder timer
  Timer? _reminderTimer;
  
  // Settings
  bool _soundEnabled = true;
  int _reminderFrequency = 60; // seconds between reminders if not acknowledged
  static const int autoDismissSeconds = 5;
  
  // Pending alerts tracking
  final Map<int, DateTime> _pendingAlerts = {}; // alertId -> time it was created
  
  // Callback for showing custom alerts
  Function(String title, String message, {Function? onClose, Function? onRemind})? _showAlertCallback;
  
  // Initialize controller
  Future<void> initialize() async {
    // Initialize local_notifier
    await localNotifier.setup(
      appName: 'TimeMark',
      shortcutPolicy: ShortcutPolicy.requireCreate,
    );
    
    // Ensure the notificationController section exists in settings
    _initializeSettings();
    
    // Load settings from SettingsManager
    _loadSettings();
  }
  
  // Initialize dedicated settings section if it doesn't exist
  void _initializeSettings() {
    // Check if our dedicated section exists
    var notificationSettings = _settingsManager.getSetting('notificationController');
    
    if (notificationSettings == null) {
      // Create our dedicated section with default values
      Map<String, dynamic> defaultSettings = {
        // "soundEnabled": true,
        "reminderFrequency": 60, // seconds
        // "useSystemNotifications": true,
        // "usePopupAlerts": true,
      };
      
      _settingsManager.updateSetting('notificationController', defaultSettings);
    }
  }
  
  // Load settings from SettingsManager
  void _loadSettings() {
    // Load from our dedicated section
    var notificationSettings = _settingsManager.getSetting('notifications');
    var frequency = _settingsManager.getSetting('notificationController.reminderFrequency');
    
    if (notificationSettings != null) {
      _soundEnabled = notificationSettings['sound'] ?? true;
      _reminderFrequency = frequency ?? 60;
    }
    
    notifyListeners();
  }
  
  // Method to register a custom alert handler for popup alerts
  void registerAlertHandler(
    Function(String title, String message, {Function? onClose, Function? onRemind}) showAlert
  ) {
    _showAlertCallback = showAlert;
  }
  
  // Settings configuration with persistence in dedicated section
  // void setSoundEnabled(bool enabled) {
  //   _soundEnabled = enabled;
  //   _settingsManager.updateSetting('notificationController.soundEnabled', enabled);
  //   notifyListeners();
  // }
  
  void setReminderFrequency(int seconds) {
    _reminderFrequency = seconds;
    _settingsManager.updateSetting('notificationController.reminderFrequency', seconds);
    notifyListeners();
  }
  
  // void setUseSystemNotifications(bool enabled) {
  //   _settingsManager.updateSetting('notificationController.useSystemNotifications', enabled);
  //   notifyListeners();
  // }
  
  // void setUsePopupAlerts(bool enabled) {
  //   _settingsManager.updateSetting('notificationController.usePopupAlerts', enabled);
  //   notifyListeners();
  // }
  
  // Getters for notification settings
  bool getSoundEnabled() {
    return _soundEnabled;
  }
  
  int getReminderFrequency() {
    return _reminderFrequency;
  }
  
  bool getUseSystemNotifications() {
    var settings = _settingsManager.getSetting('notifications');
    return settings != null ? settings['system'] ?? true : true;
  }
  
  bool getUsePopupAlerts() {
    var settings = _settingsManager.getSetting('notifications');
    return settings != null ? settings['popup'] ?? true : true;
  }
  
  // Focus Notification Functions
  void sendFocusNotification(String mode, bool isCompleted) {
    // Check if focus notifications are enabled in the general settings
    if (!(_settingsManager.getSetting('notifications.enabled') ?? true) || 
        !(_settingsManager.getSetting('notifications.focusMode') ?? true)) {
      return;
    }
    
    String title;
    String body;
    
    if (isCompleted) {
      title = '$mode Completed';
      body = 'Your $mode session has ended.';
    } else {
      title = '$mode Started';
      body = 'Your $mode session has started.';
    }
    
    _sendPomodoroNotification(title, body, isCompleted);
    
  }
  
  // Screen Time Notification
  void sendScreenTimeNotification(int limitInMinutes) {
    // Check if screen time notifications are enabled in the general settings
    if (!(_settingsManager.getSetting('notifications.enabled') ?? true) || 
        !(_settingsManager.getSetting('limitsAlerts.overallLimit.enabled') ?? true)) {
      return;
    }
    
    String title = 'Screen Time Limit Reached';
    String body = 'You have reached your daily screen time limit of $limitInMinutes minutes.';
    
    _sendNotification(title, body, 'screenTime');
  }
  
  // App Limit Notification
  void sendAppLimitNotification(String appName, int limitInMinutes) {
    // Check if app screen time notifications are enabled in the general settings
    if (!(_settingsManager.getSetting('notifications.enabled') ?? true) || 
        !(_settingsManager.getSetting('notifications.overallLimit.enabled') ?? true)) {
      return;
    }
    
    String title = 'App Time Limit Reached';
    String body = 'You have reached your time limit of $limitInMinutes minutes for $appName.';
    
    _sendNotification(title, body, 'appLimit', appName);
  }
  
  // Generic notification sender
  void _sendNotification(String title, String body, String type, [String? extraData]) {
    // Use our own dedicated settings
    bool useSystemNotifications = getUseSystemNotifications();
    bool usePopupAlerts = getUsePopupAlerts();
    
    final id = DateTime.now().millisecondsSinceEpoch % 10000;
    _pendingAlerts[id] = DateTime.now();
    
    // Cancel any existing reminder timer to prevent spam
    _reminderTimer?.cancel();
    
    // Send Windows notification if system notifications are enabled
    if (useSystemNotifications) {
      final notification = LocalNotification(
        title: title,
        body: body,
        actions: _soundEnabled 
        ? [
            LocalNotificationAction(text: 'Close', type: 'close'),
            LocalNotificationAction(text: 'Remind Later', type: 'remind'),
          ] 
        : null,
      );
      
      // Auto-dismiss timer
      Timer(const Duration(seconds: autoDismissSeconds), () {
        if (_pendingAlerts.containsKey(id)) {
          _handleNotificationAction(id, 'close', type, extraData);
        }
      });
      
      // Play sound if enabled
      if (_soundEnabled) {
        // You would implement sound playing here using a package like audioplayers
        // For example: _audioPlayer.play('assets/notification_sound.wav');
      }
      
      // Show notification
      notification.onClickAction = (actionIndex) {
        if (actionIndex == 0) { // Close
          _handleNotificationAction(id, 'close', type, extraData);
        } else if (actionIndex == 1) { // Remind Later
          _handleNotificationAction(id, 'remind', type, extraData);
        }
      };
      
      notification.show();
    }
    
    // Also show in-app alert if callback is registered and popup alerts are enabled
    if (_showAlertCallback != null && usePopupAlerts) {
      _showAlertCallback!(title, body,
        onClose: () => _handleNotificationAction(id, 'close', type, extraData),
        onRemind: () => _handleNotificationAction(id, 'remind', type, extraData),
      );
      
      // Auto-dismiss timer for popup alerts
      Timer(const Duration(seconds: autoDismissSeconds), () {
        if (_pendingAlerts.containsKey(id)) {
          _handleNotificationAction(id, 'close', type, extraData);
        }
      });
    }
    
    // Modify reminder scheduling to be less aggressive
    _scheduleReminderIfNeeded(id, type, extraData);
  }
  
  // Schedule reminder for unacknowledged alerts
  void _scheduleReminderIfNeeded(int id, String type, [String? extraData]) {
    _reminderTimer?.cancel();
    _reminderTimer = Timer.periodic(Duration(minutes: _reminderFrequency), (timer) {
      if (!_pendingAlerts.containsKey(id)) {
        timer.cancel();
        return;
      }
      
      // Send reminder based on type
      String reminderTitle = 'Reminder';
      String reminderBody = 'You have an unacknowledged alert';
      
      switch (type) {
        case 'focus':
          reminderBody = 'You have an unacknowledged focus alert';
          break;
        case 'screenTime':
          reminderBody = 'You have an unacknowledged screen time alert';
          break;
        case 'appLimit':
          if (extraData != null) {
            reminderBody = 'You have an unacknowledged app limit alert for $extraData';
          }
          break;
      }
      
      _sendNotification(reminderTitle, reminderBody, type, extraData);
    });
  }
  
  // Action handlers
  void _handleNotificationAction(int id, String action, String type, [String? extraData]) {
    if (action == 'close') {
      _pendingAlerts.remove(id);
      _reminderTimer?.cancel();
    } else if (action == 'remind') {
      _pendingAlerts.remove(id);
      _reminderTimer?.cancel();
      
      // Schedule a reminder in 15 minutes
      Timer(const Duration(minutes: 15), () {
        String title = '15-Minute Reminder';
        String body = '';
        
        switch (type) {
          case 'focus':
            body = 'This is your 15-minute reminder about your focus session';
            break;
          case 'screenTime':
            body = 'This is your 15-minute reminder about your screen time limit';
            break;
          case 'appLimit':
            if (extraData != null) {
              body = 'This is your 15-minute reminder about your app limit for $extraData';
            }
            break;
          default:
            body = 'This is your 15-minute reminder';
        }
        
        _sendNotification(title, body, type, extraData);
      });
    }
  }
  
  // Method to show a custom popup alert
  void showPopupAlert(String title, String message) {
    // Check if popup alerts are enabled
    bool usePopupAlerts = getUsePopupAlerts();
    if (!usePopupAlerts || _showAlertCallback == null) {
      return;
    }
    
    final id = DateTime.now().millisecondsSinceEpoch % 10000;
    _pendingAlerts[id] = DateTime.now();
    
    _showAlertCallback!(title, message,
      onClose: () {
        _pendingAlerts.remove(id);
        _reminderTimer?.cancel();
      },
      onRemind: () {
        _pendingAlerts.remove(id);
        _reminderTimer?.cancel();
        Timer(const Duration(minutes: 15), () {
          showPopupAlert('Reminder: $title', message);
        });
      }
    );
    
    _scheduleReminderIfNeeded(id, 'popup');
  }
  
  // Cancel all active reminders
  void cancelAllReminders() {
    _pendingAlerts.clear();
    _reminderTimer?.cancel();
  }
  
  // Method to reload settings when they change externally
  void refreshSettings() {
    _loadSettings();
  }
  void _sendPomodoroNotification(String title, String body, bool isCompleted) {
    // Use our own dedicated settings
    bool useSystemNotifications = getUseSystemNotifications();
    bool usePopupAlerts = getUsePopupAlerts();
    
    final id = DateTime.now().millisecondsSinceEpoch % 10000;
    _pendingAlerts[id] = DateTime.now();
    
    // Cancel any existing reminder timer to prevent spam
    _reminderTimer?.cancel();
    
    // Send Windows notification if system notifications are enabled
    if (useSystemNotifications) {
      final notification = LocalNotification(
        title: title,
        body: body,
        actions: _soundEnabled 
        ? [
            LocalNotificationAction(text: 'Close', type: 'close'),
          ] 
        : null,
      );
      
      // Auto-dismiss timer
      Timer(const Duration(seconds: autoDismissSeconds), () {
        if (_pendingAlerts.containsKey(id)) {
          _handleNotificationAction(id, 'close', 'focus');
        }
      });
      
      // Play sound if enabled
      if (_soundEnabled) {
        // You would implement sound playing here using a package like audioplayers
        // For example: _audioPlayer.play('assets/notification_sound.wav');
      }
      
      // Show notification
      notification.onClickAction = (actionIndex) {
        // Only close action for Pomodoro
        _handleNotificationAction(id, 'close', 'focus');
      };
      
      notification.show();
    }
    
    // Also show in-app alert if callback is registered and popup alerts are enabled
    if (_showAlertCallback != null && usePopupAlerts) {
      _showAlertCallback!(title, body,
        onClose: () => _handleNotificationAction(id, 'close', 'focus'),
        // No onRemind callback for Pomodoro
        onRemind: null,
      );
      
      // Auto-dismiss timer for popup alerts
      Timer(const Duration(seconds: autoDismissSeconds), () {
        if (_pendingAlerts.containsKey(id)) {
          _handleNotificationAction(id, 'close', 'focus');
        }
      });
    }
    
    // No reminder scheduling for Pomodoro notifications
  }
  // screenTime
  // Keep track of sent notifications to avoid spamming
  final Set<String> _notifiedApproachingApps = {};
  final Set<String> _notifiedExceededApps = {};
  bool _notifiedOverallApproaching = false;
  bool _notifiedOverallExceeded = false;

  void checkAndSendNotifications() {
    List<AppUsageSummary> appSummaries = _screenTimeController.getAllAppsSummary();

    for (final app in appSummaries) {
      if (app.limitStatus) {
        if (app.currentUsage >= app.dailyLimit) {
          // Only send if we haven't already sent an "exceeded" notification
          if (!_notifiedExceededApps.contains(app.appName)) {
            sendAppLimitNotification(app.appName, app.dailyLimit.inMinutes);
            _notifiedExceededApps.add(app.appName);  // Mark as notified
          }
        } else if (app.percentageOfLimitUsed >= 0.9) {
          // Send warning only once per day per app
          if (!_notifiedApproachingApps.contains(app.appName)) {
            showPopupAlert("Approaching App Limit", "You're about to reach your daily limit for ${app.appName}");
            _notifiedApproachingApps.add(app.appName);
          }
        }
      }
    }

    // Check overall screen time limits
    if (_screenTimeController.isOverallLimitEnabled()) {
      Duration overallLimit = _screenTimeController.getOverallLimit();
      Duration currentUsage = _screenTimeController.getOverallUsage();

      if (currentUsage >= overallLimit) {
        if (!_notifiedOverallExceeded) {
          sendScreenTimeNotification(overallLimit.inMinutes);
          _notifiedOverallExceeded = true;
        }
      } else if (currentUsage.inMinutes >= overallLimit.inMinutes * 0.9) {
        if (!_notifiedOverallApproaching) {
          showPopupAlert("Approaching Screen Time Limit", "You're about to reach your daily screen time limit of ${overallLimit.inMinutes} minutes");
          _notifiedOverallApproaching = true;
        }
      }
    }
  }

  // Reset notifications at midnight or when needed
  void resetNotifications() {
    _notifiedApproachingApps.clear();
    _notifiedExceededApps.clear();
    _notifiedOverallApproaching = false;
    _notifiedOverallExceeded = false;
  }
}
