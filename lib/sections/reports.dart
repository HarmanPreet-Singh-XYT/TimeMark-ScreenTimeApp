import 'package:fluent_ui/fluent_ui.dart';
import 'package:screentime/sections/graphs/reports_line_chart.dart';
import 'package:screentime/sections/graphs/reports_pie_chart.dart';
import './controller/data_controllers/reports_controller.dart';
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
    return CardContainer(
      title: "Category Breakdown",
      child: ReportsPieChart(
        dataMap: summary.categoryBreakdown,
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
    showDialog(
      context: context,
      builder: (context) => ContentDialog(
        title: Text(app.appName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Category: ${app.category}"),
            Text("Usage: ${_formatDuration(app.totalTime)}"),
            Text("Productivity: ${app.isProductive ? 'Productive' : 'Non-Productive'}"),
            // Add more detailed stats here
          ],
        ),
        actions: [
          Button(
            child: const Text('Close'),
            onPressed: () => Navigator.pop(context),
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