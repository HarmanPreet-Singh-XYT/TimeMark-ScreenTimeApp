import 'dart:async';
import 'package:fluent_ui/fluent_ui.dart';

import 'data_controllers/focus_mode_data_controller.dart';
import './notification_controller.dart'; // Import the notification controller

enum TimerState { work, shortBreak, longBreak, idle }

class PomodoroTimerService {
  // Singleton instance
  static final PomodoroTimerService _instance =
      PomodoroTimerService._internal();
  final FocusAnalyticsService _analyticsService = FocusAnalyticsService();
  final NotificationController _notificationController =
      NotificationController(); // Instance of notification controller

  final StreamController<TimerUpdate> _stateController =
      StreamController<TimerUpdate>.broadcast();

  Stream<TimerUpdate> get timerUpdates => _stateController.stream;

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

  // Timer callback function - notify listeners
  void _timerCallback(Timer timer) {
    if (_secondsRemaining > 0) {
      _secondsRemaining--;

      // Notify all listeners of the update
      _stateController.add(TimerUpdate(
        state: _currentState,
        secondsRemaining: _secondsRemaining,
        isRunning: isRunning,
        completedSessions: _completedSessions,
      ));

      if (_enableNotifications && _secondsRemaining == 60) {
        _notificationController.showPopupAlert('1 Minute Remaining',
            'Your ${_getSessionTypeName()} session will end in 1 minute.');
      }
    } else {
      timer.cancel();
      _timer = null;
      _handleTimerComplete();
    }
  }

  // Also emit when state changes (start, pause, reset, etc.)
  void _emitUpdate() {
    _stateController.add(TimerUpdate(
      state: _currentState,
      secondsRemaining: _secondsRemaining,
      isRunning: isRunning,
      completedSessions: _completedSessions,
    ));
  }

  // Update startWorkSession, pauseTimer, etc. to call _emitUpdate()
  void startWorkSession() {
    _currentState = TimerState.work;
    _secondsRemaining = _workDuration * 60;
    _startTimer();
    _emitUpdate(); // Add this

    if (_enableNotifications) {
      _notificationController.sendFocusNotification('Pomodoro Work', false);
      _onWorkSessionStart?.call();
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

  // In your PomodoroTimerService class
  void restartCurrentSession() {
    pauseTimer();

    // Keep the current state but reset the time
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
        _secondsRemaining = _workDuration * 60;
        break;
    }

    // Automatically restart the timer
    if (_currentState != TimerState.idle) {
      _startTimer();
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
    _emitUpdate(); // Add this

    if (_enableNotifications && _currentState != TimerState.idle) {
      _notificationController.showPopupAlert('Pomodoro Paused',
          'Your ${_getSessionTypeName()} session has been paused.');
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
        _notificationController.showPopupAlert('Pomodoro Resumed',
            'Your ${_getSessionTypeName()} session has been resumed.');
      }
    }
  }

  // Reset the timer
  void resetTimer() {
    pauseTimer();

    // Reset to idle state completely
    _currentState = TimerState.idle;
    _secondsRemaining = _workDuration * 60;

    // Optional: Send a notification for reset timer
    if (_enableNotifications) {
      _notificationController.showPopupAlert(
          'Pomodoro Reset', 'Your timer has been reset.');
    }
  }

  // // Timer callback function
  // void _timerCallback(Timer timer) {
  //   if (_secondsRemaining > 0) {
  //     _secondsRemaining--;

  //     // Optional: Send a notification when time is almost up (e.g., 1 minute remaining)
  //     if (_enableNotifications && _secondsRemaining == 60) {
  //       _notificationController.showPopupAlert('1 Minute Remaining',
  //           'Your ${_getSessionTypeName()} session will end in 1 minute.');
  //     }
  //   } else {
  //     timer.cancel();
  //     _timer = null;
  //     _handleTimerComplete();
  //   }
  // }

  // Handle timer completion
  void _handleTimerComplete() {
    debugPrint('━━━━━━━━━━ TIMER COMPLETE ━━━━━━━━━━');
    debugPrint('State before handling: $_currentState');

    String completedSessionType = _getSessionTypeName();
    TimerState completedState =
        _currentState; // ← Store the state BEFORE changing it
    int completedDuration = 0;

    // Always call the completion callback first
    if (_onTimerComplete != null) {
      _onTimerComplete!();
    }

    if (_currentState == TimerState.work) {
      completedDuration = _workDuration;
      _completedSessions++;
      _totalSessions++;

      debugPrint(
          'Work session completed. Total completed: $_completedSessions');

      // Send completion notification
      if (_enableNotifications) {
        _notificationController.sendFocusNotification('Pomodoro Work', true);
      }

      // Determine which break to start next
      if (_completedSessions % 4 == 0) {
        debugPrint('Starting LONG break (after 4 sessions)');
        if (_autoStart) {
          startLongBreak();
        } else {
          _currentState = TimerState.idle;
          if (_enableNotifications) {
            _notificationController.showPopupAlert('Time for a Long Break',
                'You have completed 4 work sessions. Time for a long break!');
          }
        }
      } else {
        debugPrint('Starting SHORT break');
        if (_autoStart) {
          startShortBreak();
        } else {
          _currentState = TimerState.idle;
          if (_enableNotifications) {
            _notificationController.showPopupAlert('Time for a Short Break',
                'Work session completed. Time for a short break!');
          }
        }
      }
    } else {
      // Break is complete
      debugPrint('Break completed: $completedSessionType');

      if (_currentState == TimerState.shortBreak) {
        completedDuration = _shortBreakDuration;
      } else if (_currentState == TimerState.longBreak) {
        completedDuration = _longBreakDuration;
      }

      // Send completion notification
      if (_enableNotifications) {
        _notificationController.sendFocusNotification(
            completedSessionType, true);
      }

      // Start a new work session if autoStart is enabled
      if (_autoStart) {
        debugPrint('Auto-starting work session');
        startWorkSession();
      } else {
        _currentState = TimerState.idle;
        if (_enableNotifications) {
          _notificationController.showPopupAlert('Break Completed',
              'Your break is over. Ready to start working again?');
        }
      }
    }

    // Save to database - ONLY for work sessions
    if (completedState == TimerState.work) {
      debugPrint('💾 Saving to database...');
      debugPrint('Duration: $completedDuration minutes');

      DateTime now = DateTime.now();
      Duration duration = Duration(minutes: completedDuration);
      DateTime startTime = now.subtract(duration);

      debugPrint('Start time: $startTime');
      debugPrint('End time: $now');

      try {
        _analyticsService.createFocusSession(
          startTime: startTime,
          duration: duration,
          appsBlocked: [],
        );
        debugPrint('✅ Database save successful');
      } catch (e) {
        debugPrint('❌ Database save failed: $e');
      }
    } else {
      debugPrint('ℹ️ Skipping database save for break session');
    }

    debugPrint('State after handling: $_currentState');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  }

  // Skip to the next phase
  void skipToNext() {
    // String skippedSessionType = _getSessionTypeName();

    switch (_currentState) {
      case TimerState.work:
        // Notify about skipping work session
        if (_enableNotifications) {
          _notificationController.showPopupAlert(
              'Work Session Skipped', 'You skipped the current work session.');
        }
        _handleTimerComplete();
        break;
      case TimerState.shortBreak:
      case TimerState.longBreak:
        // Notify about skipping break
        if (_enableNotifications) {
          _notificationController.showPopupAlert('Break Skipped',
              'You skipped your ${_currentState == TimerState.shortBreak ? 'short' : 'long'} break.');
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
          'Stats Reset', 'Your Pomodoro statistics have been reset.');
    }
  }

  // Dispose of resources
  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}

class TimerUpdate {
  final TimerState state;
  final int secondsRemaining;
  final bool isRunning;
  final int completedSessions;

  TimerUpdate({
    required this.state,
    required this.secondsRemaining,
    required this.isRunning,
    required this.completedSessions,
  });
}
