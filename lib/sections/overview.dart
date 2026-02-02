import 'package:fluent_ui/fluent_ui.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:screentime/l10n/app_localizations.dart';
import './controller/data_controllers/overview_data_controller.dart';

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
      return _buildLoadingState(l10n);
    }

    if (_hasError) {
      return _buildErrorState(l10n);
    }

    if (!_hasData) {
      return _buildEmptyState(l10n);
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          children: [
            _Header(refresh: refreshData),
            const SizedBox(height: 20),
            // Stats cards - fixed height
            _StatsCards(
              totalScreenTime: totalScreenTime,
              totalProductiveTime: totalProductiveTime,
              mostUsedApp: mostUsedApp,
              focusSessions: focusSessions,
            ),
            const SizedBox(height: 20),
            // Main content - takes remaining space
            Expanded(
              flex: 5,
              child: _MainContent(
                topApplications: topApplications,
                categoryApplications: categoryApplications,
              ),
            ),
            const SizedBox(height: 20),
            // Bottom section - flexible height
            Expanded(
              flex: 3,
              child: _BottomSection(
                screenTime: screenTime,
                productiveScore: productiveScore,
                applicationLimits: applicationLimits,
              ),
            ),
          ],
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
                color: Colors.warningPrimaryColor.withOpacity(0.1),
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
                color: FluentTheme.of(context).accentColor.withOpacity(0.1),
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
// HEADER
// ============================================================================

class _Header extends StatelessWidget {
  final VoidCallback refresh;

  const _Header({required this.refresh});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = FluentTheme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.overviewTitle,
              style: theme.typography.subtitle?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _getGreeting(l10n),
              style: TextStyle(
                color: theme.inactiveColor,
                fontSize: 13,
              ),
            ),
          ],
        ),
        _RefreshButton(onPressed: refresh),
      ],
    );
  }

  String _getGreeting(AppLocalizations l10n) {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good morning! Here's your activity summary.";
    if (hour < 17) return "Good afternoon! Here's your activity summary.";
    return "Good evening! Here's your activity summary.";
  }
}

class _RefreshButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _RefreshButton({required this.onPressed});

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
              const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
            ),
          ),
          onPressed: widget.onPressed,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedRotation(
                turns: _isHovered ? 0.5 : 0,
                duration: const Duration(milliseconds: 300),
                child: const Icon(FluentIcons.refresh, size: 14),
              ),
              const SizedBox(width: 8),
              Text(
                l10n.refresh,
                style:
                    const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// STATS CARDS
// ============================================================================

class _StatsCards extends StatelessWidget {
  final String totalScreenTime;
  final String totalProductiveTime;
  final String mostUsedApp;
  final String focusSessions;

  const _StatsCards({
    required this.totalScreenTime,
    required this.totalProductiveTime,
    required this.mostUsedApp,
    required this.focusSessions,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 800;
        // Dynamic height based on screen size, with min/max bounds
        final screenHeight = MediaQuery.of(context).size.height;
        final cardHeight = (screenHeight * 0.12).clamp(90.0, 120.0);

        final cards = [
          _StatCard(
            icon: FluentIcons.timer,
            title: l10n.totalScreenTime,
            value: totalScreenTime,
            gradient: const LinearGradient(
              colors: [Color(0xff1E3A8A), Color(0xff3B82F6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            height: cardHeight,
          ),
          _StatCard(
            icon: FluentIcons.check_mark,
            title: l10n.productiveTime,
            value: totalProductiveTime,
            gradient: const LinearGradient(
              colors: [Color(0xff14532D), Color(0xff22C55E)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            height: cardHeight,
          ),
          _StatCard(
            icon: FluentIcons.app_icon_default_list,
            title: l10n.mostUsedApp,
            value: mostUsedApp,
            gradient: const LinearGradient(
              colors: [Color(0xff581C87), Color(0xffA855F7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            height: cardHeight,
            isText: true,
          ),
          _StatCard(
            icon: FluentIcons.focus,
            title: l10n.focusSessions,
            value: focusSessions,
            gradient: const LinearGradient(
              colors: [Color(0xff7C2D12), Color(0xffF97316)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            height: cardHeight,
          ),
        ];

        if (isCompact) {
          return Column(
            children: [
              Row(children: [
                Expanded(child: cards[0]),
                const SizedBox(width: 12),
                Expanded(child: cards[1]),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: cards[2]),
                const SizedBox(width: 12),
                Expanded(child: cards[3]),
              ]),
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: cards[0]),
            const SizedBox(width: 12),
            Expanded(child: cards[1]),
            const SizedBox(width: 12),
            Expanded(child: cards[2]),
            const SizedBox(width: 12),
            Expanded(child: cards[3]),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String value;
  final LinearGradient gradient;
  final double height;
  final bool isText;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.gradient,
    required this.height,
    this.isText = false,
  });

  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: widget.height,
        transformAlignment: Alignment.center,
        transform: Matrix4.identity()
          ..setTranslationRaw(0, _isHovered ? -2 : 0, 0),
        decoration: BoxDecoration(
          gradient: widget.gradient,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: widget.gradient.colors.first
                  .withOpacity(_isHovered ? 0.4 : 0.2),
              blurRadius: _isHovered ? 16 : 8,
              offset: Offset(0, _isHovered ? 6 : 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    widget.icon,
                    size: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              Text(
                widget.value,
                style: TextStyle(
                  color: Colors.white,
                  fontSize:
                      widget.isText ? (widget.value.length > 12 ? 16 : 20) : 26,
                  fontWeight: FontWeight.bold,
                  letterSpacing: widget.isText ? 0 : -0.5,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: widget.isText ? 2 : 1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// MAIN CONTENT
// ============================================================================

class _MainContent extends StatelessWidget {
  final List<dynamic> topApplications;
  final List<dynamic> categoryApplications;

  const _MainContent({
    required this.topApplications,
    required this.categoryApplications,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: _ContentCard(
            child: _TopApplicationsList(data: topApplications),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _ContentCard(
            child: _CategoryBreakdownList(data: categoryApplications),
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

class _TopApplicationsList extends StatelessWidget {
  final List<dynamic> data;

  const _TopApplicationsList({required this.data});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = FluentTheme.of(context);

    final filteredData = data
        .where((app) =>
            app['name'] != null &&
            app['name'].toString().trim().isNotEmpty &&
            app['isVisible'] == true)
        .toList()
      ..sort((a, b) => (b['percentageOfTotalTime'] ?? 0)
          .compareTo(a['percentageOfTotalTime'] ?? 0));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xff3B82F6).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  FluentIcons.app_icon_default_list,
                  size: 14,
                  color: Color(0xff3B82F6),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                l10n.topApplications,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '${filteredData.length} apps',
                style: TextStyle(
                  fontSize: 12,
                  color: theme.inactiveColor,
                ),
              ),
            ],
          ),
        ),
        Divider(
          style: DividerThemeData(
            horizontalMargin: const EdgeInsets.symmetric(horizontal: 16),
            thickness: 1,
          ),
        ),
        Expanded(
          child: filteredData.isEmpty
              ? _EmptyState(
                  icon: FluentIcons.app_icon_default,
                  message: l10n.noApplicationDataAvailable,
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  itemCount: filteredData.take(20).length,
                  itemBuilder: (context, index) {
                    final app = filteredData[index];
                    return _ApplicationItem(
                      name: app['name'] ?? l10n.unknownApp,
                      category: app['category'] ?? l10n.uncategorized,
                      screenTime: app['screenTime'] ?? l10n.defaultTime,
                      percentage:
                          (app['percentageOfTotalTime'] ?? 0).toDouble(),
                      color: const Color(0xff3B82F6),
                      index: index,
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _CategoryBreakdownList extends StatelessWidget {
  final List<dynamic> data;

  const _CategoryBreakdownList({required this.data});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = FluentTheme.of(context);

    final filteredData = data
        .where((cat) =>
            cat['name'] != null && cat['name'].toString().trim().isNotEmpty)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xff22C55E).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  FluentIcons.category_classification,
                  size: 14,
                  color: Color(0xff22C55E),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                l10n.categoryBreakdown,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '${filteredData.length} categories',
                style: TextStyle(
                  fontSize: 12,
                  color: theme.inactiveColor,
                ),
              ),
            ],
          ),
        ),
        Divider(
          style: DividerThemeData(
            horizontalMargin: const EdgeInsets.symmetric(horizontal: 16),
            thickness: 1,
          ),
        ),
        Expanded(
          child: filteredData.isEmpty
              ? _EmptyState(
                  icon: FluentIcons.category_classification,
                  message: l10n.noCategoryDataAvailable,
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  itemCount: filteredData.length,
                  itemBuilder: (context, index) {
                    final category = filteredData[index];
                    return _CategoryItem(
                      name: category['name'] ?? l10n.uncategorized,
                      screenTime:
                          category['totalScreenTime'] ?? l10n.defaultTime,
                      percentage:
                          (category['percentageOfTotalTime'] ?? 0).toDouble(),
                      color: _getCategoryColor(index),
                      index: index,
                    );
                  },
                ),
        ),
      ],
    );
  }

  Color _getCategoryColor(int index) {
    final colors = [
      const Color(0xff22C55E),
      const Color(0xff3B82F6),
      const Color(0xffA855F7),
      const Color(0xffF97316),
      const Color(0xffEF4444),
      const Color(0xff06B6D4),
    ];
    return colors[index % colors.length];
  }
}

class _ApplicationItem extends StatefulWidget {
  final String name;
  final String category;
  final String screenTime;
  final double percentage;
  final Color color;
  final int index;

  const _ApplicationItem({
    required this.name,
    required this.category,
    required this.screenTime,
    required this.percentage,
    required this.color,
    required this.index,
  });

  @override
  State<_ApplicationItem> createState() => _ApplicationItemState();
}

class _ApplicationItemState extends State<_ApplicationItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: _isHovered
              ? theme.resources.subtleFillColorSecondary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            // Container(
            //   width: 36,
            //   height: 36,
            //   decoration: BoxDecoration(
            //     color: widget.color.withOpacity(0.12),
            //     borderRadius: BorderRadius.circular(8),
            //   ),
            //   child: Center(
            //     child: Text(
            //       widget.name.isNotEmpty ? widget.name[0].toUpperCase() : '?',
            //       style: TextStyle(
            //         color: widget.color,
            //         fontWeight: FontWeight.w600,
            //         fontSize: 14,
            //       ),
            //     ),
            //   ),
            // ),
            // const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.category,
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.inactiveColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearPercentIndicator(
                      animation: true,
                      animationDuration: 800 + (widget.index * 100),
                      lineHeight: 6,
                      percent: (widget.percentage / 100).clamp(0.0, 1.0),
                      backgroundColor: widget.color.withOpacity(0.12),
                      progressColor: widget.color,
                      padding: EdgeInsets.zero,
                      barRadius: const Radius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.screenTime,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: theme.typography.body?.color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryItem extends StatefulWidget {
  final String name;
  final String screenTime;
  final double percentage;
  final Color color;
  final int index;

  const _CategoryItem({
    required this.name,
    required this.screenTime,
    required this.percentage,
    required this.color,
    required this.index,
  });

  @override
  State<_CategoryItem> createState() => _CategoryItemState();
}

class _CategoryItemState extends State<_CategoryItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: _isHovered
              ? theme.resources.subtleFillColorSecondary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: widget.color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: Text(
                widget.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '${widget.percentage.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.inactiveColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearPercentIndicator(
                      animation: true,
                      animationDuration: 800 + (widget.index * 150),
                      lineHeight: 8,
                      percent: (widget.percentage / 100).clamp(0.0, 1.0),
                      backgroundColor: widget.color.withOpacity(0.12),
                      progressColor: widget.color,
                      padding: EdgeInsets.zero,
                      barRadius: const Radius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.screenTime,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: theme.typography.body?.color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: theme.inactiveColor.withOpacity(0.5)),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(
              color: theme.inactiveColor,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// BOTTOM SECTION
// ============================================================================

class _BottomSection extends StatelessWidget {
  final double screenTime;
  final double productiveScore;
  final List<dynamic> applicationLimits;

  const _BottomSection({
    required this.screenTime,
    required this.productiveScore,
    required this.applicationLimits,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 5,
          child: Container(
            decoration: BoxDecoration(
              color: theme.micaBackgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.resources.cardStrokeColorDefault,
                width: 1,
              ),
            ),
            child: _ApplicationLimitsList(data: applicationLimits),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: _ProgressCard(
            title: 'Screen\nTime',
            value: screenTime,
            color: const Color(0xffA855F7),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: _ProgressCard(
            title: 'Productive\nScore',
            value: productiveScore,
            color: const Color(0xff22C55E),
          ),
        ),
      ],
    );
  }
}

class _ApplicationLimitsList extends StatelessWidget {
  final List<dynamic> data;

  const _ApplicationLimitsList({required this.data});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = FluentTheme.of(context);

    final filteredData = data
        .where((app) =>
            app['name'] != null && app['name'].toString().trim().isNotEmpty)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: const Color(0xffF97316).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  FluentIcons.timer,
                  size: 12,
                  color: Color(0xffF97316),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                l10n.applicationLimits,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: filteredData.isEmpty
              ? _EmptyState(
                  icon: FluentIcons.timer,
                  message: l10n.noApplicationLimitsSet,
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  itemCount: filteredData.length,
                  itemBuilder: (context, index) {
                    final app = filteredData[index];
                    final percentOfLimit =
                        (app['percentageOfLimit'] ?? 0).toDouble();

                    return _LimitItem(
                      name: app['name'] ?? l10n.unknownApp,
                      limit: app['dailyLimit'] ?? l10n.defaultTime,
                      usage: app['actualUsage'] ?? l10n.defaultTime,
                      percentOfLimit: percentOfLimit,
                      isOverLimit: percentOfLimit > 100,
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _LimitItem extends StatelessWidget {
  final String name;
  final String limit;
  final String usage;
  final double percentOfLimit;
  final bool isOverLimit;

  const _LimitItem({
    required this.name,
    required this.limit,
    required this.usage,
    required this.percentOfLimit,
    required this.isOverLimit,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        isOverLimit ? const Color(0xffEF4444) : const Color(0xffF97316);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearPercentIndicator(
                animation: true,
                animationDuration: 1000,
                lineHeight: 5,
                percent: (percentOfLimit / 100).clamp(0.0, 1.0),
                backgroundColor: color.withOpacity(0.15),
                progressColor: color,
                padding: EdgeInsets.zero,
                barRadius: const Radius.circular(3),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 60,
            child: Text(
              '$usage / $limit',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: isOverLimit ? color : null,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressCard extends StatefulWidget {
  final String title;
  final double value;
  final Color color;

  const _ProgressCard({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  State<_ProgressCard> createState() => _ProgressCardState();
}

class _ProgressCardState extends State<_ProgressCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: theme.micaBackgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isHovered
                ? widget.color.withOpacity(0.4)
                : theme.resources.cardStrokeColorDefault,
            width: 1,
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: widget.color.withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final availableSize = constraints.maxHeight < constraints.maxWidth
                ? constraints.maxHeight
                : constraints.maxWidth;
            final radius = (availableSize / 2) - 20;
            final lineWidth = radius * 0.18;

            return Center(
              child: CircularPercentIndicator(
                radius: radius.clamp(30, 200),
                lineWidth: lineWidth.clamp(6, 24),
                animation: true,
                animationDuration: 1200,
                percent: widget.value.clamp(0.0, 1.0),
                center: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${(widget.value * 100).toInt()}%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: (radius * 0.35).clamp(14, 32),
                        color: widget.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: (radius * 0.16).clamp(9, 14),
                        color: theme.inactiveColor,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                circularStrokeCap: CircularStrokeCap.round,
                progressColor: widget.color,
                backgroundColor: widget.color.withOpacity(0.12),
              ),
            );
          },
        ),
      ),
    );
  }
}
