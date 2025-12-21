import 'package:fl_chart/fl_chart.dart';
import './resources/app_resources.dart';
import 'package:flutter/material.dart';

class FocusModeTrends extends StatefulWidget {
  const FocusModeTrends({
    super.key,
    required this.data,
    Color? gradientColor1,
    Color? gradientColor2,
    Color? gradientColor3,
    Color? indicatorStrokeColor,
  })  : gradientColor1 = gradientColor1 ?? AppColors.contentColorBlue,
        gradientColor2 = gradientColor2 ?? AppColors.contentColorPink,
        gradientColor3 = gradientColor3 ?? AppColors.contentColorRed,
        indicatorStrokeColor = indicatorStrokeColor ?? AppColors.mainTextColor1;

  final Color gradientColor1;
  final Color gradientColor2;
  final Color gradientColor3;
  final Color indicatorStrokeColor;
  final Map<String, dynamic> data;

  @override
  State<FocusModeTrends> createState() => _FocusModeTrendsState();
}

class _FocusModeTrendsState extends State<FocusModeTrends> {
  List<int> showingTooltipOnSpots = [];
  String _selectedMetric = 'sessionCounts';
  
  List<FlSpot> get allSpots {
    final List<dynamic> values = widget.data[_selectedMetric];
    return List.generate(
      values.length, 
      (index) => FlSpot(index.toDouble(), values[index].toDouble())
    );
  }

  String get yAxisTitle {
    switch(_selectedMetric) {
      case 'sessionCounts':
        return 'Sessions';
      case 'avgDuration':
        return 'Minutes';
      case 'totalFocusTime':
        return 'Minutes';
      default:
        return 'Value';
    }
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta, double chartWidth) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      color: AppColors.contentColorPink,
      fontFamily: 'Digital',
      fontSize: 14,
    );
    
    final int index = value.toInt();
    if (index >= 0 && index < (widget.data['periods'] as List).length) {
      return SideTitleWidget(
        meta: meta,
        child: Text(widget.data['periods'][index], style: style),
      );
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    // Create spots based on selected metric
    final spots = allSpots;
    
    final lineBarsData = [
      LineChartBarData(
        showingIndicators: showingTooltipOnSpots,
        spots: spots,
        isCurved: true,
        barWidth: 4,
        shadow: const Shadow(
          blurRadius: 8,
        ),
        belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(
            colors: [
              widget.gradientColor1.withValues(alpha: .4),
              widget.gradientColor2.withValues(alpha: .4),
              widget.gradientColor3.withValues(alpha: .4),
            ],
          ),
        ),
        dotData: const FlDotData(show: false),
        gradient: LinearGradient(
          colors: [
            widget.gradientColor1,
            widget.gradientColor2,
            widget.gradientColor3,
          ],
          stops: const [0.1, 0.4, 0.9],
        ),
      ),
    ];

    final tooltipsOnBar = lineBarsData[0];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'sessionCounts',
                  label: Text('Session Count'),
                ),
                ButtonSegment(
                  value: 'avgDuration',
                  label: Text('Avg Duration'),
                ),
                ButtonSegment(
                  value: 'totalFocusTime',
                  label: Text('Total Focus'),
                ),
              ],
              selected: {_selectedMetric},
              onSelectionChanged: (Set<String> selection) {
                setState(() {
                  _selectedMetric = selection.first;
                  showingTooltipOnSpots = [];
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 20),
        widget.data['percentageChange'] != null ? Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            children: [
              const Text(
                "Month-over-month change: ",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                "${widget.data['percentageChange']}%",
                style: TextStyle(
                  color: widget.data['percentageChange'] >= 0 
                    ? Colors.green 
                    : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ) : Container(),
        AspectRatio(
          aspectRatio: 3,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 10,
            ),
            child: LayoutBuilder(builder: (context, constraints) {
              return LineChart(
                LineChartData(
                  showingTooltipIndicators: showingTooltipOnSpots.map((index) {
                    return ShowingTooltipIndicators([
                      LineBarSpot(
                        tooltipsOnBar,
                        lineBarsData.indexOf(tooltipsOnBar),
                        tooltipsOnBar.spots[index],
                      ),
                    ]);
                  }).toList(),
                  lineTouchData: LineTouchData(
                    enabled: true,
                    handleBuiltInTouches: false,
                    touchCallback:
                        (FlTouchEvent event, LineTouchResponse? response) {
                      if (response == null || response.lineBarSpots == null) {
                        return;
                      }
                      if (event is FlTapUpEvent) {
                        final spotIndex = response.lineBarSpots!.first.spotIndex;
                        setState(() {
                          if (showingTooltipOnSpots.contains(spotIndex)) {
                            showingTooltipOnSpots.remove(spotIndex);
                          } else {
                            showingTooltipOnSpots.add(spotIndex);
                          }
                        });
                      }
                    },
                    mouseCursorResolver:
                        (FlTouchEvent event, LineTouchResponse? response) {
                      if (response == null || response.lineBarSpots == null) {
                        return SystemMouseCursors.basic;
                      }
                      return SystemMouseCursors.click;
                    },
                    getTouchedSpotIndicator:
                        (LineChartBarData barData, List<int> spotIndexes) {
                      return spotIndexes.map((index) {
                        return TouchedSpotIndicatorData(
                          const FlLine(
                            color: Colors.pink,
                          ),
                          FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) =>
                                FlDotCirclePainter(
                              radius: 8,
                              color: lerpGradient(
                                barData.gradient!.colors,
                                barData.gradient!.stops!,
                                percent / 100,
                              ),
                              strokeWidth: 2,
                              strokeColor: widget.indicatorStrokeColor,
                            ),
                          ),
                        );
                      }).toList();
                    },
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (touchedSpot) => Colors.pink,
                      tooltipBorderRadius:BorderRadius.circular(8.0),
                      getTooltipItems: (List<LineBarSpot> lineBarsSpot) {
                        return lineBarsSpot.map((lineBarSpot) {
                          String tooltipText = "";
                          
                          switch(_selectedMetric) {
                            case 'avgDuration':
                            case 'totalFocusTime':
                              tooltipText = "${lineBarSpot.y.toStringAsFixed(1)} min";
                              break;
                            default:
                              tooltipText = lineBarSpot.y.toStringAsFixed(0);
                          }
                          
                          return LineTooltipItem(
                            tooltipText,
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                  lineBarsData: lineBarsData,
                  minY: 0,
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      axisNameWidget: Text(yAxisTitle),
                      axisNameSize: 24,
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return SideTitleWidget(
                            meta: meta,
                            child: Text(value.toInt().toString()),
                          );
                        },
                        reservedSize: 30,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          return bottomTitleWidgets(
                            value,
                            meta,
                            constraints.maxWidth,
                          );
                        },
                        reservedSize: 30,
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: false,
                        reservedSize: 0,
                      ),
                    ),
                    topTitles: const AxisTitles(
                      axisNameWidget: Text(
                        'Focus Trends',
                        textAlign: TextAlign.left,
                      ),
                      axisNameSize: 24,
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 0,
                      ),
                    ),
                  ),
                  gridData: const FlGridData(show: true),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(
                      color: AppColors.borderColor,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

/// Lerps between a [LinearGradient] colors, based on [t]
Color lerpGradient(List<Color> colors, List<double> stops, double t) {
  if (colors.isEmpty) {
    throw ArgumentError('"colors" is empty.');
  } else if (colors.length == 1) {
    return colors[0];
  }

  if (stops.length != colors.length) {
    stops = [];

    /// provided gradientColorStops is invalid and we calculate it here
    colors.asMap().forEach((index, color) {
      final percent = 1.0 / (colors.length - 1);
      stops.add(percent * index);
    });
  }

  for (var s = 0; s < stops.length - 1; s++) {
    final leftStop = stops[s];
    final rightStop = stops[s + 1];
    final leftColor = colors[s];
    final rightColor = colors[s + 1];
    if (t <= leftStop) {
      return leftColor;
    } else if (t < rightStop) {
      final sectionT = (t - leftStop) / (rightStop - leftStop);
      return Color.lerp(leftColor, rightColor, sectionT)!;
    }
  }
  return colors.last;
}