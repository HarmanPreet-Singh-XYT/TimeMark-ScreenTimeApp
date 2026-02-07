import 'dart:io';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:screentime/sections/controller/data_controllers/reports_controller.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';

class AnalyticsXLSXExporter {
  final UsageAnalyticsController _analyticsController;

  AnalyticsXLSXExporter(this._analyticsController);

  // Beautiful color palette
  static const _primaryBlue = '#4A90E2';
  static const _accentPurple = '#9B59B6';
  static const _successGreen = '#2ECC71';
  static const _warningOrange = '#F39C12';
  static const _dangerRed = '#E74C3C';
  static const _lightGray = '#ECF0F1';
  static const _darkGray = '#34495E';
  static const _headerBg = '#2C3E50';
  static const _productiveColor = '#27AE60';
  static const _unproductiveColor = '#E67E22';

  /// Export comprehensive analytics report to Excel
  Future<bool> exportAnalyticsReport({
    required AnalyticsSummary summary,
    required String periodLabel,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // Ask user for save location
      String? outputPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Analytics Report',
        fileName: 'analytics_report_${_getFileTimestamp()}.xlsx',
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
      );

      if (outputPath == null) {
        return false; // User cancelled
      }

      // Create Excel workbook
      var excel = Excel.createExcel();

      // Remove default sheet
      excel.delete('Sheet1');

      // Create sheets
      _createSummarySheet(excel, summary, periodLabel, startDate, endDate);
      _createDailyBreakdownSheet(excel, summary);
      _createAppDetailsSheet(excel, summary);
      _createInsightsSheet(excel, summary);

      // Save file
      var fileBytes = excel.save();
      if (fileBytes != null) {
        File(outputPath)
          ..createSync(recursive: true)
          ..writeAsBytesSync(fileBytes);
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Error exporting Excel: $e');
      return false;
    }
  }

  /// Create the main summary sheet
  void _createSummarySheet(
    Excel excel,
    AnalyticsSummary summary,
    String periodLabel,
    DateTime? startDate,
    DateTime? endDate,
  ) {
    var sheet = excel['📊 Summary'];

    int row = 0;

    // Title Section
    _setCell(sheet, 0, row, 'USAGE ANALYTICS REPORT',
        fontSize: 18, bold: true, fontColor: _headerBg);
    _mergeCells(sheet, row, row, 0, 3);
    row += 2;

    // Report Info
    _setCell(sheet, 0, row, 'Generated:', bold: true);
    _setCell(sheet, 1, row,
        DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()));
    row++;

    _setCell(sheet, 0, row, 'Period:', bold: true);
    _setCell(sheet, 1, row, periodLabel);
    row++;

    if (startDate != null && endDate != null) {
      _setCell(sheet, 0, row, 'Date Range:', bold: true);
      _setCell(sheet, 1, row,
          '${DateFormat('yyyy-MM-dd').format(startDate)} to ${DateFormat('yyyy-MM-dd').format(endDate)}');
      row++;
    }
    row += 2;

    // Key Metrics Section
    _setCell(sheet, 0, row, 'KEY METRICS',
        fontSize: 14, bold: true, bgColor: _primaryBlue, fontColor: '#FFFFFF');
    _mergeCells(sheet, row, row, 0, 3);
    row++;

    // Header row
    _setCell(sheet, 0, row, 'Metric', bold: true, bgColor: _lightGray);
    _setCell(sheet, 1, row, 'Value', bold: true, bgColor: _lightGray);
    _setCell(sheet, 2, row, 'Change', bold: true, bgColor: _lightGray);
    _setCell(sheet, 3, row, 'Trend', bold: true, bgColor: _lightGray);
    row++;

    // Total Screen Time
    _setCell(sheet, 0, row, 'Total Screen Time');
    _setCell(sheet, 1, row, _formatDuration(summary.totalScreenTime),
        bold: true);
    var screenTimeChange = summary.screenTimeComparisonPercent;
    _setCell(sheet, 2, row,
        '${screenTimeChange >= 0 ? "+" : ""}${screenTimeChange.toStringAsFixed(1)}%',
        fontColor: screenTimeChange > 0 ? _dangerRed : _successGreen);
    _setCell(sheet, 3, row, screenTimeChange > 0 ? '📈' : '📉');
    row++;

    // Productive Time
    _setCell(sheet, 0, row, 'Productive Time');
    _setCell(sheet, 1, row, _formatDuration(summary.productiveTime),
        bold: true, fontColor: _productiveColor);
    var prodTimeChange = summary.productiveTimeComparisonPercent;
    _setCell(sheet, 2, row,
        '${prodTimeChange >= 0 ? "+" : ""}${prodTimeChange.toStringAsFixed(1)}%',
        fontColor: prodTimeChange > 0 ? _successGreen : _dangerRed);
    _setCell(sheet, 3, row, prodTimeChange > 0 ? '📈' : '📉');
    row++;

    // Productivity Percentage
    final productivityPercentage = summary.totalScreenTime.inMinutes > 0
        ? (summary.productiveTime.inMinutes /
            summary.totalScreenTime.inMinutes *
            100)
        : 0.0;
    _setCell(sheet, 0, row, 'Productivity Rate');
    _setCell(sheet, 1, row, '${productivityPercentage.toStringAsFixed(1)}%',
        bold: true,
        fontColor:
            productivityPercentage >= 50 ? _successGreen : _warningOrange);
    _setCell(sheet, 2, row, '');
    _setCell(
        sheet,
        3,
        row,
        productivityPercentage >= 70
            ? '🌟'
            : (productivityPercentage >= 50 ? '👍' : '⚠️'));
    row++;

    // Focus Sessions
    _setCell(sheet, 0, row, 'Focus Sessions');
    _setCell(sheet, 1, row, summary.focusSessionsCount.toString(), bold: true);
    var focusChange = summary.focusSessionsComparisonPercent;
    _setCell(sheet, 2, row,
        '${focusChange >= 0 ? "+" : ""}${focusChange.toStringAsFixed(1)}%',
        fontColor: focusChange > 0 ? _successGreen : _dangerRed);
    _setCell(sheet, 3, row, summary.focusSessionsCount > 0 ? '🎯' : '💤');
    row++;

    // Most Used App
    _setCell(sheet, 0, row, 'Most Used App');
    _setCell(sheet, 1, row, summary.mostUsedApp, bold: true);
    _setCell(sheet, 2, row, _formatDuration(summary.mostUsedAppTime));
    _setCell(sheet, 3, row, '⭐');
    row += 3;

    // Category Breakdown Section
    if (summary.categoryBreakdown.isNotEmpty) {
      _setCell(sheet, 0, row, 'CATEGORY BREAKDOWN',
          fontSize: 14,
          bold: true,
          bgColor: _accentPurple,
          fontColor: '#FFFFFF');
      _mergeCells(sheet, row, row, 0, 2);
      row++;

      _setCell(sheet, 0, row, 'Category', bold: true, bgColor: _lightGray);
      _setCell(sheet, 1, row, 'Percentage', bold: true, bgColor: _lightGray);
      _setCell(sheet, 2, row, 'Visual', bold: true, bgColor: _lightGray);
      row++;

      final sortedCategories = summary.categoryBreakdown.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      for (var entry in sortedCategories) {
        _setCell(sheet, 0, row, entry.key);
        _setCell(sheet, 1, row, '${entry.value.toStringAsFixed(1)}%',
            bold: true);

        // Create a simple text-based bar
        var barLength = (entry.value / 10).round();
        var bar = '█' * barLength;
        _setCell(sheet, 2, row, bar, fontColor: _primaryBlue);
        row++;
      }
    }

    // Note: Column widths are auto-adjusted by Excel when opening the file
  }

  /// Create daily breakdown sheet
  void _createDailyBreakdownSheet(Excel excel, AnalyticsSummary summary) {
    if (summary.dailyScreenTimeData.isEmpty) return;

    var sheet = excel['📅 Daily Breakdown'];
    int row = 0;

    // Title
    _setCell(sheet, 0, row, 'DAILY SCREEN TIME',
        fontSize: 16, bold: true, fontColor: _headerBg);
    _mergeCells(sheet, row, row, 0, 4);
    row += 2;

    // Statistics
    final totalMinutes = summary.dailyScreenTimeData
        .fold(0, (sum, day) => sum + day.screenTime.inMinutes);
    final avgMinutes = totalMinutes / summary.dailyScreenTimeData.length;
    final maxDay = summary.dailyScreenTimeData
        .reduce((a, b) => a.screenTime > b.screenTime ? a : b);
    final minDay = summary.dailyScreenTimeData
        .reduce((a, b) => a.screenTime < b.screenTime ? a : b);

    _setCell(sheet, 0, row, '📊 STATISTICS', bold: true, bgColor: _lightGray);
    _mergeCells(sheet, row, row, 0, 4);
    row++;

    _setCell(sheet, 0, row, 'Average Daily');
    _setCell(
        sheet, 1, row, _formatDuration(Duration(minutes: avgMinutes.round())),
        bold: true, fontSize: 12);
    row++;

    _setCell(sheet, 0, row, 'Highest Day');
    _setCell(sheet, 1, row, DateFormat('EEEE, MMM d').format(maxDay.date));
    _setCell(sheet, 2, row, _formatDuration(maxDay.screenTime),
        bold: true, fontColor: _dangerRed);
    row++;

    _setCell(sheet, 0, row, 'Lowest Day');
    _setCell(sheet, 1, row, DateFormat('EEEE, MMM d').format(minDay.date));
    _setCell(sheet, 2, row, _formatDuration(minDay.screenTime),
        bold: true, fontColor: _successGreen);
    row += 3;

    // Data table
    _setCell(sheet, 0, row, 'Date',
        bold: true, bgColor: _headerBg, fontColor: '#FFFFFF');
    _setCell(sheet, 1, row, 'Day',
        bold: true, bgColor: _headerBg, fontColor: '#FFFFFF');
    _setCell(sheet, 2, row, 'Hours',
        bold: true, bgColor: _headerBg, fontColor: '#FFFFFF');
    _setCell(sheet, 3, row, 'Minutes',
        bold: true, bgColor: _headerBg, fontColor: '#FFFFFF');
    _setCell(sheet, 4, row, 'Visual',
        bold: true, bgColor: _headerBg, fontColor: '#FFFFFF');
    row++;

    final maxMinutes = summary.dailyScreenTimeData
        .map((d) => d.screenTime.inMinutes)
        .reduce((a, b) => a > b ? a : b)
        .toDouble();

    for (var dailyData in summary.dailyScreenTimeData) {
      var isWeekend = dailyData.date.weekday == DateTime.saturday ||
          dailyData.date.weekday == DateTime.sunday;

      _setCell(sheet, 0, row, DateFormat('yyyy-MM-dd').format(dailyData.date),
          bgColor: isWeekend ? '#FFF3E0' : null);
      _setCell(sheet, 1, row, DateFormat('EEEE').format(dailyData.date),
          bgColor: isWeekend ? '#FFF3E0' : null);
      _setCell(sheet, 2, row,
          (dailyData.screenTime.inMinutes / 60).toStringAsFixed(2),
          bold: true, bgColor: isWeekend ? '#FFF3E0' : null);
      _setCell(sheet, 3, row, dailyData.screenTime.inMinutes.toString(),
          bgColor: isWeekend ? '#FFF3E0' : null);

      // Visual bar
      var barLength =
          ((dailyData.screenTime.inMinutes / maxMinutes) * 20).round();
      var bar = '█' * barLength;
      var color = dailyData.screenTime.inHours >= 8
          ? _dangerRed
          : dailyData.screenTime.inHours >= 4
              ? _warningOrange
              : _successGreen;
      _setCell(sheet, 4, row, bar,
          fontColor: color, bgColor: isWeekend ? '#FFF3E0' : null);

      row++;
    }

    // Note: Column widths are auto-adjusted by Excel when opening the file
  }

  /// Create app details sheet
  void _createAppDetailsSheet(Excel excel, AnalyticsSummary summary) {
    if (summary.appUsageDetails.isEmpty) return;

    var sheet = excel['📱 Apps'];
    int row = 0;

    // Title
    _setCell(sheet, 0, row, 'APPLICATION USAGE DETAILS',
        fontSize: 16, bold: true, fontColor: _headerBg);
    _mergeCells(sheet, row, row, 0, 6);
    row += 2;

    // Quick stats
    final totalTime = summary.appUsageDetails.fold<Duration>(
      Duration.zero,
      (sum, app) => sum + app.totalTime,
    );
    final productiveApps =
        summary.appUsageDetails.where((app) => app.isProductive).length;

    _setCell(sheet, 0, row, 'Total Apps:', bold: true);
    _setCell(sheet, 1, row, summary.appUsageDetails.length.toString());
    _setCell(sheet, 3, row, 'Productive Apps:', bold: true);
    _setCell(sheet, 4, row, '$productiveApps', fontColor: _successGreen);
    row += 2;

    // Header
    _setCell(sheet, 0, row, 'Rank',
        bold: true, bgColor: _headerBg, fontColor: '#FFFFFF');
    _setCell(sheet, 1, row, 'Application',
        bold: true, bgColor: _headerBg, fontColor: '#FFFFFF');
    _setCell(sheet, 2, row, 'Category',
        bold: true, bgColor: _headerBg, fontColor: '#FFFFFF');
    _setCell(sheet, 3, row, 'Time',
        bold: true, bgColor: _headerBg, fontColor: '#FFFFFF');
    _setCell(sheet, 4, row, '% of Total',
        bold: true, bgColor: _headerBg, fontColor: '#FFFFFF');
    _setCell(sheet, 5, row, 'Type',
        bold: true, bgColor: _headerBg, fontColor: '#FFFFFF');
    _setCell(sheet, 6, row, 'Usage Level',
        bold: true, bgColor: _headerBg, fontColor: '#FFFFFF');
    row++;

    int rank = 1;
    final totalMinutes = summary.totalScreenTime.inMinutes;

    for (var appDetail in summary.appUsageDetails) {
      final percentage = totalMinutes > 0
          ? (appDetail.totalTime.inMinutes / totalMinutes * 100)
          : 0.0;

      // Rank with medal for top 3
      var rankText = rank.toString();
      if (rank == 1) rankText = '🥇 1';
      if (rank == 2) rankText = '🥈 2';
      if (rank == 3) rankText = '🥉 3';

      _setCell(sheet, 0, row, rankText, bold: rank <= 3);
      _setCell(sheet, 1, row, appDetail.appName, bold: rank <= 3);
      _setCell(sheet, 2, row, appDetail.category);
      _setCell(sheet, 3, row, _formatDuration(appDetail.totalTime), bold: true);
      _setCell(sheet, 4, row, '${percentage.toStringAsFixed(1)}%');

      // Productive indicator with color
      var typeText = appDetail.isProductive ? '✅ Productive' : '⚠️ Leisure';
      var typeColor =
          appDetail.isProductive ? _productiveColor : _unproductiveColor;
      _setCell(sheet, 5, row, typeText, fontColor: typeColor, bold: true);

      // Usage level visualization
      var usageLevel = percentage >= 20
          ? 'Very High ████████'
          : percentage >= 10
              ? 'High ██████'
              : percentage >= 5
                  ? 'Medium ████'
                  : 'Low ██';
      var usageColor = percentage >= 20
          ? _dangerRed
          : percentage >= 10
              ? _warningOrange
              : percentage >= 5
                  ? _primaryBlue
                  : _successGreen;
      _setCell(sheet, 6, row, usageLevel, fontColor: usageColor);

      rank++;
      row++;
    }

    // Note: Column widths are auto-adjusted by Excel when opening the file
  }

  /// Create insights sheet
  void _createInsightsSheet(Excel excel, AnalyticsSummary summary) {
    var sheet = excel['💡 Insights'];
    int row = 0;

    // Title
    _setCell(sheet, 0, row, '💡 KEY INSIGHTS & RECOMMENDATIONS',
        fontSize: 16, bold: true, fontColor: _headerBg);
    _mergeCells(sheet, row, row, 0, 1);
    row += 2;

    final insights = _generateInsights(summary);

    for (var insight in insights) {
      // Determine icon and color based on insight content
      String icon = '📌';
      String? bgColor;

      if (insight.contains('Excellent') || insight.contains('Great')) {
        icon = '🌟';
        bgColor = '#E8F5E9';
      } else if (insight.contains('Good')) {
        icon = '✅';
        bgColor = '#E3F2FD';
      } else if (insight.contains('Low') ||
          insight.contains('High Daily Usage')) {
        icon = '⚠️';
        bgColor = '#FFF3E0';
      } else if (insight.contains('increased')) {
        icon = '📈';
        bgColor = '#FCE4EC';
      } else if (insight.contains('decreased')) {
        icon = '📉';
        bgColor = '#F3E5F5';
      }

      _setCell(sheet, 0, row, icon, fontSize: 14);
      _setCell(sheet, 1, row, insight, bgColor: bgColor);
      _mergeCells(sheet, row, row, 1, 2);
      row += 2;
    }

    row += 2;

    // Recommendations section
    _setCell(sheet, 0, row, '🎯 PERSONALIZED RECOMMENDATIONS',
        fontSize: 14, bold: true, bgColor: _accentPurple, fontColor: '#FFFFFF');
    _mergeCells(sheet, row, row, 0, 2);
    row += 2;

    final recommendations = _generateRecommendations(summary);
    for (var rec in recommendations) {
      _setCell(sheet, 0, row, '→',
          fontColor: _accentPurple, fontSize: 14, bold: true);
      _setCell(sheet, 1, row, rec, bgColor: '#F5F5F5');
      _mergeCells(sheet, row, row, 1, 2);
      row += 2;
    }

    // Note: Column widths are auto-adjusted by Excel when opening the file
  }

  /// Generate insights based on the data
  List<String> _generateInsights(AnalyticsSummary summary) {
    List<String> insights = [];

    // Screen time insights
    final hoursPerDay = summary.dailyScreenTimeData.isNotEmpty
        ? summary.totalScreenTime.inHours / summary.dailyScreenTimeData.length
        : 0;

    if (hoursPerDay > 8) {
      insights.add(
          'High Daily Usage: You\'re averaging ${hoursPerDay.toStringAsFixed(1)} hours per day of screen time');
    } else if (hoursPerDay < 2) {
      insights.add(
          'Low Daily Usage: You\'re averaging ${hoursPerDay.toStringAsFixed(1)} hours per day - great balance!');
    } else {
      insights.add(
          'Moderate Usage: Averaging ${hoursPerDay.toStringAsFixed(1)} hours per day of screen time');
    }

    // Productivity insights
    final productivityPercentage = summary.totalScreenTime.inMinutes > 0
        ? (summary.productiveTime.inMinutes /
            summary.totalScreenTime.inMinutes *
            100)
        : 0.0;

    if (productivityPercentage >= 70) {
      insights.add(
          'Excellent Productivity: ${productivityPercentage.toStringAsFixed(0)}% of your screen time is productive work!');
    } else if (productivityPercentage >= 50) {
      insights.add(
          'Good Productivity: ${productivityPercentage.toStringAsFixed(0)}% of your screen time is productive');
    } else if (productivityPercentage < 30 &&
        summary.totalScreenTime.inMinutes > 0) {
      insights.add(
          'Low Productivity Alert: Only ${productivityPercentage.toStringAsFixed(0)}% of screen time is productive');
    }

    // Focus session insights
    if (summary.focusSessionsCount > 0) {
      final daysWithData = summary.dailyScreenTimeData.length;
      final avgSessionsPerDay =
          daysWithData > 0 ? summary.focusSessionsCount / daysWithData : 0;
      insights.add(
          'Focus Sessions: Completed ${summary.focusSessionsCount} sessions (${avgSessionsPerDay.toStringAsFixed(1)} per day on average)');

      if (summary.focusSessionsCount >= 20) {
        insights.add(
            'Great Focus Habit: You\'ve built an amazing focus routine with ${summary.focusSessionsCount} completed sessions!');
      }
    } else {
      insights.add(
          'No Focus Sessions: Consider using focus mode to boost your productivity');
    }

    // Comparison insights
    if (summary.screenTimeComparisonPercent.abs() > 10) {
      final direction =
          summary.screenTimeComparisonPercent > 0 ? 'increased' : 'decreased';
      insights.add(
          'Screen Time Trend: Your usage has ${direction} by ${summary.screenTimeComparisonPercent.abs().toStringAsFixed(0)}% compared to the previous period');
    }

    if (summary.productiveTimeComparisonPercent.abs() > 10) {
      final direction = summary.productiveTimeComparisonPercent > 0
          ? 'increased'
          : 'decreased';
      insights.add(
          'Productive Time Trend: Your productive time has ${direction} by ${summary.productiveTimeComparisonPercent.abs().toStringAsFixed(0)}% compared to previous period');
    }

    // Category insights
    if (summary.categoryBreakdown.isNotEmpty) {
      final topCategory = summary.categoryBreakdown.entries
          .reduce((a, b) => a.value > b.value ? a : b);
      insights.add(
          'Top Category: ${topCategory.key} dominates with ${topCategory.value.toStringAsFixed(0)}% of your total time');
    }

    // App usage insights
    if (summary.mostUsedApp != "None" &&
        summary.mostUsedAppTime.inMinutes > 0) {
      final percentage = summary.totalScreenTime.inMinutes > 0
          ? (summary.mostUsedAppTime.inMinutes /
              summary.totalScreenTime.inMinutes *
              100)
          : 0.0;
      insights.add(
          'Most Used App: ${summary.mostUsedApp} accounts for ${percentage.toStringAsFixed(0)}% of your time (${_formatDuration(summary.mostUsedAppTime)})');
    }

    // Daily pattern insights
    if (summary.dailyScreenTimeData.isNotEmpty) {
      final sortedDays = summary.dailyScreenTimeData.toList()
        ..sort((a, b) => b.screenTime.compareTo(a.screenTime));

      if (sortedDays.length >= 2) {
        final highestDay = sortedDays.first;
        final lowestDay = sortedDays.last;

        if (highestDay.screenTime.inMinutes >
            lowestDay.screenTime.inMinutes * 2) {
          insights.add(
              'Usage Varies Significantly: ${DateFormat('EEEE').format(highestDay.date)} had ${(highestDay.screenTime.inMinutes / lowestDay.screenTime.inMinutes).toStringAsFixed(1)}x more usage than ${DateFormat('EEEE').format(lowestDay.date)}');
        }
      }
    }

    return insights.isEmpty ? ['No significant insights available'] : insights;
  }

  /// Generate personalized recommendations
  List<String> _generateRecommendations(AnalyticsSummary summary) {
    List<String> recommendations = [];

    final productivityPercentage = summary.totalScreenTime.inMinutes > 0
        ? (summary.productiveTime.inMinutes /
            summary.totalScreenTime.inMinutes *
            100)
        : 0.0;

    if (productivityPercentage < 50) {
      recommendations.add(
          'Try scheduling more focus sessions throughout your day to boost productivity');
      recommendations
          .add('Consider setting app limits on leisure applications');
    }

    if (summary.focusSessionsCount < 5 &&
        summary.dailyScreenTimeData.length >= 7) {
      recommendations.add(
          'Aim for at least 1-2 focus sessions per day to build a consistent habit');
    }

    final hoursPerDay = summary.dailyScreenTimeData.isNotEmpty
        ? summary.totalScreenTime.inHours / summary.dailyScreenTimeData.length
        : 0;

    if (hoursPerDay > 8) {
      recommendations.add(
          'Your daily screen time is quite high. Try taking regular breaks using the 20-20-20 rule');
      recommendations.add(
          'Consider setting daily screen time goals to gradually reduce usage');
    }

    if (summary.categoryBreakdown.isNotEmpty) {
      final entertainment = summary.categoryBreakdown.entries
          .where((e) =>
              e.key.toLowerCase().contains('entertainment') ||
              e.key.toLowerCase().contains('social') ||
              e.key.toLowerCase().contains('leisure'))
          .fold(0.0, (sum, e) => sum + e.value);

      if (entertainment > 40) {
        recommendations.add(
            'Entertainment apps account for a large portion of your time. Consider balancing with more productive activities');
      }
    }

    if (summary.screenTimeComparisonPercent > 20) {
      recommendations.add(
          'Your screen time has increased significantly. Review your usage patterns and set boundaries');
    }

    if (summary.productiveTimeComparisonPercent < -20) {
      recommendations.add(
          'Your productive time has decreased. Try scheduling focused work blocks in your calendar');
    }

    if (recommendations.isEmpty) {
      recommendations
          .add('Keep up the great work! Your screen time habits look healthy');
      recommendations
          .add('Continue using focus sessions to maintain productivity');
    }

    return recommendations;
  }

  /// Helper method to set cell value and formatting
  void _setCell(
    Sheet sheet,
    int col,
    int row,
    dynamic value, {
    bool bold = false,
    int fontSize = 11,
    String? bgColor,
    String? fontColor,
  }) {
    var cell = sheet.cell(
      CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row),
    );
    cell.value = TextCellValue(value.toString());

    // Build CellStyle with only non-null values
    CellStyle style;

    if (bgColor != null && fontColor != null) {
      style = CellStyle(
        bold: bold,
        fontSize: fontSize,
        backgroundColorHex: ExcelColor.fromHexString(bgColor),
        fontColorHex: ExcelColor.fromHexString(fontColor),
      );
    } else if (bgColor != null) {
      style = CellStyle(
        bold: bold,
        fontSize: fontSize,
        backgroundColorHex: ExcelColor.fromHexString(bgColor),
      );
    } else if (fontColor != null) {
      style = CellStyle(
        bold: bold,
        fontSize: fontSize,
        fontColorHex: ExcelColor.fromHexString(fontColor),
      );
    } else {
      style = CellStyle(
        bold: bold,
        fontSize: fontSize,
      );
    }

    cell.cellStyle = style;
  }

  /// Helper to merge cells
  void _mergeCells(
      Sheet sheet, int startRow, int endRow, int startCol, int endCol) {
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: startCol, rowIndex: startRow),
      CellIndex.indexByColumnRow(columnIndex: endCol, rowIndex: endRow),
    );
  }

  /// Format duration for display
  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  /// Get timestamp for filename
  String _getFileTimestamp() {
    return DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
  }
}
