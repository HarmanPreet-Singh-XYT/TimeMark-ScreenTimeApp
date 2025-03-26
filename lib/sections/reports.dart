import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:intl/intl.dart';
import 'package:screentime/sections/graphs/reports_line_chart.dart';
import 'package:screentime/sections/graphs/reports_pie_chart.dart';
import './controller/data_controllers/reports_controller.dart';
import './controller/data_controllers/alerts_limits_data_controller.dart' as app_summary_data;
import './controller/data_controllers/applications_data_controller.dart';
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
  String _selectedPeriod = 'Last 7 Days';
  final List<String> _periodOptions = ['Last 7 Days', 'Last Month', 'Last 3 Months', 'Lifetime'];

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
          _error = _analyticsController.error ?? 'Failed to initialize analytics. Please restart the application.';
          _isLoading = false;
        });
        return;
      }
      
      await _loadAnalyticsData();
    } catch (e) {
      setState(() {
        _error = 'An unexpected error occurred: $e. Please try again later.';
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
        case 'Last 7 Days':
          summary = await _analyticsController.getLastSevenDaysAnalytics();
          break;
        case 'Last Month':
          summary = await _analyticsController.getLastMonthAnalytics();
          break;
        case 'Last 3 Months':
          summary = await _analyticsController.getLastThreeMonthsAnalytics();
          break;
        case 'Lifetime':
          summary = await _analyticsController.getLifetimeAnalytics();
          break;
        default:
          summary = await _analyticsController.getLastSevenDaysAnalytics();
      }

      setState(() {
        _analyticsSummary = summary;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error loading analytics data: $e. Please check your connection and try again.';
        _isLoading = false;
      });
    }
  }

  @override
Widget build(BuildContext context) {
  return NotificationListener<ScrollNotification>(
    // Custom refresh implementation
    onNotification: (ScrollNotification scrollInfo) {
      if (scrollInfo is ScrollStartNotification && 
          scrollInfo.metrics.pixels == scrollInfo.metrics.minScrollExtent) {
        _loadAnalyticsData();
        return true;
      }
      return false;
    },
    child: SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(), // Enables scrolling
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Header with period selector
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
  return const Center(
    child: Column(
      children: [
        SizedBox(
          width: 40,
          height: 40,
          child: ProgressRing(
            strokeWidth: 3,
          ),
        ),
        SizedBox(height: 10),
        Text('Loading analytics data...'),
      ],
    ),
  );
}

Widget _buildCustomErrorDisplay() {
  return Center(
    child: Column(
      children: [
        Icon(
          FluentIcons.error,
          color: Colors.red,
          size: 40,
        ),
        const SizedBox(height: 10),
        Text(
          _error!,
          style: TextStyle(color: Colors.red),
        ),
        const SizedBox(height: 15),
        GestureDetector(
          onTap: _initializeAndLoadData,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Try Again',
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ),
      ],
    ),
  );
}

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Flexible(
          child: Text(
            'Usage Analytics',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        ComboBox<String>(
          value: _selectedPeriod,
          items: _periodOptions.map((period) => ComboBoxItem<String>(
            value: period,
            child: Text(period),
          )).toList(),
          onChanged: (value) {
            if (value != null && value != _selectedPeriod) {
              setState(() {
                _selectedPeriod = value;
              });
              _loadAnalyticsData();
            }
          },
          // accessibleLabel: 'Select time period for analytics',
        ),
      ],
    );
  }

  List<Widget> _buildAnalyticsContent() {
    final summary = _analyticsSummary!;
    return [
      // Top analytics boxes
      TopBoxes(analyticsSummary: summary),
      const SizedBox(height: 20),
      
      // Charts row
      LayoutBuilder(
        builder: (context, constraints) {
          // Responsive layout based on available width
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
                    Expanded(
                      flex: 6,
                      child: _buildScreenTimeChart(summary),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      flex: 3,
                      child: _buildCategoryBreakdownChart(summary),
                    ),
                  ],
                );
        },
      ),
      const SizedBox(height: 20),
      
      // App usage section
      ApplicationUsage(appUsageDetails: summary.appUsageDetails),
    ];
  }

  Widget _buildScreenTimeChart(AnalyticsSummary summary) {
    return CardContainer(
      title: "Daily Screen Time",
      child: SizedBox(
        child: LineChartWidget(
          chartType: ChartType.main,
          dailyScreenTimeData: summary.dailyScreenTimeData,
          periodType: _selectedPeriod,
        ),
      ),
    );
  }

  Widget _buildCategoryBreakdownChart(AnalyticsSummary summary) {
    final dataMap = summary.categoryBreakdown;

    if (dataMap.isEmpty) {
      return const CardContainer(
        title: "Category Breakdown",
        child: Center(
          child: Text("No data available"),
        ),
      );
    }

    return CardContainer(
      title: "Category Breakdown",
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
      // Replace constraints with a fixed height
      constraints: BoxConstraints(maxHeight: height ?? 405),
      // height: height ?? 300, // Use a fixed default height instead of just min constraints
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
        // Change this to make the Column take up exactly the available space
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
    // Responsive layout based on screen width
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 800) {
          // Stack vertically on smaller screens (2x2 grid)
          return Column(
            children: [
              Row(
                children: [
                  Expanded(child: _buildAnalyticsBox(
                    context: context,
                    title: "Total Screen Time",
                    value: _formatDuration(analyticsSummary.totalScreenTime),
                    percentChange: analyticsSummary.screenTimeComparisonPercent,
                    icon: FluentIcons.screen_time,
                  )),
                  const SizedBox(width: 10),
                  Expanded(child: _buildAnalyticsBox(
                    context: context,
                    title: "Productive Time",
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
                    title: "Most Used App",
                    value: analyticsSummary.mostUsedApp,
                    subValue: _formatDuration(analyticsSummary.mostUsedAppTime),
                    icon: FluentIcons.account_browser,
                  )),
                  const SizedBox(width: 10),
                  Expanded(child: _buildAnalyticsBox(
                    context: context,
                    title: "Focus Sessions",
                    value: analyticsSummary.focusSessionsCount.toString(),
                    percentChange: analyticsSummary.focusSessionsComparisonPercent,
                    icon: FluentIcons.red_eye,
                  )),
                ],
              ),
            ],
          );
        } else {
          // Horizontal layout for larger screens
          return Row(
            children: [
              Expanded(child: _buildAnalyticsBox(
                context: context,
                title: "Total Screen Time",
                value: _formatDuration(analyticsSummary.totalScreenTime),
                percentChange: analyticsSummary.screenTimeComparisonPercent,
                icon: FluentIcons.screen_time,
              )),
              const SizedBox(width: 10),
              Expanded(child: _buildAnalyticsBox(
                context: context,
                title: "Productive Time",
                value: _formatDuration(analyticsSummary.productiveTime),
                percentChange: analyticsSummary.productiveTimeComparisonPercent,
                icon: FluentIcons.timer,
              )),
              const SizedBox(width: 10),
              Expanded(child: _buildAnalyticsBox(
                context: context,
                title: "Most Used App",
                value: analyticsSummary.mostUsedApp,
                subValue: _formatDuration(analyticsSummary.mostUsedAppTime),
                icon: FluentIcons.account_browser,
              )),
              const SizedBox(width: 10),
              Expanded(child: _buildAnalyticsBox(
                context: context,
                title: "Focus Sessions",
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
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 5),
          if (percentChange != null)
            Text(
              percentChange >= 0 
                ? "+${percentChange.toStringAsFixed(1)}% vs previous period" 
                : "${percentChange.toStringAsFixed(1)}% vs previous period",
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
    return CardContainer(
      title: "Detailed Application Usage",
      height: 500,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search and sort controls
          Row(
            children: [
              Expanded(
                child: TextBox(
                  placeholder: 'Search applications',
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
                items: ['Name', 'Category', 'Usage'].map((option) => 
                  ComboBoxItem<String>(
                    value: option,
                    child: Text('Sort by: $option'),
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
                icon: Icon(
                  _sortAscending ? FluentIcons.sort_up : FluentIcons.sort_down,
                ),
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
          // Table header
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text("Name", style: TextStyle(fontWeight: FontWeight.w600)),
                ),
                Expanded(
                  flex: 2,
                  child: Text("Category", style: TextStyle(fontWeight: FontWeight.w600)),
                ),
                Expanded(
                  flex: 2,
                  child: Text("Total Time", style: TextStyle(fontWeight: FontWeight.w600)),
                ),
                Expanded(
                  flex: 2,
                  child: Text("Productivity", style: TextStyle(fontWeight: FontWeight.w600)),
                ),
                Expanded(
                  flex: 1,
                  child: Text("Actions", style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          Container(height: 1, color: FluentTheme.of(context).inactiveBackgroundColor),
          const SizedBox(height: 10),
          // App list
          Expanded(
            child: _filteredAppUsageDetails
                    .where((app) =>  app.appName.trim().isNotEmpty)
                    .isEmpty
                ? const Center(child: Text("No applications match your search criteria"))
                : ListView.builder(
                    itemCount: _filteredAppUsageDetails
                        .where((app) =>  app.appName.trim().isNotEmpty)
                        .length,
                    itemBuilder: (context, index) {
                      final filteredApps = _filteredAppUsageDetails
                          .where((app) =>  app.appName.trim().isNotEmpty)
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
    // Get the controller instance
  final app_summary_data.ScreenTimeDataController controller = app_summary_data.ScreenTimeDataController();
  
  // Fetch the app summary using the controller
  final app_summary_data.AppUsageSummary? appSummary = controller.getAppSummary(app.appName);
  
  // If app summary is null, return
  if (appSummary == null) {
    return;
  }
  final appDataProvider = ApplicationsDataProvider();
  // Fetch detailed application data for the selected timeframe
  final ApplicationBasicDetail appBasicDetails = await appDataProvider.fetchApplicationByName(app.appName);
  final ApplicationDetailedData appDetails = await appDataProvider.fetchApplicationDetails(
    app.appName, 
    TimeRange.week // Default to weekly view, can be made dynamic
  );
  
    // Modify the daily usage spots generation
  final List<FlSpot> dailyUsageSpots = [];
  final Map<String, Duration> weeklyData = appDetails.usageTrends.daily;

  // Use a mapping to ensure unique x-coordinates
  final Map<String, double> dateToXCoordinate = {};
  double currentXCoordinate = 0;

  // Sort dates to ensure chronological order
  final List<String> sortedDates = weeklyData.keys.toList()..sort((a, b) {
    final DateFormat formatter = DateFormat('MM/dd');
    return formatter.parse(a).compareTo(formatter.parse(b));
  });

  // Calculate max usage for Y-axis scaling
  double maxUsage = 0;

  // Convert data to chart points with unique x-coordinates
  for (final String dateKey in sortedDates) {
    final Duration duration = weeklyData[dateKey] ?? Duration.zero;
    final double usageMinutes = duration.inMinutes.toDouble();
    
    // Update max usage
    maxUsage = max(maxUsage, usageMinutes);
    
    // Map each unique date to a unique x-coordinate
    if (!dateToXCoordinate.containsKey(dateKey)) {
      dateToXCoordinate[dateKey] = currentXCoordinate;
      currentXCoordinate += 1;
    }
    
    dailyUsageSpots.add(FlSpot(
      dateToXCoordinate[dateKey]!, 
      usageMinutes
    ));
  }
  // Calculate statistics
  
  // final double maxUsage = sortedDates.isEmpty 
  //     ? 0 
  //     : sortedDates.map((date) => weeklyData[date]?.inMinutes ?? 0)
  //           .reduce((a, b) => a > b ? a : b).toDouble();
  
  // Generate time of day usage data from hourly breakdown
  final Map<String, double> timeOfDayUsage = _generateTimeOfDayData(appDetails.hourlyBreakdown);
  if (!context.mounted) return; // Ensure the context is still valid
  showDialog(
    context: context,
    builder: (context) => ContentDialog(
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
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                letterSpacing: 0.3,
              ),
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
                    const Text("Usage Summary", 
                      style: TextStyle(
                        fontWeight: FontWeight.bold, 
                        fontSize: 18,
                        letterSpacing: 0.4,
                      )),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildSummaryItem(
                          context, 
                          "Today", 
                          appBasicDetails.formattedScreenTime,
                          icon: FluentIcons.calendar_day,
                          iconSize: 20,
                        ),
                        _buildSummaryItem(
                          context, 
                          "Daily Limit", 
                          appSummary.limitStatus 
                            ? _formatDuration(appSummary.dailyLimit) 
                            : "No limit",
                          icon: FluentIcons.timer,
                          iconSize: 20,
                        ),
                        _buildSummaryItem(
                          context, 
                          "Usage Trend", 
                          _determineTrend(appDetails.comparisons),
                          icon: _getTrendIcon(appDetails.comparisons),
                          color: _getTrendColor(appDetails.comparisons),
                          iconSize: 20,
                        ),
                        _buildSummaryItem(
                          context, 
                          "Productivity", 
                          app.isProductive ? "Productive" : "Non-Productive",
                          icon: app.isProductive 
                            ? FluentIcons.check_mark 
                            : FluentIcons.cancel,
                          color: app.isProductive 
                            ? Colors.green 
                            : Colors.red,
                          iconSize: 20,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Usage Over Time Chart
              Card(
                padding: const EdgeInsets.all(20),
                borderRadius: BorderRadius.circular(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Usage Over Past Week", 
                      style: TextStyle(
                        fontWeight: FontWeight.bold, 
                        fontSize: 18,
                        letterSpacing: 0.4,
                      )),
                    const SizedBox(height: 24),
                    Container(
                      height: 220,
                      padding: const EdgeInsets.only(right: 16, bottom: 16),
                      child: dailyUsageSpots.isEmpty 
                        ? Center(
                            child: Text(
                              "No historical data available",
                              style: TextStyle(
                                fontSize: 16,
                                color: FluentTheme.of(context).accentColor.withAlpha(128),
                              ),
                            ))
                        : LineChart(
                            LineChartData(
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: true,
                                getDrawingHorizontalLine: (value) {
                                  return FlLine(
                                    color: FluentTheme.of(context).accentColor.withAlpha(40),
                                    strokeWidth: 1,
                                  );
                                },
                                getDrawingVerticalLine: (value) {
                                  return FlLine(
                                    color: FluentTheme.of(context).accentColor.withAlpha(40),
                                    strokeWidth: 1,
                                  );
                                },
                              ),
                              titlesData: FlTitlesData(
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      // Find the date corresponding to this x-coordinate
                                      final matchingEntries = dateToXCoordinate.entries
                                        .where((entry) => entry.value == value);
                                      
                                      if (matchingEntries.isNotEmpty) {
                                        final String date = matchingEntries.first.key;
                                        final String displayDate = _formatDateForAxis(date);
                                        return Padding(
                                          padding: const EdgeInsets.only(top: 8.0),
                                          child: Text(
                                            displayDate,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: FluentTheme.of(context).accentColor.withAlpha(128),
                                            ),
                                          ),
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
                                    getTitlesWidget: (value, meta) {
                                      return Padding(
                                        padding: const EdgeInsets.only(right: 8.0),
                                        child: Text(
                                          '${value.toInt()}m',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: FluentTheme.of(context).accentColor.withAlpha(128),
                                          ),
                                        ),
                                      );
                                    },
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
                                    getDotPainter: (spot, percent, barData, index) {
                                      return FlDotCirclePainter(
                                        radius: 5,
                                        color: Colors.blue,
                                        strokeWidth: 2,
                                        strokeColor: Colors.white,
                                      );
                                    },
                                  ),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    color: Colors.blue.withAlpha(38),
                                    spotsLine: BarAreaSpotsLine(
                                      show: true,
                                      flLineStyle: FlLine(
                                        color: Colors.blue.withAlpha(128),
                                        strokeWidth: 1,
                                      ),
                                    ),
                                  ),
                                ),
                                // Add a line for the daily limit if set
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
                        _buildStatCard(
                          context,
                          "Avg. Daily Usage",
                          appDetails.usageInsights.formattedAverageDailyUsage,
                          FluentIcons.chart_series,
                          cardSize: 100,
                        ),
                        _buildStatCard(
                          context,
                          "Longest Session",
                          appDetails.sessionBreakdown.formattedLongestSessionDuration,
                          FluentIcons.timeline_progress,
                          cardSize: 100,
                        ),
                        _buildStatCard(
                          context,
                          "Weekly Total",
                          _formatDuration(Duration(minutes: weeklyData.values
                              .map((duration) => duration.inMinutes)
                              .fold(0, (a, b) => a + b))),
                          FluentIcons.calendar_week,
                          cardSize: 100,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Time of Day Distribution
              Card(
                padding: const EdgeInsets.all(20),
                borderRadius: BorderRadius.circular(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Usage Pattern by Time of Day", 
                      style: TextStyle(
                        fontWeight: FontWeight.bold, 
                        fontSize: 18,
                        letterSpacing: 0.4,
                      )),
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
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(
                                          blurRadius: 2.0,
                                          color: Colors.black,
                                        ),
                                      ],
                                    ),
                                    badgeWidget: entry.value > 20 ? const Icon(
                                      FluentIcons.starburst,
                                      color: Colors.white,
                                      size: 12,
                                    ) : null,
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
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 14,
                                          height: 14,
                                          decoration: BoxDecoration(
                                            color: _getTimeOfDayColor(entry.key),
                                            shape: BoxShape.rectangle,
                                            borderRadius: BorderRadius.circular(3),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withAlpha(26),
                                                blurRadius: 1,
                                                offset: const Offset(0, 1),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          entry.key,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
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
              ),
              
              const SizedBox(height: 24),
              
              // Usage Pattern Analysis
              Card(
                padding: const EdgeInsets.all(20),
                borderRadius: BorderRadius.circular(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Pattern Analysis", 
                      style: TextStyle(
                        fontWeight: FontWeight.bold, 
                        fontSize: 18,
                        letterSpacing: 0.4,
                      )),
                    const SizedBox(height: 20),
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.withAlpha(26),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          FluentIcons.lightbulb, 
                          color: Colors.blue,
                          size: 24,
                        ),
                      ),
                      title: const Text("Usage Insights", 
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        )),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8.0, left: 4.0),
                        child: Text(
                          _generateUsageInsights(appBasicDetails, appDetails, timeOfDayUsage),
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.4,
                          ),
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
                          child: Icon(
                            FluentIcons.timer, 
                            color: _getLimitStatusColor(appBasicDetails),
                            size: 24,
                          ),
                        ),
                        title: const Text("Limit Status", 
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          )),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8.0, left: 4.0),
                          child: Text(
                            _generateLimitStatusInsight(appBasicDetails),
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              
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
          child: const Text(
            'Close',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    ),
  );
}

  // Helper functions for data manipulation
  Map<String, double> _generateTimeOfDayData(Map<int, Duration> hourlyBreakdown) {
    // Create buckets for each time of day
    final Map<String, Duration> timeOfDayDurations = {
      'Morning (6-12)': Duration.zero,
      'Afternoon (12-5)': Duration.zero,
      'Evening (5-9)': Duration.zero,
      'Night (9-6)': Duration.zero,
    };
    
    // Sum up durations for each time bracket
    hourlyBreakdown.forEach((hour, duration) {
      if (hour >= 6 && hour < 12) {
        timeOfDayDurations['Morning (6-12)'] = 
            timeOfDayDurations['Morning (6-12)']! + duration;
      } else if (hour >= 12 && hour < 17) {
        timeOfDayDurations['Afternoon (12-5)'] = 
            timeOfDayDurations['Afternoon (12-5)']! + duration;
      } else if (hour >= 17 && hour < 21) {
        timeOfDayDurations['Evening (5-9)'] = 
            timeOfDayDurations['Evening (5-9)']! + duration;
      } else {
        timeOfDayDurations['Night (9-6)'] = 
            timeOfDayDurations['Night (9-6)']! + duration;
      }
    });
    
    // Calculate total duration
    final Duration totalDuration = timeOfDayDurations.values.fold(
      Duration.zero, (prev, curr) => prev + curr);
    
    // Convert to percentages for chart
    final Map<String, double> percentages = {};
    if (totalDuration.inSeconds > 0) {
      timeOfDayDurations.forEach((timeOfDay, duration) {
        percentages[timeOfDay] = (duration.inSeconds / totalDuration.inSeconds) * 100;
      });
    } else {
      // Equal distribution if no data
      for (var timeOfDay in timeOfDayDurations.keys) {
        percentages[timeOfDay] = 25.0;
      }
    }
    
    return percentages;
  }

  String _formatDateForAxis(String dateString) {
    try {
      // Assuming dateString is in 'MM/dd' format
      final DateFormat inputFormatter = DateFormat('MM/dd');
      final DateTime date = inputFormatter.parse(dateString);
      
      // Check if the date is today
      final DateTime today = DateTime.now();
      if (date.year == today.year && 
          date.month == today.month && 
          date.day == today.day) {
        return 'Today';
      }
      
      // Return day of week for other dates
      return DateFormat('EEE').format(date);
    } catch (e) {
      return dateString; // Fallback to original if parsing fails
    }
  }

  String _determineTrend(UsageComparisons comparisons) {
    final double percentage = comparisons.growthPercentage;
    
    if (percentage > 5) {
      return "Increasing";
    } else if (percentage < -5) {
      return "Decreasing";
    } else {
      return "Stable";
    }
  }

  IconData _getTrendIcon(UsageComparisons comparisons) {
    final double percentage = comparisons.growthPercentage;
    
    if (percentage > 5) {
      return FluentIcons.up;
    } else if (percentage < -5) {
      return FluentIcons.down;
    } else {
      return FluentIcons.horizontal_tab_key;
    }
  }

  Color _getTrendColor(UsageComparisons comparisons) {
    final double percentage = comparisons.growthPercentage;
    
    if (percentage > 5) {
      return Colors.red;
    } else if (percentage < -5) {
      return Colors.green;
    } else {
      return Colors.blue;
    }
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
    
    // Calculate percentage used
    final double percentUsed = app.screenTime.inSeconds / 
        (app.dailyLimit.inSeconds > 0 ? app.dailyLimit.inSeconds : 1);
    
    if (percentUsed >= 1.0) return Colors.red;
    if (percentUsed >= 0.75) return Colors.orange;
    return Colors.green;
  }

  String _generateUsageInsights(
      ApplicationBasicDetail app, 
      ApplicationDetailedData details,
      Map<String, double> timeOfDay) {
    final List<String> insights = [];
    
    // Determine primary usage time
    final String primaryTimeOfDay = timeOfDay.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
    
    insights.add("You primarily use ${app.name} during $primaryTimeOfDay.");
    
    // Add trend insight based on growth percentage
    final double growthPercentage = details.comparisons.growthPercentage;
    if (growthPercentage > 10) {
      insights.add("Your usage has increased significantly (${growthPercentage.toStringAsFixed(1)}%) compared to the previous period.");
    } else if (growthPercentage > 5) {
      insights.add("Your usage is trending upward compared to the previous period.");
    } else if (growthPercentage < -10) {
      insights.add("Your usage has decreased significantly (${growthPercentage.abs().toStringAsFixed(1)}%) compared to the previous period.");
    } else if (growthPercentage < -5) {
      insights.add("Your usage is trending downward compared to the previous period.");
    } else {
      insights.add("Your usage has been consistent compared to the previous period.");
    }
    
    // Add productivity insight
    if (app.isProductive) {
      insights.add("This is marked as a productive app in your settings.");
    } else {
      insights.add("This is marked as a non-productive app in your settings.");
    }
    
    // Add most active hour insight if available
    if (details.usageInsights.mostActiveHours.isNotEmpty) {
      final int mostActiveHour = details.usageInsights.mostActiveHours.first;
      insights.add("Your most active time is around ${_formatHourOfDay(mostActiveHour)}.");
    }
    
    return insights.join(" ");
  }

  String _formatHourOfDay(int hour) {
    final String period = hour >= 12 ? 'PM' : 'AM';
    final int displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour $period';
  }

  String _generateLimitStatusInsight(ApplicationBasicDetail app) {
    if (!app.limitStatus) {
      return "No usage limit has been set for this application.";
    }
    
    // Calculate percentage used
    final double percentUsed = app.screenTime.inSeconds / 
        (app.dailyLimit.inSeconds > 0 ? app.dailyLimit.inSeconds : 1);
    
    final String remainingTime = _formatDuration(app.dailyLimit - app.screenTime);
    
    if (percentUsed >= 1.0) {
      return "You've reached your daily limit for this application.";
    } else if (percentUsed >= 0.9) {
      return "You're about to reach your daily limit with only $remainingTime remaining.";
    } else if (percentUsed >= 0.75) {
      return "You've used ${(percentUsed * 100).toInt()}% of your daily limit with $remainingTime remaining.";
    } else {
      return "You have $remainingTime remaining out of your daily limit.";
    }
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

  // Helper widgets
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
                fontSize: 13,
                fontWeight: FontWeight.normal,
                color: FluentTheme.of(context).accentColor.withAlpha(204),
              )),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
              letterSpacing: 0.4,
            ),
          ),
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
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                color: FluentTheme.of(context).accentColor.withAlpha(204),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.4,
              ),
            ),
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
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(name, overflow: TextOverflow.ellipsis),
              ),
              Expanded(
                flex: 2,
                child: Text(category, overflow: TextOverflow.ellipsis),
              ),
              Expanded(
                flex: 2,
                child: Text(totalTime),
              ),
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
                    Text(productivity ? "Productive" : "Non-Productive"),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Tooltip(
                  message: "View details",
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

// Placeholder of the utility widgets that should be created in separate files
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
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}