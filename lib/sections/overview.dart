import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:screentime/l10n/app_localizations.dart';
import 'package:screentime/main.dart' as mn;
import 'package:shared_preferences/shared_preferences.dart';
import './controller/data_controllers/overview_data_controller.dart';
import 'UI sections/Overview/bottom.dart';
import 'UI sections/Overview/statCards.dart';
import 'UI sections/Overview/main_app.dart';

class Overview extends StatefulWidget {
  const Overview({super.key});

  @override
  State<Overview> createState() => _OverviewState();
}

class _OverviewState extends State<Overview> with TickerProviderStateMixin {
  // Data
  String totalScreenTime = "0h 0m";
  String totalProductiveTime = "0h 0m";
  String mostUsedApp = "None";
  String focusSessions = "0";
  List<dynamic> topApplications = [];
  List<dynamic> categoryApplications = [];
  List<dynamic> applicationLimits = [];
  double screenTime = 0.0;
  double productiveScore = 0.0;

  // States
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = "";
  bool _hasData = false;

  // Animation
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    );
    // Register this screen's refresh callback
    WidgetsBinding.instance.addPostFrameCallback((_) {
      mn.navigationState.registerRefreshCallback(_loadData);
    });
    _loadData();
    if (Platform.isWindows) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        RebrandingModal.showIfNeeded(context);
      });
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      final DailyOverviewData dataProvider = DailyOverviewData();
      final OverviewData overviewData = await dataProvider.fetchTodayOverview();

      setState(() {
        totalScreenTime = overviewData.formattedTotalScreenTime;
        totalProductiveTime = overviewData.formattedProductiveTime;
        mostUsedApp = overviewData.mostUsedApp;
        focusSessions = overviewData.focusSessions.toString();
        screenTime = overviewData.screenTimePercentage / 100;
        productiveScore = overviewData.productivityScore / 100;

        topApplications = overviewData.topApplications
            .map((app) => {
                  "name": app.name,
                  "category": app.category,
                  "screenTime": app.formattedScreenTime,
                  "percentageOfTotalTime": app.percentageOfTotalTime,
                  "isVisible": app.isVisible
                })
            .toList();

        categoryApplications = overviewData.categoryBreakdown
            .map((category) => {
                  "name": category.name,
                  "totalScreenTime": category.formattedTotalScreenTime,
                  "percentageOfTotalTime": category.percentageOfTotalTime
                })
            .toList();

        applicationLimits = overviewData.applicationLimits
            .map((limit) => {
                  "name": limit.name,
                  "category": limit.category,
                  "dailyLimit": limit.formattedDailyLimit,
                  "actualUsage": limit.formattedActualUsage,
                  "percentageOfLimit": limit.percentageOfLimit,
                  "percentageOfTotalTime": limit.percentageOfTotalTime
                })
            .toList();

        _isLoading = false;
        _hasData = topApplications.isNotEmpty ||
            categoryApplications.isNotEmpty ||
            applicationLimits.isNotEmpty ||
            int.parse(focusSessions) > 0;
      });

      _fadeController.forward(from: 0);
    } catch (e) {
      debugPrint('Error loading overview data: $e');
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage =
            AppLocalizations.of(context)!.errorLoadingData(e.toString());
      });
    }
  }

  Future<void> refreshData() async {
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading) {
      return ScaffoldPage(
        padding: EdgeInsets.zero,
        content: _buildLoadingState(l10n),
      );
    }

    if (_hasError) {
      return ScaffoldPage(
        padding: EdgeInsets.zero,
        content: _buildErrorState(l10n),
      );
    }

    if (!_hasData) {
      return ScaffoldPage(
        padding: EdgeInsets.zero,
        content: _buildEmptyState(l10n),
      );
    }

    return ScaffoldPage(
      padding: EdgeInsets.zero,
      content: FadeTransition(
        opacity: _fadeAnimation,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return _ResponsiveOverviewContent(
              constraints: constraints,
              refreshData: refreshData,
              totalScreenTime: totalScreenTime,
              totalProductiveTime: totalProductiveTime,
              mostUsedApp: mostUsedApp,
              focusSessions: focusSessions,
              topApplications: topApplications,
              categoryApplications: categoryApplications,
              applicationLimits: applicationLimits,
              screenTime: screenTime,
              productiveScore: productiveScore,
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoadingState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const ProgressRing(strokeWidth: 3),
          const SizedBox(height: 20),
          Text(
            l10n.loadingProductivityData,
            style: TextStyle(
              color: FluentTheme.of(context).inactiveColor,
              fontSize: 14,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildErrorState(AppLocalizations l10n) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 360),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.warningPrimaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                FluentIcons.error_badge,
                size: 40,
                color: Colors.warningPrimaryColor,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: refreshData,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Text(l10n.tryAgain),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 360),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color:
                    FluentTheme.of(context).accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                FluentIcons.analytics_view,
                size: 48,
                color: FluentTheme.of(context).accentColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.noActivityDataAvailable,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.startUsingApplications,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: FluentTheme.of(context).inactiveColor,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: refreshData,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(FluentIcons.refresh, size: 14),
                    const SizedBox(width: 8),
                    Text(l10n.refreshData),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// RESPONSIVE CONTENT WRAPPER
// ============================================================================

class _ResponsiveOverviewContent extends StatelessWidget {
  final BoxConstraints constraints;
  final VoidCallback refreshData;
  final String totalScreenTime;
  final String totalProductiveTime;
  final String mostUsedApp;
  final String focusSessions;
  final List<dynamic> topApplications;
  final List<dynamic> categoryApplications;
  final List<dynamic> applicationLimits;
  final double screenTime;
  final double productiveScore;

  const _ResponsiveOverviewContent({
    required this.constraints,
    required this.refreshData,
    required this.totalScreenTime,
    required this.totalProductiveTime,
    required this.mostUsedApp,
    required this.focusSessions,
    required this.topApplications,
    required this.categoryApplications,
    required this.applicationLimits,
    required this.screenTime,
    required this.productiveScore,
  });

  // Breakpoints
  static const double compactBreakpoint = 700;
  static const double mediumBreakpoint = 1000;

  bool get isCompact => constraints.maxWidth < compactBreakpoint;
  bool get isMedium => constraints.maxWidth < mediumBreakpoint;

  double get horizontalPadding {
    if (isCompact) return 12;
    if (isMedium) return 18;
    return 24;
  }

  double get verticalSpacing {
    if (isCompact) return 12;
    if (isMedium) return 16;
    return 20;
  }

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return _buildCompactLayout(context);
    }
    return _buildExpandedLayout(context);
  }

  // Scrollable layout for narrow screens
  Widget _buildCompactLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        horizontalPadding * 0.67,
        horizontalPadding,
        horizontalPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(refresh: refreshData),
          SizedBox(height: verticalSpacing),
          StatsCards(
            totalScreenTime: totalScreenTime,
            totalProductiveTime: totalProductiveTime,
            mostUsedApp: mostUsedApp,
            focusSessions: focusSessions,
          ),
          SizedBox(height: verticalSpacing),
          // Main content - stacked vertically
          _ResponsiveMainContent(
            topApplications: topApplications,
            categoryApplications: categoryApplications,
            isCompact: true,
          ),
          SizedBox(height: verticalSpacing),
          // Bottom section - stacked vertically
          _ResponsiveBottomSection(
            screenTime: screenTime,
            productiveScore: productiveScore,
            applicationLimits: applicationLimits,
            isCompact: true,
            isMedium: false,
          ),
        ],
      ),
    );
  }

  // Fixed layout for wider screens
  Widget _buildExpandedLayout(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        horizontalPadding * 0.67,
        horizontalPadding,
        horizontalPadding,
      ),
      child: Column(
        children: [
          _Header(refresh: refreshData),
          SizedBox(height: verticalSpacing),
          StatsCards(
            totalScreenTime: totalScreenTime,
            totalProductiveTime: totalProductiveTime,
            mostUsedApp: mostUsedApp,
            focusSessions: focusSessions,
          ),
          SizedBox(height: verticalSpacing),
          // Main content - takes remaining space
          Expanded(
            flex: 5,
            child: _ResponsiveMainContent(
              topApplications: topApplications,
              categoryApplications: categoryApplications,
              isCompact: false,
            ),
          ),
          SizedBox(height: verticalSpacing),
          // Bottom section
          Expanded(
            flex: 3,
            child: _ResponsiveBottomSection(
              screenTime: screenTime,
              productiveScore: productiveScore,
              applicationLimits: applicationLimits,
              isCompact: false,
              isMedium: isMedium,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// HEADER
// ============================================================================

class _Header extends StatelessWidget {
  final VoidCallback refresh;

  const _Header({required this.refresh});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = FluentTheme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 400;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.overviewTitle,
                    style: theme.typography.subtitle?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: isNarrow ? 18 : null,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _getGreeting(l10n),
                    style: TextStyle(
                      color: theme.inactiveColor,
                      fontSize: isNarrow ? 11 : 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            _RefreshButton(onPressed: refresh, compact: isNarrow),
          ],
        );
      },
    );
  }

  String _getGreeting(AppLocalizations l10n) {
    final hour = DateTime.now().hour;
    if (hour < 12) return l10n.greetingMorning;
    if (hour < 17) return l10n.greetingAfternoon;
    return l10n.greetingEvening;
  }
}

class _RefreshButton extends StatefulWidget {
  final VoidCallback onPressed;
  final bool compact;

  const _RefreshButton({required this.onPressed, this.compact = false});

  @override
  State<_RefreshButton> createState() => _RefreshButtonState();
}

class _RefreshButtonState extends State<_RefreshButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: Button(
          style: ButtonStyle(
            padding: WidgetStateProperty.all(
              EdgeInsets.symmetric(
                vertical: widget.compact ? 6 : 8,
                horizontal: widget.compact ? 10 : 14,
              ),
            ),
          ),
          onPressed: widget.onPressed,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedRotation(
                turns: _isHovered ? 0.5 : 0,
                duration: const Duration(milliseconds: 300),
                child:
                    Icon(FluentIcons.refresh, size: widget.compact ? 12 : 14),
              ),
              if (!widget.compact) ...[
                const SizedBox(width: 8),
                Text(
                  l10n.refresh,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// RESPONSIVE MAIN CONTENT
// ============================================================================

class _ResponsiveMainContent extends StatelessWidget {
  final List<dynamic> topApplications;
  final List<dynamic> categoryApplications;
  final bool isCompact;

  const _ResponsiveMainContent({
    required this.topApplications,
    required this.categoryApplications,
    required this.isCompact,
  });

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return Column(
        children: [
          SizedBox(
            height: 320,
            child: _ContentCard(
              child: TopApplicationsList(data: topApplications),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 320,
            child: _ContentCard(
              child: CategoryBreakdownList(data: categoryApplications),
            ),
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: _ContentCard(
            child: TopApplicationsList(data: topApplications),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _ContentCard(
            child: CategoryBreakdownList(data: categoryApplications),
          ),
        ),
      ],
    );
  }
}

class _ContentCard extends StatelessWidget {
  final Widget child;

  const _ContentCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.micaBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.resources.cardStrokeColorDefault,
          width: 1,
        ),
      ),
      child: child,
    );
  }
}

// ============================================================================
// RESPONSIVE BOTTOM SECTION
// ============================================================================

class _ResponsiveBottomSection extends StatelessWidget {
  final double screenTime;
  final double productiveScore;
  final List<dynamic> applicationLimits;
  final bool isCompact;
  final bool isMedium;

  const _ResponsiveBottomSection({
    required this.screenTime,
    required this.productiveScore,
    required this.applicationLimits,
    required this.isCompact,
    required this.isMedium,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final l10n = AppLocalizations.of(context)!;

    if (isCompact) {
      return _buildCompactLayout(theme, l10n);
    }

    if (isMedium) {
      return _buildMediumLayout(theme, l10n);
    }

    return _buildExpandedLayout(theme, l10n);
  }

  // Stacked vertical layout for narrow screens
  Widget _buildCompactLayout(FluentThemeData theme, AppLocalizations l10n) {
    return Column(
      children: [
        // Progress cards in a row
        SizedBox(
          height: 140,
          child: Row(
            children: [
              Expanded(
                child: ProgressCard(
                  title: l10n.screenTimeProgress,
                  value: screenTime,
                  color: const Color(0xffA855F7),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ProgressCard(
                  title: l10n.productiveScoreProgress,
                  value: productiveScore,
                  color: const Color(0xff22C55E),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Application limits
        SizedBox(
          height: 220,
          child: _buildApplicationLimitsCard(theme),
        ),
      ],
    );
  }

  // Two-column layout with limits on left, progress stacked on right
  Widget _buildMediumLayout(FluentThemeData theme, AppLocalizations l10n) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Application limits - larger portion
        Expanded(
          flex: 4,
          child: _buildApplicationLimitsCard(theme),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: ProgressCard(
            title: 'Screen\nTime',
            value: screenTime,
            color: const Color(0xffA855F7),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: ProgressCard(
            title: 'Productive\nScore',
            value: productiveScore,
            color: const Color(0xff22C55E),
          ),
        ),
      ],
    );
  }

  // Full horizontal layout for wide screens
  Widget _buildExpandedLayout(FluentThemeData theme, AppLocalizations l10n) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 5,
          child: _buildApplicationLimitsCard(theme),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: ProgressCard(
            title: 'Screen\nTime',
            value: screenTime,
            color: const Color(0xffA855F7),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: ProgressCard(
            title: 'Productive\nScore',
            value: productiveScore,
            color: const Color(0xff22C55E),
          ),
        ),
      ],
    );
  }

  Widget _buildApplicationLimitsCard(FluentThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.micaBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.resources.cardStrokeColorDefault,
          width: 1,
        ),
      ),
      child: ApplicationLimitsList(data: applicationLimits),
    );
  }
}

class RebrandingModal extends StatefulWidget {
  const RebrandingModal({super.key});

  static const String _dismissedKey = 'rebranding_modal_dismissed';
  static final DateTime _expiryDate = DateTime(2026, 2, 25);

  static Future<void> showIfNeeded(BuildContext context) async {
    final now = DateTime.now();

    if (now.isAfter(_expiryDate) || now.isAtSameMomentAs(_expiryDate)) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final dismissed = prefs.getBool(_dismissedKey) ?? false;

    if (dismissed) return;

    if (context.mounted) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const RebrandingModal(),
      );
    }
  }

  @override
  State<RebrandingModal> createState() => _RebrandingModalState();
}

class _RebrandingModalState extends State<RebrandingModal>
    with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final AnimationController _pulseController;
  late final AnimationController _shimmerController;

  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _iconBounceAnimation;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Main entrance animation
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.1, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    _iconBounceAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.3, 0.8, curve: Curves.elasticOut),
      ),
    );

    // Subtle pulse for the icon
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Shimmer effect controller
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _entranceController.forward().then((_) {
      _pulseController.repeat(reverse: true);
      _shimmerController.repeat();
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _pulseController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  Future<void> _dismiss(BuildContext context) async {
    // Reverse animation before closing
    await _entranceController.reverse();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(RebrandingModal._dismissedKey, true);

    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    const primaryPurple = Color(0xFFA855F7);
    const deepPurple = Color(0xFF7C3AED);
    const lightPurple = Color(0xFFC084FC);
    const pinkAccent = Color(0xFFEC4899);

    return AnimatedBuilder(
      animation: _entranceController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: child,
            ),
          ),
        );
      },
      child: ContentDialog(
        constraints: const BoxConstraints(maxWidth: 520),
        content: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              // Background gradient decoration
              Positioned(
                top: -60,
                right: -60,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        primaryPurple.withValues(alpha: isDark ? 0.15 : 0.08),
                        primaryPurple.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -40,
                left: -40,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        pinkAccent.withValues(alpha: isDark ? 0.12 : 0.06),
                        pinkAccent.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),

              // Main content
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 36),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Animated icon with glow
                    AnimatedBuilder(
                      animation: Listenable.merge(
                          [_iconBounceAnimation, _pulseAnimation]),
                      builder: (context, child) {
                        return Transform.scale(
                          scale:
                              _iconBounceAnimation.value * _pulseAnimation.value,
                          child: child,
                        );
                      },
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0x30A855F7),
                              Color(0x18EC4899),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: primaryPurple.withValues(alpha: 0.2),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: primaryPurple.withValues(alpha: 0.15),
                              blurRadius: 30,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            '🎉',
                            style: TextStyle(fontSize: 52),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // "NEW NAME" badge
                    _buildStaggeredFade(
                      delay: 0.35,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 5),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [deepPurple, pinkAccent],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: deepPurple.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Text(
                          '✨ NEW NAME',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Main heading with shimmer on "Scolect"
                    _buildStaggeredFade(
                      delay: 0.45,
                      child: AnimatedBuilder(
                        animation: _shimmerController,
                        builder: (context, _) {
                          return RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: theme.typography.body?.color,
                                height: 1.3,
                              ),
                              children: [
                                const TextSpan(text: 'TimeMark is now\n'),
                                WidgetSpan(
                                  alignment: PlaceholderAlignment.baseline,
                                  baseline: TextBaseline.alphabetic,
                                  child: ShaderMask(
                                    shaderCallback: (bounds) {
                                      final shimmerValue =
                                          _shimmerController.value;
                                      return LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: const [
                                          deepPurple,
                                          lightPurple,
                                          pinkAccent,
                                          lightPurple,
                                          deepPurple,
                                        ],
                                        stops: [
                                          0.0,
                                          (shimmerValue - 0.2).clamp(0.0, 1.0),
                                          shimmerValue,
                                          (shimmerValue + 0.2).clamp(0.0, 1.0),
                                          1.0,
                                        ],
                                      ).createShader(bounds);
                                    },
                                    child: const Text(
                                      'Scolect',
                                      style: TextStyle(
                                        fontSize: 34,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Decorative divider
                    _buildStaggeredFade(
                      delay: 0.5,
                      child: Container(
                        width: 60,
                        height: 3,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [deepPurple, pinkAccent],
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Subtitle
                    _buildStaggeredFade(
                      delay: 0.55,
                      child: Text(
                        'Same powerful productivity tracking.\nA fresh new identity and experience.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: theme.inactiveColor,
                          height: 1.6,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Feature highlights
                    _buildStaggeredFade(
                      delay: 0.65,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.04)
                              : Colors.black.withValues(alpha: 0.02),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : Colors.black.withValues(alpha: 0.06),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildFeatureItem('🚀', 'Faster'),
                            _buildDividerDot(isDark),
                            _buildFeatureItem('🎨', 'Fresher'),
                            _buildDividerDot(isDark),
                            _buildFeatureItem('💪', 'Better'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Continue button with gradient
                    _buildStaggeredFade(
                      delay: 0.75,
                      child: SizedBox(
                        width: double.infinity,
                        child: GestureDetector(
                          onTap: () => _dismiss(context),
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [deepPurple, primaryPurple, pinkAccent],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        primaryPurple.withValues(alpha: 0.35),
                                    blurRadius: 20,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Text(
                                  'Get Started →',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStaggeredFade({
    required double delay,
    required Widget child,
  }) {
    final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: Interval(delay, (delay + 0.3).clamp(0.0, 1.0),
            curve: Curves.easeOut),
      ),
    );

    final slideAnim =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: Interval(delay, (delay + 0.35).clamp(0.0, 1.0),
            curve: Curves.easeOutCubic),
      ),
    );

    return AnimatedBuilder(
      animation: _entranceController,
      builder: (context, _) {
        return Opacity(
          opacity: animation.value,
          child: SlideTransition(
            position: slideAnim,
            child: child,
          ),
        );
      },
    );
  }

  Widget _buildFeatureItem(String emoji, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: FluentTheme.of(context).inactiveColor,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildDividerDot(bool isDark) {
    return Container(
      width: 4,
      height: 4,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDark
            ? Colors.white.withValues(alpha: 0.15)
            : Colors.black.withValues(alpha: 0.12),
      ),
    );
  }
}