import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:screentime/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:screentime/sections/graphs/reports_line_chart.dart';
import 'package:screentime/sections/graphs/reports_pie_chart.dart';
import './controller/data_controllers/reports_controller.dart';
import './controller/data_controllers/alerts_limits_data_controller.dart' as app_summary_data;
import './controller/data_controllers/applications_data_controller.dart';

// Add this enum at the top of your file
enum PeriodType {
  last7Days,
  lastMonth,
  last3Months,
  lifetime,
  custom
}

class Reports extends StatefulWidget {
  const Reports({super.key});

  @override
  State<Reports> createState() => _ReportsState();
}

class _ReportsState extends State<Reports> {
  final UsageAnalyticsController _analyticsController = UsageAnalyticsController();
  AnalyticsSummary? _analyticsSummary;
  bool _isLoading = true;
  String? _error;
  PeriodType _selectedPeriod = PeriodType.last7Days; // Changed to enum
  
  @override
  void initState() {
    super.initState();
    _initializeAndLoadData();
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
          _error = _analyticsController.error ?? AppLocalizations.of(context)!.failedToInitialize;
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
          if (_startDate != null && _endDate != null && _isDateRangeMode == true) {
            summary = await _analyticsController.getSpecificDateRangeAnalytics(_startDate!, _endDate!);
            graphData = summary.dailyScreenTimeData;
          } else if (_specificDate != null && _isDateRangeMode == false) {
            summary = await _analyticsController.getSpecificDayAnalytics(_specificDate!);
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
        _error = AppLocalizations.of(context)!.errorLoadingAnalytics(e.toString());
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
      summary = await _analyticsController.getSpecificDayAnalytics(specificDate);
      setState(() {
        _analyticsSummary = summary;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = AppLocalizations.of(context)!.errorLoadingAnalytics(e.toString());
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

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
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
        ComboBox<PeriodType>(
          value: _selectedPeriod,
          items: PeriodType.values.map((period) => ComboBoxItem<PeriodType>(
            value: period,
            child: Text(_getPeriodLabel(period)),
          )).toList(),
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
    );
  }

  void _showDateRangeDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    DateTime now = DateTime.now();
    DateTime startDate = _startDate ?? DateTime(now.year, now.month-1, 1);
    DateTime endDate = _endDate ?? DateTime(now.year, now.month, now.day);
    DateTime specificDate = _specificDate ?? now;
    bool isRangeMode = _isDateRangeMode;
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
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
          }
        );
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
                    Expanded(flex: 3, child: _buildCategoryBreakdownChart(summary)),
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
            semanticsLabel: '$title section',
          ),
          const SizedBox(height: 20),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class TopBoxes extends StatelessWidget {
  final AnalyticsSummary analyticsSummary;

  const TopBoxes({super.key, required this.analyticsSummary});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 800) {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(child: _buildAnalyticsBox(
                    context: context,
                    title: l10n.totalScreenTime,
                    value: _formatDuration(analyticsSummary.totalScreenTime),
                    percentChange: analyticsSummary.screenTimeComparisonPercent,
                    icon: FluentIcons.screen_time,
                  )),
                  const SizedBox(width: 10),
                  Expanded(child: _buildAnalyticsBox(
                    context: context,
                    title: l10n.productiveTime,
                    value: _formatDuration(analyticsSummary.productiveTime),
                    percentChange: analyticsSummary.productiveTimeComparisonPercent,
                    icon: FluentIcons.timer,
                  )),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _buildAnalyticsBox(
                    context: context,
                    title: l10n.mostUsedApp,
                    value: analyticsSummary.mostUsedApp,
                    subValue: _formatDuration(analyticsSummary.mostUsedAppTime),
                    icon: FluentIcons.account_browser,
                  )),
                  const SizedBox(width: 10),
                  Expanded(child: _buildAnalyticsBox(
                    context: context,
                    title: l10n.focusSessions,
                    value: analyticsSummary.focusSessionsCount.toString(),
                    percentChange: analyticsSummary.focusSessionsComparisonPercent,
                    icon: FluentIcons.red_eye,
                  )),
                ],
              ),
            ],
          );
        } else {
          return Row(
            children: [
              Expanded(child: _buildAnalyticsBox(
                context: context,
                title: l10n.totalScreenTime,
                value: _formatDuration(analyticsSummary.totalScreenTime),
                percentChange: analyticsSummary.screenTimeComparisonPercent,
                icon: FluentIcons.screen_time,
              )),
              const SizedBox(width: 10),
              Expanded(child: _buildAnalyticsBox(
                context: context,
                title: l10n.productiveTime,
                value: _formatDuration(analyticsSummary.productiveTime),
                percentChange: analyticsSummary.productiveTimeComparisonPercent,
                icon: FluentIcons.timer,
              )),
              const SizedBox(width: 10),
              Expanded(child: _buildAnalyticsBox(
                context: context,
                title: l10n.mostUsedApp,
                value: analyticsSummary.mostUsedApp,
                subValue: _formatDuration(analyticsSummary.mostUsedAppTime),
                icon: FluentIcons.account_browser,
              )),
              const SizedBox(width: 10),
              Expanded(child: _buildAnalyticsBox(
                context: context,
                title: l10n.focusSessions,
                value: analyticsSummary.focusSessionsCount.toString(),
                percentChange: analyticsSummary.focusSessionsComparisonPercent,
                icon: FluentIcons.red_eye,
              )),
            ],
          );
        }
      },
    );
  }

  Widget _buildAnalyticsBox({
    required BuildContext context,
    required String title,
    required String value,
    double? percentChange,
    String? subValue,
    required IconData icon,
  }) {
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FluentTheme.of(context).micaBackgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: FluentTheme.of(context).inactiveBackgroundColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: FluentTheme.of(context).accentColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                  semanticsLabel: title,
                ),
              ),
              Icon(icon, size: 24, semanticLabel: '$title icon'),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 5),
          if (percentChange != null)
            Text(
              percentChange >= 0 
                ? l10n.positiveComparison(percentChange.toStringAsFixed(1))
                : l10n.negativeComparison(percentChange.toStringAsFixed(1)),
              style: TextStyle(
                fontSize: 12,
                color: percentChange >= 0 ? Colors.green : Colors.red,
              ),
              overflow: TextOverflow.ellipsis,
            )
          else if (subValue != null)
            Text(
              subValue,
              style: TextStyle(
                fontSize: 12,
                color: FluentTheme.of(context).accentColor.withValues(alpha: .8),
              ),
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    
    if (hours > 0) {
      return "${hours}h ${minutes}m";
    } else {
      return "${minutes}m";
    }
  }
}

class ApplicationUsage extends StatefulWidget {
  final List<AppUsageSummary> appUsageDetails;

  const ApplicationUsage({
    super.key,
    required this.appUsageDetails,
  });

  @override
  State<ApplicationUsage> createState() => _ApplicationUsageState();
}

class _ApplicationUsageState extends State<ApplicationUsage> {
  late List<AppUsageSummary> _filteredAppUsageDetails;
  String _searchQuery = '';
  String _sortBy = 'Usage';
  bool _sortAscending = false;

  @override
  void initState() {
    super.initState();
    _filteredAppUsageDetails = List.from(widget.appUsageDetails);
    _sortAppList();
  }

  @override
  void didUpdateWidget(ApplicationUsage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.appUsageDetails != widget.appUsageDetails) {
      _filteredAppUsageDetails = List.from(widget.appUsageDetails);
      _filterAndSortAppList();
    }
  }

  void _filterAndSortAppList() {
    setState(() {
      _filteredAppUsageDetails = widget.appUsageDetails
          .where((app) => app.appName.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
      _sortAppList();
    });
  }

  void _sortAppList() {
    setState(() {
      switch (_sortBy) {
        case 'Name':
          _filteredAppUsageDetails.sort((a, b) => 
            _sortAscending ? a.appName.compareTo(b.appName) : b.appName.compareTo(a.appName));
          break;
        case 'Category':
          _filteredAppUsageDetails.sort((a, b) => 
            _sortAscending ? a.category.compareTo(b.category) : b.category.compareTo(a.category));
          break;
        case 'Usage':
        default:
          _filteredAppUsageDetails.sort((a, b) => 
            _sortAscending ? a.totalTime.compareTo(b.totalTime) : b.totalTime.compareTo(a.totalTime));
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return CardContainer(
      title: l10n.detailedApplicationUsage,
      height: 500,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextBox(
                  placeholder: l10n.searchApplications,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                      _filterAndSortAppList();
                    });
                  },
                  prefix: const Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Icon(FluentIcons.search),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ComboBox<String>(
                value: _sortBy,
                items: [l10n.sortByName, l10n.sortByCategory, l10n.sortByUsage].map((option) => 
                  ComboBoxItem<String>(
                    value: option,
                    child: Text(l10n.sortByOption(option)),
                  )
                ).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _sortBy = value;
                      _sortAppList();
                    });
                  }
                },
              ),
              IconButton(
                icon: Icon(_sortAscending ? FluentIcons.sort_up : FluentIcons.sort_down),
                onPressed: () {
                  setState(() {
                    _sortAscending = !_sortAscending;
                    _sortAppList();
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(flex: 2, child: Text(l10n.nameHeader, style: const TextStyle(fontWeight: FontWeight.w600))),
                Expanded(flex: 2, child: Text(l10n.categoryHeader, style: const TextStyle(fontWeight: FontWeight.w600))),
                Expanded(flex: 2, child: Text(l10n.totalTimeHeader, style: const TextStyle(fontWeight: FontWeight.w600))),
                Expanded(flex: 2, child: Text(l10n.productivityHeader, style: const TextStyle(fontWeight: FontWeight.w600))),
                Expanded(flex: 1, child: Text(l10n.actionsHeader, style: const TextStyle(fontWeight: FontWeight.w600))),
              ],
            ),
          ),
          Container(height: 1, color: FluentTheme.of(context).inactiveBackgroundColor),
          const SizedBox(height: 10),
          Expanded(
            child: _filteredAppUsageDetails.where((app) => app.appName.trim().isNotEmpty).isEmpty
                ? Center(child: Text(l10n.noApplicationsMatch))
                : ListView.builder(
                    itemCount: _filteredAppUsageDetails.where((app) => app.appName.trim().isNotEmpty).length,
                    itemBuilder: (context, index) {
                      final filteredApps = _filteredAppUsageDetails
                          .where((app) => app.appName.trim().isNotEmpty)
                          .toList();
                      final app = filteredApps[index];

                      return ApplicationListItem(
                        name: app.appName,
                        category: app.category,
                        productivity: app.isProductive,
                        totalTime: _formatDuration(app.totalTime),
                        onViewDetails: () => _showAppDetails(context, app),
                      );
                    },
                  ),
          )
        ],
      ),
    );
  }

  void _showAppDetails(BuildContext context, AppUsageSummary app) async {
    final l10n = AppLocalizations.of(context)!;
    final app_summary_data.ScreenTimeDataController controller = app_summary_data.ScreenTimeDataController();
    final app_summary_data.AppUsageSummary? appSummary = controller.getAppSummary(app.appName);
    
    if (appSummary == null) return;
    
    final appDataProvider = ApplicationsDataProvider();
    final ApplicationBasicDetail appBasicDetails = await appDataProvider.fetchApplicationByName(app.appName);
    final ApplicationDetailedData appDetails = await appDataProvider.fetchApplicationDetails(
      app.appName, 
      TimeRange.week
    );
    
    // Generate chart data
    final List<FlSpot> dailyUsageSpots = [];
    final Map<String, Duration> weeklyData = appDetails.usageTrends.daily;
    final Map<String, double> dateToXCoordinate = {};
    double currentXCoordinate = 0;

    final List<String> sortedDates = weeklyData.keys.toList()..sort((a, b) {
      final DateFormat formatter = DateFormat('MM/dd');
      return formatter.parse(a).compareTo(formatter.parse(b));
    });

    double maxUsage = 0;

    for (final String dateKey in sortedDates) {
      final Duration duration = weeklyData[dateKey] ?? Duration.zero;
      final double usageMinutes = duration.inMinutes.toDouble();
      maxUsage = max(maxUsage, usageMinutes);
      
      if (!dateToXCoordinate.containsKey(dateKey)) {
        dateToXCoordinate[dateKey] = currentXCoordinate;
        currentXCoordinate += 1;
      }
      
      dailyUsageSpots.add(FlSpot(dateToXCoordinate[dateKey]!, usageMinutes));
    }

    final Map<String, double> timeOfDayUsage = _generateTimeOfDayData(appDetails.hourlyBreakdown);
    
    if (!context.mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => _buildAppDetailsDialog(
        context, 
        l10n, 
        app, 
        appSummary, 
        appBasicDetails, 
        appDetails,
        dailyUsageSpots,
        sortedDates,
        maxUsage,
        dateToXCoordinate,
        timeOfDayUsage,
      ),
    );
  }

  Widget _buildAppDetailsDialog(
    BuildContext context,
    AppLocalizations l10n,
    AppUsageSummary app,
    app_summary_data.AppUsageSummary appSummary,
    ApplicationBasicDetail appBasicDetails,
    ApplicationDetailedData appDetails,
    List<FlSpot> dailyUsageSpots,
    List<String> sortedDates,
    double maxUsage,
    Map<String, double> dateToXCoordinate,
    Map<String, double> timeOfDayUsage,
  ) {
    return ContentDialog(
      title: Row(
        children: [
          Icon(
            FluentIcons.app_icon_default,
            color: app.isProductive ? Colors.green : Colors.red,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              app.appName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, letterSpacing: 0.3),
            ),
          ),
        ],
      ),
      constraints: const BoxConstraints(maxWidth: 800, maxHeight: 700),
      content: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Usage Summary Card
              Card(
                padding: const EdgeInsets.all(20),
                borderRadius: BorderRadius.circular(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.usageSummary, 
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 0.4)),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildSummaryItem(context, l10n.today, appBasicDetails.formattedScreenTime,
                          icon: FluentIcons.calendar_day, iconSize: 20),
                        _buildSummaryItem(context, l10n.dailyLimit, 
                          appSummary.limitStatus ? _formatDuration(appSummary.dailyLimit) : l10n.noLimit,
                          icon: FluentIcons.timer, iconSize: 20),
                        _buildSummaryItem(context, l10n.usageTrend, _determineTrend(appDetails.comparisons, l10n),
                          icon: _getTrendIcon(appDetails.comparisons),
                          color: _getTrendColor(appDetails.comparisons), iconSize: 20),
                        _buildSummaryItem(context, l10n.productivity, 
                          app.isProductive ? l10n.productive : l10n.nonProductive,
                          icon: app.isProductive ? FluentIcons.check_mark : FluentIcons.cancel,
                          color: app.isProductive ? Colors.green : Colors.red, iconSize: 20),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Usage Over Time Chart
              _buildUsageOverTimeCard(context, l10n, dailyUsageSpots, sortedDates, maxUsage, 
                dateToXCoordinate, appSummary, appDetails),
              
              const SizedBox(height: 24),
              
              // Time of Day Distribution
              _buildTimeOfDayCard(context, l10n, timeOfDayUsage),
              
              const SizedBox(height: 24),
              
              // Usage Pattern Analysis
              _buildPatternAnalysisCard(context, l10n, appBasicDetails, appDetails, timeOfDayUsage, appSummary),
              
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      actions: [
        FilledButton(
          style: ButtonStyle(
            padding: WidgetStateProperty.all(const EdgeInsets.only(top: 12, bottom: 12, left: 20, right: 20)),
          ),
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.close, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }

  Widget _buildUsageOverTimeCard(
    BuildContext context,
    AppLocalizations l10n,
    List<FlSpot> dailyUsageSpots,
    List<String> sortedDates,
    double maxUsage,
    Map<String, double> dateToXCoordinate,
    app_summary_data.AppUsageSummary appSummary,
    ApplicationDetailedData appDetails,
  ) {
    final Map<String, Duration> weeklyData = appDetails.usageTrends.daily;
    
    return Card(
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.usageOverPastWeek, 
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 0.4)),
          const SizedBox(height: 24),
          Container(
            height: 220,
            padding: const EdgeInsets.only(right: 16, bottom: 16),
            child: dailyUsageSpots.isEmpty 
              ? Center(child: Text(l10n.noHistoricalData,
                  style: TextStyle(fontSize: 16, color: FluentTheme.of(context).accentColor.withAlpha(128))))
              : LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: true,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: FluentTheme.of(context).accentColor.withAlpha(40), strokeWidth: 1),
                      getDrawingVerticalLine: (value) => FlLine(
                        color: FluentTheme.of(context).accentColor.withAlpha(40), strokeWidth: 1),
                    ),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final matchingEntries = dateToXCoordinate.entries
                              .where((entry) => entry.value == value);
                            
                            if (matchingEntries.isNotEmpty) {
                              final String date = matchingEntries.first.key;
                              final String displayDate = _formatDateForAxis(date, l10n);
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(displayDate,
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500,
                                    color: FluentTheme.of(context).accentColor.withAlpha(128))),
                              );
                            }
                            return const Text('');
                          },
                          reservedSize: 30,
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) => Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Text('${value.toInt()}m',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500,
                                color: FluentTheme.of(context).accentColor.withAlpha(128))),
                          ),
                        ),
                      ),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(color: FluentTheme.of(context).accentColor.withAlpha(40)),
                    ),
                    minX: 0,
                    maxX: sortedDates.length - 1.0,
                    minY: 0,
                    maxY: maxUsage + 20,
                    lineBarsData: [
                      LineChartBarData(
                        spots: dailyUsageSpots,
                        isCurved: true,
                        color: Colors.blue,
                        barWidth: 4,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                            radius: 5, color: Colors.blue, strokeWidth: 2, strokeColor: Colors.white),
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          color: Colors.blue.withAlpha(38),
                          spotsLine: BarAreaSpotsLine(
                            show: true,
                            flLineStyle: FlLine(color: Colors.blue.withAlpha(128), strokeWidth: 1),
                          ),
                        ),
                      ),
                      if (appSummary.limitStatus && appSummary.dailyLimit > Duration.zero)
                        LineChartBarData(
                          spots: List.generate(sortedDates.length, (index) => 
                            FlSpot(index.toDouble(), appSummary.dailyLimit.inMinutes.toDouble())),
                          isCurved: false,
                          color: Colors.red.withAlpha(179),
                          barWidth: 2,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: false),
                          dashArray: [5, 5],
                        ),
                    ],
                  ),
                ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatCard(context, l10n.avgDailyUsage,
                appDetails.usageInsights.formattedAverageDailyUsage, FluentIcons.chart_series, cardSize: 100),
              _buildStatCard(context, l10n.longestSession,
                appDetails.sessionBreakdown.formattedLongestSessionDuration, FluentIcons.timeline_progress, cardSize: 100),
              _buildStatCard(context, l10n.weeklyTotal,
                _formatDuration(Duration(minutes: weeklyData.values.map((d) => d.inMinutes).fold(0, (a, b) => a + b))),
                FluentIcons.calendar_week, cardSize: 100),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeOfDayCard(BuildContext context, AppLocalizations l10n, Map<String, double> timeOfDayUsage) {
    return Card(
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.usagePatternByTimeOfDay, 
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 0.4)),
          const SizedBox(height: 24),
          SizedBox(
            height: 300,
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: PieChart(
                    PieChartData(
                      sections: timeOfDayUsage.entries.map((entry) {
                        final Color color = _getTimeOfDayColor(entry.key);
                        return PieChartSectionData(
                          color: color,
                          value: entry.value,
                          title: '${entry.value.toInt()}%',
                          radius: 90,
                          titleStyle: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white,
                            shadows: [Shadow(blurRadius: 2.0, color: Colors.black)]),
                          badgeWidget: entry.value > 20 ? const Icon(FluentIcons.starburst, color: Colors.white, size: 12) : null,
                          badgePositionPercentageOffset: 1.05,
                        );
                      }).toList(),
                      centerSpaceRadius: 40,
                      sectionsSpace: 3,
                      pieTouchData: PieTouchData(),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: timeOfDayUsage.entries.map((entry) {
                        String localizedLabel = entry.key;
                        if (entry.key.contains('Morning')) {localizedLabel = l10n.morning;}
                        else if (entry.key.contains('Afternoon')) {localizedLabel = l10n.afternoon;}
                        else if (entry.key.contains('Evening')) {localizedLabel = l10n.evening;}
                        else if (entry.key.contains('Night')) {localizedLabel = l10n.night;}
                        
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              Container(
                                width: 14, height: 14,
                                decoration: BoxDecoration(
                                  color: _getTimeOfDayColor(entry.key),
                                  shape: BoxShape.rectangle,
                                  borderRadius: BorderRadius.circular(3),
                                  boxShadow: [BoxShadow(color: Colors.black.withAlpha(26), blurRadius: 1, offset: const Offset(0, 1))],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(localizedLabel, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatternAnalysisCard(
    BuildContext context,
    AppLocalizations l10n,
    ApplicationBasicDetail appBasicDetails,
    ApplicationDetailedData appDetails,
    Map<String, double> timeOfDayUsage,
    app_summary_data.AppUsageSummary appSummary,
  ) {
    return Card(
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.patternAnalysis, 
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 0.4)),
          const SizedBox(height: 20),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withAlpha(26),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(FluentIcons.lightbulb, color: Colors.blue, size: 24),
            ),
            title: Text(l10n.usageInsights, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 4.0),
              child: Text(
                _generateUsageInsights(l10n, appBasicDetails, appDetails, timeOfDayUsage),
                style: const TextStyle(fontSize: 14, height: 1.4),
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (appSummary.limitStatus)
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getLimitStatusColor(appBasicDetails).withAlpha(26),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(FluentIcons.timer, color: _getLimitStatusColor(appBasicDetails), size: 24),
              ),
              title: Text(l10n.limitStatus, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 4.0),
                child: Text(
                  _generateLimitStatusInsight(l10n, appBasicDetails),
                  style: const TextStyle(fontSize: 14, height: 1.4),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Helper functions
  Map<String, double> _generateTimeOfDayData(Map<int, Duration> hourlyBreakdown) {
    final Map<String, Duration> timeOfDayDurations = {
      'Morning (6-12)': Duration.zero,
      'Afternoon (12-5)': Duration.zero,
      'Evening (5-9)': Duration.zero,
      'Night (9-6)': Duration.zero,
    };
    
    hourlyBreakdown.forEach((hour, duration) {
      if (hour >= 6 && hour < 12) {
        timeOfDayDurations['Morning (6-12)'] = timeOfDayDurations['Morning (6-12)']! + duration;
      } else if (hour >= 12 && hour < 17) {
        timeOfDayDurations['Afternoon (12-5)'] = timeOfDayDurations['Afternoon (12-5)']! + duration;
      } else if (hour >= 17 && hour < 21) {
        timeOfDayDurations['Evening (5-9)'] = timeOfDayDurations['Evening (5-9)']! + duration;
      } else {
        timeOfDayDurations['Night (9-6)'] = timeOfDayDurations['Night (9-6)']! + duration;
      }
    });
    
    final Duration totalDuration = timeOfDayDurations.values.fold(Duration.zero, (prev, curr) => prev + curr);
    final Map<String, double> percentages = {};
    
    if (totalDuration.inSeconds > 0) {
      timeOfDayDurations.forEach((timeOfDay, duration) {
        percentages[timeOfDay] = (duration.inSeconds / totalDuration.inSeconds) * 100;
      });
    } else {
      for (var timeOfDay in timeOfDayDurations.keys) {
        percentages[timeOfDay] = 25.0;
      }
    }
    
    return percentages;
  }

  String _formatDateForAxis(String dateString, AppLocalizations l10n) {
    try {
      final DateFormat inputFormatter = DateFormat('MM/dd');
      final DateTime date = inputFormatter.parse(dateString);
      final DateTime today = DateTime.now();
      
      if (date.year == today.year && date.month == today.month && date.day == today.day) {
        return l10n.todayChart;
      }
      
      return DateFormat('EEE').format(date);
    } catch (e) {
      return dateString;
    }
  }

  String _determineTrend(UsageComparisons comparisons, AppLocalizations l10n) {
    final double percentage = comparisons.growthPercentage;
    if (percentage > 5) return l10n.increasing;
    if (percentage < -5) return l10n.decreasing;
    return l10n.stable;
  }

  IconData _getTrendIcon(UsageComparisons comparisons) {
    final double percentage = comparisons.growthPercentage;
    if (percentage > 5) return FluentIcons.up;
    if (percentage < -5) return FluentIcons.down;
    return FluentIcons.horizontal_tab_key;
  }

  Color _getTrendColor(UsageComparisons comparisons) {
    final double percentage = comparisons.growthPercentage;
    if (percentage > 5) return Colors.red;
    if (percentage < -5) return Colors.green;
    return Colors.blue;
  }

  Color _getTimeOfDayColor(String timeOfDay) {
    final Map<String, Color> timeColors = {
      'Morning (6-12)': Colors.orange,
      'Afternoon (12-5)': Colors.yellow,
      'Evening (5-9)': Colors.purple,
      'Night (9-6)': Colors.blue,
    };
    return timeColors[timeOfDay] ?? Colors.grey;
  }

  Color _getLimitStatusColor(ApplicationBasicDetail app) {
    if (!app.limitStatus) return Colors.grey;
    final double percentUsed = app.screenTime.inSeconds / 
        (app.dailyLimit.inSeconds > 0 ? app.dailyLimit.inSeconds : 1);
    if (percentUsed >= 1.0) return Colors.red;
    if (percentUsed >= 0.75) return Colors.orange;
    return Colors.green;
  }

  String _generateUsageInsights(
    AppLocalizations l10n,
    ApplicationBasicDetail app, 
    ApplicationDetailedData details,
    Map<String, double> timeOfDay,
  ) {
    final List<String> insights = [];
    final String primaryTimeOfDay = timeOfDay.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    String localizedTimeOfDay = primaryTimeOfDay;
    
    if (primaryTimeOfDay.contains('Morning')) {localizedTimeOfDay = l10n.morning;}
    else if (primaryTimeOfDay.contains('Afternoon')) {localizedTimeOfDay = l10n.afternoon;}
    else if (primaryTimeOfDay.contains('Evening')) {localizedTimeOfDay = l10n.evening;}
    else if (primaryTimeOfDay.contains('Night')) {localizedTimeOfDay = l10n.night;}
    
    insights.add(
      l10n.primaryUsageTime(app.name, localizedTimeOfDay),
    );

    
    final double growthPercentage = details.comparisons.growthPercentage;
    if (growthPercentage > 10) {
      insights.add(l10n.significantIncrease(growthPercentage.toStringAsFixed(1)));
    } else if (growthPercentage > 5) {
      insights.add(l10n.trendingUpward);
    } else if (growthPercentage < -10) {
      insights.add(l10n.significantDecrease(growthPercentage.abs().toStringAsFixed(1)));
    } else if (growthPercentage < -5) {
      insights.add(l10n.trendingDownward);
    } else {
      insights.add(l10n.consistentUsage);
    }
    
    if (app.isProductive) {
      insights.add(l10n.markedAsProductive);
    } else {
      insights.add(l10n.markedAsNonProductive);
    }
    
    if (details.usageInsights.mostActiveHours.isNotEmpty) {
      final int mostActiveHour = details.usageInsights.mostActiveHours.first;
      insights.add(l10n.mostActiveTime(_formatHourOfDay(mostActiveHour, l10n)));
    }
    
    return insights.join(" ");
  }

  String _formatHourOfDay(int hour, AppLocalizations l10n) {
    final int displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

    return hour >= 12
        ? l10n.hourPeriodPM(displayHour)
        : l10n.hourPeriodAM(displayHour);
  }


  String _generateLimitStatusInsight(
      AppLocalizations l10n,
      ApplicationBasicDetail app,
  ) {
    if (!app.limitStatus) return l10n.noLimitSet;

    final double percentUsed = app.screenTime.inSeconds /
        (app.dailyLimit.inSeconds > 0 ? app.dailyLimit.inSeconds : 1);

    final String remainingTime =
        _formatDuration(app.dailyLimit - app.screenTime);

    if (percentUsed >= 1.0) {
      return l10n.limitReached;
    } else if (percentUsed >= 0.9) {
      return l10n.aboutToReachLimit(remainingTime);
    } else if (percentUsed >= 0.75) {
      return l10n.percentOfLimitUsed(
        (percentUsed * 100).toInt(),
        remainingTime,
      );
    } else {
      return l10n.remainingTime(remainingTime);
    }
  }


  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) return "${hours}h ${minutes}m";
    return "${minutes}m";
  }

  Widget _buildSummaryItem(BuildContext context, String title, String value, 
      {IconData? icon, Color? color, double iconSize = 16}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: iconSize, color: color ?? FluentTheme.of(context).accentColor),
                const SizedBox(width: 8),
              ],
              Text(title, style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.normal,
                color: FluentTheme.of(context).accentColor.withAlpha(204))),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, 
            color: color, letterSpacing: 0.4)),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, {double cardSize = 80}) {
    return Card(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: cardSize,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 24),
            const SizedBox(height: 10),
            Text(title, style: TextStyle(fontSize: 13, 
              color: FluentTheme.of(context).accentColor.withAlpha(204)), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.4)),
          ],
        ),
      ),
    );
  }
}

class ApplicationListItem extends StatelessWidget {
  final String name;
  final String category;
  final String totalTime;
  final bool productivity;
  final VoidCallback onViewDetails;

  const ApplicationListItem({
    super.key,
    required this.name,
    required this.category,
    required this.productivity,
    required this.totalTime,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Expanded(flex: 2, child: Text(name, overflow: TextOverflow.ellipsis)),
              Expanded(flex: 2, child: Text(category, overflow: TextOverflow.ellipsis)),
              Expanded(flex: 2, child: Text(totalTime)),
              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    Icon(
                      productivity ? FluentIcons.check_mark : FluentIcons.cancel,
                      color: productivity ? Colors.green : Colors.red,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(productivity ? l10n.productive : l10n.nonProductive),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Tooltip(
                  message: l10n.viewDetails,
                  child: IconButton(
                    icon: Icon(FluentIcons.view, size: 16, color: Colors.blue),
                    onPressed: onViewDetails,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(height: 1, color: FluentTheme.of(context).inactiveBackgroundColor),
      ],
    );
  }
}

class LoadingIndicator extends StatelessWidget {
  final String message;
  
  const LoadingIndicator({super.key, required this.message});
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const ProgressRing(),
          const SizedBox(height: 10),
          Text(message, semanticsLabel: message),
        ],
      ),
    );
  }
}

class ErrorDisplay extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;
  
  const ErrorDisplay({super.key, required this.errorMessage, required this.onRetry});
  
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(FluentIcons.error, size: 40, color: Colors.red),
          const SizedBox(height: 10),
          Text(errorMessage, style: TextStyle(color: Colors.red), textAlign: TextAlign.center),
          const SizedBox(height: 20),
          Button(
            onPressed: onRetry,
            child: Text(l10n.retry),
          ),
        ],
      ),
    );
  }
}