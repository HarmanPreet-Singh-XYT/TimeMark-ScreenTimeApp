// focus_mode_history.dart
import './resources/app_resources.dart';
import './resources/color_extensions.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:fluent_ui/fluent_ui.dart' hide Colors;
import 'package:flutter/material.dart' show Colors, Material;
import 'package:screentime/l10n/app_localizations.dart';

class FocusModeHistoryChart extends StatefulWidget {
  final Map<String, int> data;

  const FocusModeHistoryChart({super.key, required this.data});

  @override
  State<StatefulWidget> createState() => FocusModeHistoryChartState();
}

class FocusModeHistoryChartState extends State<FocusModeHistoryChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final totalSessions = widget.data.values.fold(0, (sum, val) => sum + val);
    final maxValue = widget.data.values.isEmpty
        ? 10
        : widget.data.values.reduce((a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary row
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              _buildSummaryChip(
                context,
                label: 'This Week',
                value: '$totalSessions sessions',
                color: const Color(0xFF42A5F5),
              ),
              const SizedBox(width: 12),
              _buildSummaryChip(
                context,
                label: 'Best Day',
                value: _getBestDay(l10n),
                color: const Color(0xFF4CAF50),
              ),
            ],
          ),
        ),

        // Chart
        AspectRatio(
          aspectRatio: 2.5,
          child: BarChart(
            BarChartData(
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  tooltipBorderRadius: BorderRadius.circular(8),
                  tooltipPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  getTooltipColor: (group) =>
                      FluentTheme.of(context).micaBackgroundColor,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final l10n = AppLocalizations.of(context)!;
                    final days = [
                      l10n.day_monday,
                      l10n.day_tuesday,
                      l10n.day_wednesday,
                      l10n.day_thursday,
                      l10n.day_friday,
                      l10n.day_saturday,
                      l10n.day_sunday
                    ];
                    return BarTooltipItem(
                      '${days[groupIndex]}\n',
                      TextStyle(
                        color: FluentTheme.of(context).typography.body?.color,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                      children: [
                        TextSpan(
                          text: '${rod.toY.toInt()} sessions',
                          style: const TextStyle(
                            color: Color(0xFF4CAF50),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                touchCallback: (FlTouchEvent event, barTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        barTouchResponse == null ||
                        barTouchResponse.spot == null) {
                      _touchedIndex = -1;
                      return;
                    }
                    _touchedIndex = barTouchResponse.spot!.touchedBarGroupIndex;
                  });
                },
              ),
              titlesData: _getTitlesData(context),
              borderData: FlBorderData(show: false),
              barGroups: _getBarGroups(context, maxValue),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval:
                    (maxValue / 4).ceilToDouble().clamp(1, double.infinity),
                getDrawingHorizontalLine: (value) => FlLine(
                  color: FluentTheme.of(context)
                      .inactiveBackgroundColor
                      .withOpacity(0.5),
                  strokeWidth: 1,
                  dashArray: [5, 5],
                ),
              ),
              alignment: BarChartAlignment.spaceAround,
              maxY: (maxValue * 1.2).ceilToDouble().clamp(5, double.infinity),
            ),
            swapAnimationDuration: const Duration(milliseconds: 300),
            swapAnimationCurve: Curves.easeOutCubic,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryChip(
    BuildContext context, {
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: FluentTheme.of(context).typography.caption?.copyWith(
                      color: FluentTheme.of(context)
                          .typography
                          .caption
                          ?.color
                          ?.withOpacity(0.6),
                      fontSize: 10,
                    ),
              ),
              Text(
                value,
                style: FluentTheme.of(context).typography.body?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getBestDay(AppLocalizations l10n) {
    if (widget.data.isEmpty) return '-';

    final days = {
      'Monday': l10n.day_monday,
      'Tuesday': l10n.day_tuesday,
      'Wednesday': l10n.day_wednesday,
      'Thursday': l10n.day_thursday,
      'Friday': l10n.day_friday,
      'Saturday': l10n.day_saturday,
      'Sunday': l10n.day_sunday,
    };

    String bestDay = '';
    int maxSessions = 0;

    widget.data.forEach((day, count) {
      if (count > maxSessions) {
        maxSessions = count;
        bestDay = day;
      }
    });

    return maxSessions > 0 ? (days[bestDay] ?? bestDay) : '-';
  }

  FlTitlesData _getTitlesData(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return FlTitlesData(
      show: true,
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 32,
          getTitlesWidget: (value, meta) {
            final days = [
              l10n.day_mondayAbbr,
              l10n.day_tuesdayAbbr,
              l10n.day_wednesdayAbbr,
              l10n.day_thursdayAbbr,
              l10n.day_fridayAbbr,
              l10n.day_saturdayAbbr,
              l10n.day_sundayAbbr
            ];

            final isToday = DateTime.now().weekday - 1 == value.toInt();

            return SideTitleWidget(
              meta: meta,
              space: 8,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    days[value.toInt()],
                    style: TextStyle(
                      color: isToday
                          ? const Color(0xFF4CAF50)
                          : FluentTheme.of(context)
                              .typography
                              .body
                              ?.color
                              ?.withOpacity(0.6),
                      fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                  if (isToday)
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: Color(0xFF4CAF50),
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 32,
          getTitlesWidget: (value, meta) {
            if (value == 0) return const SizedBox.shrink();
            return SideTitleWidget(
              meta: meta,
              child: Text(
                value.toInt().toString(),
                style: TextStyle(
                  color: FluentTheme.of(context)
                      .typography
                      .body
                      ?.color
                      ?.withOpacity(0.4),
                  fontSize: 10,
                ),
              ),
            );
          },
        ),
      ),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  List<BarChartGroupData> _getBarGroups(BuildContext context, int maxValue) {
    final l10n = AppLocalizations.of(context)!;
    final List<String> days = [
      l10n.day_monday,
      l10n.day_tuesday,
      l10n.day_wednesday,
      l10n.day_thursday,
      l10n.day_friday,
      l10n.day_saturday,
      l10n.day_sunday
    ];

    // Also check English day names as fallback
    final List<String> englishDays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];

    final todayIndex = DateTime.now().weekday - 1;

    return List.generate(7, (index) {
      // Try localized name first, then English
      int value =
          widget.data[days[index]] ?? widget.data[englishDays[index]] ?? 0;
      final isTouched = index == _touchedIndex;
      final isToday = index == todayIndex;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: value.toDouble(),
            width: isTouched ? 20 : 16,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            gradient: LinearGradient(
              colors: isToday
                  ? [const Color(0xFF4CAF50), const Color(0xFF81C784)]
                  : isTouched
                      ? [const Color(0xFF42A5F5), const Color(0xFF90CAF9)]
                      : [
                          const Color(0xFF42A5F5).withOpacity(0.7),
                          const Color(0xFF90CAF9).withOpacity(0.7)
                        ],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: maxValue * 1.2,
              color: FluentTheme.of(context)
                  .inactiveBackgroundColor
                  .withOpacity(0.2),
            ),
          ),
        ],
      );
    });
  }
}
