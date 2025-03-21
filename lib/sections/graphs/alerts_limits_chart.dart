import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../controller/data_controllers/alertsLimits_data_controller.dart';
import './resources/app_resources.dart';

class AlertUsageChart extends StatefulWidget {
  
  const AlertUsageChart({
    super.key,
  });

  @override
  State<AlertUsageChart> createState() => _AlertUsageChartState();
}

class _AlertUsageChartState extends State<AlertUsageChart> {
  final controller = ScreenTimeController();
  List<Color> gradientColors = [
    AppColors.contentColorCyan,
    AppColors.contentColorBlue,
  ];

  bool showAvg = false;
  List<AppAlert> alerts = [];
  Map<String, int> _alertCountByMonth = {};
  double _avgAlertsPerMonth = 0;

  @override
  void initState() {
    super.initState();
    _fetchAlertData();
    // Set up periodic refresh instead of using stream
    _setupPeriodicRefresh();
  }

  void _setupPeriodicRefresh() {
    // Refresh data every 60 seconds
    Future.delayed(const Duration(seconds: 60), () {
      if (mounted) {
        _fetchAlertData();
        _setupPeriodicRefresh();
      }
    });
  }

  void _fetchAlertData() {
    // Get alerts from controller
    alerts = controller.getAlerts();
    _processAlertData();
    setState(() {});
  }

  void _processAlertData() {
    // Group alerts by month and count them
    _alertCountByMonth = {};
    final now = DateTime.now();
    
    // Create entries for the last 12 months
    for (int i = 0; i < 12; i++) {
      final month = DateTime(now.year, now.month - i, 1);
      final monthKey = '${month.year}-${month.month.toString().padLeft(2, '0')}';
      _alertCountByMonth[monthKey] = 0;
    }
    
    // Count alerts by month
    for (final alert in alerts) {
      final monthKey = '${alert.time.year}-${alert.time.month.toString().padLeft(2, '0')}';
      if (_alertCountByMonth.containsKey(monthKey)) {
        _alertCountByMonth[monthKey] = (_alertCountByMonth[monthKey] ?? 0) + 1;
      }
    }
    
    // Calculate average
    if (_alertCountByMonth.isNotEmpty) {
      _avgAlertsPerMonth = _alertCountByMonth.values.reduce((a, b) => a + b) / _alertCountByMonth.length;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AspectRatio(
          aspectRatio: 3,
          child: Padding(
            padding: const EdgeInsets.only(
              right: 18,
              left: 12,
              top: 24,
              bottom: 12,
            ),
            child: LineChart(
              showAvg ? avgData() : mainData(),
            ),
          ),
        ),
        SizedBox(
          width: 60,
          height: 34,
          child: TextButton(
            onPressed: () {
              setState(() {
                showAvg = !showAvg;
              });
            },
            child: Text(
              'avg',
              style: TextStyle(
                fontSize: 12,
                color: showAvg
                    ? Colors.white.withValues(alpha: .5)
                    : Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
    );
    Widget text;
    
    // Get the month names based on the processed data
    final months = _alertCountByMonth.keys.toList()..sort();
    final shortMonths = {
      1: 'JAN', 2: 'FEB', 3: 'MAR', 4: 'APR', 5: 'MAY', 6: 'JUN',
      7: 'JUL', 8: 'AUG', 9: 'SEP', 10: 'OCT', 11: 'NOV', 12: 'DEC'
    };
    
    // Display only a few month labels to avoid crowding
    if (value.toInt() >= 0 && value.toInt() < months.length) {
      final monthKey = months[months.length - 1 - value.toInt()];
      final month = int.parse(monthKey.split('-')[1]);
      
      if (value.toInt() % 3 == 0) {
        text = Text(shortMonths[month] ?? '', style: style);
      } else {
        text = const Text('', style: style);
      }
    } else {
      text = const Text('', style: style);
    }

    return SideTitleWidget(
      meta: meta,
      child: text,
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 15,
    );
    
    // Find the maximum alert count to scale the y-axis
    final maxAlertCount = _alertCountByMonth.values.isEmpty ? 
      10 : _alertCountByMonth.values.reduce((a, b) => a > b ? a : b);
    
    // Calculate appropriate interval for the y-axis
    final maxY = (maxAlertCount / 5).ceil() * 5;
    
    if (value % (maxY / 3) == 0 && value > 0) {
      return Text(value.toInt().toString(), 
        style: style, 
        textAlign: TextAlign.left
      );
    }
    
    return Container();
  }

  LineChartData mainData() {
    // Create spots from the alert data
    final spots = <FlSpot>[];
    
    final months = _alertCountByMonth.keys.toList()..sort();
    
    for (int i = 0; i < months.length; i++) {
      final monthKey = months[months.length - 1 - i];
      final count = _alertCountByMonth[monthKey] ?? 0;
      spots.add(FlSpot(i.toDouble(), count.toDouble()));
    }
    
    // Find the maximum alert count to scale the y-axis
    final maxAlertCount = _alertCountByMonth.values.isEmpty ? 
      10 : _alertCountByMonth.values.reduce((a, b) => a > b ? a : b);
    
    // Calculate appropriate max for the y-axis
    final maxY = (maxAlertCount / 5).ceil() * 5;

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: maxY > 0 ? maxY / 6 : 1,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return const FlLine(
            color: AppColors.mainGridLineColor,
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return const FlLine(
            color: AppColors.mainGridLineColor,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 42,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: 0,
      maxX: months.length.toDouble() - 1,
      minY: 0,
      maxY: maxY.toDouble(),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          gradient: LinearGradient(
            colors: gradientColors,
          ),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors
                  .map((color) => color.withValues(alpha: .3))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  LineChartData avgData() {
    // Create flat line for average
    final spots = <FlSpot>[];
    final months = _alertCountByMonth.keys.toList()..sort();
    
    for (int i = 0; i < months.length; i++) {
      spots.add(FlSpot(i.toDouble(), _avgAlertsPerMonth));
    }
    
    // Find the maximum alert count to scale the y-axis
    final maxAlertCount = _alertCountByMonth.values.isEmpty ? 
      10 : _alertCountByMonth.values.reduce((a, b) => a > b ? a : b);
    
    // Calculate appropriate max for the y-axis
    final maxY = (maxAlertCount / 5).ceil() * 5;

    return LineChartData(
      lineTouchData: const LineTouchData(enabled: false),
      gridData: FlGridData(
        show: true,
        drawHorizontalLine: true,
        verticalInterval: 1,
        horizontalInterval: maxY > 0 ? maxY / 6 : 1,
        getDrawingVerticalLine: (value) {
          return const FlLine(
            color: Color(0xff37434d),
            strokeWidth: 1,
          );
        },
        getDrawingHorizontalLine: (value) {
          return const FlLine(
            color: Color(0xff37434d),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: bottomTitleWidgets,
            interval: 1,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 42,
            interval: 1,
          ),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: 0,
      maxX: months.length.toDouble() - 1,
      minY: 0,
      maxY: maxY.toDouble(),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          gradient: LinearGradient(
            colors: [
              ColorTween(begin: gradientColors[0], end: gradientColors[1])
                  .lerp(0.2)!,
              ColorTween(begin: gradientColors[0], end: gradientColors[1])
                  .lerp(0.2)!,
            ],
          ),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                ColorTween(begin: gradientColors[0], end: gradientColors[1])
                    .lerp(0.2)!
                    .withValues(alpha: .1),
                ColorTween(begin: gradientColors[0], end: gradientColors[1])
                    .lerp(0.2)!
                    .withValues(alpha: .1),
              ],
            ),
          ),
        ),
      ],
    );
  }
}