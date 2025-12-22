import 'package:fl_chart/fl_chart.dart';
import 'package:screentime/sections/controller/data_controllers/reports_controller.dart';
import './resources/app_resources.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:screentime/l10n/app_localizations.dart';

enum ChartType { main, alternate }
enum DateDisplayMode { dayOfWeek, dayMonth, monthYear }

class LineChartWidget extends StatelessWidget {
  final ChartType chartType;
  final List<DailyScreenTime>? dailyScreenTimeData;
  final String periodType;
  final DateTime? startDate;
  final DateTime? endDate;
  final Function(DateTime) onDateSelected;

  const LineChartWidget({
    super.key, 
    required this.chartType,
    this.dailyScreenTimeData,
    this.periodType = 'Custom Range',
    this.startDate,
    this.endDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return LineChart(
      getChartData(chartType, context),
      duration: const Duration(milliseconds: 250),
    );
  }

  LineChartData getChartData(ChartType type, BuildContext context) {
    // Calculate max Y value for the chart based on daily screen time data
    double maxY = 6.0; // Default value
    
    if (dailyScreenTimeData != null && dailyScreenTimeData!.isNotEmpty) {
      final maxScreenTimeHours = dailyScreenTimeData!
          .map((data) => data.screenTime.inMinutes / 60.0)
          .reduce((a, b) => a > b ? a : b);
      
      // Round up to the nearest hour and add 1 for better visualization
      maxY = (maxScreenTimeHours.ceil() + 1).toDouble();
    }

    // Set minX to 0.5 to give some padding at the start
    const double minX = 0.5;
    
    // Set maxX based on the data length with some padding at the end
    final double maxX = dailyScreenTimeData != null && dailyScreenTimeData!.isNotEmpty
        ? (dailyScreenTimeData!.length + 0.5).toDouble()
        : 7.5; // Default to 7 days if no data

    return LineChartData(
      lineTouchData: type == ChartType.main ? lineTouchData1(context) : lineTouchData2,
      gridData: gridData,
      titlesData: type == ChartType.main ? titlesData1(context) : titlesData2(context),
      borderData: borderData,
      lineBarsData: type == ChartType.main ? lineBarsData1 : lineBarsData2,
      minX: minX,
      maxX: maxX,
      maxY: type == ChartType.main ? maxY : 6,
      minY: 0,
    );
  }

  // Determine the best date display format based on the date range
  DateDisplayMode _getDateDisplayMode() {
    if (dailyScreenTimeData == null || dailyScreenTimeData!.isEmpty) {
      return DateDisplayMode.dayOfWeek;
    }

    // Calculate total days in the data
    final int totalDays = dailyScreenTimeData!.length;
    
    if (totalDays <= 14) {
      return DateDisplayMode.dayOfWeek; // Show day names for shorter periods
    } else if (totalDays <= 90) {
      return DateDisplayMode.dayMonth; // Show day/month for medium periods
    } else {
      return DateDisplayMode.monthYear; // Show month/year for longer periods
    }
  }

  // Format a date according to the display mode
  String _formatDate(DateTime date, DateDisplayMode mode, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    switch (mode) {
      case DateDisplayMode.dayOfWeek:
        // Use localized short day names
        final List<String> dayNames = [
          l10n.day_mondayShort,
          l10n.day_tuesdayShort,
          l10n.day_wednesdayShort,
          l10n.day_thursdayShort,
          l10n.day_fridayShort,
          l10n.day_saturdayShort,
          l10n.day_sundayShort,
        ];
        return dayNames[date.weekday - 1];
      case DateDisplayMode.dayMonth:
        // Day and month in short format (locale-aware)
        return DateFormat('d/M').format(date);
      case DateDisplayMode.monthYear:
        // Month abbreviation (locale-aware)
        return DateFormat('MMM', l10n.localeName).format(date);
    }
  }

  LineTouchData lineTouchData1(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return LineTouchData(
      handleBuiltInTouches: true,
      touchCallback: (FlTouchEvent event, LineTouchResponse? touchResponse) {
        // Handle tap event to trigger onDateSelected callback
        if (event is FlTapUpEvent && touchResponse != null && touchResponse.lineBarSpots != null && 
            touchResponse.lineBarSpots!.isNotEmpty) {
          final spot = touchResponse.lineBarSpots!.first;
          final spotIndex = spot.x.toInt() - 1; // Convert to 0-based index
          
          if (dailyScreenTimeData != null && 
              spotIndex >= 0 && 
              spotIndex < dailyScreenTimeData!.length) {
            // Get the date for the tapped spot and call the callback
            final date = dailyScreenTimeData![spotIndex].date;
            onDateSelected(date);
          }
        }
      },
      touchTooltipData: LineTouchTooltipData(
        getTooltipItems: (List<LineBarSpot> touchedSpots) {
          return touchedSpots.map((spot) {
            if (dailyScreenTimeData != null && 
                spot.x.toInt() > 0 && 
                spot.x.toInt() <= dailyScreenTimeData!.length) {
              final screenTime = dailyScreenTimeData![spot.x.toInt() - 1].screenTime;
              final hours = screenTime.inHours;
              final minutes = screenTime.inMinutes.remainder(60);
              
              // Include the date in the tooltip
              final date = dailyScreenTimeData![spot.x.toInt() - 1].date;
              final dateStr = DateFormat('MMM d, yyyy', l10n.localeName).format(date);
              
              return LineTooltipItem(
                l10n.tooltip_dateScreenTime(dateStr, hours, minutes),
                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              );
            }
            return LineTooltipItem(
              l10n.tooltip_hoursFormat(spot.y.toStringAsFixed(1)),
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            );
          }).toList();
        },
        getTooltipColor: (touchedSpot) => Colors.blueGrey.withValues(alpha: .8),
      ),
    );
  }

  LineTouchData get lineTouchData2 => const LineTouchData(enabled: false);

  FlTitlesData titlesData1(BuildContext context) => FlTitlesData(
        bottomTitles: AxisTitles(sideTitles: bottomTitles(context)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(sideTitles: leftTitles(context)),
      );

  FlTitlesData titlesData2(BuildContext context) => titlesData1(context);

  List<LineChartBarData> get lineBarsData1 {
    if (dailyScreenTimeData != null && dailyScreenTimeData!.isNotEmpty) {
      return [
        LineChartBarData(
          isCurved: true,
          color: AppColors.contentColorGreen,
          barWidth: 8,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              // Enhance dot visualization to make them more tappable
              return FlDotCirclePainter(
                radius: 4,
                strokeWidth: 2,
                strokeColor: AppColors.contentColorGreen,
                color: Colors.white,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            color: AppColors.contentColorGreen.withValues(alpha: .2),
          ),
          spots: _getSpots(),
        ),
      ];
    } else {
      return [
        lineChartBarData1_1,
        lineChartBarData1_3,
      ];
    }
  }

  List<FlSpot> _getSpots() {
    if (dailyScreenTimeData == null || dailyScreenTimeData!.isEmpty) {
      return const [
        FlSpot(1, 1),
        FlSpot(3, 1.5),
        FlSpot(5, 1.4),
        FlSpot(7, 3.4),
      ];
    }

    return dailyScreenTimeData!.asMap().entries.map((entry) {
      // Convert index to 1-based X value and minutes to hours for Y value
      final index = entry.key;
      final data = entry.value;
      final hourValue = data.screenTime.inMinutes / 60.0;
      
      return FlSpot((index + 1).toDouble(), hourValue);
    }).toList();
  }

  List<LineChartBarData> get lineBarsData2 => [
        lineChartBarData2_1,
        lineChartBarData2_2,
      ];

  SideTitles leftTitles(BuildContext context) {
    
    return SideTitles(
      getTitlesWidget: (value, meta) => leftTitleWidgets(value, meta, context),
      showTitles: true,
      interval: 1,
      reservedSize: 40,
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    const style = TextStyle(fontWeight: FontWeight.bold, fontSize: 14);
    
    if (value == 0) return Container();
    
    final isInteger = value == value.roundToDouble();
    if (isInteger) {
      return SideTitleWidget(
        meta: meta, 
        child: Text(l10n.time_hours(value.toInt()), style: style),
      );
    }
    
    return Container();
  }

  SideTitles bottomTitles(BuildContext context) {
    // Calculate an appropriate interval based on the data length
    double interval = 1.0;  // Default for 7 days
    
    if (dailyScreenTimeData != null) {
      final int dataLength = dailyScreenTimeData!.length;
      
      // Dynamic interval calculation
      if (dataLength > 365) {        // For yearly data
        interval = (dataLength / 12).ceilToDouble();  // ~Monthly labels
      } else if (dataLength > 180) { // For ~6 months data
        interval = (dataLength / 6).ceilToDouble();   // ~6 labels
      } else if (dataLength > 90) {  // For ~3 months data
        interval = 30.0;             // ~Monthly labels
      } else if (dataLength > 30) {  // For ~1 month data
        interval = 7.0;              // Weekly intervals
      } else if (dataLength > 14) {  // For 2-4 weeks
        interval = 4.0;              // Every 4 days
      } else if (dataLength > 7) {   // For 1-2 weeks
        interval = 2.0;              // Every other day
      }
    }
    
    return SideTitles(
      showTitles: true,
      reservedSize: 40,  // Increased for longer labels
      interval: interval,
      getTitlesWidget: (value, meta) => bottomTitleWidgets(value, meta, context),
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    const style = TextStyle(fontWeight: FontWeight.bold, fontSize: 12);
    String? text;
    
    if (dailyScreenTimeData != null && 
        value >= 1 && 
        value <= dailyScreenTimeData!.length &&
        value == value.roundToDouble()) {
      
      // Get the date for this data point
      final date = dailyScreenTimeData![value.toInt() - 1].date;
      final displayMode = _getDateDisplayMode();
      
      // Format the date based on the determined display mode
      text = _formatDate(date, displayMode, context);
      
      // For monthYear mode, only show year on January or first data point
      if (displayMode == DateDisplayMode.monthYear) {
        if (date.month == 1 || value == 1) {
          text = '$text ${date.year}';
        }
      }
    } else {
      // Fallback for sample data using localized day names
      switch (value.toInt()) {
        case 2:
          text = l10n.day_mondayShort;
          break;
        case 4:
          text = l10n.day_wednesdayShort;
          break;
        case 6:
          text = l10n.day_fridayShort;
          break;
      }
    }

    if (text == null) return Container();
    
    // Calculate rotation angle based on text length and data density
    double angle = 0;
    if (dailyScreenTimeData != null) {
      if (dailyScreenTimeData!.length > 30) {
        angle = 0.5; // More rotation for dense data
      } else if (dailyScreenTimeData!.length > 14) {
        angle = 0.3; // Slight angle
      }
    }
    
    return SideTitleWidget(
      meta: meta, 
      angle: angle,
      space: 10, 
      child: Text(text, style: style),
    );
  }

  FlGridData get gridData => FlGridData(
    show: true,
    drawVerticalLine: false,
    horizontalInterval: 1,
    getDrawingHorizontalLine: (value) {
      return FlLine(
        color: Colors.grey.withValues(alpha: .2),
        strokeWidth: 1,
      );
    },
  );

  FlBorderData get borderData => FlBorderData(
        show: true,
        border: Border(
          bottom: BorderSide(color: AppColors.primary.withValues(alpha: .2), width: 4),
          left: const BorderSide(color: Colors.transparent),
          right: const BorderSide(color: Colors.transparent),
          top: const BorderSide(color: Colors.transparent),
        ),
      );

  LineChartBarData get lineChartBarData1_1 => LineChartBarData(
        isCurved: true,
        color: AppColors.contentColorGreen,
        barWidth: 8,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
        spots: const [
          FlSpot(1, 1),
          FlSpot(3, 1.5),
          FlSpot(5, 1.4),
          FlSpot(7, 3.4),
        ],
      );

  LineChartBarData get lineChartBarData1_3 => LineChartBarData(
        isCurved: true,
        color: AppColors.contentColorCyan,
        barWidth: 8,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
        spots: const [
          FlSpot(1, 2.8),
          FlSpot(3, 1.9),
          FlSpot(5, 3),
          FlSpot(7, 2.5),
        ],
      );

  LineChartBarData get lineChartBarData2_1 => lineChartBarData1_1.copyWith(
        color: AppColors.contentColorGreen.withValues(alpha: .5),
        barWidth: 4,
      );

  LineChartBarData get lineChartBarData2_2 => LineChartBarData(
        isCurved: true,
        color: AppColors.contentColorPink.withValues(alpha: .5),
        barWidth: 4,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(
          show: true, 
          color: AppColors.contentColorPink.withValues(alpha: .2)
        ),
        spots: const [
          FlSpot(1, 1),
          FlSpot(3, 2.8),
          FlSpot(5, 1.2),
          FlSpot(7, 2.8),
        ],
      );
}