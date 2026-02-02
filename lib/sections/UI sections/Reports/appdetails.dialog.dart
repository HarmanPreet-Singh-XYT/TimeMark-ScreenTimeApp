import 'package:fluent_ui/fluent_ui.dart';
import 'package:fl_chart/fl_chart.dart';
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
    final appBasicDetails = widget.appBasicDetails;
    final appSummary = widget.appSummary;
    final appDetails = widget.appDetails;
    final weeklyData = appDetails.usageTrends.daily;
    final weeklyTotal = Duration(
        minutes:
            weeklyData.values.map((d) => d.inMinutes).fold(0, (a, b) => a + b));

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Summary Stats Row
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
              const SizedBox(width: 12),
              Expanded(
                  child: _buildStatCard(
                      context,
                      l10n.dailyLimit,
                      appSummary.limitStatus
                          ? _formatDuration(appSummary.dailyLimit)
                          : l10n.noLimit,
                      FluentIcons.timer,
                      Colors.orange,
                      theme)),
              const SizedBox(width: 12),
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
          const SizedBox(height: 16),

          // Usage Breakdown
          _buildCompactCard(
            context,
            l10n.usageSummary,
            FluentIcons.bulleted_list,
            theme,
            child: Column(
              children: [
                _buildInfoRow(l10n.avgDailyUsage,
                    appDetails.usageInsights.formattedAverageDailyUsage, theme),
                _buildInfoRow(
                    l10n.longestSession,
                    appDetails.sessionBreakdown.formattedLongestSessionDuration,
                    theme),
                _buildInfoRow(l10n.usageTrend,
                    _determineTrend(appDetails.comparisons, l10n), theme,
                    valueColor: _getTrendColor(appDetails.comparisons)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsageChartTab(
      BuildContext context, AppLocalizations l10n, FluentThemeData theme) {
    final dailyUsageSpots = widget.dailyUsageSpots;
    final sortedDates = widget.sortedDates;
    final maxUsage = widget.maxUsage;
    final dateToXCoordinate = widget.dateToXCoordinate;
    final appSummary = widget.appSummary;

    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.usageOverPastWeek,
              style: theme.typography.subtitle?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 250,
              padding: const EdgeInsets.only(right: 16, bottom: 16, top: 8),
              child: dailyUsageSpots.isEmpty
                  ? Center(
                      child: Text(
                        l10n.noHistoricalData,
                        style: TextStyle(
                          fontSize: 16,
                          color: theme.accentColor.withOpacity(0.5),
                        ),
                      ),
                    )
                  : LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: true,
                          getDrawingHorizontalLine: (value) => FlLine(
                            color: theme.accentColor.withOpacity(0.15),
                            strokeWidth: 1,
                          ),
                          getDrawingVerticalLine: (value) => FlLine(
                            color: theme.accentColor.withOpacity(0.15),
                            strokeWidth: 1,
                          ),
                        ),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final matchingEntries = dateToXCoordinate
                                    .entries
                                    .where((entry) => entry.value == value);

                                if (matchingEntries.isNotEmpty) {
                                  final String date = matchingEntries.first.key;
                                  final String displayDate =
                                      _formatDateForAxis(date, l10n);
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      displayDate,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: theme.inactiveColor,
                                      ),
                                    ),
                                  );
                                }
                                return const Text('');
                              },
                              reservedSize: 30,
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) => Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Text(
                                  '${value.toInt()}m',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: theme.inactiveColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border.all(
                              color: theme.accentColor.withOpacity(0.15)),
                        ),
                        minX: 0,
                        maxX: sortedDates.length - 1.0,
                        minY: 0,
                        maxY: maxUsage + 20,
                        lineBarsData: [
                          LineChartBarData(
                            spots: dailyUsageSpots,
                            isCurved: true,
                            color: Colors.blue,
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) =>
                                  FlDotCirclePainter(
                                radius: 4,
                                color: Colors.blue,
                                strokeWidth: 2,
                                strokeColor: Colors.white,
                              ),
                            ),
                            belowBarData: BarAreaData(
                              show: true,
                              color: Colors.blue.withOpacity(0.15),
                            ),
                          ),
                          if (appSummary.limitStatus &&
                              appSummary.dailyLimit > Duration.zero)
                            LineChartBarData(
                              spots: List.generate(
                                sortedDates.length,
                                (index) => FlSpot(
                                  index.toDouble(),
                                  appSummary.dailyLimit.inMinutes.toDouble(),
                                ),
                              ),
                              isCurved: false,
                              color: Colors.red.withOpacity(0.7),
                              barWidth: 2,
                              isStrokeCapRound: true,
                              dotData: const FlDotData(show: false),
                              dashArray: [5, 5],
                            ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
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
