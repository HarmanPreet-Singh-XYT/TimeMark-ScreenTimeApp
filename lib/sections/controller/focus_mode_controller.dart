import 'dart:async';
import './data_controllers/focusMode_data_controller.dart';
import './notification_controller.dart'; // Import the notification controller

enum TimerState { work, shortBreak, longBreak, idle }

class PomodoroTimerService {
  // Singleton instance
  static final PomodoroTimerService _instance = PomodoroTimerService._internal();
  final FocusAnalyticsService _analyticsService = FocusAnalyticsService();
  final NotificationController _notificationController = NotificationController(); // Instance of notification controller
  
  // Factory constructor
  factory PomodoroTimerService({
    required int workDuration,
    required int shortBreakDuration,
    required int longBreakDuration,
    bool autoStart = false,
    bool enableNotifications = true,
    Function()? onWorkSessionStart,
    Function()? onShortBreakStart,
    Function()? onLongBreakStart,
    Function()? onTimerComplete,
  }) {
    _instance._workDuration = workDuration;
    _instance._shortBreakDuration = shortBreakDuration;
    _instance._longBreakDuration = longBreakDuration;
    _instance._autoStart = autoStart;
    _instance._enableNotifications = enableNotifications;
    _instance._onWorkSessionStart = onWorkSessionStart;
    _instance._onShortBreakStart = onShortBreakStart;
    _instance._onLongBreakStart = onLongBreakStart;
    _instance._onTimerComplete = onTimerComplete;
    
    return _instance;
  }
  
  // Private constructor
  PomodoroTimerService._internal();
  
  // Config variables
  int _workDuration = 25; // default 25 minute
  int _shortBreakDuration = 5; // default 5 minutes
  int _longBreakDuration = 15; // default 15 minutes
  bool _autoStart = false;
  bool _enableNotifications = true;
  
  // Session tracking
  int _completedSessions = 0;
  int _totalSessions = 0;
  
  // Timer state
  TimerState _currentState = TimerState.idle;
  int _secondsRemaining = 0;
  Timer? _timer;
  
  // Callbacks
  Function()? _onWorkSessionStart;
  Function()? _onShortBreakStart;
  Function()? _onLongBreakStart;
  Function()? _onTimerComplete;
  
  // Getters
  TimerState get currentState => _currentState;
  int get secondsRemaining => _secondsRemaining;
  int get minutesRemaining => _secondsRemaining ~/ 60;
  int get secondsInCurrentMinute => _secondsRemaining % 60;
  bool get isRunning => _timer != null && _timer!.isActive;
  int get completedSessions => _completedSessions;
  int get totalSessions => _totalSessions;
  
  // Initialize the timer service
  Future<void> initialize() async {
    // Ensure notification controller is initialized
    await _notificationController.initialize();
  }
  
  // Update configuration
  void updateConfig({
    int? workDuration,
    int? shortBreakDuration,
    int? longBreakDuration,
    bool? autoStart,
    bool? enableNotifications,
    Function()? onWorkSessionStart,
    Function()? onShortBreakStart,
    Function()? onLongBreakStart,
    Function()? onTimerComplete,
  }) {
    _workDuration = workDuration ?? _workDuration;
    _shortBreakDuration = shortBreakDuration ?? _shortBreakDuration;
    _longBreakDuration = longBreakDuration ?? _longBreakDuration;
    _autoStart = autoStart ?? _autoStart;
    _enableNotifications = enableNotifications ?? _enableNotifications;
    _onWorkSessionStart = onWorkSessionStart ?? _onWorkSessionStart;
    _onShortBreakStart = onShortBreakStart ?? _onShortBreakStart;
    _onLongBreakStart = onLongBreakStart ?? _onLongBreakStart;
    _onTimerComplete = onTimerComplete ?? _onTimerComplete;
  }
  
  // Start a work session
  void startWorkSession() {
    _currentState = TimerState.work;
    _secondsRemaining = _workDuration * 60;
    _startTimer();
    
    // Send notification for work session start
    if (_enableNotifications) {
      _notificationController.sendFocusNotification('Pomodoro Work', false);
      if (_onWorkSessionStart != null) {
        _onWorkSessionStart!();
      }
    }
  }
  
  // Start a short break
  void startShortBreak() {
    _currentState = TimerState.shortBreak;
    _secondsRemaining = _shortBreakDuration * 60;
    _startTimer();
    
    // Send notification for short break start
    if (_enableNotifications) {
      _notificationController.sendFocusNotification('Short Break', false);
      if (_onShortBreakStart != null) {
        _onShortBreakStart!();
      }
    }
  }
  
  // Start a long break
  void startLongBreak() {
    _currentState = TimerState.longBreak;
    _secondsRemaining = _longBreakDuration * 60;
    _startTimer();
    
    // Send notification for long break start
    if (_enableNotifications) {
      _notificationController.sendFocusNotification('Long Break', false);
      if (_onLongBreakStart != null) {
        _onLongBreakStart!();
      }
    }
  }
  
  // Start the timer
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), _timerCallback);
  }
  
  // Pause the timer
  void pauseTimer() {
    _timer?.cancel();
    _timer = null;
    
    // Optional: Send a notification for paused timer
    if (_enableNotifications && _currentState != TimerState.idle) {
      _notificationController.showPopupAlert(
        'Pomodoro Paused', 
        'Your ${_getSessionTypeName()} session has been paused.'
      );
    }
  }
  
  // Get the name of the current session type for notifications
  String _getSessionTypeName() {
    switch (_currentState) {
      case TimerState.work:
        return 'Pomodoro Work';
      case TimerState.shortBreak:
        return 'Short Break';
      case TimerState.longBreak:
        return 'Long Break';
      case TimerState.idle:
        return 'Pomodoro';
    }
  }
  
  // Resume the timer
  void resumeTimer() {
    if (!isRunning && _secondsRemaining > 0) {
      _startTimer();
      
      // Optional: Send a notification for resumed timer
      if (_enableNotifications && _currentState != TimerState.idle) {
        _notificationController.showPopupAlert(
          'Pomodoro Resumed', 
          'Your ${_getSessionTypeName()} session has been resumed.'
        );
      }
    }
  }
  
  // Reset the timer
  void resetTimer() {
    pauseTimer();
    switch (_currentState) {
      case TimerState.work:
        _secondsRemaining = _workDuration * 60;
        break;
      case TimerState.shortBreak:
        _secondsRemaining = _shortBreakDuration * 60;
        break;
      case TimerState.longBreak:
        _secondsRemaining = _longBreakDuration * 60;
        break;
      case TimerState.idle:
        break;
    }
    
    // Optional: Send a notification for reset timer
    if (_enableNotifications && _currentState != TimerState.idle) {
      _notificationController.showPopupAlert(
        'Pomodoro Reset', 
        'Your ${_getSessionTypeName()} session has been reset.'
      );
    }
  }
  
  // Timer callback function
  void _timerCallback(Timer timer) {
    if (_secondsRemaining > 0) {
      _secondsRemaining--;
      
      // Optional: Send a notification when time is almost up (e.g., 1 minute remaining)
      if (_enableNotifications && _secondsRemaining == 60) {
        _notificationController.showPopupAlert(
          '1 Minute Remaining', 
          'Your ${_getSessionTypeName()} session will end in 1 minute.'
        );
      }
    } else {
      timer.cancel();
      _timer = null;
      _handleTimerComplete();
    }
  }
  
  // Handle timer completion
  void _handleTimerComplete() {
    String completedSessionType = _getSessionTypeName();
    
    if (_currentState == TimerState.work) {
      _completedSessions++;
      _totalSessions++;
      
      // Send completion notification
      if (_enableNotifications) {
        _notificationController.sendFocusNotification('Pomodoro Work', true);
      }
      
      // Determine which break to start next
      if (_completedSessions % 4 == 0) {
        if (_autoStart) {
          startLongBreak();
        } else {
          _currentState = TimerState.idle;
          
          // Send notification suggesting a long break
          if (_enableNotifications) {
            _notificationController.showPopupAlert(
              'Time for a Long Break', 
              'You have completed 4 work sessions. Time for a long break!'
            );
          }
        }
      } else {
        if (_autoStart) {
          startShortBreak();
        } else {
          _currentState = TimerState.idle;
          
          // Send notification suggesting a short break
          if (_enableNotifications) {
            _notificationController.showPopupAlert(
              'Time for a Short Break', 
              'Work session completed. Time for a short break!'
            );
          }
        }
      }
    } else {
      // Break is complete
      // Send completion notification
      if (_enableNotifications) {
        _notificationController.sendFocusNotification(completedSessionType, true);
      }
      
      // Start a new work session if autoStart is enabled
      if (_autoStart) {
        startWorkSession();
      } else {
        _currentState = TimerState.idle;
        
        // Send notification suggesting to start work
        if (_enableNotifications) {
          _notificationController.showPopupAlert(
            'Break Completed', 
            'Your break is over. Ready to start working again?'
          );
        }
      }
    }
    
    // Add into DB
    num totalDuration = _workDuration + _shortBreakDuration + _longBreakDuration;
    Duration duration = Duration(minutes: totalDuration.toInt());
    DateTime now = DateTime.now();
    DateTime startTime = DateTime(now.year, now.month, now.day, now.hour, now.minute, now.second);
    _analyticsService.createFocusSession(startTime: startTime, duration: duration, appsBlocked: []);
    
    if (_enableNotifications && _onTimerComplete != null) {
      _onTimerComplete!();
    }
  }
  
  // Skip to the next phase
  void skipToNext() {
    String skippedSessionType = _getSessionTypeName();
    
    switch (_currentState) {
      case TimerState.work:
        // Notify about skipping work session
        if (_enableNotifications) {
          _notificationController.showPopupAlert(
            'Work Session Skipped', 
            'You skipped the current work session.'
          );
        }
        _handleTimerComplete();
        break;
      case TimerState.shortBreak:
      case TimerState.longBreak:
        // Notify about skipping break
        if (_enableNotifications) {
          _notificationController.showPopupAlert(
            'Break Skipped', 
            'You skipped your ${_currentState == TimerState.shortBreak ? 'short' : 'long'} break.'
          );
        }
        
        if (_autoStart) {
          startWorkSession();
        } else {
          _currentState = TimerState.idle;
        }
        break;
      case TimerState.idle:
        startWorkSession();
        break;
    }
  }
  
  // Reset all stats
  void resetStats() {
    _completedSessions = 0;
    _totalSessions = 0;
    
    // Notify about stats reset
    if (_enableNotifications) {
      _notificationController.showPopupAlert(
        'Stats Reset', 
        'Your Pomodoro statistics have been reset.'
      );
    }
  }
  
  // Dispose of resources
  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}