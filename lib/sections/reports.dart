import 'package:fluent_ui/fluent_ui.dart';
import 'package:screentime/l10n/app_localizations.dart';
import 'package:screentime/main.dart';
import 'package:screentime/sections/graphs/reports_line_chart.dart';
import 'package:screentime/sections/graphs/reports_pie_chart.dart';
import './controller/data_controllers/reports_controller.dart';
import 'package:screentime/sections/UI sections/Reports/application_usage.dart';
import 'package:screentime/sections/UI sections/Reports/top_boxes.dart';
import 'package:screentime/sections/controller/analytics_xlsx_exporter.dart';

// Add this enum at the top of your file
enum PeriodType { last7Days, lastMonth, last3Months, lifetime, custom }

class Reports extends StatefulWidget {
  const Reports({super.key});

  @override
  State<Reports> createState() => _ReportsState();
}

class _ReportsState extends State<Reports> {
  final UsageAnalyticsController _analyticsController =
      UsageAnalyticsController();
  AnalyticsXLSXExporter? _xlsxExporter; // Make nullable initially
  AnalyticsSummary? _analyticsSummary;
  bool _isLoading = true;
  bool _isExporting = false;
  String? _error;
  PeriodType _selectedPeriod = PeriodType.last7Days;
  bool _isInitialized = false; // Add flag to prevent multiple calls

  @override
  void initState() {
    super.initState();
    // Don't access context here
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _isInitialized = true;
      _xlsxExporter = AnalyticsXLSXExporter(
        _analyticsController,
        AppLocalizations.of(context)!,
      );
      _initializeAndLoadData();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        navigationState.registerRefreshCallback(_refreshData);
      });
    }
  }

  Future<void> _refreshData() async {
    // Re-load the analytics data without re-initializing
    await _loadAnalyticsData();
  }

  Future<void> _initializeAndLoadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final initialized = await _analyticsController.initialize();
      if (!initialized) {
        setState(() {
          _error = _analyticsController.error ??
              AppLocalizations.of(context)!.failedToInitialize;
          _isLoading = false;
        });
        return;
      }

      await _loadAnalyticsData();
    } catch (e) {
      setState(() {
        _error = AppLocalizations.of(context)!.unexpectedError(e.toString());
        _isLoading = false;
      });
    }
  }

  Future<void> _loadAnalyticsData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      AnalyticsSummary? summary;

      switch (_selectedPeriod) {
        case PeriodType.last7Days:
          summary = await _analyticsController.getLastSevenDaysAnalytics();
          graphData = summary.dailyScreenTimeData;
          break;
        case PeriodType.lastMonth:
          summary = await _analyticsController.getLastMonthAnalytics();
          graphData = summary.dailyScreenTimeData;
          break;
        case PeriodType.last3Months:
          summary = await _analyticsController.getLastThreeMonthsAnalytics();
          graphData = summary.dailyScreenTimeData;
          break;
        case PeriodType.lifetime:
          summary = await _analyticsController.getLifetimeAnalytics();
          graphData = summary.dailyScreenTimeData;
          break;
        case PeriodType.custom:
          if (_startDate != null &&
              _endDate != null &&
              _isDateRangeMode == true) {
            summary = await _analyticsController.getSpecificDateRangeAnalytics(
                _startDate!, _endDate!);
            graphData = summary.dailyScreenTimeData;
          } else if (_specificDate != null && _isDateRangeMode == false) {
            summary = await _analyticsController
                .getSpecificDayAnalytics(_specificDate!);
            graphData = summary.dailyScreenTimeData;
          }
          break;
      }

      setState(() {
        _analyticsSummary = summary;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error =
            AppLocalizations.of(context)!.errorLoadingAnalytics(e.toString());
        _isLoading = false;
      });
    }
  }

  DateTime? _startDate;
  DateTime? _endDate;
  DateTime? _specificDate;
  bool _isDateRangeMode = false;
  List<DailyScreenTime> graphData = [];

  Future<void> executeLineChart(DateTime specificDate) async {
    setState(() {
      _isLoading = true;
    });
    AnalyticsSummary? summary;
    try {
      summary =
          await _analyticsController.getSpecificDayAnalytics(specificDate);
      setState(() {
        _analyticsSummary = summary;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error =
            AppLocalizations.of(context)!.errorLoadingAnalytics(e.toString());
        _isLoading = false;
      });
    }
  }

  // Helper method to get localized string for period type
  String _getPeriodLabel(PeriodType period) {
    final l10n = AppLocalizations.of(context)!;
    switch (period) {
      case PeriodType.last7Days:
        return l10n.last7Days;
      case PeriodType.lastMonth:
        return l10n.lastMonth;
      case PeriodType.last3Months:
        return l10n.last3Months;
      case PeriodType.lifetime:
        return l10n.lifetime;
      case PeriodType.custom:
        return l10n.custom;
    }
  }

  // Excel Export Methods
  Future<void> _showExportDialog() async {
    final l10n = AppLocalizations.of(context)!;

    await showDialog(
      context: context,
      builder: (context) => ContentDialog(
        title: Text(l10n.exportAnalyticsReport),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.chooseExportFormat),
            const SizedBox(height: 16),
            ListTile(
              title: Text(l10n.beautifulExcelReport),
              subtitle: Text(l10n.beautifulExcelReportDescription),
              leading: const Icon(FluentIcons.excel_document),
              onPressed: () {
                Navigator.pop(context);
                _exportComprehensiveReport();
              },
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              l10n.excelReportIncludes,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            _buildFeatureItem(l10n.summarySheetDescription),
            _buildFeatureItem(l10n.dailyBreakdownDescription),
            _buildFeatureItem(l10n.appsSheetDescription),
            _buildFeatureItem(l10n.insightsDescription),
          ],
        ),
        actions: [
          Button(
            child: Text(l10n.cancel),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 4),
      child: Row(
        children: [
          Icon(FluentIcons.check_mark, size: 12, color: Colors.green),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportComprehensiveReport() async {
    final l10n = AppLocalizations.of(context)!;
    if (_analyticsSummary == null) return;

    setState(() => _isExporting = true);

    try {
      final success = await _xlsxExporter?.exportAnalyticsReport(
        summary: _analyticsSummary!,
        periodLabel: _getPeriodLabel(_selectedPeriod),
        startDate: _startDate,
        endDate: _endDate,
      );

      if (success!) {
        _showSuccessMessage(l10n.beautifulExcelExportSuccess);
      }
    } catch (e) {
      _showErrorMessage(l10n.failedToExportReport(e.toString()));
    } finally {
      setState(() => _isExporting = false);
    }
  }

  void _showSuccessMessage(String message) {
    final l10n = AppLocalizations.of(context)!;
    displayInfoBar(context, builder: (context, close) {
      return InfoBar(
        title: Text(l10n.exportSuccessful),
        content: Text(message),
        severity: InfoBarSeverity.success,
        action: IconButton(
          icon: const Icon(FluentIcons.clear),
          onPressed: close,
        ),
      );
    });
  }

  void _showErrorMessage(String message) {
    final l10n = AppLocalizations.of(context)!;
    displayInfoBar(context, builder: (context, close) {
      return InfoBar(
        title: Text(l10n.exportFailed),
        content: Text(message),
        severity: InfoBarSeverity.error,
        action: IconButton(
          icon: const Icon(FluentIcons.clear),
          onPressed: close,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      padding: EdgeInsets.zero,
      content: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo is ScrollStartNotification &&
              scrollInfo.metrics.pixels == scrollInfo.metrics.minScrollExtent) {
            _loadAnalyticsData();
            return true;
          }
          return false;
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                if (_isLoading)
                  _buildCustomLoadingIndicator()
                else if (_error != null)
                  _buildCustomErrorDisplay()
                else if (_analyticsSummary != null)
                  ..._buildAnalyticsContent(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomLoadingIndicator() {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        children: [
          const SizedBox(
            width: 40,
            height: 40,
            child: ProgressRing(strokeWidth: 3),
          ),
          const SizedBox(height: 10),
          Text(l10n.loadingAnalyticsData),
        ],
      ),
    );
  }

  Widget _buildCustomErrorDisplay() {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        children: [
          Icon(FluentIcons.error, color: Colors.red, size: 40),
          const SizedBox(height: 10),
          Text(_error!, style: TextStyle(color: Colors.red)),
          const SizedBox(height: 15),
          GestureDetector(
            onTap: _initializeAndLoadData,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(l10n.tryAgain, style: TextStyle(color: Colors.blue)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            l10n.usageAnalytics,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Row(
          children: [
            // Export Button
            if (_analyticsSummary != null && !_isLoading)
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: FilledButton(
                  onPressed: _isExporting ? null : _showExportDialog,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_isExporting)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: ProgressRing(strokeWidth: 2),
                        )
                      else
                        const Icon(FluentIcons.excel_document, size: 16),
                      const SizedBox(width: 8),
                      Text(_isExporting ? 'Exporting...' : 'Export Excel'),
                    ],
                  ),
                ),
              ),
            // Period Selector
            ComboBox<PeriodType>(
              value: _selectedPeriod,
              items: PeriodType.values
                  .map((period) => ComboBoxItem<PeriodType>(
                        value: period,
                        child: Text(_getPeriodLabel(period)),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null && value != _selectedPeriod) {
                  if (value == PeriodType.custom) {
                    _showDateRangeDialog(context);
                  } else {
                    setState(() {
                      _selectedPeriod = value;
                    });
                    _loadAnalyticsData();
                  }
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  void _showDateRangeDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    DateTime now = DateTime.now();
    DateTime startDate = _startDate ?? DateTime(now.year, now.month - 1, 1);
    DateTime endDate = _endDate ?? DateTime(now.year, now.month, now.day);
    DateTime specificDate = _specificDate ?? now;
    bool isRangeMode = _isDateRangeMode;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return ContentDialog(
            title: Text(l10n.customDialogTitle),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      ToggleSwitch(
                        checked: isRangeMode,
                        onChanged: (value) {
                          setState(() {
                            isRangeMode = value;
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      Text(isRangeMode ? l10n.dateRange : l10n.specificDate),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (isRangeMode) ...[
                    Row(
                      children: [
                        Text(l10n.startDate),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DatePicker(
                            selected: startDate,
                            onChanged: (date) {
                              setState(() {
                                startDate = date;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text(l10n.endDate),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DatePicker(
                            selected: endDate,
                            onChanged: (date) {
                              setState(() {
                                endDate = date;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    Row(
                      children: [
                        Text(l10n.date),
                        const SizedBox(width: 24),
                        Expanded(
                          child: DatePicker(
                            selected: specificDate,
                            onChanged: (date) {
                              setState(() {
                                specificDate = date;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              Button(
                child: Text(l10n.cancel),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              FilledButton(
                child: Text(l10n.apply),
                onPressed: () {
                  if (isRangeMode) {
                    if (startDate.isAfter(endDate)) {
                      showDialog(
                        context: context,
                        builder: (context) => ContentDialog(
                          title: Text(l10n.invalidDateRange),
                          content: Text(l10n.startDateBeforeEndDate),
                          actions: [
                            Button(
                              child: Text(l10n.ok),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      );
                      return;
                    }
                  }

                  Navigator.pop(context);

                  this.setState(() {
                    _isDateRangeMode = isRangeMode;
                    _selectedPeriod = PeriodType.custom;
                    if (isRangeMode) {
                      _startDate = startDate;
                      _endDate = endDate;
                      _specificDate = null;
                    } else {
                      _specificDate = specificDate;
                      _startDate = null;
                      _endDate = null;
                    }
                  });
                  _loadAnalyticsData();
                },
              ),
            ],
          );
        });
      },
    );
  }

  List<Widget> _buildAnalyticsContent() {
    final summary = _analyticsSummary!;
    return [
      TopBoxes(analyticsSummary: summary),
      const SizedBox(height: 20),
      LayoutBuilder(
        builder: (context, constraints) {
          return constraints.maxWidth < 800
              ? Column(
                  children: [
                    _buildScreenTimeChart(summary),
                    const SizedBox(height: 20),
                    _buildCategoryBreakdownChart(summary),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 6, child: _buildScreenTimeChart(summary)),
                    const SizedBox(width: 20),
                    Expanded(
                        flex: 3, child: _buildCategoryBreakdownChart(summary)),
                  ],
                );
        },
      ),
      const SizedBox(height: 20),
      ApplicationUsage(appUsageDetails: summary.appUsageDetails),
    ];
  }

  Widget _buildScreenTimeChart(AnalyticsSummary summary) {
    final l10n = AppLocalizations.of(context)!;
    return CardContainer(
      title: l10n.dailyScreenTime,
      child: SizedBox(
        child: LineChartWidget(
          chartType: ChartType.main,
          dailyScreenTimeData: graphData,
          periodType: _getPeriodLabel(_selectedPeriod),
          onDateSelected: executeLineChart,
        ),
      ),
    );
  }

  Widget _buildCategoryBreakdownChart(AnalyticsSummary summary) {
    final l10n = AppLocalizations.of(context)!;
    final dataMap = summary.categoryBreakdown;

    if (dataMap.isEmpty) {
      return CardContainer(
        title: l10n.categoryBreakdown,
        child: Center(child: Text(l10n.noDataAvailable)),
      );
    }

    return CardContainer(
      title: l10n.categoryBreakdown,
      child: ReportsPieChart(
        dataMap: dataMap,
        colorList: const [
          Color.fromRGBO(223, 250, 92, 1),
          Color.fromRGBO(129, 250, 112, 1),
          Color.fromRGBO(129, 182, 205, 1),
          Color.fromRGBO(91, 253, 199, 1),
        ],
      ),
    );
  }
}

class CardContainer extends StatelessWidget {
  final String title;
  final Widget child;
  final double? height;

  const CardContainer({
    super.key,
    required this.title,
    required this.child,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: height ?? 405),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: FluentTheme.of(context).micaBackgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: FluentTheme.of(context).inactiveBackgroundColor,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            semanticsLabel: AppLocalizations.of(context)!.sectionLabel(title),
          ),
          const SizedBox(height: 20),
          Expanded(child: child),
        ],
      ),
    );
  }
}
