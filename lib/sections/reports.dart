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
          _error = _analyticsController.error ?? 'Failed to initialize analytics';
          _isLoading = false;
        });
        return;
      }
      
      await _loadAnalyticsData();
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
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
        _error = 'Error loading analytics: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Header with period selector
            _buildHeader(),
            const SizedBox(height: 20),
            
            if (_isLoading)
              const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ProgressRing(),
                    SizedBox(height: 10),
                    Text('Loading analytics data...'),
                  ],
                ),
              )
            else if (_error != null)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(FluentIcons.error, size: 40, color: Colors.red),
                    const SizedBox(height: 10),
                    Text(_error!, style: TextStyle(color: Colors.red)),
                    const SizedBox(height: 20),
                    Button(
                      onPressed: _initializeAndLoadData,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            else if (_analyticsSummary != null)
              ..._buildAnalyticsContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Usage Analytics',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 6,
            child: Container(
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Daily Screen Time",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    height: 300,
                    child: LineChartWidget(
                      chartType: ChartType.main,
                      dailyScreenTimeData: summary.dailyScreenTimeData,
                      periodType: _selectedPeriod, // Pass the selected period to the chart
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            flex: 3,
            child: Container(
              constraints:const BoxConstraints(minHeight: 405),
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Category Breakdown",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  ReportsPieChart(
                    dataMap: summary.categoryBreakdown,
                    colorList: const [
                      Color.fromRGBO(223, 250, 92, 1),
                      Color.fromRGBO(129, 250, 112, 1),
                      Color.fromRGBO(129, 182, 205, 1),
                      Color.fromRGBO(91, 253, 199, 1),
                    ],
                  ),
                  const SizedBox(height: 1),
                ],
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 20),
      
      // App usage section
      Container(
        constraints: const BoxConstraints(minHeight: 100),
        width: MediaQuery.of(context).size.width * 1,
        decoration: BoxDecoration(
          color: FluentTheme.of(context).micaBackgroundColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: FluentTheme.of(context).inactiveBackgroundColor,
            width: 1,
          ),
        ),
        child: ApplicationUsage(appUsageDetails: summary.appUsageDetails),
      ),
    ];
  }
}

class TopBoxes extends StatelessWidget {
  final AnalyticsSummary analyticsSummary;

  const TopBoxes({Key? key, required this.analyticsSummary}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: _buildAnalyticsBox(
            context: context,
            title: "Total Screen Time",
            value: _formatDuration(analyticsSummary.totalScreenTime),
            percentChange: analyticsSummary.screenTimeComparisonPercent,
            icon: FluentIcons.screen_time,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildAnalyticsBox(
            context: context,
            title: "Productive Time",
            value: _formatDuration(analyticsSummary.productiveTime),
            percentChange: analyticsSummary.productiveTimeComparisonPercent,
            icon: FluentIcons.timer,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildAnalyticsBox(
            context: context,
            title: "Most Used App",
            value: analyticsSummary.mostUsedApp,
            subValue: _formatDuration(analyticsSummary.mostUsedAppTime),
            icon: FluentIcons.account_browser,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildAnalyticsBox(
            context: context,
            title: "Focus Sessions",
            value: analyticsSummary.focusSessionsCount.toString(),
            percentChange: analyticsSummary.focusSessionsComparisonPercent,
            icon: FluentIcons.red_eye,
          ),
        ),
      ],
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: FluentTheme.of(context).accentColor,
                ),
              ),
              Icon(icon, size: 24),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
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
            )
          else if (subValue != null)
            Text(
              subValue,
              style: TextStyle(
                fontSize: 12,
                color: FluentTheme.of(context).accentColor.withOpacity(0.8),
              ),
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

class Header extends StatelessWidget {
  const Header({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Reports",
          style: FluentTheme.of(context).typography.subtitle,
        ),
        // Row(
        //   children: [
        //     Button(
        //       style: ButtonStyle(padding: WidgetStateProperty.all(const EdgeInsets.only(top: 8,bottom: 8,left: 25,right: 25))),
        //       child: const Text('Start Focus Mode',style: TextStyle(fontWeight: FontWeight.w600),),
        //       onPressed: () => debugPrint('pressed button'),
        //     ),
        //     const SizedBox(width: 25,),
        //     Button(
        //       style: ButtonStyle(padding: WidgetStateProperty.all(const EdgeInsets.only(top: 8,bottom: 8,left: 25,right: 25))),
        //       child: const Text('Add Application',style: TextStyle(fontWeight: FontWeight.w600),),
        //       onPressed: () => debugPrint('pressed button'),
        //     ),
        //   ],
        // )
      ],
    );
  }
}

class ApplicationUsage extends StatelessWidget {
  final List<AppUsageSummary> appUsageDetails;

  const ApplicationUsage({
    super.key,
    required this.appUsageDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        minHeight: 200,
        maxHeight: 400,
      ),
      padding: const EdgeInsets.only(top: 15, bottom: 15, left: 20, right: 20),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: FluentTheme.of(context).micaBackgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Detailed Application Usage",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(width: 100, child: Text("Name", style: TextStyle(fontWeight: FontWeight.w600))),
                SizedBox(width: 100, child: Text("Category", style: TextStyle(fontWeight: FontWeight.w600))),
                SizedBox(width: 100, child: Text("Total Time", style: TextStyle(fontWeight: FontWeight.w600))),
                SizedBox(width: 100, child: Text("Productivity", style: TextStyle(fontWeight: FontWeight.w600))),
                SizedBox(width: 100, child: Text("More Details", style: TextStyle(fontWeight: FontWeight.w600))),
              ],
            ),
          ),
          Container(height: 1, color: FluentTheme.of(context).inactiveBackgroundColor),
          const SizedBox(height: 10),
          // Wrap List of Applications in Expanded and SingleChildScrollView
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: appUsageDetails.map((app) => Application(
                  name: app.appName,
                  category: app.category,
                  totalTime: _formatDuration(app.totalTime),
                  productivity: app.isProductive,
                )).toList(),
              ),
            ),
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

class Application extends StatelessWidget {
  final String name;
  final String category;
  final String totalTime;
  final bool productivity;

  const Application({
    super.key,
    required this.name,
    required this.category,
    required this.productivity,
    required this.totalTime,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(width: 100, height: 20, child: Text(name)),
              SizedBox(width: 100, height: 20, child: Text(category)),
              SizedBox(width: 100, height: 20, child: Text(totalTime)),
              SizedBox(width: 100, height: 20, child: Text(productivity ? "Productive" : "Non-Productive")),
              SizedBox(
                width: 100,
                child: SmallIconButton(
                  child: IconButton(
                    icon: Icon(
                      FluentIcons.view,
                      size: 20.0,
                      color: Colors.blue,
                    ),
                    onPressed: () => debugPrint('pressed button'),
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