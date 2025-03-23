import 'package:fl_chart/fl_chart.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:screentime/sections/graphs/reports_line_chart.dart';
import 'package:screentime/sections/graphs/reports_pie_chart.dart';
import './controller/data_controllers/reports_controller.dart';
import './controller/data_controllers/alerts_limits_data_controller.dart' as appSummaryData;
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
    final dataMap = summary.categoryBreakdown ?? {};

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

  void _showAppDetails(BuildContext context, AppUsageSummary app) {
  // Get the controller instance
  final appSummaryData.ScreenTimeDataController controller = appSummaryData.ScreenTimeDataController();
  
  // Fetch the app summary using the controller
  final appSummaryData.AppUsageSummary? appSummary = controller.getAppSummary(app.appName);
  
  // If app summary is null, return
  if (appSummary == null) {
    return;
  }
  
  // Get usage history data for the past week
  final List<Map<String, dynamic>> weeklyData = _getWeeklyUsageData(app.appName);
  
  // Parse data for charts
  final List<FlSpot> dailyUsageSpots = weeklyData
      .asMap()
      .entries
      .map((entry) => FlSpot(entry.key.toDouble(), 
          entry.value['minutes'].toDouble()))
      .toList();
  
  // Calculate statistics
  final double avgDailyUsage = weeklyData.isEmpty 
      ? 0 
      : weeklyData.map((day) => day['minutes'] as num).reduce((a, b) => a + b) / weeklyData.length;
  
  final double maxUsage = weeklyData.isEmpty 
      ? 0 
      : weeklyData.map((day) => day['minutes'] as num).reduce((a, b) => a > b ? a : b).toDouble();
  
  // Generate time of day usage data
  final Map<String, double> timeOfDayUsage = {
    'Morning (6-12)': 35,
    'Afternoon (12-5)': 45,
    'Evening (5-9)': 15,
    'Night (9-6)': 5,
  };
  
  showDialog(
    context: context,
    builder: (context) => ContentDialog(
      title: Row(
        children: [
          Icon(
            FluentIcons.app_icon_default,
            color: app.isProductive ? Colors.green : Colors.red,
            size: 24, // Increased icon size
          ),
          const SizedBox(width: 12), // Increased spacing
          Expanded(
            child: Text(
              app.appName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20, // Increased font size
                letterSpacing: 0.3, // Added letter spacing for better readability
              ),
            ),
          ),
        ],
      ),
      constraints: const BoxConstraints(maxWidth: 800, maxHeight: 700), // Increased dialog size
      content: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0), // Added horizontal padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Usage Summary Card
              Card(
                padding: const EdgeInsets.all(20), // Increased padding
                borderRadius: BorderRadius.circular(12), // Rounded corners
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Usage Summary", 
                      style: TextStyle(
                        fontWeight: FontWeight.bold, 
                        fontSize: 18, // Increased font size
                        letterSpacing: 0.4,
                      )),
                    const SizedBox(height: 20), // Increased spacing
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround, // Better distribution
                      children: [
                        _buildSummaryItem(
                          context, 
                          "Today", 
                          _formatDuration(appSummary.currentUsage),
                          icon: FluentIcons.calendar_day,
                          iconSize: 20, // Specified icon size
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
                          _formatTrend(appSummary.trend),
                          icon: _getTrendIcon(appSummary.trend),
                          color: _getTrendColor(appSummary.trend),
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
              
              const SizedBox(height: 24), // Increased spacing between cards
              
              // Usage Over Time Chart
              Card(
                padding: const EdgeInsets.all(20), // Increased padding
                borderRadius: BorderRadius.circular(12), // Rounded corners
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Usage Over Past Week", 
                      style: TextStyle(
                        fontWeight: FontWeight.bold, 
                        fontSize: 18,
                        letterSpacing: 0.4,
                      )),
                    const SizedBox(height: 24), // Increased spacing
                    Container(
                      height: 220, // Increased height for the chart
                      padding: const EdgeInsets.only(right: 16, bottom: 16), // Added padding around chart
                      child: weeklyData.isEmpty 
                        ? Center(
                            child: Text(
                              "No historical data available",
                              style: TextStyle(
                                fontSize: 16,
                                color: FluentTheme.of(context).accentColor.withValues(alpha: .8),
                              ),
                            ))
                        : LineChart(
                            LineChartData(
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: true,
                                getDrawingHorizontalLine: (value) {
                                  return FlLine(
                                    color: FluentTheme.of(context).accentColor.withValues(alpha: .8).withValues(alpha: .2),
                                    strokeWidth: 1,
                                  );
                                },
                                getDrawingVerticalLine: (value) {
                                  return FlLine(
                                    color: FluentTheme.of(context).accentColor.withValues(alpha: .8).withValues(alpha: .2),
                                    strokeWidth: 1,
                                  );
                                },
                              ),
                              titlesData: FlTitlesData(
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      // Get day name for x-axis
                                      final List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                                      final int index = value.toInt();
                                      return index >= 0 && index < days.length 
                                        ? Padding(
                                            padding: const EdgeInsets.only(top: 8.0),
                                            child: Text(
                                              days[index],
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: FluentTheme.of(context).accentColor.withValues(alpha: .8),
                                              ),
                                            ),
                                          ) 
                                        : const Text('');
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
                                            color: FluentTheme.of(context).accentColor.withValues(alpha: .8),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                topTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                rightTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                              ),
                              borderData: FlBorderData(
                                show: true,
                                border: Border.all(color: FluentTheme.of(context).accentColor.withValues(alpha: .8).withValues(alpha: .2)),
                              ),
                              minX: 0,
                              maxX: 6,
                              minY: 0,
                              maxY: maxUsage + 20, // Added more padding at the top
                              lineBarsData: [
                                LineChartBarData(
                                  spots: dailyUsageSpots,
                                  isCurved: true,
                                  color: Colors.blue,
                                  barWidth: 4, // Thicker line
                                  isStrokeCapRound: true,
                                  dotData: FlDotData(
                                    show: true,
                                    getDotPainter: (spot, percent, barData, index) {
                                      return FlDotCirclePainter(
                                        radius: 5, // Larger dots
                                        color: Colors.blue,
                                        strokeWidth: 2,
                                        strokeColor: Colors.white,
                                      );
                                    },
                                  ),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    color: Colors.blue.withValues(alpha: .15), // Lighter gradient
                                    // gradientFrom: const Offset(0, 0),
                                    // gradientTo: const Offset(0, 1),
                                    // gradientColorStops: const [0.0, 1.0],
                                    spotsLine: BarAreaSpotsLine(
                                      show: true,
                                      flLineStyle: FlLine(
                                        color: Colors.blue.withValues(alpha: .5),
                                        strokeWidth: 1,
                                      ),
                                    ),
                                  ),
                                ),
                                // Add a line for the daily limit if set
                                if (appSummary.limitStatus && appSummary.dailyLimit > Duration.zero)
                                  LineChartBarData(
                                    spots: List.generate(7, (index) => 
                                      FlSpot(index.toDouble(), appSummary.dailyLimit.inMinutes.toDouble())),
                                    isCurved: false,
                                    color: Colors.red.withValues(alpha: .7),
                                    barWidth: 2,
                                    isStrokeCapRound: true,
                                    dotData: FlDotData(show: false),
                                    dashArray: [5, 5],
                                  ),
                              ],
                            ),
                          ),
                    ),
                    const SizedBox(height: 20), // Increased spacing
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatCard(
                          "Avg. Daily Usage",
                          "${avgDailyUsage.toStringAsFixed(1)}m",
                          FluentIcons.chart_series,
                          cardSize: 100, // Specified card size
                        ),
                        _buildStatCard(
                          "Peak Day",
                          maxUsage > 0 
                            ? "${maxUsage.toInt()}m" 
                            : "No data",
                          FluentIcons.chart_series,
                          cardSize: 100,
                        ),
                        _buildStatCard(
                          "Weekly Total",
                          _formatDuration(Duration(minutes: weeklyData
                              .map((day) => day['minutes'] as int)
                              .fold(0, (a, b) => a + b))),
                          FluentIcons.calendar_week,
                          cardSize: 100,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24), // Increased spacing between cards
              
              // Time of Day Distribution
              Card(
                padding: const EdgeInsets.all(20), // Increased padding
                borderRadius: BorderRadius.circular(12), // Rounded corners
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Usage Pattern by Time of Day", 
                      style: TextStyle(
                        fontWeight: FontWeight.bold, 
                        fontSize: 18,
                        letterSpacing: 0.4,
                      )),
                    const SizedBox(height: 24), // Increased spacing
                    SizedBox(
                      height: 300, // Increased height
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
                                    radius: 90, // Increased radius
                                    titleStyle: const TextStyle(
                                      fontSize: 16, // Larger text
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
                                sectionsSpace: 3, // Increased space between sections
                                pieTouchData: PieTouchData(
                                  touchCallback: (event, response) {
                                    // Optional touch interactions
                                  },
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 16.0), // Added padding for legend
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: timeOfDayUsage.entries.map((entry) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8), // Increased spacing
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 14, // Larger color indicator
                                          height: 14,
                                          decoration: BoxDecoration(
                                            color: _getTimeOfDayColor(entry.key),
                                            shape: BoxShape.rectangle,
                                            borderRadius: BorderRadius.circular(3),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withValues(alpha: .1),
                                                blurRadius: 1,
                                                offset: const Offset(0, 1),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 12), // Increased spacing
                                        Text(
                                          entry.key,
                                          style: const TextStyle(
                                            fontSize: 14, // Larger text
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
              
              const SizedBox(height: 24), // Increased spacing between cards
              
              // Usage Pattern Analysis
              Card(
                padding: const EdgeInsets.all(20), // Increased padding
                borderRadius: BorderRadius.circular(12), // Rounded corners
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Pattern Analysis", 
                      style: TextStyle(
                        fontWeight: FontWeight.bold, 
                        fontSize: 18,
                        letterSpacing: 0.4,
                      )),
                    const SizedBox(height: 20), // Increased spacing
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8), // Added padding around icon
                        decoration: BoxDecoration(
                          color: Colors.errorPrimaryColor.withValues(alpha: .1), // Added background color
                          borderRadius: BorderRadius.circular(8), // Rounded corners
                        ),
                        child: Icon(
                          FluentIcons.lightbulb, 
                          color: Colors.errorPrimaryColor,
                          size: 24, // Increased icon size
                        ),
                      ),
                      title: const Text("Usage Insights", 
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16, // Increased font size
                        )),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8.0, left: 4.0), // Added padding
                        child: Text(
                          _generateUsageInsights(appSummary, avgDailyUsage, timeOfDayUsage),
                          style: const TextStyle(
                            fontSize: 14, // Increased font size
                            height: 1.4, // Added line height for better readability
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12), // Added spacing between list tiles
                    if (appSummary.limitStatus)
                      ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8), // Added padding around icon
                          decoration: BoxDecoration(
                            color: _getLimitStatusColor(appSummary).withValues(alpha: .1), // Added background color
                            borderRadius: BorderRadius.circular(8), // Rounded corners
                          ),
                          child: Icon(
                            FluentIcons.timer, 
                            color: _getLimitStatusColor(appSummary),
                            size: 24, // Increased icon size
                          ),
                        ),
                        title: const Text("Limit Status", 
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16, // Increased font size
                          )),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8.0, left: 4.0), // Added padding
                          child: Text(
                            _generateLimitStatusInsight(appSummary),
                            style: const TextStyle(
                              fontSize: 14, // Increased font size
                              height: 1.4, // Added line height for better readability
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16), // Added bottom spacing
            ],
          ),
        ),
      ),
      actions: [
        // Button(
        //   onPressed: () {
        //     // Open settings for this app
        //     _openAppSettings(context, app);
        //   },
        //   style: ButtonStyle(
        //     padding: ButtonState.all(const EdgeInsets.symmetric(horizontal: 20, vertical: 12)), // Increased button padding
        //   ),
        //   child: const Text(
        //     'App Settings',
        //     style: TextStyle(
        //       fontSize: 14, // Increased font size
        //       fontWeight: FontWeight.w500,
        //     ),
        //   ),
        // ),
        const SizedBox(width: 12), // Added spacing between buttons
        FilledButton(
          style: ButtonStyle(
            padding: ButtonState.all(const EdgeInsets.symmetric(horizontal: 20, vertical: 12)), // Increased button padding
          ),
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Close',
            style: TextStyle(
              fontSize: 14, // Increased font size
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    ),
  );
}

// Helper widgets
Widget _buildSummaryItem(BuildContext context, String title, String value, 
    {IconData? icon, Color? color, double iconSize = 16}) {
  return Padding(
    padding: const EdgeInsets.all(8.0), // Added padding around items
    child: Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: iconSize, color: color ?? FluentTheme.of(context).accentColor),
              const SizedBox(width: 8), // Increased spacing
            ],
            Text(title, style: TextStyle(
              fontSize: 13, // Increased font size
              fontWeight: FontWeight.normal,
              color: FluentTheme.of(context).accentColor.withValues(alpha: .8), // Added color for better hierarchy
            )),
          ],
        ),
        const SizedBox(height: 8), // Increased spacing
        Text(
          value,
          style: TextStyle(
            fontSize: 18, // Increased font size
            fontWeight: FontWeight.bold,
            color: color,
            letterSpacing: 0.4, // Added letter spacing
          ),
        ),
      ],
    ),
  );
}

Widget _buildStatCard(String title, String value, IconData icon, {double cardSize = 80}) {
  return Card(
    padding: const EdgeInsets.all(16), // Increased padding
    borderRadius: BorderRadius.circular(8), // Rounded corners
    child: SizedBox(
      width: cardSize,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24), // Increased icon size
          const SizedBox(height: 10), // Increased spacing
          Text(
            title,
            style: TextStyle(
              fontSize: 13, // Increased font size
              color: FluentTheme.of(context).accentColor.withValues(alpha: .8), // Added color for better hierarchy
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8), // Increased spacing
          Text(
            value,
            style: const TextStyle(
              fontSize: 18, // Increased font size
              fontWeight: FontWeight.bold,
              letterSpacing: 0.4, // Added letter spacing
            ),
          ),
        ],
      ),
    ),
  );
}

// Keep the other helper functions as they are

  // Helper functions for data and colors
  List<Map<String, dynamic>> _getWeeklyUsageData(String appName) {
    // This would be retrieved from your data store
    // Mock data for demonstration:
    return [
      {'day': 'Mon', 'minutes': 45},
      {'day': 'Tue', 'minutes': 30},
      {'day': 'Wed', 'minutes': 60},
      {'day': 'Thu', 'minutes': 25},
      {'day': 'Fri', 'minutes': 50},
      {'day': 'Sat', 'minutes': 70},
      {'day': 'Sun', 'minutes': 40},
    ];
  }

  String _formatTrend(appSummaryData.UsageTrend trend) {
    switch (trend) {
      case appSummaryData.UsageTrend.increasing:
        return "Increasing";
      case appSummaryData.UsageTrend.decreasing:
        return "Decreasing";
      case appSummaryData.UsageTrend.stable:
        return "Stable";
      case appSummaryData.UsageTrend.noData:
        return "No Data";
    }
  }

  IconData _getTrendIcon(appSummaryData.UsageTrend trend) {
    switch (trend) {
      case appSummaryData.UsageTrend.increasing:
        return FluentIcons.up;
      case appSummaryData.UsageTrend.decreasing:
        return FluentIcons.down;
      case appSummaryData.UsageTrend.stable:
        return FluentIcons.horizontal_tab_key;
      case appSummaryData.UsageTrend.noData:
      default:
        return FluentIcons.unknown;
    }
  }

  Color _getTrendColor(appSummaryData.UsageTrend trend) {
    switch (trend) {
      case appSummaryData.UsageTrend.increasing:
        return Colors.red;
      case appSummaryData.UsageTrend.decreasing:
        return Colors.green;
      case appSummaryData.UsageTrend.stable:
        return Colors.blue;
      case appSummaryData.UsageTrend.noData:
      default:
        return FluentTheme.of(context).accentColor.withValues(alpha: .8);
    }
  }

  Color _getCategoryColor(String category) {
    // Map categories to colors
    final Map<String, Color> categoryColors = {
      'Social': Colors.purple,
      'Productivity': Colors.green,
      'Entertainment': Colors.orange,
      'Games': Colors.red,
      'Education': Colors.blue,
      'Utility': Colors.teal,
    };
    
    return categoryColors[category] ?? FluentTheme.of(context).accentColor.withValues(alpha: .8);
  }

  Color _getTimeOfDayColor(String timeOfDay) {
    final Map<String, Color> timeColors = {
      'Morning (6-12)': Colors.orange,
      'Afternoon (12-5)': Colors.yellow,
      'Evening (5-9)': Colors.purple,
      'Night (9-6)': Colors.teal,
    };
    
    return timeColors[timeOfDay] ?? FluentTheme.of(context).accentColor.withValues(alpha: .8);
  }

  Color _getLimitStatusColor(appSummaryData.AppUsageSummary app) {
    if (!app.limitStatus) return FluentTheme.of(context).accentColor.withValues(alpha: .8);
    if (app.isAboutToReachLimit) return Colors.orange;
    if (app.percentageOfLimitUsed >= 1.0) return Colors.red;
    if (app.percentageOfLimitUsed >= 0.75) return Colors.warningPrimaryColor;
    return Colors.green;
  }

  String _generateUsageInsights(appSummaryData.AppUsageSummary app, double avgDailyUsage, Map<String, double> timeOfDay) {
    final List<String> insights = [];
    
    // Determine primary usage time
    final String primaryTimeOfDay = timeOfDay.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
    
    insights.add("You primarily use ${app.appName} during $primaryTimeOfDay.");
    
    // Add trend insight
    switch (app.trend) {
      case appSummaryData.UsageTrend.increasing:
        insights.add("Your usage is trending upward compared to last week.");
        break;
      case appSummaryData.UsageTrend.decreasing:
        insights.add("Your usage is trending downward compared to last week.");
        break;
      case appSummaryData.UsageTrend.stable:
        insights.add("Your usage has been consistent over the past week.");
        break;
      default:
        break;
    }
    
    // Add productivity insight
    if (app.isProductive) {
      insights.add("This is marked as a productive app in your settings.");
    } else {
      insights.add("This is marked as a non-productive app in your settings.");
    }
    
    return insights.join(" ");
  }

  String _generateLimitStatusInsight(appSummaryData.AppUsageSummary app) {
    if (!app.limitStatus) {
      return "No usage limit has been set for this application.";
    }
    
    final double percentUsed = app.percentageOfLimitUsed;
    final String remainingTime = _formatDuration(app.dailyLimit - app.currentUsage);
    
    if (percentUsed >= 1.0) {
      return "You've reached your daily limit for this application.";
    } else if (app.isAboutToReachLimit) {
      return "You're about to reach your daily limit with only $remainingTime remaining.";
    } else if (percentUsed >= 0.75) {
      return "You've used ${(percentUsed * 100).toInt()}% of your daily limit with $remainingTime remaining.";
    } else {
      return "You have $remainingTime remaining out of your daily limit.";
    }
  }

  void _openAppSettings(BuildContext context, AppUsageSummary app) {
    // Implementation for opening app settings
    Navigator.pop(context); // Close the current dialog
    // Navigate to app settings page or show a settings dialog
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