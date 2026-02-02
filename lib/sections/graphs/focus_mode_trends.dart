// focus_mode_trends.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:fluent_ui/fluent_ui.dart' hide Colors;
import 'package:flutter/material.dart' show Colors;
import 'package:screentime/l10n/app_localizations.dart';

class FocusModeTrends extends StatefulWidget {
  const FocusModeTrends({
    super.key,
    required this.data,
  });

  final Map<String, dynamic> data;

  @override
  State<FocusModeTrends> createState() => _FocusModeTrendsState();
}

class _FocusModeTrendsState extends State<FocusModeTrends> {
  int? _touchedIndex;
  String _selectedMetric = 'sessionCounts';

  // Color schemes for different metrics
  final Map<String, List<Color>> _metricColors = {
    'sessionCounts': [const Color(0xFF42A5F5), const Color(0xFF1976D2)],
    'avgDuration': [const Color(0xFF66BB6A), const Color(0xFF388E3C)],
    'totalFocusTime': [const Color(0xFFFF7043), const Color(0xFFE64A19)],
  };

  List<FlSpot> get allSpots {
    final List<dynamic> values = widget.data[_selectedMetric] ?? [];
    if (values.isEmpty) return [const FlSpot(0, 0)];
    return List.generate(values.length,
        (index) => FlSpot(index.toDouble(), (values[index] as num).toDouble()));
  }

  double get maxY {
    final spots = allSpots;
    if (spots.isEmpty) return 10;
    final maxVal = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    return (maxVal * 1.2).ceilToDouble().clamp(5, double.infinity);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = _metricColors[_selectedMetric]!;
    final percentageChange = widget.data['percentageChange'] as num? ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Metric selector
        _buildMetricSelector(context, l10n),
        const SizedBox(height: 16),

        // Stats row
        _buildStatsRow(context, l10n, percentageChange, colors[0]),
        const SizedBox(height: 20),

        // Chart
        AspectRatio(
          aspectRatio: 2.5,
          child: LineChart(
            LineChartData(
              lineTouchData: _buildTouchData(context, l10n, colors[0]),
              gridData: _buildGridData(context),
              titlesData: _buildTitlesData(context),
              borderData: FlBorderData(show: false),
              lineBarsData: [_buildLineBarData(colors)],
              minY: 0,
              maxY: maxY,
            ),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricSelector(BuildContext context, AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: FluentTheme.of(context)
            .inactiveBackgroundColor
            .withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _MetricTab(
            label: l10n.chart_sessionCount,
            isSelected: _selectedMetric == 'sessionCounts',
            color: _metricColors['sessionCounts']![0],
            onTap: () => setState(() {
              _selectedMetric = 'sessionCounts';
              _touchedIndex = null;
            }),
          ),
          _MetricTab(
            label: l10n.chart_avgDuration,
            isSelected: _selectedMetric == 'avgDuration',
            color: _metricColors['avgDuration']![0],
            onTap: () => setState(() {
              _selectedMetric = 'avgDuration';
              _touchedIndex = null;
            }),
          ),
          _MetricTab(
            label: l10n.chart_totalFocus,
            isSelected: _selectedMetric == 'totalFocusTime',
            color: _metricColors['totalFocusTime']![0],
            onTap: () => setState(() {
              _selectedMetric = 'totalFocusTime';
              _touchedIndex = null;
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context, AppLocalizations l10n,
      num percentageChange, Color color) {
    final spots = allSpots;
    final currentValue = spots.isNotEmpty ? spots.last.y : 0;
    final previousValue =
        spots.length > 1 ? spots[spots.length - 2].y : currentValue;

    String formatValue(double value) {
      switch (_selectedMetric) {
        case 'avgDuration':
        case 'totalFocusTime':
          return '${value.toStringAsFixed(0)} min';
        default:
          return value.toStringAsFixed(0);
      }
    }

    return Row(
      children: [
        _StatCard(
          label: 'Current',
          value: formatValue(currentValue.toDouble()),
          color: color,
        ),
        const SizedBox(width: 12),
        _StatCard(
          label: 'Previous',
          value: formatValue(previousValue.toDouble()),
          color: Colors.grey,
        ),
        const SizedBox(width: 12),
        _TrendIndicator(
          percentageChange: percentageChange.toDouble(),
        ),
      ],
    );
  }

  LineTouchData _buildTouchData(
      BuildContext context, AppLocalizations l10n, Color color) {
    return LineTouchData(
      enabled: true,
      touchTooltipData: LineTouchTooltipData(
        tooltipBorderRadius: BorderRadius.circular(8),
        tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        getTooltipColor: (spot) => FluentTheme.of(context).micaBackgroundColor,
        getTooltipItems: (touchedSpots) {
          return touchedSpots.map((spot) {
            final periods = widget.data['periods'] as List? ?? [];
            final periodLabel =
                spot.x.toInt() < periods.length ? periods[spot.x.toInt()] : '';

            String valueText;
            switch (_selectedMetric) {
              case 'avgDuration':
              case 'totalFocusTime':
                valueText = '${spot.y.toStringAsFixed(1)} min';
                break;
              default:
                valueText = spot.y.toStringAsFixed(0);
            }

            return LineTooltipItem(
              '$periodLabel\n',
              TextStyle(
                color: FluentTheme.of(context)
                    .typography
                    .body
                    ?.color
                    ?.withValues(alpha: 0.6),
                fontSize: 11,
              ),
              children: [
                TextSpan(
                  text: valueText,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            );
          }).toList();
        },
      ),
      touchCallback: (FlTouchEvent event, LineTouchResponse? response) {
        if (response == null || response.lineBarSpots == null) {
          setState(() => _touchedIndex = null);
          return;
        }
        if (event is FlTapUpEvent || event is FlPanUpdateEvent) {
          setState(() {
            _touchedIndex = response.lineBarSpots!.isNotEmpty
                ? response.lineBarSpots!.first.spotIndex
                : null;
          });
        }
      },
      handleBuiltInTouches: true,
      getTouchedSpotIndicator: (barData, spotIndexes) {
        return spotIndexes.map((index) {
          return TouchedSpotIndicatorData(
            FlLine(
              color: color.withValues(alpha: 0.3),
              strokeWidth: 2,
              dashArray: [5, 5],
            ),
            FlDotData(
              show: true,
              getDotPainter: (spot, percent, bar, index) {
                return FlDotCirclePainter(
                  radius: 6,
                  color: color,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
          );
        }).toList();
      },
    );
  }

  FlGridData _buildGridData(BuildContext context) {
    return FlGridData(
      show: true,
      drawVerticalLine: false,
      horizontalInterval: maxY / 4,
      getDrawingHorizontalLine: (value) => FlLine(
        color: FluentTheme.of(context)
            .inactiveBackgroundColor
            .withValues(alpha: 0.4),
        strokeWidth: 1,
        dashArray: [5, 5],
      ),
    );
  }

  FlTitlesData _buildTitlesData(BuildContext context) {
    final periods = widget.data['periods'] as List? ?? [];

    return FlTitlesData(
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 32,
          interval: 1,
          getTitlesWidget: (value, meta) {
            final index = value.toInt();
            if (index < 0 || index >= periods.length) {
              return const SizedBox.shrink();
            }

            return SideTitleWidget(
              meta: meta,
              space: 8,
              child: Text(
                periods[index].toString(),
                style: TextStyle(
                  color: FluentTheme.of(context)
                      .typography
                      .body
                      ?.color
                      ?.withValues(alpha: 0.5),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          },
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 40,
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
                      ?.withValues(alpha: 0.4),
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

  LineChartBarData _buildLineBarData(List<Color> colors) {
    return LineChartBarData(
      spots: allSpots,
      isCurved: true,
      curveSmoothness: 0.3,
      preventCurveOverShooting: true,
      barWidth: 3,
      isStrokeCapRound: true,
      gradient: LinearGradient(colors: colors),
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) {
          final isHighlighted = index == _touchedIndex;
          return FlDotCirclePainter(
            radius: isHighlighted ? 6 : 4,
            color: colors[0],
            strokeWidth: 2,
            strokeColor: Colors.white,
          );
        },
      ),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          colors: [
            colors[0].withValues(alpha: 0.3),
            colors[1].withValues(alpha: 0.05),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }
}

class _MetricTab extends StatefulWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _MetricTab({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  State<_MetricTab> createState() => _MetricTabState();
}

class _MetricTabState extends State<_MetricTab> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? widget.color.withValues(alpha: 0.15)
                : _isHovered
                    ? widget.color.withValues(alpha: 0.05)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              color: widget.isSelected
                  ? widget.color
                  : FluentTheme.of(context)
                      .typography
                      .body
                      ?.color
                      ?.withValues(alpha: 0.6),
              fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w400,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: FluentTheme.of(context).typography.caption?.copyWith(
                  color: FluentTheme.of(context)
                      .typography
                      .caption
                      ?.color
                      ?.withValues(alpha: 0.6),
                  fontSize: 10,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendIndicator extends StatelessWidget {
  final double percentageChange;

  const _TrendIndicator({required this.percentageChange});

  @override
  Widget build(BuildContext context) {
    final isPositive = percentageChange >= 0;
    final color =
        isPositive ? const Color(0xFF4CAF50) : const Color(0xFFE53935);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPositive ? FluentIcons.up : FluentIcons.down,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            '${percentageChange.abs().toStringAsFixed(1)}%',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
