import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart'; // For playing sounds
import 'package:screentime/sections/controller/data_controllers/focusMode_data_controller.dart';

class FocusTimerController {
  final FocusAnalyticsService _analyticsService = FocusAnalyticsService();
  final AudioPlayer _audioPlayer = AudioPlayer();

  Timer? _timer;
  Duration _workDuration;
  Duration _shortBreakDuration;
  Duration _longBreakDuration;
  int _workSessionsCompleted = 0;
  bool _isWorking = false;
  bool _isOnBreak = false;
  bool _isLongBreak = false;

  // Callbacks for UI updates
  Function(Duration)? onTick;
  Function(bool)? onWorkStateChanged;
  Function(bool)? onBreakStateChanged;

  FocusTimerController({
    required Duration workDuration,
    required Duration shortBreakDuration,
    required Duration longBreakDuration,
  })  : _workDuration = workDuration,
        _shortBreakDuration = shortBreakDuration,
        _longBreakDuration = longBreakDuration;

  // Current state of the timer
  Duration get currentDuration => _isWorking ? _workDuration : (_isLongBreak ? _longBreakDuration : _shortBreakDuration);
  bool get isWorking => _isWorking;
  bool get isOnBreak => _isOnBreak;
  bool get isLongBreak => _isLongBreak;

  // Start the timer
  void startTimer() {
    if (_timer != null && _timer!.isActive) return;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isWorking) {
        _workDuration -= const Duration(seconds: 1);
      } else if (_isOnBreak) {
        if (_isLongBreak) {
          _longBreakDuration -= const Duration(seconds: 1);
        } else {
          _shortBreakDuration -= const Duration(seconds: 1);
        }
      }

      // Notify UI of the updated time
      if (onTick != null) {
        onTick!(_isWorking ? _workDuration : (_isLongBreak ? _longBreakDuration : _shortBreakDuration));
      }

      // Check if the work session or break is complete
      if (_isWorking && _workDuration.inSeconds == 0) {
        _completeWorkSession();
      } else if (_isOnBreak && (_isLongBreak ? _longBreakDuration.inSeconds == 0 : _shortBreakDuration.inSeconds == 0)) {
        _completeBreak();
      }
    });

    // Play a sound when the timer starts
    _playSound('start_sound.mp3');

    // Notify UI of the state change
    if (onWorkStateChanged != null) {
      onWorkStateChanged!(_isWorking);
    }
    if (onBreakStateChanged != null) {
      onBreakStateChanged!(_isOnBreak);
    }
  }

  // Pause the timer
  void pauseTimer() {
    _timer?.cancel();
    _timer = null;

    // Play a sound when the timer is paused
    _playSound('pause_sound.mp3');
  }

  // Reset the timer
  void resetTimer() {
    _timer?.cancel();
    _timer = null;
    _workDuration = const Duration(minutes: 25); // Reset to default work duration
    _shortBreakDuration = const Duration(minutes: 5); // Reset to default short break duration
    _longBreakDuration = const Duration(minutes: 15); // Reset to default long break duration
    _isWorking = false;
    _isOnBreak = false;
    _isLongBreak = false;

    // Notify UI of the reset
    if (onTick != null) {
      onTick!(_workDuration);
    }
    if (onWorkStateChanged != null) {
      onWorkStateChanged!(_isWorking);
    }
    if (onBreakStateChanged != null) {
      onBreakStateChanged!(_isOnBreak);
    }

    // Play a sound when the timer is reset
    _playSound('reset_sound.mp3');
  }

  // Complete a work session
  void _completeWorkSession() {
    _timer?.cancel();
    _timer = null;
    _isWorking = false;
    _isOnBreak = true;
    _workSessionsCompleted++;

    // Determine if it's time for a long break (e.g., every 4 work sessions)
    _isLongBreak = _workSessionsCompleted % 4 == 0;

    // Record the session in analytics
    _analyticsService.createFocusSession(
      startTime: DateTime.now().subtract(_workDuration),
      duration: _workDuration,
      appsBlocked: [], // Add apps blocked during the session if applicable
    );

    // Play a sound when the work session is complete
    _playSound('work_complete_sound.mp3');

    // Notify UI of the state change
    if (onWorkStateChanged != null) {
      onWorkStateChanged!(_isWorking);
    }
    if (onBreakStateChanged != null) {
      onBreakStateChanged!(_isOnBreak);
    }

    // Start the break automatically
    startTimer();
  }

  // Complete a break
  void _completeBreak() {
    _timer?.cancel();
    _timer = null;
    _isOnBreak = false;
    _isWorking = true;

    // Reset break durations
    _shortBreakDuration = const Duration(minutes: 5);
    _longBreakDuration = const Duration(minutes: 15);

    // Play a sound when the break is complete
    _playSound(_isLongBreak ? 'long_break_complete_sound.mp3' : 'short_break_complete_sound.mp3');

    // Notify UI of the state change
    if (onWorkStateChanged != null) {
      onWorkStateChanged!(_isWorking);
    }
    if (onBreakStateChanged != null) {
      onBreakStateChanged!(_isOnBreak);
    }

    // Start the next work session automatically
    startTimer();
  }

  // Play a sound
  void _playSound(String soundFile) async {
    try {
      await _audioPlayer.play(AssetSource(soundFile));
    } catch (e) {
      debugPrint("Error playing sound: $e");
    }
  }

  // Dispose the controller
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
  }
}