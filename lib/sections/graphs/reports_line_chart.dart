import 'package:fl_chart/fl_chart.dart';
import 'package:productive_screentime/sections/controller/data_controllers/reports_controller.dart';
import './resources/app_resources.dart';
import 'package:flutter/material.dart';

enum ChartType { main, alternate }

class LineChartWidget extends StatelessWidget {
  final ChartType chartType;
  final List<DailyScreenTime>? dailyScreenTimeData;
  final String periodType; // Add this new parameter

  const LineChartWidget({
    super.key, 
    required this.chartType,
    this.dailyScreenTimeData,
    this.periodType = 'Last 7 Days', // Default to 7 days
  });

  @override
  Widget build(BuildContext context) {
    return LineChart(
      getChartData(chartType),
      duration: const Duration(milliseconds: 250),
    );
  }

  LineChartData getChartData(ChartType type) {
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
      lineTouchData: type == ChartType.main ? lineTouchData1 : lineTouchData2,
      gridData: gridData,
      titlesData: type == ChartType.main ? titlesData1 : titlesData2,
      borderData: borderData,
      lineBarsData: type == ChartType.main ? lineBarsData1 : lineBarsData2,
      minX: minX,
      maxX: maxX,
      maxY: type == ChartType.main ? maxY : 6,
      minY: 0,
    );
  }

  LineTouchData get lineTouchData1 => LineTouchData(
        handleBuiltInTouches: true,
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
                final dateStr = '${date.day}/${date.month}';
                
                return LineTooltipItem(
                  '$dateStr: ${hours}h ${minutes}m',
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                );
              }
              return LineTooltipItem(
                '${spot.y.toStringAsFixed(1)} hours',
                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              );
            }).toList();
          },
          getTooltipColor: (touchedSpot) => Colors.blueGrey.withValues(alpha: .8),
        ),
      );

  LineTouchData get lineTouchData2 => const LineTouchData(enabled: false);

  FlTitlesData get titlesData1 => FlTitlesData(
        bottomTitles: AxisTitles(sideTitles: bottomTitles),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(sideTitles: leftTitles()),
      );

  FlTitlesData get titlesData2 => titlesData1; // Reuse titlesData1

  List<LineChartBarData> get lineBarsData1 {
    if (dailyScreenTimeData != null && dailyScreenTimeData!.isNotEmpty) {
      return [
        LineChartBarData(
          isCurved: true,
          color: AppColors.contentColorGreen,
          barWidth: 8,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: true),
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

  SideTitles leftTitles() => SideTitles(
        getTitlesWidget: leftTitleWidgets,
        showTitles: true,
        interval: 1,
        reservedSize: 40,
      );

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(fontWeight: FontWeight.bold, fontSize: 14);
    if (value == 0) return Container();
    
    final isInteger = value == value.roundToDouble();
    if (isInteger) {
      return SideTitleWidget(
        meta: meta, 
        child: Text('${value.toInt()}h', style: style),
      );
    }
    
    return Container();
  }

  SideTitles get bottomTitles {
    // Calculate an appropriate interval based on the data length
    double interval = 1.0;  // Default for 7 days
    
    if (dailyScreenTimeData != null) {
      final int dataLength = dailyScreenTimeData!.length;
      
      if (dataLength > 30) {  // For "Last 3 Months" or "Lifetime"
        interval = (dataLength / 6).ceilToDouble();  // Show ~6 labels
      } else if (dataLength > 14) {  // For "Last Month"
        interval = 7.0;  // Weekly intervals
      } else if (dataLength > 7) {  // For slightly more than a week
        interval = 2.0;  // Every other day
      }
    }
    
    return SideTitles(
      showTitles: true,
      reservedSize: 32,
      interval: interval,
      getTitlesWidget: bottomTitleWidgets,
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(fontWeight: FontWeight.bold, fontSize: 14);
    String? text;
    
    if (dailyScreenTimeData != null && 
        value >= 1 && 
        value <= dailyScreenTimeData!.length &&
        value == value.roundToDouble()) {
      
      // Get the date for this data point
      final date = dailyScreenTimeData![value.toInt() - 1].date;
      
      // Format based on the time period
      if (periodType == 'Last 7 Days') {
        // Use day of week for short periods
        final List<String> dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        text = dayNames[date.weekday - 1];
      } else {
        // Use date format for longer periods
        text = '${date.day}/${date.month}';
      }
    } else {
      // Fallback for sample data
      switch (value.toInt()) {
        case 2:
          text = 'Mon';
          break;
        case 4:
          text = 'Wed';
          break;
        case 6:
          text = 'Fri';
          break;
      }
    }

    if (text == null) return Container();
    
    return SideTitleWidget(
      meta: meta, 
      angle: 0.3, // Slight angle to prevent overlap for longer text
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