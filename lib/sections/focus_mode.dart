import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:screentime/sections/UI%20sections/FocusMode/audio.dart';
import 'package:screentime/sections/UI%20sections/FocusMode/permissionbanner.dart';
import 'package:screentime/sections/UI%20sections/FocusMode/sessionHistory.dart';
import 'package:screentime/sections/UI%20sections/FocusMode/helper.dart';
import 'package:screentime/sections/controller/data_controllers/focus_mode_data_controller.dart';
import 'package:screentime/sections/graphs/focus_mode_history.dart';
import 'package:screentime/sections/graphs/focus_mode_pie_chart.dart';
import 'package:screentime/sections/graphs/focus_mode_trends.dart';
import 'controller/settings_data_controller.dart';
import './controller/focus_mode_controller.dart';
import 'package:intl/intl.dart';
import 'package:screentime/l10n/app_localizations.dart';

class FocusMode extends StatefulWidget {
  const FocusMode({super.key});

  @override
  State<FocusMode> createState() => _FocusModeState();
}

class _FocusModeState extends State<FocusMode>
    with SingleTickerProviderStateMixin {
  final FocusAnalyticsService _analyticsService = FocusAnalyticsService();

  // State variables
  double workPercentage = 0;
  double shortBreakPercentage = 0;
  double longBreakPercentage = 0;
  List<Map<String, dynamic>> sessionHistory = [];
  Map<String, int> sessionCountByDay = {
    'Monday': 0,
    'Tuesday': 0,
    'Wednesday': 0,
    'Thursday': 0,
    'Friday': 0,
    'Saturday': 0,
    'Sunday': 0,
  };
  Map<String, dynamic> focusTrends = {
    'periods': [],
    'sessionCounts': [],
    'avgDuration': [],
    'totalFocusTime': [],
    'percentageChange': 0,
  };
  Map<String, dynamic> weeklySummary = {};
  bool isLoading = true;

  // Animation controller for smooth transitions
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
    _loadData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);

    try {
      final DateTime now = DateTime.now();
      final DateTime startDate = DateTime(now.year, now.month - 1, now.day);
      final DateTime endDate = now;

      final timeDistribution = _analyticsService.getTimeDistribution(
        startDate: startDate,
        endDate: endDate,
      );
      final history = _analyticsService.getSessionHistory(
        startDate: startDate,
        endDate: endDate,
      );
      final countByDay = _analyticsService.getSessionCountByDay(
        startDate: startDate,
        endDate: endDate,
      );
      final trends = _analyticsService.getFocusTrends(months: 3);
      final summary = _analyticsService.getWeeklySummary();

      setState(() {
        workPercentage = timeDistribution['workPercentage'] ?? 0;
        shortBreakPercentage = timeDistribution['shortBreakPercentage'] ?? 0;
        longBreakPercentage = timeDistribution['longBreakPercentage'] ?? 0;
        sessionHistory = history;
        sessionCountByDay = _getLatestDataByWeekday(countByDay);
        focusTrends = trends;
        weeklySummary = summary;
        isLoading = false;
      });
      _animationController.forward();
    } catch (e) {
      debugPrint("Error loading focus mode data: $e");
      setState(() {
        workPercentage = 5;
        shortBreakPercentage = 6;
        longBreakPercentage = 8;
        isLoading = false;
      });
      _animationController.forward();
    }
  }

  Map<String, int> _getLatestDataByWeekday(Map<String, int> sessionCountByDay) {
    final Map<String, int> latestByWeekday = {
      'Monday': 0,
      'Tuesday': 0,
      'Wednesday': 0,
      'Thursday': 0,
      'Friday': 0,
      'Saturday': 0,
      'Sunday': 0,
    };
    final Map<String, DateTime> latestDateByWeekday = {};

    sessionCountByDay.forEach((dateStr, count) {
      try {
        final DateTime date = DateFormat('yyyy-MM-dd').parse(dateStr);
        final String weekday = DateFormat('EEEE').format(date);

        if (!latestDateByWeekday.containsKey(weekday) ||
            date.isAfter(latestDateByWeekday[weekday]!)) {
          latestDateByWeekday[weekday] = date;
          latestByWeekday[weekday] = count;
        }
      } catch (e) {
        debugPrint('Error parsing date: $dateStr - $e');
      }
    });

    return latestByWeekday;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (isLoading) {
      return ScaffoldPage(
        padding: EdgeInsets.zero,
        content: const Center(
          child: ProgressRing(),
        ),
      );
    }

    return ScaffoldPage(
      padding: EdgeInsets.zero,
      content: FadeTransition(
        opacity: _fadeAnimation,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isSmallScreen = constraints.maxWidth < 700;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with title
                  _buildHeader(context, l10n),
                  const SizedBox(height: 24),

                  const NotificationPermissionBanner(),

                  // Main content area - Timer + Quick Stats
                  _buildTimerAndStatsSection(context, l10n, isSmallScreen),
                  const SizedBox(height: 20),

                  // Analytics Section
                  _buildSectionTitle(
                      context, l10n.historySection, FluentIcons.chart),
                  const SizedBox(height: 12),
                  _AnimatedCard(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: FocusModeHistoryChart(data: sessionCountByDay),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Trends and Session History
                  _buildTrendsAndHistorySection(context, l10n, isSmallScreen),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// Timer + Quick Stats Section (responsive)
  Widget _buildTimerAndStatsSection(
    BuildContext context,
    AppLocalizations l10n,
    bool isSmallScreen,
  ) {
    final timerWidget = _AnimatedCard(
      child: const Meter(),
    );

    final quickStatsWidget = Column(
      children: [
        _buildQuickStatCard(
          context,
          l10n.timeDistributionSection,
          FocusModePieChart(
            dataMap: {
              l10n.workSession: workPercentage,
              l10n.shortBreak: shortBreakPercentage,
              l10n.longBreak: longBreakPercentage,
            },
            colorList: const [
              Color(0xFF4CAF50),
              Color(0xFFFF7043),
              Color(0xFF42A5F5),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildWeeklySummaryCard(context, l10n),
      ],
    );

    if (isSmallScreen) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          timerWidget,
          const SizedBox(height: 20),
          quickStatsWidget,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 3, child: timerWidget),
        const SizedBox(width: 20),
        Expanded(flex: 2, child: quickStatsWidget),
      ],
    );
  }

  /// Trends and Session History Section (responsive)
  Widget _buildTrendsAndHistorySection(
    BuildContext context,
    AppLocalizations l10n,
    bool isSmallScreen,
  ) {
    final trendsWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, l10n.trendsSection, FluentIcons.trending12),
        const SizedBox(height: 12),
        _AnimatedCard(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: FocusModeTrends(data: focusTrends),
          ),
        ),
      ],
    );

    final historyWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          context,
          l10n.sessionHistorySection,
          FluentIcons.history,
        ),
        const SizedBox(height: 12),
        _AnimatedCard(
          child: SessionHistory(data: sessionHistory),
        ),
      ],
    );

    if (isSmallScreen) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          trendsWidget,
          const SizedBox(height: 20),
          historyWidget,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 3, child: trendsWidget),
        const SizedBox(width: 20),
        Expanded(flex: 2, child: historyWidget),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFF5C50).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                FluentIcons.timer,
                color: Color(0xFFFF5C50),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.focusModeTitle,
                  style: FluentTheme.of(context).typography.subtitle?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Stay focused, be productive',
                  style: FluentTheme.of(context).typography.caption?.copyWith(
                        color: FluentTheme.of(context)
                            .typography
                            .caption
                            ?.color
                            ?.withValues(alpha: 0.7),
                      ),
                ),
              ],
            ),
          ],
        ),
        IconButton(
          icon: const Icon(FluentIcons.refresh, size: 18),
          onPressed: _loadData,
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: FluentTheme.of(context).accentColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: FluentTheme.of(context).typography.bodyStrong?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }

  Widget _buildQuickStatCard(
      BuildContext context, String title, Widget content) {
    return _AnimatedCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: FluentTheme.of(context).typography.bodyStrong?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklySummaryCard(BuildContext context, AppLocalizations l10n) {
    final totalSessions = weeklySummary['totalSessions'] ?? 0;
    final totalMinutes = weeklySummary['totalMinutes'] ?? 0;
    final avgSessionLength = weeklySummary['avgSessionLength'] ?? 0;

    return _AnimatedCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This Week',
              style: FluentTheme.of(context).typography.bodyStrong?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            _buildStatRow(
                context, 'Sessions', '$totalSessions', FluentIcons.check_mark),
            const SizedBox(height: 12),
            _buildStatRow(
                context, 'Total Time', '${totalMinutes}m', FluentIcons.clock),
            const SizedBox(height: 12),
            _buildStatRow(context, 'Avg Length', '${avgSessionLength}m',
                FluentIcons.calculator),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(
      BuildContext context, String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: FluentTheme.of(context).accentColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child:
              Icon(icon, size: 14, color: FluentTheme.of(context).accentColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: FluentTheme.of(context).typography.body,
          ),
        ),
        Text(
          value,
          style: FluentTheme.of(context).typography.bodyStrong?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}

// Animated card wrapper with hover effects
class _AnimatedCard extends StatefulWidget {
  final Widget child;

  const _AnimatedCard({
    required this.child,
  });

  @override
  State<_AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<_AnimatedCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: FluentTheme.of(context).micaBackgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isHovered
                ? FluentTheme.of(context).accentColor.withValues(alpha: 0.3)
                : FluentTheme.of(context).inactiveBackgroundColor,
            width: 1,
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: FluentTheme.of(context)
                        .accentColor
                        .withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: widget.child,
      ),
    );
  }
}

class Meter extends StatefulWidget {
  const Meter({super.key});

  @override
  State<Meter> createState() => _MeterState();
}

class _MeterState extends State<Meter> with TickerProviderStateMixin {
  SettingsManager settingsManager = SettingsManager();
  final AudioPlayer _audioPlayer = AudioPlayer();
  double workDuration = 25;
  double shortBreak = 5;
  double longBreak = 15;
  bool autoStart = false;
  bool blockDistractions = false;
  bool enableSounds = true;
  String selectedMode = "Custom";

  late PomodoroTimerService _timerService;
  String _displayTime = "25:00";
  double _percentComplete = 1.0;
  bool _isRunning = false;
  TimerState _currentTimerState = TimerState.idle;
  Timer? _uiUpdateTimer;

  // Track completed sessions locally
  int _completedWorkSessions = 0;

  // Animation controllers
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _buttonScaleController;
  late Animation<double> _buttonScaleAnimation;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _initializeTimerService();
    _startUiUpdateTimer();
    _initAnimations();
  }

  void _loadSettings() {
    workDuration = settingsManager.getSetting("focusModeSettings.workDuration");
    shortBreak = settingsManager.getSetting("focusModeSettings.shortBreak");
    longBreak = settingsManager.getSetting("focusModeSettings.longBreak");
    autoStart = settingsManager.getSetting("focusModeSettings.autoStart");
    blockDistractions =
        settingsManager.getSetting("focusModeSettings.blockDistractions");
    enableSounds = settingsManager
        .getSetting("focusModeSettings.enableSoundsNotifications");
    selectedMode = settingsManager.getSetting("focusModeSettings.selectedMode");
  }

  void _initAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _buttonScaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _buttonScaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _buttonScaleController, curve: Curves.easeInOut),
    );
  }

  void _initializeTimerService() {
    _timerService = PomodoroTimerService(
      workDuration: workDuration.toInt(),
      shortBreakDuration: shortBreak.toInt(),
      longBreakDuration: longBreak.toInt(),
      autoStart: autoStart,
      enableNotifications: enableSounds,
      onWorkSessionStart: _onWorkSessionStart,
      onShortBreakStart: _onShortBreakStart,
      onLongBreakStart: _onLongBreakStart,
      onTimerComplete: _onTimerComplete,
    );
    _updateDisplayTime();
  }

  void _startUiUpdateTimer() {
    _uiUpdateTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _updateDisplayTime();
          // Handle pulse animation
          if (_isRunning && !_pulseController.isAnimating) {
            _pulseController.repeat(reverse: true);
          } else if (!_isRunning && _pulseController.isAnimating) {
            _pulseController.stop();
            _pulseController.reset();
          }
        });
      }
    });
  }

  void _updateDisplayTime() {
    int minutes = _timerService.minutesRemaining;
    int seconds = _timerService.secondsInCurrentMinute;

    double totalSeconds;
    switch (_timerService.currentState) {
      case TimerState.work:
        totalSeconds = workDuration * 60;
        break;
      case TimerState.shortBreak:
        totalSeconds = shortBreak * 60;
        break;
      case TimerState.longBreak:
        totalSeconds = longBreak * 60;
        break;
      case TimerState.idle:
        totalSeconds = workDuration * 60;
        break;
    }

    _displayTime =
        "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
    _percentComplete = _timerService.secondsRemaining > 0
        ? (_timerService.secondsRemaining / totalSeconds)
        : 1.0;
    _isRunning = _timerService.isRunning;
    _currentTimerState = _timerService.currentState;
  }

  String selectedVoiceGender = 'male';

  void _onWorkSessionStart() {
    debugPrint('Work session started');
    if (enableSounds) {
      SoundManager.playSound(
        context: context,
        soundType: 'work_start',
        voiceGender: selectedVoiceGender,
      );
    }
    if (blockDistractions) debugPrint('Blocking distractions');
  }

  void _onShortBreakStart() {
    debugPrint('Short break started');
    if (enableSounds) {
      SoundManager.playSound(
        context: context,
        soundType: 'break_start',
        voiceGender: selectedVoiceGender,
      );
    }
    setState(() {
      _completedWorkSessions++;
    });
  }

  void _onLongBreakStart() {
    debugPrint('Long break started');
    if (enableSounds) {
      SoundManager.playSound(
        context: context,
        soundType: 'long_break_start',
        voiceGender: selectedVoiceGender,
      );
    }
    setState(() {
      _completedWorkSessions++;
    });
  }

  void _onTimerComplete() {
    debugPrint('Timer completed');
    if (enableSounds) {
      SoundManager.playSound(
        context: context,
        soundType: 'timer_complete',
        voiceGender: selectedVoiceGender,
      );
    }
  }

  void _handlePlayPausePressed() {
    _buttonScaleController
        .forward()
        .then((_) => _buttonScaleController.reverse());
    setState(() {
      if (_isRunning) {
        _timerService.pauseTimer();
      } else {
        if (_timerService.currentState == TimerState.idle) {
          _timerService.startWorkSession();
        } else {
          _timerService.resumeTimer();
        }
      }
    });
  }

  void _handleReloadPressed() {
    setState(() {
      _timerService.resetTimer();
      if (_timerService.currentState == TimerState.idle) {
        _timerService.startWorkSession();
      }
    });
  }

  void _handleSkipPressed() {
    setState(() {
      // Skip to next session
      if (_currentTimerState == TimerState.work) {
        // If in work session, increment count and start break
        _completedWorkSessions++;
        if (_completedWorkSessions % 4 == 0) {
          _timerService.startLongBreak();
        } else {
          _timerService.startShortBreak();
        }
      } else {
        // If in break, start new work session
        _timerService.startWorkSession();
      }
    });
  }

  void _resetAllSessions() {
    setState(() {
      _completedWorkSessions = 0;
      _timerService.resetTimer();
    });
  }

  Color _getTimerColor() {
    switch (_currentTimerState) {
      case TimerState.work:
        return const Color(0xFFFF5C50);
      case TimerState.shortBreak:
      case TimerState.longBreak:
        return const Color(0xFF4CAF50);
      case TimerState.idle:
        return const Color(0xFFFF5C50);
    }
  }

  String _getStatusText(AppLocalizations l10n) {
    switch (_currentTimerState) {
      case TimerState.work:
        return _isRunning ? 'Focus Time' : 'Paused';
      case TimerState.shortBreak:
        return _isRunning ? 'Short Break' : 'Paused';
      case TimerState.longBreak:
        return _isRunning ? 'Long Break' : 'Paused';
      case TimerState.idle:
        return 'Ready to Focus';
    }
  }

  @override
  void dispose() {
    _timerService.dispose();
    _uiUpdateTimer?.cancel();
    _pulseController.dispose();
    _buttonScaleController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final timerColor = _getTimerColor();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Session Type Indicator
          _buildSessionTypeChips(l10n),
          const SizedBox(height: 32),

          // Timer Display
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _isRunning ? _pulseAnimation.value : 1.0,
                child: child,
              );
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer glow effect when running
                if (_isRunning)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: timerColor.withValues(alpha: 0.15),
                          blurRadius: 40,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                  ),
                CircularPercentIndicator(
                  radius: 120.0,
                  lineWidth: 12.0,
                  animation: true,
                  animationDuration: 300,
                  backgroundColor: FluentTheme.of(context)
                      .inactiveBackgroundColor
                      .withValues(alpha: 0.3),
                  percent: _percentComplete.clamp(0.0, 1.0),
                  center: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _displayTime,
                        style: TextStyle(
                          fontWeight: FontWeight.w300,
                          fontSize: 52.0,
                          fontFeatures: const [FontFeature.tabularFigures()],
                          color: timerColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Text(
                          _getStatusText(l10n),
                          key: ValueKey(_getStatusText(l10n)),
                          style: FluentTheme.of(context)
                              .typography
                              .caption
                              ?.copyWith(
                                color: FluentTheme.of(context)
                                    .typography
                                    .caption
                                    ?.color
                                    ?.withValues(alpha: 0.6),
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ),
                    ],
                  ),
                  circularStrokeCap: CircularStrokeCap.round,
                  progressColor: timerColor,
                ),
              ],
            ),
          ),
          const SizedBox(height: 36),

          // Control Buttons
          _buildControlButtons(context, timerColor),
          const SizedBox(height: 24),

          // Session counter
          _buildSessionCounter(context),
        ],
      ),
    );
  }

  Widget _buildSessionTypeChips(AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SessionChip(
          label: 'Focus',
          isActive: _currentTimerState == TimerState.work ||
              _currentTimerState == TimerState.idle,
          color: const Color(0xFFFF5C50),
          onTap: () {
            if (_currentTimerState != TimerState.work &&
                _currentTimerState != TimerState.idle) {
              setState(() {
                _timerService.startWorkSession();
              });
            }
          },
        ),
        const SizedBox(width: 8),
        SessionChip(
          label: 'Short Break',
          isActive: _currentTimerState == TimerState.shortBreak,
          color: const Color(0xFF4CAF50),
          onTap: () {
            if (_currentTimerState != TimerState.shortBreak) {
              setState(() {
                _timerService.startShortBreak();
              });
            }
          },
        ),
        const SizedBox(width: 8),
        SessionChip(
          label: 'Long Break',
          isActive: _currentTimerState == TimerState.longBreak,
          color: const Color(0xFF42A5F5),
          onTap: () {
            if (_currentTimerState != TimerState.longBreak) {
              setState(() {
                _timerService.startLongBreak();
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildControlButtons(BuildContext context, Color timerColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ControlButton(
          icon: FluentIcons.refresh,
          onPressed: _handleReloadPressed,
          tooltip: 'Restart Session',
        ),
        const SizedBox(width: 16),

        ControlButton(
          icon: FluentIcons.previous,
          onPressed: _resetAllSessions,
          tooltip: 'Reset All',
        ),
        const SizedBox(width: 20),

        // Main play/pause button
        ScaleTransition(
          scale: _buttonScaleAnimation,
          child: PlayPauseButton(
            isRunning: _isRunning,
            color: timerColor,
            onPressed: _handlePlayPausePressed,
          ),
        ),

        const SizedBox(width: 20),
        ControlButton(
          icon: FluentIcons.next,
          onPressed: _handleSkipPressed,
          tooltip: 'Skip to Next',
        ),
        const SizedBox(width: 16),

        ControlButton(
          icon: FluentIcons.settings,
          onPressed: () => _showSettingsDialog(context),
          tooltip: 'Settings',
        ),
      ],
    );
  }

  Widget _buildSessionCounter(BuildContext context) {
    // Show 4 dots representing sessions until long break
    final sessionsUntilLongBreak = 4;
    final currentCycleProgress =
        _completedWorkSessions % sessionsUntilLongBreak;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(sessionsUntilLongBreak, (index) {
            final isCompleted = index < currentCycleProgress;
            final isCurrent = index == currentCycleProgress &&
                (_currentTimerState == TimerState.work ||
                    _currentTimerState == TimerState.idle);

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                width: isCurrent ? 24 : 10,
                height: 10,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: isCompleted
                      ? const Color(0xFFFF5C50)
                      : isCurrent
                          ? const Color(0xFFFF5C50).withValues(alpha: 0.5)
                          : FluentTheme.of(context).inactiveBackgroundColor,
                  boxShadow: isCompleted || isCurrent
                      ? [
                          BoxShadow(
                            color:
                                const Color(0xFFFF5C50).withValues(alpha: 0.3),
                            blurRadius: 4,
                            spreadRadius: 0,
                          ),
                        ]
                      : null,
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Text(
          '$_completedWorkSessions sessions completed',
          style: FluentTheme.of(context).typography.caption?.copyWith(
                color: FluentTheme.of(context)
                    .typography
                    .caption
                    ?.color
                    ?.withValues(alpha: 0.5),
              ),
        ),
      ],
    );
  }

  void _saveSettings(
      double newWorkDuration,
      double newShortBreak,
      double newLongBreak,
      bool newAutoStart,
      bool newBlockDistractions,
      bool newEnableSounds,
      String newSelectedMode) {
    settingsManager.updateSetting(
        "focusModeSettings.workDuration", newWorkDuration);
    settingsManager.updateSetting(
        "focusModeSettings.shortBreak", newShortBreak);
    settingsManager.updateSetting("focusModeSettings.longBreak", newLongBreak);
    settingsManager.updateSetting("focusModeSettings.autoStart", newAutoStart);
    settingsManager.updateSetting(
        "focusModeSettings.blockDistractions", newBlockDistractions);
    settingsManager.updateSetting(
        "focusModeSettings.enableSoundsNotifications", newEnableSounds);
    settingsManager.updateSetting(
        "focusModeSettings.selectedMode", newSelectedMode);

    setState(() {
      workDuration = newWorkDuration;
      shortBreak = newShortBreak;
      longBreak = newLongBreak;
      autoStart = newAutoStart;
      blockDistractions = newBlockDistractions;
      enableSounds = newEnableSounds;
      selectedMode = newSelectedMode;

      _timerService.updateConfig(
          workDuration: newWorkDuration.toInt(),
          shortBreakDuration: newShortBreak.toInt(),
          longBreakDuration: newLongBreak.toInt(),
          autoStart: newAutoStart,
          enableNotifications: newEnableSounds);

      if (!_timerService.isRunning) {
        _timerService.resetTimer();
      }
    });
  }

  void _showSettingsDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;

    double dialogWorkDuration = workDuration;
    double dialogShortBreak = shortBreak;
    double dialogLongBreak = longBreak;
    bool dialogAutoStart = autoStart;
    bool dialogBlockDistractions = blockDistractions;
    bool dialogEnableSounds = enableSounds;
    String dialogSelectedMode = selectedMode;

    await showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return ContentDialog(
            constraints: const BoxConstraints(maxWidth: 420),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: FluentTheme.of(context)
                        .accentColor
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    FluentIcons.settings,
                    size: 18,
                    color: FluentTheme.of(context).accentColor,
                  ),
                ),
                const SizedBox(width: 12),
                Text(l10n.focusModeSettingsTitle),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Mode Selection
                  Text(
                    'Focus Mode Preset',
                    style: FluentTheme.of(context).typography.bodyStrong,
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ComboBox<String>(
                      value: dialogSelectedMode,
                      isExpanded: true,
                      items: [
                        l10n.modeCustom,
                        l10n.modeDeepWork,
                        l10n.modeQuickTasks,
                        l10n.modeReading
                      ].map((mode) {
                        return ComboBoxItem<String>(
                          value: mode,
                          child: Text(mode),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() {
                            dialogSelectedMode = value;
                            if (value == l10n.modeDeepWork) {
                              dialogWorkDuration = 60;
                              dialogShortBreak = 10;
                              dialogLongBreak = 30;
                            } else if (value == l10n.modeQuickTasks) {
                              dialogWorkDuration = 25;
                              dialogShortBreak = 5;
                              dialogLongBreak = 15;
                            } else if (value == l10n.modeReading) {
                              dialogWorkDuration = 45;
                              dialogShortBreak = 10;
                              dialogLongBreak = 20;
                            }
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Duration Settings
                  _buildSliderSetting(
                    context,
                    label: 'Focus Duration',
                    value: dialogWorkDuration,
                    displayValue: '${dialogWorkDuration.toInt()} min',
                    min: 15,
                    max: 120,
                    divisions: 21,
                    color: const Color(0xFFFF5C50),
                    onChanged: (value) => setDialogState(() {
                      dialogWorkDuration = value;
                      dialogSelectedMode = l10n.modeCustom;
                    }),
                  ),
                  const SizedBox(height: 16),

                  _buildSliderSetting(
                    context,
                    label: 'Short Break',
                    value: dialogShortBreak,
                    displayValue: '${dialogShortBreak.toInt()} min',
                    min: 1,
                    max: 15,
                    divisions: 14,
                    color: const Color(0xFF4CAF50),
                    onChanged: (value) => setDialogState(() {
                      dialogShortBreak = value;
                      dialogSelectedMode = l10n.modeCustom;
                    }),
                  ),
                  const SizedBox(height: 16),

                  _buildSliderSetting(
                    context,
                    label: 'Long Break',
                    value: dialogLongBreak,
                    displayValue: '${dialogLongBreak.toInt()} min',
                    min: 5,
                    max: 60,
                    divisions: 11,
                    color: const Color(0xFF42A5F5),
                    onChanged: (value) => setDialogState(() {
                      dialogLongBreak = value;
                      dialogSelectedMode = l10n.modeCustom;
                    }),
                  ),
                  const SizedBox(height: 20),

                  // Toggle Options
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: FluentTheme.of(context)
                          .inactiveBackgroundColor
                          .withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        _buildToggleOption(
                          context,
                          label: l10n.autoStartNextSession,
                          value: dialogAutoStart,
                          icon: FluentIcons.play,
                          onChanged: (value) =>
                              setDialogState(() => dialogAutoStart = value!),
                        ),
                        const SizedBox(height: 12),
                        _buildToggleOption(
                          context,
                          label: "l10n.enableSounds",
                          value: dialogEnableSounds,
                          icon: FluentIcons.ringer,
                          onChanged: (value) =>
                              setDialogState(() => dialogEnableSounds = value!),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              Button(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(FluentIcons.refresh, size: 12),
                    const SizedBox(width: 6),
                    Text(l10n.resetAll),
                  ],
                ),
                onPressed: () {
                  setDialogState(() {
                    dialogWorkDuration = 25;
                    dialogShortBreak = 5;
                    dialogLongBreak = 15;
                    dialogAutoStart = false;
                    dialogBlockDistractions = false;
                    dialogEnableSounds = true;
                    dialogSelectedMode = l10n.modeCustom;
                  });
                },
              ),
              FilledButton(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(FluentIcons.save, size: 12),
                    const SizedBox(width: 6),
                    Text(l10n.save),
                  ],
                ),
                onPressed: () {
                  _saveSettings(
                      dialogWorkDuration,
                      dialogShortBreak,
                      dialogLongBreak,
                      dialogAutoStart,
                      dialogBlockDistractions,
                      dialogEnableSounds,
                      dialogSelectedMode);
                  Navigator.pop(context, l10n.saved);
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSliderSetting(
    BuildContext context, {
    required String label,
    required double value,
    required String displayValue,
    required double min,
    required double max,
    required int divisions,
    required Color color,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: FluentTheme.of(context).typography.body),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                displayValue,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderThemeData(
            thumbColor: WidgetStateProperty.all(color),
            activeColor: WidgetStateProperty.all(color),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildToggleOption(
    BuildContext context, {
    required String label,
    required bool value,
    required IconData icon,
    required ValueChanged<bool?> onChanged,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: FluentTheme.of(context).accentColor),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label, style: FluentTheme.of(context).typography.body),
        ),
        ToggleSwitch(
          checked: value,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
