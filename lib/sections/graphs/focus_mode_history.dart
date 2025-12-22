import './resources/app_resources.dart';
import './resources/color_extensions.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:screentime/l10n/app_localizations.dart';

class _BarChart extends StatelessWidget {
  final Map<String, int> data;
  
  const _BarChart({required this.data});

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        barTouchData: barTouchData,
        titlesData: titlesData(context),
        borderData: borderData,
        barGroups: barGroups(context),
        gridData: const FlGridData(show: false),
        alignment: BarChartAlignment.spaceAround,
        maxY: 20,
      ),
    );
  }

  BarTouchData get barTouchData => BarTouchData(
        enabled: false,
        touchTooltipData: BarTouchTooltipData(
          getTooltipColor: (group) => Colors.transparent,
          tooltipPadding: EdgeInsets.zero,
          tooltipMargin: 8,
          getTooltipItem: (
            BarChartGroupData group,
            int groupIndex,
            BarChartRodData rod,
            int rodIndex,
          ) {
            return BarTooltipItem(
              rod.toY.round().toString(),
              const TextStyle(
                color: AppColors.contentColorCyan,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
      );

  Widget getTitles(double value, TitleMeta meta, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final style = TextStyle(
      color: AppColors.contentColorBlue.darken(20),
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    
    String text;
    switch (value.toInt()) {
      case 0:
        text = l10n.day_mondayAbbr;
        break;
      case 1:
        text = l10n.day_tuesdayAbbr;
        break;
      case 2:
        text = l10n.day_wednesdayAbbr;
        break;
      case 3:
        text = l10n.day_thursdayAbbr;
        break;
      case 4:
        text = l10n.day_fridayAbbr;
        break;
      case 5:
        text = l10n.day_saturdayAbbr;
        break;
      case 6:
        text = l10n.day_sundayAbbr;
        break;
      default:
        text = '';
        break;
    }
    return SideTitleWidget(
      meta: meta,
      space: 4,
      child: Text(text, style: style),
    );
  }

  FlTitlesData titlesData(BuildContext context) => FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: (value, meta) => getTitles(value, meta, context),
          ),
        ),
        leftTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      );

  FlBorderData get borderData => FlBorderData(show: false);

  LinearGradient get _barsGradient => LinearGradient(
        colors: [
          AppColors.contentColorBlue.darken(20),
          AppColors.contentColorCyan,
        ],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      );

  List<BarChartGroupData> barGroups(BuildContext context) {
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
    
    return List.generate(7, (index) {
      final dayName = days[index];
      final value = data[dayName] ?? 0;
      
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: value.toDouble(),
            gradient: _barsGradient,
          )
        ],
        showingTooltipIndicators: value > 0 ? [0] : [],
      );
    });
  }
}

class FocusModeHistoryChart extends StatefulWidget {
  final Map<String, int> data;
  
  const FocusModeHistoryChart({super.key, required this.data});

  @override
  State<StatefulWidget> createState() => FocusModeHistoryChartState();
}

class FocusModeHistoryChartState extends State<FocusModeHistoryChart> {
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 4,
      child: _BarChart(data: widget.data),
    );
  }
}