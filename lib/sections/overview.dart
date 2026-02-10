import 'package:fluent_ui/fluent_ui.dart';
import 'package:screentime/l10n/app_localizations.dart';
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
    _loadData();

    // Show rebranding modal after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      RebrandingModal.showIfNeeded(context);
    });
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

class RebrandingModal extends StatelessWidget {
  const RebrandingModal({super.key});

  static const String _dismissedKey = 'rebranding_modal_dismissed';
  static final DateTime _expiryDate = DateTime(2026, 2, 25);

  /// Check if modal should be shown and display it if needed
  static Future<void> showIfNeeded(BuildContext context) async {
    final now = DateTime.now();

    // Don't show if date is on or after Feb 25, 2026
    if (now.isAfter(_expiryDate) || now.isAtSameMomentAs(_expiryDate)) {
      return;
    }

    // Check if user has already dismissed it
    final prefs = await SharedPreferences.getInstance();
    final dismissed = prefs.getBool(_dismissedKey) ?? false;

    if (dismissed) {
      return;
    }

    // Show the modal
    if (context.mounted) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const RebrandingModal(),
      );
    }
  }

  Future<void> _dismiss(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_dismissedKey, true);

    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    return ContentDialog(
      constraints: const BoxConstraints(maxWidth: 480),
      content: Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Celebration icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.accentColor.withValues(alpha: 0.2),
                    theme.accentColor.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Text(
                  '🎉',
                  style: TextStyle(fontSize: 48),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Main message
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: theme.typography.body?.color,
                  height: 1.3,
                ),
                children: const [
                  TextSpan(text: 'TimeMark is now '),
                  TextSpan(
                    text: 'Scolect',
                    style: TextStyle(
                      color: Color(0xffA855F7), // Purple accent
                    ),
                  ),
                  TextSpan(text: ' 🎉'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Subtitle
            Text(
              'Same powerful productivity tracking,\nnew name and experience!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: theme.inactiveColor,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),

            // Continue button
            FilledButton(
              onPressed: () => _dismiss(context),
              style: ButtonStyle(
                padding: WidgetStateProperty.all(
                  const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
              ),
              child: const Text(
                'Continue',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
