import 'dart:async';

enum TimerState { work, shortBreak, longBreak, idle }

class PomodoroTimerService {
  // Singleton instance
  static final PomodoroTimerService _instance = PomodoroTimerService._internal();
  
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
  int _workDuration = 25; // default 25 minutes
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
    if (_enableNotifications && _onWorkSessionStart != null) {
      _onWorkSessionStart!();
    }
  }
  
  // Start a short break
  void startShortBreak() {
    _currentState = TimerState.shortBreak;
    _secondsRemaining = _shortBreakDuration * 60;
    _startTimer();
    if (_enableNotifications && _onShortBreakStart != null) {
      _onShortBreakStart!();
    }
  }
  
  // Start a long break
  void startLongBreak() {
    _currentState = TimerState.longBreak;
    _secondsRemaining = _longBreakDuration * 60;
    _startTimer();
    if (_enableNotifications && _onLongBreakStart != null) {
      _onLongBreakStart!();
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
  }
  
  // Resume the timer
  void resumeTimer() {
    if (!isRunning && _secondsRemaining > 0) {
      _startTimer();
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
  }
  
  // Timer callback function
  void _timerCallback(Timer timer) {
    if (_secondsRemaining > 0) {
      _secondsRemaining--;
    } else {
      timer.cancel();
      _timer = null;
      _handleTimerComplete();
    }
  }
  
  // Handle timer completion
  void _handleTimerComplete() {
    if (_currentState == TimerState.work) {
      _completedSessions++;
      _totalSessions++;
      
      // Determine which break to start next
      if (_completedSessions % 4 == 0) {
        if (_autoStart) {
          startLongBreak();
        } else {
          _currentState = TimerState.idle;
        }
      } else {
        if (_autoStart) {
          startShortBreak();
        } else {
          _currentState = TimerState.idle;
        }
      }
    } else {
      // Break is complete, start a new work session if autoStart is enabled
      if (_autoStart) {
        startWorkSession();
      } else {
        _currentState = TimerState.idle;
      }
    }
    
    if (_enableNotifications && _onTimerComplete != null) {
      _onTimerComplete!();
    }
  }
  
  // Skip to the next phase
  void skipToNext() {
    switch (_currentState) {
      case TimerState.work:
        _handleTimerComplete();
        break;
      case TimerState.shortBreak:
      case TimerState.longBreak:
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
  }
  
  // Dispose of resources
  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}