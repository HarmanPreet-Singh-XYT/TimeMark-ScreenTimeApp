import 'package:fl_chart/fl_chart.dart';
import './resources/app_resources.dart';
import 'package:flutter/material.dart';

enum ChartType { main, alternate }

class LineChartWidget extends StatelessWidget {
  final ChartType chartType;

  const LineChartWidget({super.key, required this.chartType});

  @override
  Widget build(BuildContext context) {
    return LineChart(
      getChartData(chartType),
      duration: const Duration(milliseconds: 250),
    );
  }

  LineChartData getChartData(ChartType type) {
    return LineChartData(
      lineTouchData: type == ChartType.main ? lineTouchData1 : lineTouchData2,
      gridData: gridData,
      titlesData: type == ChartType.main ? titlesData1 : titlesData2,
      borderData: borderData,
      lineBarsData: type == ChartType.main ? lineBarsData1 : lineBarsData2,
      minX: 0,
      maxX: 14,
      maxY: type == ChartType.main ? 4 : 6,
      minY: 0,
    );
  }

  LineTouchData get lineTouchData1 => LineTouchData(
        handleBuiltInTouches: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (touchedSpot) =>
              Colors.blueGrey.withValues(alpha: 0.8),
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

  List<LineChartBarData> get lineBarsData1 => [
        lineChartBarData1_1,
        // lineChartBarData1_2,
        lineChartBarData1_3,
      ];

  List<LineChartBarData> get lineBarsData2 => [
        lineChartBarData2_1,
        lineChartBarData2_2,
        // lineChartBarData2_3,
      ];

  SideTitles leftTitles() => SideTitles(
        getTitlesWidget: leftTitleWidgets,
        showTitles: true,
        interval: 1,
        reservedSize: 40,
      );

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(fontWeight: FontWeight.bold, fontSize: 14);
    String? text;
    switch (value.toInt()) {
      case 1:
        text = '1m';
        break;
      case 2:
        text = '2m';
        break;
      case 3:
        text = '3m';
        break;
      case 4:
        text = '5m';
        break;
      case 5:
        text = '6m';
        break;
    }

    return text != null
        ? SideTitleWidget(meta: meta, child: Text(text, style: style))
        : Container();
  }

  SideTitles get bottomTitles => SideTitles(
        showTitles: true,
        reservedSize: 32,
        interval: 1,
        getTitlesWidget: bottomTitleWidgets,
      );

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(fontWeight: FontWeight.bold, fontSize: 16);
    String? text;
    switch (value.toInt()) {
      case 2:
        text = 'SEPT';
        break;
      case 7:
        text = 'OCT';
        break;
      case 12:
        text = 'DEC';
        break;
    }

    return text != null
        ? SideTitleWidget(meta: meta, space: 10, child: Text(text, style: style))
        : Container();
  }

  FlGridData get gridData => const FlGridData(show: false);

  FlBorderData get borderData => FlBorderData(
        show: true,
        border: Border(
          bottom: BorderSide(color: AppColors.primary.withValues(alpha: 0.2), width: 4),
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
          FlSpot(10, 2),
          FlSpot(12, 2.2),
          FlSpot(13, 1.8),
        ],
      );

  LineChartBarData get lineChartBarData1_2 => LineChartBarData(
        isCurved: true,
        color: AppColors.contentColorPink,
        barWidth: 8,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
        spots: const [
          FlSpot(1, 1),
          FlSpot(3, 2.8),
          FlSpot(7, 1.2),
          FlSpot(10, 2.8),
          FlSpot(12, 2.6),
          FlSpot(13, 3.9),
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
          FlSpot(6, 3),
          FlSpot(10, 1.3),
          FlSpot(13, 2.5),
        ],
      );

  LineChartBarData get lineChartBarData2_1 => lineChartBarData1_1.copyWith(
        color: AppColors.contentColorGreen.withValues(alpha: 0.5),
        barWidth: 4,
      );

  LineChartBarData get lineChartBarData2_2 => lineChartBarData1_2.copyWith(
        color: AppColors.contentColorPink.withValues(alpha: 0.5),
        barWidth: 4,
        belowBarData: BarAreaData(show: true, color: AppColors.contentColorPink.withValues(alpha: 0.2)),
      );

  LineChartBarData get lineChartBarData2_3 => lineChartBarData1_3.copyWith(
        color: AppColors.contentColorCyan.withValues(alpha: 0.5),
        barWidth: 2,
        dotData: const FlDotData(show: true),
      );
}
