import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:screentime/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:screentime/sections/graphs/reports_line_chart.dart';
import 'package:screentime/sections/graphs/reports_pie_chart.dart';
import './controller/data_controllers/reports_controller.dart';
import './controller/data_controllers/alerts_limits_data_controller.dart'
    as app_summary_data;
import './controller/data_controllers/applications_data_controller.dart';

// Add this enum at the top of your file
enum PeriodType { last7Days, lastMonth, last3Months, lifetime, custom }

class Reports extends StatefulWidget {
  const Reports({super.key});

  @override
  State<Reports> createState() => _ReportsState();
}

class _ReportsState extends State<Reports> {
  final UsageAnalyticsController _analyticsController =
      UsageAnalyticsController();
  AnalyticsSummary? _analyticsSummary;
  bool _isLoading = true;
  String? _error;
  PeriodType _selectedPeriod = PeriodType.last7Days; // Changed to enum

  @override
  void initState() {
    super.initState();
    _initializeAndLoadData();
  }

  Future<void> _initializeAndLoadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final initialized = await _analyticsController.initialize();
      if (!initialized) {
        setState(() {
          _error = _analyticsController.error ??
              AppLocalizations.of(context)!.failedToInitialize;
          _isLoading = false;
        });
        return;
      }

      await _loadAnalyticsData();
    } catch (e) {
      setState(() {
        _error = AppLocalizations.of(context)!.unexpectedError(e.toString());
        _isLoading = false;
      });
    }
  }

  Future<void> _loadAnalyticsData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      AnalyticsSummary? summary;

      switch (_selectedPeriod) {
        case PeriodType.last7Days:
          summary = await _analyticsController.getLastSevenDaysAnalytics();
          graphData = summary.dailyScreenTimeData;
          break;
        case PeriodType.lastMonth:
          summary = await _analyticsController.getLastMonthAnalytics();
          graphData = summary.dailyScreenTimeData;
          break;
        case PeriodType.last3Months:
          summary = await _analyticsController.getLastThreeMonthsAnalytics();
          graphData = summary.dailyScreenTimeData;
          break;
        case PeriodType.lifetime:
          summary = await _analyticsController.getLifetimeAnalytics();
          graphData = summary.dailyScreenTimeData;
          break;
        case PeriodType.custom:
          if (_startDate != null &&
              _endDate != null &&
              _isDateRangeMode == true) {
            summary = await _analyticsController.getSpecificDateRangeAnalytics(
                _startDate!, _endDate!);
            graphData = summary.dailyScreenTimeData;
          } else if (_specificDate != null && _isDateRangeMode == false) {
            summary = await _analyticsController
                .getSpecificDayAnalytics(_specificDate!);
            graphData = summary.dailyScreenTimeData;
          }
          break;
      }

      setState(() {
        _analyticsSummary = summary;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error =
            AppLocalizations.of(context)!.errorLoadingAnalytics(e.toString());
        _isLoading = false;
      });
    }
  }

  DateTime? _startDate;
  DateTime? _endDate;
  DateTime? _specificDate;
  bool _isDateRangeMode = false;
  List<DailyScreenTime> graphData = [];

  Future<void> executeLineChart(DateTime specificDate) async {
    setState(() {
      _isLoading = true;
    });
    AnalyticsSummary? summary;
    try {
      summary =
          await _analyticsController.getSpecificDayAnalytics(specificDate);
      setState(() {
        _analyticsSummary = summary;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error =
            AppLocalizations.of(context)!.errorLoadingAnalytics(e.toString());
        _isLoading = false;
      });
    }
  }

  // Helper method to get localized string for period type
  String _getPeriodLabel(PeriodType period) {
    final l10n = AppLocalizations.of(context)!;
    switch (period) {
      case PeriodType.last7Days:
        return l10n.last7Days;
      case PeriodType.lastMonth:
        return l10n.lastMonth;
      case PeriodType.last3Months:
        return l10n.last3Months;
      case PeriodType.lifetime:
        return l10n.lifetime;
      case PeriodType.custom:
        return l10n.custom;
    }
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (scrollInfo is ScrollStartNotification &&
            scrollInfo.metrics.pixels == scrollInfo.metrics.minScrollExtent) {
          _loadAnalyticsData();
          return true;
        }
        return false;
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              if (_isLoading)
                _buildCustomLoadingIndicator()
              else if (_error != null)
                _buildCustomErrorDisplay()
              else if (_analyticsSummary != null)
                ..._buildAnalyticsContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomLoadingIndicator() {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        children: [
          const SizedBox(
            width: 40,
            height: 40,
            child: ProgressRing(strokeWidth: 3),
          ),
          const SizedBox(height: 10),
          Text(l10n.loadingAnalyticsData),
        ],
      ),
    );
  }

  Widget _buildCustomErrorDisplay() {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        children: [
          Icon(FluentIcons.error, color: Colors.red, size: 40),
          const SizedBox(height: 10),
          Text(_error!, style: TextStyle(color: Colors.red)),
          const SizedBox(height: 15),
          GestureDetector(
            onTap: _initializeAndLoadData,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(l10n.tryAgain, style: TextStyle(color: Colors.blue)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            l10n.usageAnalytics,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        ComboBox<PeriodType>(
          value: _selectedPeriod,
          items: PeriodType.values
              .map((period) => ComboBoxItem<PeriodType>(
                    value: period,
                    child: Text(_getPeriodLabel(period)),
                  ))
              .toList(),
          onChanged: (value) {
            if (value != null && value != _selectedPeriod) {
              if (value == PeriodType.custom) {
                _showDateRangeDialog(context);
              } else {
                setState(() {
                  _selectedPeriod = value;
                });
                _loadAnalyticsData();
              }
            }
          },
        ),
      ],
    );
  }

  void _showDateRangeDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    DateTime now = DateTime.now();
    DateTime startDate = _startDate ?? DateTime(now.year, now.month - 1, 1);
    DateTime endDate = _endDate ?? DateTime(now.year, now.month, now.day);
    DateTime specificDate = _specificDate ?? now;
    bool isRangeMode = _isDateRangeMode;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return ContentDialog(
            title: Text(l10n.customDialogTitle),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      ToggleSwitch(
                        checked: isRangeMode,
                        onChanged: (value) {
                          setState(() {
                            isRangeMode = value;
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      Text(isRangeMode ? l10n.dateRange : l10n.specificDate),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (isRangeMode) ...[
                    Row(
                      children: [
                        Text(l10n.startDate),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DatePicker(
                            selected: startDate,
                            onChanged: (date) {
                              setState(() {
                                startDate = date;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text(l10n.endDate),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DatePicker(
                            selected: endDate,
                            onChanged: (date) {
                              setState(() {
                                endDate = date;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    Row(
                      children: [
                        Text(l10n.date),
                        const SizedBox(width: 24),
                        Expanded(
                          child: DatePicker(
                            selected: specificDate,
                            onChanged: (date) {
                              setState(() {
                                specificDate = date;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              Button(
                child: Text(l10n.cancel),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              FilledButton(
                child: Text(l10n.apply),
                onPressed: () {
                  if (isRangeMode) {
                    if (startDate.isAfter(endDate)) {
                      showDialog(
                        context: context,
                        builder: (context) => ContentDialog(
                          title: Text(l10n.invalidDateRange),
                          content: Text(l10n.startDateBeforeEndDate),
                          actions: [
                            Button(
                              child: Text(l10n.ok),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      );
                      return;
                    }
                  }

                  Navigator.pop(context);

                  this.setState(() {
                    _isDateRangeMode = isRangeMode;
                    _selectedPeriod = PeriodType.custom;
                    if (isRangeMode) {
                      _startDate = startDate;
                      _endDate = endDate;
                      _specificDate = null;
                    } else {
                      _specificDate = specificDate;
                      _startDate = null;
                      _endDate = null;
                    }
                  });
                  _loadAnalyticsData();
                },
              ),
            ],
          );
        });
      },
    );
  }

  List<Widget> _buildAnalyticsContent() {
    final summary = _analyticsSummary!;
    return [
      TopBoxes(analyticsSummary: summary),
      const SizedBox(height: 20),
      LayoutBuilder(
        builder: (context, constraints) {
          return constraints.maxWidth < 800
              ? Column(
                  children: [
                    _buildScreenTimeChart(summary),
                    const SizedBox(height: 20),
                    _buildCategoryBreakdownChart(summary),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 6, child: _buildScreenTimeChart(summary)),
                    const SizedBox(width: 20),
                    Expanded(
                        flex: 3, child: _buildCategoryBreakdownChart(summary)),
                  ],
                );
        },
      ),
      const SizedBox(height: 20),
      ApplicationUsage(appUsageDetails: summary.appUsageDetails),
    ];
  }

  Widget _buildScreenTimeChart(AnalyticsSummary summary) {
    final l10n = AppLocalizations.of(context)!;
    return CardContainer(
      title: l10n.dailyScreenTime,
      child: SizedBox(
        child: LineChartWidget(
          chartType: ChartType.main,
          dailyScreenTimeData: graphData,
          periodType: _getPeriodLabel(_selectedPeriod),
          onDateSelected: executeLineChart,
        ),
      ),
    );
  }

  Widget _buildCategoryBreakdownChart(AnalyticsSummary summary) {
    final l10n = AppLocalizations.of(context)!;
    final dataMap = summary.categoryBreakdown;

    if (dataMap.isEmpty) {
      return CardContainer(
        title: l10n.categoryBreakdown,
        child: Center(child: Text(l10n.noDataAvailable)),
      );
    }

    return CardContainer(
      title: l10n.categoryBreakdown,
      child: ReportsPieChart(
        dataMap: dataMap,
        colorList: const [
          Color.fromRGBO(223, 250, 92, 1),
          Color.fromRGBO(129, 250, 112, 1),
          Color.fromRGBO(129, 182, 205, 1),
          Color.fromRGBO(91, 253, 199, 1),
        ],
      ),
    );
  }
}

class CardContainer extends StatelessWidget {
  final String title;
  final Widget child;
  final double? height;

  const CardContainer({
    super.key,
    required this.title,
    required this.child,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: height ?? 405),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: FluentTheme.of(context).micaBackgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: FluentTheme.of(context).inactiveBackgroundColor,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            semanticsLabel: '$title section',
          ),
          const SizedBox(height: 20),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class TopBoxes extends StatelessWidget {
  final AnalyticsSummary analyticsSummary;
  final bool isLoading;

  const TopBoxes({
    super.key,
    required this.analyticsSummary,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final items = [
      _AnalyticsItem(
        title: l10n.totalScreenTime,
        value: _formatDuration(analyticsSummary.totalScreenTime),
        percentChange: analyticsSummary.screenTimeComparisonPercent,
        icon: FluentIcons.screen_time,
        accentColor: const Color(0xFF6366F1), // Indigo
      ),
      _AnalyticsItem(
        title: l10n.productiveTime,
        value: _formatDuration(analyticsSummary.productiveTime),
        percentChange: analyticsSummary.productiveTimeComparisonPercent,
        icon: FluentIcons.timer,
        accentColor: const Color(0xFF10B981), // Emerald
      ),
      _AnalyticsItem(
        title: l10n.mostUsedApp,
        value: analyticsSummary.mostUsedApp,
        subValue: _formatDuration(analyticsSummary.mostUsedAppTime),
        icon: FluentIcons.account_browser,
        accentColor: const Color(0xFFF59E0B), // Amber
      ),
      _AnalyticsItem(
        title: l10n.focusSessions,
        value: analyticsSummary.focusSessionsCount.toString(),
        percentChange: analyticsSummary.focusSessionsComparisonPercent,
        icon: FluentIcons.red_eye,
        accentColor: const Color(0xFFEC4899), // Pink
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 800;
        final crossAxisCount = isCompact ? 2 : 4;
        final aspectRatio = isCompact ? 1.6 : 1.8;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: aspectRatio,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            return _AnalyticsCard(
              item: items[index],
              isLoading: isLoading,
              index: index,
            );
          },
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return "${hours}h ${minutes}m";
    }
    return "${minutes}m";
  }
}

class _AnalyticsItem {
  final String title;
  final String value;
  final double? percentChange;
  final String? subValue;
  final IconData icon;
  final Color accentColor;

  const _AnalyticsItem({
    required this.title,
    required this.value,
    this.percentChange,
    this.subValue,
    required this.icon,
    required this.accentColor,
  });
}

class _AnalyticsCard extends StatefulWidget {
  final _AnalyticsItem item;
  final bool isLoading;
  final int index;

  const _AnalyticsCard({
    required this.item,
    required this.isLoading,
    required this.index,
  });

  @override
  State<_AnalyticsCard> createState() => _AnalyticsCardState();
}

class _AnalyticsCardState extends State<_AnalyticsCard>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    // Staggered entrance animation
    Future.delayed(Duration(milliseconds: widget.index * 100), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: child,
          ),
        );
      },
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => _showDetailsFlyout(context),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  isDark
                      ? widget.item.accentColor.withOpacity(0.08)
                      : widget.item.accentColor.withOpacity(0.04),
                  isDark ? theme.micaBackgroundColor : Colors.white,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isHovered
                    ? widget.item.accentColor.withOpacity(0.5)
                    : theme.inactiveBackgroundColor.withOpacity(0.5),
                width: _isHovered ? 1.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: _isHovered
                      ? widget.item.accentColor.withOpacity(0.15)
                      : Colors.black.withOpacity(0.05),
                  blurRadius: _isHovered ? 20 : 10,
                  offset: Offset(0, _isHovered ? 8 : 4),
                ),
              ],
            ),
            transform: _isHovered
                ? (Matrix4.identity()..translate(0.0, -2.0))
                : Matrix4.identity(),
            child: widget.isLoading
                ? _buildShimmer(context)
                : _buildContent(context, l10n, theme),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    AppLocalizations l10n,
    FluentThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                widget.item.title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.typography.caption?.color?.withOpacity(0.7),
                  letterSpacing: 0.3,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            const SizedBox(width: 8),
            _buildIconBadge(theme),
          ],
        ),

        const Spacer(),

        // Value
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: TextStyle(
            fontSize: _isHovered ? 26 : 24,
            fontWeight: FontWeight.w700,
            color: theme.typography.title?.color,
            letterSpacing: -0.5,
          ),
          child: Text(
            widget.item.value,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),

        const SizedBox(height: 6),

        // Comparison or SubValue
        _buildFooter(l10n, theme),
      ],
    );
  }

  Widget _buildIconBadge(FluentThemeData theme) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: widget.item.accentColor.withOpacity(_isHovered ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        widget.item.icon,
        size: 18,
        color: widget.item.accentColor,
      ),
    );
  }

  Widget _buildFooter(AppLocalizations l10n, FluentThemeData theme) {
    if (widget.item.percentChange != null) {
      final isPositive = widget.item.percentChange! >= 0;
      final color =
          isPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444);

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isPositive ? FluentIcons.trending12 : FluentIcons.stock_down,
              size: 12,
              color: color,
            ),
            const SizedBox(width: 4),
            Text(
              '${isPositive ? '+' : ''}${widget.item.percentChange!.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      );
    }

    if (widget.item.subValue != null) {
      return Row(
        children: [
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: widget.item.accentColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              widget.item.subValue!,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: theme.typography.caption?.color?.withOpacity(0.6),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    return const SizedBox(height: 16);
  }

  Widget _buildShimmer(BuildContext context) {
    return ShimmerLoading(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 80,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            width: 100,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 60,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  void _showDetailsFlyout(BuildContext context) {
    // Optional: Show a flyout/tooltip with more details
    displayInfoBar(
      context,
      builder: (context, close) {
        return InfoBar(
          title: Text(widget.item.title),
          content: Text('Value: ${widget.item.value}'),
          severity: InfoBarSeverity.info,
          isLong: false,
        );
      },
    );
  }
}

// Shimmer Loading Widget
class ShimmerLoading extends StatefulWidget {
  final Widget child;

  const ShimmerLoading({super.key, required this.child});

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = FluentTheme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: isDark
                  ? [
                      Colors.grey[800],
                      Colors.grey[700],
                      Colors.grey[800],
                    ]
                  : [
                      Colors.grey[300],
                      Colors.grey[100],
                      Colors.grey[300],
                    ],
              stops: [
                _controller.value - 0.3,
                _controller.value,
                _controller.value + 0.3,
              ].map((e) => e.clamp(0.0, 1.0)).toList(),
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: widget.child,
        );
      },
    );
  }
}

class ApplicationUsage extends StatefulWidget {
  final List<AppUsageSummary> appUsageDetails;

  const ApplicationUsage({
    super.key,
    required this.appUsageDetails,
  });

  @override
  State<ApplicationUsage> createState() => _ApplicationUsageState();
}

class _ApplicationUsageState extends State<ApplicationUsage> {
  late List<AppUsageSummary> _filteredAppUsageDetails;
  String _searchQuery = '';
  String _sortBy = 'Usage';
  bool _sortAscending = false;
  int? _hoveredIndex;
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _filteredAppUsageDetails = List.from(widget.appUsageDetails);
    _sortAppList();
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ApplicationUsage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.appUsageDetails != widget.appUsageDetails) {
      _filteredAppUsageDetails = List.from(widget.appUsageDetails);
      _filterAndSortAppList();
    }
  }

  void _filterAndSortAppList() {
    setState(() {
      _filteredAppUsageDetails = widget.appUsageDetails
          .where((app) =>
              app.appName.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
      _sortAppList();
    });
  }

  void _sortAppList() {
    switch (_sortBy) {
      case 'Name':
        _filteredAppUsageDetails.sort((a, b) => _sortAscending
            ? a.appName.compareTo(b.appName)
            : b.appName.compareTo(a.appName));
        break;
      case 'Category':
        _filteredAppUsageDetails.sort((a, b) => _sortAscending
            ? a.category.compareTo(b.category)
            : b.category.compareTo(a.category));
        break;
      case 'Usage':
      default:
        _filteredAppUsageDetails.sort((a, b) => _sortAscending
            ? a.totalTime.compareTo(b.totalTime)
            : b.totalTime.compareTo(a.totalTime));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = FluentTheme.of(context);
    final filteredApps = _filteredAppUsageDetails
        .where((app) => app.appName.trim().isNotEmpty)
        .toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          height: 500,
          decoration: BoxDecoration(
            color: theme.micaBackgroundColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: theme.resources.dividerStrokeColorDefault,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              _buildHeader(context, l10n, theme),

              // Toolbar
              _buildToolbar(context, l10n, theme),

              // Column Headers
              _buildColumnHeaders(context, l10n, theme),

              // List
              Expanded(
                child: filteredApps.isEmpty
                    ? _buildEmptyState(context, l10n, theme)
                    : _buildAppList(context, filteredApps, theme),
              ),

              // Footer Stats
              _buildFooterStats(context, l10n, theme, filteredApps),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(
      BuildContext context, AppLocalizations l10n, FluentThemeData theme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.resources.dividerStrokeColorDefault,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            FluentIcons.app_icon_default_list,
            size: 20,
            color: theme.accentColor,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              l10n.detailedApplicationUsage,
              style: theme.typography.subtitle?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),
          _buildQuickStats(context, l10n, theme),
        ],
      ),
    );
  }

  Widget _buildQuickStats(
      BuildContext context, AppLocalizations l10n, FluentThemeData theme) {
    final totalApps = _filteredAppUsageDetails.length;
    final productiveApps =
        _filteredAppUsageDetails.where((a) => a.isProductive).length;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildMiniStat(
          context,
          '$totalApps',
          "l10n.apps",
          FluentIcons.grid_view_medium,
          theme.accentColor,
        ),
        const SizedBox(width: 16),
        _buildMiniStat(
          context,
          '$productiveApps',
          l10n.productive,
          FluentIcons.check_mark,
          Colors.green,
        ),
      ],
    );
  }

  Widget _buildMiniStat(BuildContext context, String value, String label,
      IconData icon, Color color) {
    final theme = FluentTheme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(icon, size: 12, color: color),
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: theme.typography.caption?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            Text(
              label,
              style: theme.typography.caption?.copyWith(
                fontSize: 10,
                color: theme.inactiveColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildToolbar(
      BuildContext context, AppLocalizations l10n, FluentThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          // Search
          SizedBox(
            width: 200,
            height: 32,
            child: TextBox(
              focusNode: _searchFocusNode,
              placeholder: l10n.searchApplications,
              style: const TextStyle(fontSize: 13),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _filterAndSortAppList();
                });
              },
              prefix: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Icon(FluentIcons.search,
                    size: 14, color: theme.inactiveColor),
              ),
              suffix: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: Icon(FluentIcons.clear,
                          size: 12, color: theme.inactiveColor),
                      onPressed: () {
                        setState(() {
                          _searchQuery = '';
                          _filterAndSortAppList();
                        });
                      },
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 12),

          // Sort Pills
          Expanded(
            child: _buildSortPills(context, l10n, theme),
          ),

          const SizedBox(width: 8),

          // Sort Direction
          Tooltip(
            message:
                _sortAscending ? "l10n.sortAscending" : "l10n.sortDescending",
            child: ToggleButton(
              checked: _sortAscending,
              onChanged: (value) {
                setState(() {
                  _sortAscending = value;
                  _sortAppList();
                });
              },
              child: Icon(
                _sortAscending ? FluentIcons.sort_up : FluentIcons.sort_down,
                size: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortPills(
      BuildContext context, AppLocalizations l10n, FluentThemeData theme) {
    final sortOptions = [
      ('Usage', l10n.sortByUsage, FluentIcons.timer),
      ('Name', l10n.sortByName, FluentIcons.text_field),
      ('Category', l10n.sortByCategory, FluentIcons.tag),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: sortOptions.map((option) {
          final isSelected = _sortBy == option.$1;
          return Padding(
            padding: const EdgeInsets.only(right: 4),
            child: ToggleButton(
              checked: isSelected,
              onChanged: (value) {
                if (value) {
                  setState(() {
                    _sortBy = option.$1;
                    _sortAppList();
                  });
                }
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(option.$3, size: 12),
                  const SizedBox(width: 4),
                  Text(option.$2, style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildColumnHeaders(
      BuildContext context, AppLocalizations l10n, FluentThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.cardColor.withOpacity(0.5),
        border: Border(
          bottom: BorderSide(color: theme.resources.dividerStrokeColorDefault),
        ),
      ),
      child: Row(
        children: [
          Expanded(flex: 3, child: _buildHeaderCell(l10n.nameHeader, theme)),
          Expanded(
              flex: 2, child: _buildHeaderCell(l10n.categoryHeader, theme)),
          Expanded(
              flex: 2, child: _buildHeaderCell(l10n.totalTimeHeader, theme)),
          Expanded(
              flex: 2, child: _buildHeaderCell(l10n.productivityHeader, theme)),
          const SizedBox(
              width: 50, child: Center(child: Text(''))), // Actions column
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String text, FluentThemeData theme) {
    return Text(
      text,
      style: theme.typography.caption?.copyWith(
        fontWeight: FontWeight.w600,
        color: theme.inactiveColor,
        fontSize: 11,
        letterSpacing: 0.5,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildAppList(
      BuildContext context, List<AppUsageSummary> apps, FluentThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: apps.length,
      itemBuilder: (context, index) {
        final app = apps[index];
        final isHovered = _hoveredIndex == index;

        return MouseRegion(
          onEnter: (_) => setState(() => _hoveredIndex = index),
          onExit: (_) => setState(() => _hoveredIndex = null),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: isHovered
                  ? theme.accentColor.withOpacity(0.05)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: isHovered
                  ? Border.all(color: theme.accentColor.withOpacity(0.2))
                  : Border.all(color: Colors.transparent),
            ),
            child: _buildAppListItem(context, app, isHovered, theme),
          ),
        );
      },
    );
  }

  Widget _buildAppListItem(BuildContext context, AppUsageSummary app,
      bool isHovered, FluentThemeData theme) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Row(
        children: [
          // App Name with Icon
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: app.isProductive
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    FluentIcons.app_icon_default,
                    size: 14,
                    color: app.isProductive ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    app.appName,
                    style: theme.typography.body?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // Category
          Expanded(
            flex: 2,
            child: _buildCategoryChip(app.category, theme),
          ),

          // Total Time
          Expanded(
            flex: 2,
            child: _buildTimeDisplay(app.totalTime, theme),
          ),

          // Productivity
          Expanded(
            flex: 2,
            child: _buildProductivityBadge(app.isProductive, l10n, theme),
          ),

          // Actions
          SizedBox(
            width: 50,
            child: Center(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 150),
                opacity: isHovered ? 1.0 : 0.5,
                child: IconButton(
                  icon: Icon(
                    FluentIcons.info,
                    size: 14,
                    color: theme.accentColor,
                  ),
                  onPressed: () => _showAppDetails(context, app),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String category, FluentThemeData theme) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: theme.resources.dividerStrokeColorDefault),
        ),
        child: Text(
          category,
          style: theme.typography.caption?.copyWith(fontSize: 11),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildTimeDisplay(Duration duration, FluentThemeData theme) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hours > 0) ...[
          Text(
            '$hours',
            style: theme.typography.body?.copyWith(
              fontWeight: FontWeight.bold,
              color: hours > 2 ? Colors.orange : null,
            ),
          ),
          Text(
            'h ',
            style: theme.typography.caption?.copyWith(
              color: theme.inactiveColor,
            ),
          ),
        ],
        Text(
          '$minutes',
          style: theme.typography.body?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          'm',
          style: theme.typography.caption?.copyWith(
            color: theme.inactiveColor,
          ),
        ),
      ],
    );
  }

  Widget _buildProductivityBadge(
      bool isProductive, AppLocalizations l10n, FluentThemeData theme) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: isProductive
              ? Colors.green.withOpacity(0.1)
              : Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isProductive ? FluentIcons.check_mark : FluentIcons.cancel,
              size: 10,
              color: isProductive ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                isProductive ? l10n.productive : l10n.nonProductive,
                style: TextStyle(
                  fontSize: 11,
                  color: isProductive ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(
      BuildContext context, AppLocalizations l10n, FluentThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            FluentIcons.search,
            size: 40,
            color: theme.inactiveColor.withOpacity(0.5),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.noApplicationsMatch,
            style: theme.typography.body?.copyWith(
              color: theme.inactiveColor,
            ),
          ),
          if (_searchQuery.isNotEmpty) ...[
            const SizedBox(height: 8),
            Button(
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                  _filterAndSortAppList();
                });
              },
              child: Text("l10n.clearSearch"),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFooterStats(BuildContext context, AppLocalizations l10n,
      FluentThemeData theme, List<AppUsageSummary> apps) {
    final totalTime = apps.fold<Duration>(
      Duration.zero,
      (sum, app) => sum + app.totalTime,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: theme.cardColor.withOpacity(0.5),
        border: Border(
          top: BorderSide(color: theme.resources.dividerStrokeColorDefault),
        ),
      ),
      child: Row(
        children: [
          Text(
            '${apps.length} ${"l10n.applicationsShowing"}',
            style: theme.typography.caption?.copyWith(
              color: theme.inactiveColor,
            ),
          ),
          const Spacer(),
          Text(
            '${"l10n.totalTime"}: ',
            style: theme.typography.caption?.copyWith(
              color: theme.inactiveColor,
            ),
          ),
          Text(
            _formatDuration(totalTime),
            style: theme.typography.caption?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== APP DETAILS DIALOG ====================

  void _showAppDetails(BuildContext context, AppUsageSummary app) async {
    final l10n = AppLocalizations.of(context)!;

    // Fetch your data here (keeping your existing logic)
    // For now showing improved dialog

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => _AppDetailsDialog(
        app: app,
        l10n: l10n,
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) return "${hours}h ${minutes}m";
    return "${minutes}m";
  }
}

// Separate dialog widget for better organization
class _AppDetailsDialog extends StatefulWidget {
  final AppUsageSummary app;
  final AppLocalizations l10n;

  const _AppDetailsDialog({
    required this.app,
    required this.l10n,
  });

  @override
  State<_AppDetailsDialog> createState() => _AppDetailsDialogState();
}

class _AppDetailsDialogState extends State<_AppDetailsDialog> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final l10n = widget.l10n;

    return ContentDialog(
      constraints: const BoxConstraints(maxWidth: 700, maxHeight: 550),
      title: _buildDialogHeader(context, theme),
      content: SizedBox(
        width: 680,
        height: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Tab Bar
            _buildTabBar(context, l10n, theme),

            const SizedBox(height: 16),

            // Tab Content
            Expanded(
              child: _buildTabContent(context, l10n, theme),
            ),
          ],
        ),
      ),
      actions: [
        Button(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.close),
        ),
      ],
    );
  }

  Widget _buildDialogHeader(BuildContext context, FluentThemeData theme) {
    final app = widget.app;
    final l10n = widget.l10n;

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: app.isProductive
                  ? [Colors.green.light, Colors.green]
                  : [Colors.red.light, Colors.red],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: (app.isProductive ? Colors.green : Colors.red)
                    .withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            FluentIcons.app_icon_default,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                app.appName,
                style: theme.typography.subtitle?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildSmallBadge(
                    app.category,
                    theme.accentColor.withOpacity(0.1),
                    theme.accentColor,
                  ),
                  const SizedBox(width: 8),
                  _buildSmallBadge(
                    app.isProductive ? l10n.productive : l10n.nonProductive,
                    app.isProductive
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    app.isProductive ? Colors.green : Colors.red,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSmallBadge(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTabBar(
      BuildContext context, AppLocalizations l10n, FluentThemeData theme) {
    final tabs = [
      ("l10n.overview", FluentIcons.view_dashboard),
      (l10n.usageOverPastWeek, FluentIcons.chart),
      ("l10n.patterns", FluentIcons.insights),
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final tab = entry.value;
          final isSelected = _selectedTab == index;

          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? theme.accentColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      tab.$2,
                      size: 14,
                      color: isSelected ? Colors.white : theme.inactiveColor,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        tab.$1,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                          color:
                              isSelected ? Colors.white : theme.inactiveColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTabContent(
      BuildContext context, AppLocalizations l10n, FluentThemeData theme) {
    switch (_selectedTab) {
      case 0:
        return _buildOverviewTab(context, l10n, theme);
      case 1:
        return _buildUsageChartTab(context, l10n, theme);
      case 2:
        return _buildPatternsTab(context, l10n, theme);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildOverviewTab(
      BuildContext context, AppLocalizations l10n, FluentThemeData theme) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Summary Stats Row
          Row(
            children: [
              Expanded(
                  child: _buildStatCard(context, l10n.today, '2h 34m',
                      FluentIcons.calendar_day, Colors.blue, theme)),
              const SizedBox(width: 12),
              Expanded(
                  child: _buildStatCard(context, l10n.dailyLimit, '3h',
                      FluentIcons.timer, Colors.orange, theme)),
              const SizedBox(width: 12),
              Expanded(
                  child: _buildStatCard(context, l10n.weeklyTotal, '14h 22m',
                      FluentIcons.calendar_week, Colors.purple, theme)),
            ],
          ),
          const SizedBox(height: 16),

          // Usage Breakdown
          _buildCompactCard(
            context,
            l10n.usageSummary,
            FluentIcons.bulleted_list,
            theme,
            child: Column(
              children: [
                _buildInfoRow(l10n.avgDailyUsage, '2h 3m', theme),
                _buildInfoRow(l10n.longestSession, '45m', theme),
                _buildInfoRow(l10n.usageTrend, '+5%', theme,
                    valueColor: Colors.orange),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsageChartTab(
      BuildContext context, AppLocalizations l10n, FluentThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FluentIcons.chart,
              size: 48,
              color: theme.inactiveColor.withOpacity(0.5),
            ),
            const SizedBox(height: 12),
            Text(
              'Weekly Usage Chart',
              style: theme.typography.body?.copyWith(
                color: theme.inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatternsTab(
      BuildContext context, AppLocalizations l10n, FluentThemeData theme) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildCompactCard(
            context,
            l10n.usagePatternByTimeOfDay,
            FluentIcons.timeline_progress,
            theme,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTimeSlot(l10n.morning, '25%', Colors.orange, theme),
                _buildTimeSlot(l10n.afternoon, '35%', Colors.yellow, theme),
                _buildTimeSlot(l10n.evening, '30%', Colors.purple, theme),
                _buildTimeSlot(l10n.night, '10%', Colors.blue, theme),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _buildCompactCard(
            context,
            l10n.usageInsights,
            FluentIcons.lightbulb,
            theme,
            child: Text(
              'You primarily use this app in the afternoon. Your usage has been consistent over the past week.',
              style: theme.typography.body?.copyWith(
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value,
      IconData icon, Color color, FluentThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.typography.subtitle?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.typography.caption?.copyWith(
              color: theme.inactiveColor,
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildCompactCard(
      BuildContext context, String title, IconData icon, FluentThemeData theme,
      {required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.resources.dividerStrokeColorDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: theme.accentColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: theme.typography.bodyStrong?.copyWith(
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, FluentThemeData theme,
      {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.typography.body?.copyWith(
                color: theme.inactiveColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            value,
            style: theme.typography.body?.copyWith(
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSlot(
      String label, String percent, Color color, FluentThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              percent,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: theme.typography.caption?.copyWith(
            fontSize: 11,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
