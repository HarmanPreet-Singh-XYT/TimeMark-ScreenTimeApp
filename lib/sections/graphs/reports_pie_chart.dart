import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ReportsPieChart extends StatefulWidget {
  final Map<String, double> dataMap;
  final List<Color> colorList;

  const ReportsPieChart({
    super.key,
    required this.dataMap,
    required this.colorList,
  });

  @override
  State<ReportsPieChart> createState() => _ReportsPieChartState();
}

class _ReportsPieChartState extends State<ReportsPieChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final total = widget.dataMap.values.fold(0.0, (a, b) => a + b);

    return Column(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      _touchedIndex = -1;
                      return;
                    }
                    _touchedIndex =
                        pieTouchResponse.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              borderData: FlBorderData(show: false),
              sectionsSpace: 2,
              centerSpaceRadius: 50,
              sections: _buildSections(total),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children:
              widget.dataMap.entries.toList().asMap().entries.map((entry) {
            final index = entry.key;
            final data = entry.value;
            final percentage = (data.value / total * 100).toStringAsFixed(1);
            final isSelected = _touchedIndex == index;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? widget.colorList[index % widget.colorList.length]
                        .withValues(alpha: 0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: widget.colorList[index % widget.colorList.length],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${data.key} ($percentage%)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  List<PieChartSectionData> _buildSections(double total) {
    return widget.dataMap.entries.toList().asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      final isTouched = index == _touchedIndex;
      final percentage = (data.value / total * 100);

      return PieChartSectionData(
        color: widget.colorList[index % widget.colorList.length],
        value: data.value,
        title: isTouched ? '${percentage.toStringAsFixed(1)}%' : '',
        radius: isTouched ? 65 : 55,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        badgePositionPercentageOffset: .98,
      );
    }).toList();
  }
}
