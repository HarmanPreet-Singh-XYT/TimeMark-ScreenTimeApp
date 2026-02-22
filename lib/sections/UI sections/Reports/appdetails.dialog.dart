import 'package:fluent_ui/fluent_ui.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart' as mt;
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:screentime/l10n/app_localizations.dart';
import 'package:screentime/sections/controller/data_controllers/applications_data_controller.dart';
import '../../controller/data_controllers/reports_controller.dart';
import '../../controller/data_controllers/alerts_limits_data_controller.dart'
    as app_summary_data;

// Main function to show the dialog with data fetching
void showAppDetailsDialog(BuildContext context, AppUsageSummary app) async {
  final l10n = AppLocalizations.of(context)!;
  final app_summary_data.ScreenTimeDataController controller =
      app_summary_data.ScreenTimeDataController();
  final app_summary_data.AppUsageSummary? appSummary =
      controller.getAppSummary(app.appName);

  if (appSummary == null) return;

  final appDataProvider = ApplicationsDataProvider();
  final ApplicationBasicDetail appBasicDetails =
      await appDataProvider.fetchApplicationByName(app.appName);
  final ApplicationDetailedData appDetails = await appDataProvider
      .fetchApplicationDetails(app.appName, TimeRange.week);

  // Generate chart data
  final List<FlSpot> dailyUsageSpots = [];
  final Map<String, Duration> weeklyData = appDetails.usageTrends.daily;
  final Map<String, double> dateToXCoordinate = {};
  double currentXCoordinate = 0;

  final List<String> sortedDates = weeklyData.keys.toList()
    ..sort((a, b) {
      final DateFormat formatter = DateFormat('MM/dd');
      return formatter.parse(a).compareTo(formatter.parse(b));
    });

  double maxUsage = 0;

  for (final String dateKey in sortedDates) {
    final Duration duration = weeklyData[dateKey] ?? Duration.zero;
    final double usageMinutes = duration.inMinutes.toDouble();
    maxUsage = max(maxUsage, usageMinutes);

    if (!dateToXCoordinate.containsKey(dateKey)) {
      dateToXCoordinate[dateKey] = currentXCoordinate;
      currentXCoordinate += 1;
    }

    dailyUsageSpots.add(FlSpot(dateToXCoordinate[dateKey]!, usageMinutes));
  }

  final Map<String, double> timeOfDayUsage =
      _generateTimeOfDayData(appDetails.hourlyBreakdown);

  if (!context.mounted) return;

  showDialog(
    context: context,
    builder: (context) => AppDetailsDialog(
      app: app,
      l10n: l10n,
      appSummary: appSummary,
      appBasicDetails: appBasicDetails,
      appDetails: appDetails,
      dailyUsageSpots: dailyUsageSpots,
      sortedDates: sortedDates,
      maxUsage: maxUsage,
      dateToXCoordinate: dateToXCoordinate,
      timeOfDayUsage: timeOfDayUsage,
    ),
  );
}

// Helper function
Map<String, double> _generateTimeOfDayData(Map<int, Duration> hourlyBreakdown) {
  final Map<String, Duration> timeOfDayDurations = {
    'Morning (6-12)': Duration.zero,
    'Afternoon (12-5)': Duration.zero,
    'Evening (5-9)': Duration.zero,
    'Night (9-6)': Duration.zero,
  };

  hourlyBreakdown.forEach((hour, duration) {
    if (hour >= 6 && hour < 12) {
      timeOfDayDurations['Morning (6-12)'] =
          timeOfDayDurations['Morning (6-12)']! + duration;
    } else if (hour >= 12 && hour < 17) {
      timeOfDayDurations['Afternoon (12-5)'] =
          timeOfDayDurations['Afternoon (12-5)']! + duration;
    } else if (hour >= 17 && hour < 21) {
      timeOfDayDurations['Evening (5-9)'] =
          timeOfDayDurations['Evening (5-9)']! + duration;
    } else {
      timeOfDayDurations['Night (9-6)'] =
          timeOfDayDurations['Night (9-6)']! + duration;
    }
  });

  final Duration totalDuration = timeOfDayDurations.values
      .fold(Duration.zero, (prev, curr) => prev + curr);
  final Map<String, double> percentages = {};

  if (totalDuration.inSeconds > 0) {
    timeOfDayDurations.forEach((timeOfDay, duration) {
      percentages[timeOfDay] =
          (duration.inSeconds / totalDuration.inSeconds) * 100;
    });
  } else {
    for (var timeOfDay in timeOfDayDurations.keys) {
      percentages[timeOfDay] = 25.0;
    }
  }

  return percentages;
}

// Main dialog widget with chart integration
class AppDetailsDialog extends StatefulWidget {
  final AppUsageSummary app;
  final AppLocalizations l10n;
  final app_summary_data.AppUsageSummary appSummary;
  final ApplicationBasicDetail appBasicDetails;
  final ApplicationDetailedData appDetails;
  final List<FlSpot> dailyUsageSpots;
  final List<String> sortedDates;
  final double maxUsage;
  final Map<String, double> dateToXCoordinate;
  final Map<String, double> timeOfDayUsage;

  const AppDetailsDialog({
    super.key,
    required this.app,
    required this.l10n,
    required this.appSummary,
    required this.appBasicDetails,
    required this.appDetails,
    required this.dailyUsageSpots,
    required this.sortedDates,
    required this.maxUsage,
    required this.dateToXCoordinate,
    required this.timeOfDayUsage,
  });

  @override
  State<AppDetailsDialog> createState() => AppDetailsDialogState();
}

class AppDetailsDialogState extends State<AppDetailsDialog> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final l10n = widget.l10n;

    return ContentDialog(
      constraints: const BoxConstraints(maxWidth: 700, maxHeight: 1000),
      title: _buildDialogHeader(context, theme),
      content: SizedBox(
        width: 680,
        height: 460,
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
                    .withValues(alpha: 0.3),
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
                    theme.accentColor.withValues(alpha: 0.1),
                    theme.accentColor,
                  ),
                  const SizedBox(width: 8),
                  _buildSmallBadge(
                    app.isProductive ? l10n.productive : l10n.nonProductive,
                    app.isProductive
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.red.withValues(alpha: 0.1),
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
      (l10n.overview, FluentIcons.view_dashboard),
      (l10n.usageOverPastWeek, FluentIcons.chart),
      (l10n.patterns, FluentIcons.insights),
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
    final appBasicDetails = widget.appBasicDetails;
    final appSummary = widget.appSummary;
    final appDetails = widget.appDetails;

    // Weekly totals
    final weeklyData = appDetails.usageTrends.daily;
    final List<String> sortedDateKeys = _getSortedDateKeys(weeklyData);
    final weeklyTotal = Duration(
        minutes:
            weeklyData.values.map((d) => d.inMinutes).fold(0, (a, b) => a + b));

    // Daily limit
    final bool hasLimit =
        appSummary.limitStatus && appSummary.dailyLimit > Duration.zero;
    final double limitProgress = hasLimit
        ? (appBasicDetails.screenTime.inSeconds /
                appSummary.dailyLimit.inSeconds)
            .clamp(0.0, 1.0)
        : 0.0;
    final bool overLimit =
        hasLimit && appBasicDetails.screenTime > appSummary.dailyLimit;

    // Most active day
    String mostActiveDay = '—';
    Duration mostActiveDuration = Duration.zero;
    weeklyData.forEach((date, duration) {
      if (duration > mostActiveDuration) {
        mostActiveDuration = duration;
        mostActiveDay = _formatDayLabel(date, l10n);
      }
    });

    // Week-over-week
    final double growthPct = appDetails.comparisons.growthPercentage;
    final bool isIncrease = growthPct > 0;
    final String growthLabel = growthPct == 0
        ? l10n.sameAsLastWeek
        : isIncrease
            ? l10n.moreUsageThanLastWeek(growthPct.abs().toStringAsFixed(1))
            : l10n.lessUsageThanLastWeek(growthPct.abs().toStringAsFixed(1));

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Top 3 stat cards ────────────────────────────────────────
          Row(
            children: [
              Expanded(
                  child: _buildStatCard(
                      context,
                      l10n.today,
                      appBasicDetails.formattedScreenTime,
                      FluentIcons.calendar_day,
                      Colors.blue,
                      theme)),
              const SizedBox(width: 10),
              Expanded(
                  child: _buildStatCard(
                      context,
                      l10n.dailyLimit,
                      hasLimit
                          ? _formatDuration(appSummary.dailyLimit)
                          : l10n.noLimit,
                      FluentIcons.timer,
                      Colors.orange,
                      theme)),
              const SizedBox(width: 10),
              Expanded(
                  child: _buildStatCard(
                      context,
                      l10n.weeklyTotal,
                      _formatDuration(weeklyTotal),
                      FluentIcons.calendar_week,
                      Colors.purple,
                      theme)),
            ],
          ),
          const SizedBox(height: 12),

          // ── Daily limit progress bar ─────────────────────────────────
          if (hasLimit)
            _buildCompactCard(
              context,
              l10n.todaysLimitUsage,
              FluentIcons.timer,
              theme,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        appBasicDetails.formattedScreenTime,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: overLimit ? Colors.red : Colors.blue,
                        ),
                      ),
                      Text(
                        _formatDuration(appSummary.dailyLimit),
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.inactiveColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Stack(
                      children: [
                        Container(
                          height: 10,
                          decoration: BoxDecoration(
                            color: theme.accentColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: limitProgress,
                          child: Container(
                            height: 10,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: overLimit
                                    ? [Colors.red.light, Colors.red]
                                    : limitProgress > 0.75
                                        ? [Colors.orange.light, Colors.orange]
                                        : [Colors.blue.light, Colors.blue],
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    overLimit
                        ? l10n.limitExceededBy(_formatDuration(
                            appBasicDetails.screenTime - appSummary.dailyLimit))
                        : l10n.timeRemaining(_formatDuration(
                            appSummary.dailyLimit -
                                appBasicDetails.screenTime)),
                    style: TextStyle(
                      fontSize: 11,
                      color: overLimit ? Colors.red : theme.inactiveColor,
                      fontWeight:
                          overLimit ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),

          if (hasLimit) const SizedBox(height: 12),

          // ── Sparkline bar chart ──────────────────────────────────────
          _buildCompactCard(
            context,
            l10n.thisWeekAtAGlance,
            FluentIcons.chart,
            theme,
            child: _buildSparkline(
              weeklyData: weeklyData,
              sortedDates: sortedDateKeys,
              hasLimit: hasLimit,
              limitMinutes:
                  hasLimit ? appSummary.dailyLimit.inMinutes.toDouble() : 0,
              theme: theme,
            ),
          ),
          const SizedBox(height: 12),

          // ── Hourly heatmap ───────────────────────────────────────────
          _buildCompactCard(
            context,
            l10n.hourlyActivityHeatmap,
            FluentIcons.clock,
            theme,
            child: _buildHourlyHeatmap(appDetails.hourlyBreakdown, theme),
          ),
          const SizedBox(height: 12),

          // ── Sessions + This Week row ─────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildCompactCard(
                  context,
                  l10n.sessions,
                  FluentIcons.issue_tracking,
                  theme,
                  child: Column(
                    children: [
                      _buildInfoRow(
                          l10n.totalSessions,
                          '${appDetails.sessionBreakdown.totalSessions}',
                          theme),
                      _buildInfoRow(
                          l10n.avgSession,
                          _formatDuration(appDetails
                              .sessionBreakdown.averageSessionDuration),
                          theme),
                      _buildInfoRow(
                          l10n.longestSession,
                          appDetails
                              .sessionBreakdown.formattedLongestSessionDuration,
                          theme),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildCompactCard(
                  context,
                  l10n.thisWeek,
                  FluentIcons.calendar_week,
                  theme,
                  child: Column(
                    children: [
                      _buildInfoRow(l10n.mostActive, mostActiveDay, theme),
                      _buildInfoRow(l10n.peakUsage,
                          _formatDuration(mostActiveDuration), theme),
                      _buildInfoRow(
                          l10n.dailyAverage,
                          appDetails.usageInsights.formattedAverageDailyUsage,
                          theme),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Productivity score + Streak row ─────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildCompactCard(
                  context,
                  l10n.productivityScore,
                  FluentIcons.like,
                  theme,
                  child: _buildProductivityScore(widget.app, appDetails, theme),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildCompactCard(
                  context,
                  l10n.streaks,
                  FluentIcons.lightning_bolt,
                  theme,
                  child: _buildStreakTracker(
                    weeklyData,
                    hasLimit: hasLimit,
                    limitDuration: appSummary.dailyLimit,
                    theme: theme,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Week-over-week banner ────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: growthPct == 0
                    ? [
                        Colors.blue.withValues(alpha: 0.06),
                        Colors.blue.withValues(alpha: 0.02),
                      ]
                    : isIncrease
                        ? [
                            Colors.red.withValues(alpha: 0.06),
                            Colors.red.withValues(alpha: 0.02),
                          ]
                        : [
                            Colors.green.withValues(alpha: 0.06),
                            Colors.green.withValues(alpha: 0.02),
                          ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: growthPct == 0
                    ? Colors.blue.withValues(alpha: 0.2)
                    : isIncrease
                        ? Colors.red.withValues(alpha: 0.2)
                        : Colors.green.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: (growthPct == 0
                            ? Colors.blue
                            : isIncrease
                                ? Colors.red
                                : Colors.green)
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    growthPct == 0
                        ? FluentIcons.subtract_shape
                        : isIncrease
                            ? FluentIcons.trending12
                            : FluentIcons.arrow_down_right8,
                    size: 16,
                    color: growthPct == 0
                        ? Colors.blue
                        : isIncrease
                            ? Colors.red
                            : Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.weekOverWeek,
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.inactiveColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        growthLabel,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: growthPct == 0
                              ? Colors.blue
                              : isIncrease
                                  ? Colors.red
                                  : Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

// ── Sparkline ────────────────────────────────────────────────────────────────

  Widget _buildSparkline({
    required Map<String, Duration> weeklyData,
    required List<String> sortedDates,
    required bool hasLimit,
    required double limitMinutes,
    required FluentThemeData theme,
  }) {
    final l10n = widget.l10n;

    if (sortedDates.isEmpty) {
      return Text(l10n.noData, style: TextStyle(color: theme.inactiveColor));
    }

    final double maxMins = weeklyData.values
        .map((d) => d.inMinutes.toDouble())
        .fold(0.0, (a, b) => a > b ? a : b);
    final double scaleMax = maxMins == 0 ? 1 : maxMins;

    return SizedBox(
      height: 72,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: sortedDates.map((date) {
          final double mins =
              (weeklyData[date] ?? Duration.zero).inMinutes.toDouble();
          final double heightFraction = mins / scaleMax;
          final bool over = hasLimit && limitMinutes > 0 && mins > limitMinutes;
          final bool isToday = _isToday(date);
          final bool isPeak = mins == maxMins && maxMins > 0;

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (isToday || isPeak)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Text(
                        _formatMinutesShort(mins),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: over
                              ? Colors.red
                              : isToday
                                  ? theme.accentColor
                                  : Colors.orange,
                        ),
                      ),
                    ),
                  Flexible(
                    child: FractionallySizedBox(
                      heightFactor: heightFraction.clamp(0.04, 1.0),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: over
                                ? [Colors.red.light, Colors.red]
                                : isToday
                                    ? [
                                        theme.accentColor
                                            .withValues(alpha: 0.7),
                                        theme.accentColor
                                      ]
                                    : [
                                        Colors.blue.withValues(alpha: 0.4),
                                        Colors.blue.withValues(alpha: 0.75)
                                      ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDateForAxis(date, l10n),
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      color: isToday ? theme.accentColor : theme.inactiveColor,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

// ── Hourly heatmap ───────────────────────────────────────────────────────────

  Widget _buildHourlyHeatmap(
      Map<int, Duration> hourlyBreakdown, FluentThemeData theme) {
    final double maxSecs = hourlyBreakdown.values
        .map((d) => d.inSeconds.toDouble())
        .fold(0.0, (a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (int row = 0; row < 2; row++) ...[
          Row(
            children: List.generate(12, (col) {
              final int hour = row * 12 + col;
              final double secs =
                  (hourlyBreakdown[hour] ?? Duration.zero).inSeconds.toDouble();
              final double intensity = maxSecs > 0 ? (secs / maxSecs) : 0.0;
              final Color cellColor = intensity == 0
                  ? theme.accentColor.withValues(alpha: 0.06)
                  : Color.lerp(
                      Colors.blue.withValues(alpha: 0.2),
                      Colors.blue,
                      intensity,
                    )!;

              return Expanded(
                child: Tooltip(
                  message:
                      '${_formatHour(hour)}: ${_formatMinutesShort(secs / 60)}',
                  child: Container(
                    height: 20,
                    margin: const EdgeInsets.all(1.5),
                    decoration: BoxDecoration(
                      color: cellColor,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              );
            }),
          ),
          if (row == 0) const SizedBox(height: 2),
        ],
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: ['12a', '6a', '12p', '6p', '11p']
              .map((t) => Text(t,
                  style: TextStyle(fontSize: 9, color: theme.inactiveColor)))
              .toList(),
        ),
      ],
    );
  }

// ── Productivity score ───────────────────────────────────────────────────────

  Widget _buildProductivityScore(AppUsageSummary app,
      ApplicationDetailedData details, FluentThemeData theme) {
    final l10n = widget.l10n;

    int score = app.isProductive ? 65 : 35;
    final double growth = details.comparisons.growthPercentage;

    if (app.isProductive) {
      if (growth < -10)
        score += 15;
      else if (growth < 0)
        score += 8;
      else if (growth > 20) score -= 10;
    } else {
      if (growth > 10)
        score -= 15;
      else if (growth > 0)
        score -= 8;
      else if (growth < -20) score += 10;
    }
    score = score.clamp(0, 100);

    final Color scoreColor = score >= 70
        ? Colors.green
        : score >= 45
            ? Colors.orange
            : Colors.red;

    final String label = score >= 70
        ? l10n.productivityScoreGreat
        : score >= 45
            ? l10n.productivityScoreModerate
            : l10n.productivityScoreNeedsAttention;

    return Row(
      children: [
        SizedBox(
          width: 56,
          height: 56,
          child: Stack(
            fit: StackFit.expand,
            children: [
              mt.CircularProgressIndicator(
                value: score / 100,
                strokeWidth: 5,
                backgroundColor: scoreColor.withValues(alpha: 0.15),
                color: scoreColor,
              ),
              Center(
                child: Text(
                  '$score',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: scoreColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: scoreColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                app.isProductive
                    ? l10n.productiveAppMotivation
                    : l10n.nonProductiveAppSuggestion,
                style: TextStyle(
                  fontSize: 11,
                  color: theme.inactiveColor,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

// ── Streak tracker ───────────────────────────────────────────────────────────

  Widget _buildStreakTracker(
    Map<String, Duration> weeklyData, {
    required bool hasLimit,
    required Duration limitDuration,
    required FluentThemeData theme,
  }) {
    final l10n = widget.l10n;
    final sortedKeys = _getSortedDateKeys(weeklyData);

    int usedStreak = 0;
    int overLimitStreak = 0;

    for (final date in sortedKeys.reversed) {
      final Duration d = weeklyData[date] ?? Duration.zero;
      if (d > Duration.zero)
        usedStreak++;
      else
        break;
    }

    if (hasLimit) {
      for (final date in sortedKeys.reversed) {
        final Duration d = weeklyData[date] ?? Duration.zero;
        if (d > limitDuration)
          overLimitStreak++;
        else
          break;
      }
    }

    return Column(
      children: [
        _buildStreakRow(
          icon: FluentIcons.calendar,
          iconColor: Colors.blue,
          label: l10n.daysUsedInARow,
          value:
              '$usedStreak ${usedStreak != 1 ? l10n.daysPlural : l10n.daysSingular}',
          theme: theme,
        ),
        if (hasLimit) ...[
          const SizedBox(height: 10),
          _buildStreakRow(
            icon: overLimitStreak > 0
                ? FluentIcons.warning
                : FluentIcons.shield_alert,
            iconColor: overLimitStreak > 0 ? Colors.red : Colors.green,
            label: overLimitStreak > 0
                ? l10n.daysOverLimitInARow
                : l10n.withinLimitAllWeek,
            value: overLimitStreak > 0
                ? '$overLimitStreak ${overLimitStreak != 1 ? l10n.daysPlural : l10n.daysSingular}'
                : '✓',
            valueColor: overLimitStreak > 0 ? Colors.red : Colors.green,
            theme: theme,
          ),
        ],
      ],
    );
  }

  Widget _buildStreakRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    Color? valueColor,
    required FluentThemeData theme,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 14, color: iconColor),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 11, color: theme.inactiveColor),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: valueColor ?? theme.accentColor,
          ),
        ),
      ],
    );
  }

// ── Utility helpers ──────────────────────────────────────────────────────────

  List<String> _getSortedDateKeys(Map<String, Duration> data) {
    return data.keys.toList()
      ..sort((a, b) {
        try {
          return DateFormat('MM/dd')
              .parse(a)
              .compareTo(DateFormat('MM/dd').parse(b));
        } catch (_) {
          return 0;
        }
      });
  }

  bool _isToday(String dateString) {
    try {
      final date = DateFormat('MM/dd').parse(dateString);
      final now = DateTime.now();
      return date.month == now.month && date.day == now.day;
    } catch (_) {
      return false;
    }
  }

  String _formatHour(int hour) {
    if (hour == 0) return '12 AM';
    if (hour == 12) return '12 PM';
    return hour < 12 ? '$hour AM' : '${hour - 12} PM';
  }

  String _formatDayLabel(String dateString, AppLocalizations l10n) {
    try {
      final date = DateFormat('MM/dd').parse(dateString);
      final now = DateTime.now();
      if (date.month == now.month && date.day == now.day) return l10n.today;
      if (date.month == now.month && date.day == now.day - 1)
        return l10n.yesterday;
      return DateFormat('EEEE').format(date);
    } catch (_) {
      return dateString;
    }
  }

  String _formatMinutesShort(double minutes) {
    if (minutes >= 60) {
      final h = (minutes / 60).floor();
      final m = (minutes % 60).round();
      return m == 0 ? '${h}h' : '${h}h${m}m';
    }
    return '${minutes.round()}m';
  }

  Widget _buildUsageChartTab(
      BuildContext context, AppLocalizations l10n, FluentThemeData theme) {
    final dailyUsageSpots = widget.dailyUsageSpots;
    final sortedDates = widget.sortedDates;
    final maxUsage = widget.maxUsage;
    final dateToXCoordinate = widget.dateToXCoordinate;
    final appSummary = widget.appSummary;

    final bool hasLimit =
        appSummary.limitStatus && appSummary.dailyLimit > Duration.zero;
    final double limitMinutes =
        hasLimit ? appSummary.dailyLimit.inMinutes.toDouble() : 0;

    // Average line
    final double avgUsage = dailyUsageSpots.isEmpty
        ? 0
        : dailyUsageSpots.map((s) => s.y).reduce((a, b) => a + b) /
            dailyUsageSpots.length;

    // Peak spot
    FlSpot? peakSpot;
    if (dailyUsageSpots.isNotEmpty) {
      peakSpot = dailyUsageSpots.reduce((a, b) => a.y > b.y ? a : b);
    }

    // Smart Y-axis max
    double yMax = maxUsage + 30;
    if (hasLimit && limitMinutes > yMax) yMax = limitMinutes + 20;

    // Smart Y-axis interval
    double yInterval = _niceInterval(yMax);

    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.resources.dividerStrokeColorDefault),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.usageOverPastWeek,
                  style: theme.typography.subtitle
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                // Legend pills
                Wrap(
                  spacing: 10,
                  children: [
                    _legendPill(l10n.legendUsage, Colors.blue, theme),
                    _legendPill(l10n.legendAverage, Colors.teal, theme,
                        dashed: true),
                    if (hasLimit)
                      _legendPill(l10n.legendLimit, Colors.red, theme,
                          dashed: true),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 250,
              child: dailyUsageSpots.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(FluentIcons.chart,
                              size: 40,
                              color: theme.accentColor.withValues(alpha: 0.3)),
                          const SizedBox(height: 12),
                          Text(
                            l10n.noHistoricalData,
                            style: TextStyle(
                              fontSize: 14,
                              color: theme.inactiveColor,
                            ),
                          ),
                        ],
                      ),
                    )
                  : LineChart(
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeInOutCubic,
                      LineChartData(
                        clipData: const FlClipData.all(),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: yInterval,
                          getDrawingHorizontalLine: (value) => FlLine(
                            color: theme.accentColor.withValues(alpha: 0.08),
                            strokeWidth: 1,
                          ),
                        ),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 36,
                              interval: 1,
                              getTitlesWidget: (value, meta) {
                                final idx = value.round();
                                if (idx < 0 || idx >= sortedDates.length) {
                                  return const SizedBox.shrink();
                                }
                                final date = sortedDates[idx];
                                final label = _formatDateForAxis(date, l10n);
                                final isPeak = peakSpot != null &&
                                    peakSpot.x.round() == idx;
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    label,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: isPeak
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                      color: isPeak
                                          ? theme.accentColor
                                          : theme.inactiveColor,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 48,
                              interval: yInterval,
                              getTitlesWidget: (value, meta) {
                                if (value == 0) return const SizedBox.shrink();
                                return Padding(
                                  padding: const EdgeInsets.only(right: 6.0),
                                  child: Text(
                                    _formatMinutesShort(value),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: theme.inactiveColor,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border(
                            bottom: BorderSide(
                                color:
                                    theme.accentColor.withValues(alpha: 0.2)),
                            left: BorderSide(
                                color:
                                    theme.accentColor.withValues(alpha: 0.2)),
                          ),
                        ),
                        minX: 0,
                        maxX: (sortedDates.length - 1).toDouble(),
                        minY: 0,
                        maxY: yMax,
                        lineTouchData: LineTouchData(
                          enabled: true,
                          touchTooltipData: LineTouchTooltipData(
                            tooltipBorder: BorderSide(
                                color:
                                    theme.accentColor.withValues(alpha: 0.3)),
                            tooltipBorderRadius: BorderRadius.circular(10),
                            getTooltipColor: (_) =>
                                theme.cardColor.withValues(alpha: 0.97),
                            fitInsideHorizontally: true,
                            fitInsideVertically: true,
                            getTooltipItems: (touchedSpots) {
                              return touchedSpots.map((spot) {
                                // Only show tooltip for usage line (index 0)
                                if (spot.barIndex == 0) {
                                  final int idx = spot.x.round();
                                  final String date = idx < sortedDates.length
                                      ? sortedDates[idx]
                                      : '';
                                  final double mins = spot.y;
                                  final bool overLimit =
                                      hasLimit && mins > limitMinutes;
                                  return LineTooltipItem(
                                    '',
                                    const TextStyle(),
                                    children: [
                                      TextSpan(
                                        text: '$date\n',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: theme.inactiveColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      TextSpan(
                                        text: _formatMinutesLong(mins),
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: overLimit
                                              ? Colors.red
                                              : Colors.blue,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (overLimit)
                                        TextSpan(
                                          text:
                                              '\n${l10n.overLimitBy(_formatMinutesLong(mins - limitMinutes))}',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.red
                                                .withValues(alpha: 0.8),
                                          ),
                                        ),
                                    ],
                                  );
                                }
                                return null;
                              }).toList();
                            },
                          ),
                          handleBuiltInTouches: true,
                          getTouchedSpotIndicator: (barData, spotIndexes) {
                            return spotIndexes.map((idx) {
                              return TouchedSpotIndicatorData(
                                FlLine(
                                  color: Colors.blue.withValues(alpha: 0.4),
                                  strokeWidth: 1.5,
                                  dashArray: [4, 4],
                                ),
                                FlDotData(
                                  show: true,
                                  getDotPainter: (spot, percent, bar, index) =>
                                      FlDotCirclePainter(
                                    radius: 6,
                                    color: Colors.blue,
                                    strokeWidth: 2.5,
                                    strokeColor: Colors.white,
                                  ),
                                ),
                              );
                            }).toList();
                          },
                        ),
                        lineBarsData: [
                          // ── Main usage line ──────────────────────────
                          LineChartBarData(
                            spots: dailyUsageSpots,
                            isCurved: true,
                            curveSmoothness: 0.35,
                            color: Colors.blue,
                            barWidth: 2.5,
                            isStrokeCapRound: true,
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, bar, index) {
                                final bool isPeak =
                                    peakSpot != null && spot.x == peakSpot.x;
                                final bool overLimit =
                                    hasLimit && spot.y > limitMinutes;
                                return FlDotCirclePainter(
                                  radius: isPeak ? 6 : 4,
                                  color: overLimit
                                      ? Colors.red
                                      : isPeak
                                          ? Colors.orange
                                          : Colors.blue,
                                  strokeWidth: 2,
                                  strokeColor: Colors.white,
                                );
                              },
                            ),
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                colors: [
                                  Colors.blue.withValues(alpha: 0.25),
                                  Colors.blue.withValues(alpha: 0.0),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                          // ── Average line ─────────────────────────────
                          LineChartBarData(
                            spots: [
                              FlSpot(0, avgUsage),
                              FlSpot((sortedDates.length - 1).toDouble(),
                                  avgUsage),
                            ],
                            isCurved: false,
                            color: Colors.teal.withValues(alpha: 0.7),
                            barWidth: 1.5,
                            isStrokeCapRound: true,
                            dotData: const FlDotData(show: false),
                            dashArray: [6, 4],
                          ),
                          // ── Limit line ───────────────────────────────
                          if (hasLimit)
                            LineChartBarData(
                              spots: List.generate(
                                sortedDates.length,
                                (i) => FlSpot(i.toDouble(), limitMinutes),
                              ),
                              isCurved: false,
                              color: Colors.red.withValues(alpha: 0.75),
                              barWidth: 1.5,
                              isStrokeCapRound: true,
                              dotData: const FlDotData(show: false),
                              dashArray: [8, 4],
                            ),
                        ],
                      ),
                    ),
            ),
            // ── Summary bar under chart ──────────────────────────────
            if (dailyUsageSpots.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: theme.accentColor.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _chartStat(
                        l10n.chartPeak,
                        _formatMinutesLong(peakSpot?.y ?? 0),
                        Colors.orange,
                        theme),
                    _verticalDivider(theme),
                    _chartStat(l10n.legendAverage, _formatMinutesLong(avgUsage),
                        Colors.teal, theme),
                    if (hasLimit) ...[
                      _verticalDivider(theme),
                      _chartStat(l10n.legendLimit,
                          _formatMinutesLong(limitMinutes), Colors.red, theme),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

// ── New helper widgets & methods ─────────────────────────────────────────────

  Widget _legendPill(String label, Color color, FluentThemeData theme,
      {bool dashed = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 2.5,
          decoration: BoxDecoration(
            color: dashed ? Colors.transparent : color,
            border: dashed
                ? Border(
                    bottom: BorderSide(
                      color: color,
                      width: 2,
                      style: BorderStyle.solid,
                    ),
                  )
                : null,
          ),
          child: dashed ? null : null,
        ),
        Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(right: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: dashed ? 0.5 : 1.0),
            shape: BoxShape.circle,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: theme.inactiveColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _chartStat(
      String label, String value, Color color, FluentThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: theme.inactiveColor,
          ),
        ),
      ],
    );
  }

  Widget _verticalDivider(FluentThemeData theme) {
    return Container(
      width: 1,
      height: 30,
      color: theme.resources.dividerStrokeColorDefault,
    );
  }

  double _niceInterval(double maxVal) {
    if (maxVal <= 60) return 15;
    if (maxVal <= 120) return 30;
    if (maxVal <= 300) return 60;
    return 120;
  }

  String _formatMinutesLong(double minutes) {
    final h = (minutes / 60).floor();
    final m = (minutes % 60).round();
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
  }

  Widget _buildPatternsTab(
      BuildContext context, AppLocalizations l10n, FluentThemeData theme) {
    final timeOfDayUsage = widget.timeOfDayUsage;
    final appBasicDetails = widget.appBasicDetails;
    final appDetails = widget.appDetails;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Time of Day Chart
          _buildCompactCard(
            context,
            l10n.usagePatternByTimeOfDay,
            FluentIcons.timeline_progress,
            theme,
            child: SizedBox(
              height: 200,
              child: Row(
                children: [
                  // Pie Chart
                  Expanded(
                    flex: 3,
                    child: PieChart(
                      PieChartData(
                        sections: timeOfDayUsage.entries.map((entry) {
                          final Color color = _getTimeOfDayColor(entry.key);
                          return PieChartSectionData(
                            color: color,
                            value: entry.value,
                            title: '${entry.value.toInt()}%',
                            radius: 70,
                            titleStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          );
                        }).toList(),
                        centerSpaceRadius: 30,
                        sectionsSpace: 2,
                      ),
                    ),
                  ),
                  // Legend
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: timeOfDayUsage.entries.map((entry) {
                        String localizedLabel = entry.key;
                        if (entry.key.contains('Morning')) {
                          localizedLabel = l10n.morning;
                        } else if (entry.key.contains('Afternoon')) {
                          localizedLabel = l10n.afternoon;
                        } else if (entry.key.contains('Evening')) {
                          localizedLabel = l10n.evening;
                        } else if (entry.key.contains('Night')) {
                          localizedLabel = l10n.night;
                        }

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: _getTimeOfDayColor(entry.key),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                localizedLabel,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Usage Insights
          _buildCompactCard(
            context,
            l10n.usageInsights,
            FluentIcons.lightbulb,
            theme,
            child: Text(
              _generateUsageInsights(
                  l10n, appBasicDetails, appDetails, timeOfDayUsage),
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
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
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

  // Helper methods
  String _formatDateForAxis(String dateString, AppLocalizations l10n) {
    try {
      final DateFormat inputFormatter = DateFormat('MM/dd');
      final DateTime date = inputFormatter.parse(dateString);
      final DateTime today = DateTime.now();

      if (date.year == today.year &&
          date.month == today.month &&
          date.day == today.day) {
        return l10n.todayChart;
      }

      return DateFormat('EEE').format(date);
    } catch (e) {
      return dateString;
    }
  }

  String _determineTrend(UsageComparisons comparisons, AppLocalizations l10n) {
    final double percentage = comparisons.growthPercentage;
    if (percentage > 5) return l10n.increasing;
    if (percentage < -5) return l10n.decreasing;
    return l10n.stable;
  }

  Color _getTrendColor(UsageComparisons comparisons) {
    final double percentage = comparisons.growthPercentage;
    if (percentage > 5) return Colors.red;
    if (percentage < -5) return Colors.green;
    return Colors.blue;
  }

  Color _getTimeOfDayColor(String timeOfDay) {
    final Map<String, Color> timeColors = {
      'Morning (6-12)': Colors.orange,
      'Afternoon (12-5)': Colors.yellow,
      'Evening (5-9)': Colors.purple,
      'Night (9-6)': Colors.blue,
    };
    return timeColors[timeOfDay] ?? Colors.grey;
  }

  String _generateUsageInsights(
    AppLocalizations l10n,
    ApplicationBasicDetail app,
    ApplicationDetailedData details,
    Map<String, double> timeOfDay,
  ) {
    final List<String> insights = [];
    final String primaryTimeOfDay =
        timeOfDay.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    String localizedTimeOfDay = primaryTimeOfDay;

    if (primaryTimeOfDay.contains('Morning')) {
      localizedTimeOfDay = l10n.morning;
    } else if (primaryTimeOfDay.contains('Afternoon')) {
      localizedTimeOfDay = l10n.afternoon;
    } else if (primaryTimeOfDay.contains('Evening')) {
      localizedTimeOfDay = l10n.evening;
    } else if (primaryTimeOfDay.contains('Night')) {
      localizedTimeOfDay = l10n.night;
    }

    insights.add(
      l10n.primaryUsageTime(app.name, localizedTimeOfDay),
    );

    final double growthPercentage = details.comparisons.growthPercentage;
    if (growthPercentage > 10) {
      insights
          .add(l10n.significantIncrease(growthPercentage.toStringAsFixed(1)));
    } else if (growthPercentage > 5) {
      insights.add(l10n.trendingUpward);
    } else if (growthPercentage < -10) {
      insights.add(
          l10n.significantDecrease(growthPercentage.abs().toStringAsFixed(1)));
    } else if (growthPercentage < -5) {
      insights.add(l10n.trendingDownward);
    } else {
      insights.add(l10n.consistentUsage);
    }

    return insights.join(" ");
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) return "${hours}h ${minutes}m";
    return "${minutes}m";
  }
}
