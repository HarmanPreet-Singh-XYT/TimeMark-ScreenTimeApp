import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';

class FocusModePieChart extends StatelessWidget {
  final Map<String, double> dataMap;
  final List<Color> colorList;
  final ChartType chartType;
  final double ringStrokeWidth;
  final bool showCenterText;
  final Widget? centerWidget;

  const FocusModePieChart({
    Key? key,
    required this.dataMap,
    required this.colorList,
    this.chartType = ChartType.disc,
    this.ringStrokeWidth = 32,
    this.showCenterText = true,
    this.centerWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PieChart(
      dataMap: dataMap,
      animationDuration: const Duration(milliseconds: 800),
      chartRadius: math.min(MediaQuery.of(context).size.width / 3.2, 280),
      colorList: colorList,
      initialAngleInDegree: 0,
      chartType: chartType,
      centerText: null,
      centerWidget: centerWidget,
      legendOptions: const LegendOptions(
        showLegends: true,
      ),
      chartValuesOptions: const ChartValuesOptions(
        showChartValues: true,
        showChartValuesInPercentage: true,
      ),
      ringStrokeWidth: ringStrokeWidth,
      baseChartColor: Colors.transparent,
    );
  }
}