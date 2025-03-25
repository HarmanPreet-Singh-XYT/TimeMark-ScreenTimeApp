import 'package:fluent_ui/fluent_ui.dart';
import 'package:percent_indicator/percent_indicator.dart';
import './controller/data_controllers/overview_data_controller.dart';

class Overview extends StatefulWidget {
  const Overview({super.key});

  @override
  State<Overview> createState() => _OverviewState();
}

class _OverviewState extends State<Overview> {
  // Top
  String totalScreenTime = "0h 0m";
  String totalProductiveTime = "0h 0m";
  String mostUsedApp = "None";
  String focusSessions = "0";
  
  // Middle
  List<dynamic> topApplications = [];
  List<dynamic> categoryApplications = [];
  
  // Bottom
  List<dynamic> applicationLimits = [];
  double screenTime = 0.0;
  double productiveScore = 0.0;
  
  // Add loading and error states
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = "";
  bool _hasData = false;
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  // Function to load data and update state
  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });
      
      // Create instance of DailyOverviewData
      final DailyOverviewData dataProvider = DailyOverviewData();
      
      // Fetch today's overview data
      final OverviewData overviewData = await dataProvider.fetchTodayOverview();
      
      // Update state with fetched data
      setState(() {
        // Top section
        totalScreenTime = overviewData.formattedTotalScreenTime;
        totalProductiveTime = overviewData.formattedProductiveTime;
        mostUsedApp = overviewData.mostUsedApp;
        focusSessions = overviewData.focusSessions.toString();
        
        // Progress indicators
        screenTime = overviewData.screenTimePercentage / 100;  // Convert percentage to value between 0-1
        productiveScore = overviewData.productivityScore / 100;  // Convert percentage to value between 0-1
        
        // Middle section - Top Applications
        topApplications = overviewData.topApplications.map((app) => {
          "name": app.name,
          "category": app.category,
          "screenTime": app.formattedScreenTime,
          "percentageOfTotalTime": app.percentageOfTotalTime
        }).toList();
        
        // Middle section - Category Applications
        categoryApplications = overviewData.categoryBreakdown.map((category) => {
          "name": category.name,
          "totalScreenTime": category.formattedTotalScreenTime,
          "percentageOfTotalTime": category.percentageOfTotalTime
        }).toList();
        
        // Bottom section - Application Limits
        applicationLimits = overviewData.applicationLimits.map((limit) => {
          "name": limit.name,
          "category": limit.category,
          "dailyLimit": limit.formattedDailyLimit,
          "actualUsage": limit.formattedActualUsage,
          "percentageOfLimit": limit.percentageOfLimit,
          "percentageOfTotalTime": limit.percentageOfTotalTime
        }).toList();
        
        _isLoading = false;
        
        // Check if we have any meaningful data
        _hasData = 
          topApplications.isNotEmpty || 
          categoryApplications.isNotEmpty || 
          applicationLimits.isNotEmpty ||
          int.parse(focusSessions) > 0;
      });
    } catch (e) {
      print('Error loading overview data: $e');
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Failed to load data: ${e.toString()}';
      });
    }
  }

  // Function to manually refresh data
  Future<void> refreshData() async {
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ProgressRing(),
            SizedBox(height: 16),
            Text("Loading your productivity data...")
          ],
        )
      );
    }
    
    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(FluentIcons.error, size: 48, color: Colors.warningPrimaryColor),
            const SizedBox(height: 16),
            Text(_errorMessage),
            const SizedBox(height: 16),
            Button(
              child: const Text('Try Again'),
              onPressed: refreshData,
            ),
          ],
        ),
      );
    }
    
    if (!_hasData) {
      return Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(FluentIcons.info, size: 48),
              const SizedBox(height: 16),
              const Text(
                "No activity data available yet",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                "Start using your applications to track screen time and productivity.",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Button(
                child: const Text('Refresh Data'),
                onPressed: refreshData,
              ),
            ],
          ),
        ),
      );
    }
    
    // Simple approach with a manual refresh button at the top
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Header(refresh: refreshData),
                  const SizedBox(height: 10),
                  TopBoxes(
                    totalProductiveTime: totalProductiveTime,
                    totalScreenTime: totalScreenTime,
                    mostUsedApp: mostUsedApp,
                    focusSessions: focusSessions,
                  ),
                  const SizedBox(height: 10),
                  MidSection(
                    topApplications: topApplications,
                    categoryApplications: categoryApplications,
                    isEmpty: topApplications.isEmpty && categoryApplications.isEmpty,
                  ),
                  const SizedBox(height: 10),
                  BottomSection(
                    screenTime: screenTime,
                    productiveScore: productiveScore,
                    applicationLimits: applicationLimits,
                    isEmpty: applicationLimits.isEmpty,
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class MidSection extends StatelessWidget {
  final List<dynamic> topApplications;
  final List<dynamic> categoryApplications;
  final bool isEmpty;
  
  const MidSection({
    super.key,
    required this.topApplications,
    required this.categoryApplications,
    this.isEmpty = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 30),
        decoration: BoxDecoration(
          color: FluentTheme.of(context).micaBackgroundColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: FluentTheme.of(context).inactiveBackgroundColor, width: 1)
        ),
        child: const Center(
          child: Text(
            "No application usage data available yet",
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 5,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            height: MediaQuery.of(context).size.height * 0.45,
            decoration: BoxDecoration(
              color: FluentTheme.of(context).micaBackgroundColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: FluentTheme.of(context).inactiveBackgroundColor, width: 1)
            ),
            child: TopApplications(
              data: topApplications,
              isEmpty: topApplications.isEmpty,
            ),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          flex: 5,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            height: MediaQuery.of(context).size.height * 0.45,
            decoration: BoxDecoration(
              color: FluentTheme.of(context).micaBackgroundColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: FluentTheme.of(context).inactiveBackgroundColor, width: 1)
            ),
            child: CategoryBreakdown(
              data: categoryApplications,
              isEmpty: categoryApplications.isEmpty,
            ),
          ),
        ),
      ],
    );
  }
}

class TopApplications extends StatelessWidget {
  final List<dynamic> data;
  final bool isEmpty;
  
  const TopApplications({
    super.key,
    required this.data,
    this.isEmpty = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Top Applications",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 20),
        if (isEmpty || data.isEmpty)
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(FluentIcons.app_icon_default, size: 32, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text(
                    "No application data available",
                    style: TextStyle(color: FluentTheme.of(context).inactiveColor),
                    textAlign: TextAlign.center,
                  )
                ],
              ),
            ),
          )
        else
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: (data
                        .where((app) => app['name'] != null && app['name'].toString().trim().isNotEmpty)
                        .toList() // Convert to list before sorting
                      ..sort((a, b) => (b['percentageOfTotalTime'] ?? 0).compareTo(a['percentageOfTotalTime'] ?? 0))) // Sort in descending order
                    .take(10) // Take the top 10
                    .map((app) => Column(
                          children: [
                            Application(
                              name: app['name'] ?? 'Unknown',
                              category: app['category'] ?? 'Uncategorized',
                              screenTime: app['screenTime'] ?? '0h 0m',
                              percentageOfTotalTime: (app['percentageOfTotalTime'] ?? 0).toDouble(),
                              barColor: const Color(0xff263A8A),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ))
                    .toList(),
              ),
            ),
          ),

      ],
    );
  }
}

class ApplicationLimits extends StatelessWidget {
  final List<dynamic> data;
  final bool isEmpty;
  
  const ApplicationLimits({
    super.key,
    required this.data,
    this.isEmpty = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Application Limits",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 20),
        if (isEmpty || data.isEmpty)
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(FluentIcons.timer, size: 32, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text(
                    "No application limits set",
                    style: TextStyle(color: FluentTheme.of(context).inactiveColor),
                    textAlign: TextAlign.center,
                  )
                ],
              ),
            ),
          )
        else
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: data
                    .where((app) => app['name'] != null && app['name'].toString().trim().isNotEmpty)
                    .map((app) => Column(
                          children: [
                            Application(
                              name: app['name'] ?? 'Unknown',
                              category: app['category'] ?? 'Uncategorized',
                              screenTime: app['dailyLimit'] ?? '0h 0m',
                              percentageOfTotalTime: (app['percentageOfTotalTime'] ?? 0).toDouble(),
                              barColor: const Color(0xff263A8A),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ))
                    .toList(),
              ),
            ),
          )
      ],
    );
  }
}

class CategoryBreakdown extends StatelessWidget {
  final List<dynamic> data;
  final bool isEmpty;
  
  const CategoryBreakdown({
    super.key,
    required this.data,
    this.isEmpty = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Category Breakdown",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 20),
        if (isEmpty || data.isEmpty)
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(FluentIcons.category_classification, size: 32, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text(
                    "No category data available",
                    style: TextStyle(color: FluentTheme.of(context).inactiveColor),
                    textAlign: TextAlign.center,
                  )
                ],
              ),
            ),
          )
        else
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: data
                    .where((category) => category['name'] != null && category['name'].toString().trim().isNotEmpty)
                    .map((category) => Column(
                      children: [
                        Category(
                          name: category['name'] ?? 'Uncategorized',
                          totalScreenTime: category['totalScreenTime'] ?? '0h 0m',
                          percentageOfTotalTime: (category['percentageOfTotalTime'] ?? 0).toDouble(),
                          barColor: const Color(0xff14532D),
                        ),
                        const SizedBox(height: 34),
                      ],
                    )).toList(),
              ),
            ),
          ),
      ],
    );
  }
}

class Application extends StatelessWidget {
  final String name;
  final String category;
  final String screenTime;
  final double percentageOfTotalTime;
  final Color barColor;

  const Application({
    super.key,
    required this.name,
    required this.category,
    required this.screenTime,
    required this.percentageOfTotalTime,
    required this.barColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                category,
                style: const TextStyle(fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Expanded(
          flex: 5,
          child: LinearPercentIndicator(
            animation: true,
            lineHeight: 25.0,
            animationDuration: 1500,
            percent: (percentageOfTotalTime/100).clamp(0.0, 1.0),
            barRadius: const Radius.circular(100),
            progressColor: barColor,
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            screenTime,
            style: const TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

class Category extends StatelessWidget {
  final String name;
  final String totalScreenTime;
  final double percentageOfTotalTime;
  final Color barColor;

  const Category({
    super.key,
    required this.name,
    required this.totalScreenTime,
    required this.percentageOfTotalTime,
    required this.barColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 3,
          child: Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Expanded(
          flex: 5,
          child: LinearPercentIndicator(
            animation: true,
            lineHeight: 25.0,
            animationDuration: 1500,
            percent: (percentageOfTotalTime/100).clamp(0.0, 1.0),
            barRadius: const Radius.circular(100),
            progressColor: barColor,
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            totalScreenTime,
            style: const TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

class BottomSection extends StatelessWidget {
  final List<dynamic> applicationLimits;
  final double screenTime;
  final double productiveScore;
  final bool isEmpty;
  
  const BottomSection({
    super.key,
    required this.applicationLimits,
    required this.screenTime,
    required this.productiveScore,
    this.isEmpty = false,
  });

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    // Use adaptive height based on screen size
    final double sectionHeight = screenSize.height * 0.24;
    final double circleSize = screenSize.width < 1200 
        ? screenSize.width * 0.05 
        : screenSize.width * 0.06;  // Adaptive sizing for circles
        
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 6,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            height: sectionHeight,
            decoration: BoxDecoration(
              color: FluentTheme.of(context).micaBackgroundColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: FluentTheme.of(context).inactiveBackgroundColor, width: 1)
            ),
            child: ApplicationLimits(
              data: applicationLimits,
              isEmpty: isEmpty || applicationLimits.isEmpty,
            ),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          flex: 2,
          child: Container(
            height: sectionHeight,
            decoration: BoxDecoration(
              color: FluentTheme.of(context).micaBackgroundColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: FluentTheme.of(context).inactiveBackgroundColor, width: 1)
            ),
            child: Center(
              child: CircularPercentIndicator(
                radius: circleSize,
                lineWidth: circleSize * 0.3,
                animation: true,
                percent: screenTime.clamp(0.0, 1.0),
                center: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Screen",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                    ),
                    Text(
                      "Time",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                    ),
                  ],
                ),
                circularStrokeCap: CircularStrokeCap.round,
                progressColor: Colors.purple,
              ),
            ),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          flex: 2,
          child: Container(
            height: sectionHeight,
            decoration: BoxDecoration(
              color: FluentTheme.of(context).micaBackgroundColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: FluentTheme.of(context).inactiveBackgroundColor, width: 1)
            ),
            child: Center(
              child: CircularPercentIndicator(
                radius: circleSize,
                lineWidth: circleSize * 0.3,
                animation: true,
                percent: productiveScore.clamp(0.0, 1.0),
                center: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Productive",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                    ),
                    Text(
                      "Score",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                    ),
                  ],
                ),
                circularStrokeCap: CircularStrokeCap.round,
                progressColor: Colors.purple,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class TopBoxes extends StatelessWidget {
  final String totalScreenTime;
  final String totalProductiveTime;
  final String mostUsedApp;
  final String focusSessions;
  
  const TopBoxes({
    super.key,
    required this.focusSessions,
    required this.mostUsedApp,
    required this.totalProductiveTime,
    required this.totalScreenTime
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Use a Column layout for narrow screens
        if (constraints.maxWidth < 800) {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(child: TopBox(
                    boxColor: const Color(0xff263A8A),
                    textColor: const Color(0xffBFDBFE),
                    textContent: totalScreenTime,
                    textHeading: "Total Screen Time"
                  )),
                  const SizedBox(width: 10),
                  Expanded(child: TopBox(
                    boxColor: const Color(0xff14532D),
                    textColor: const Color(0xffBBF7D0),
                    textContent: totalProductiveTime,
                    textHeading: "Productive Time"
                  )),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: TopBox(
                    boxColor: const Color(0xff581C87),
                    textColor: const Color(0xffE8D5FF),
                    textContent: mostUsedApp,
                    textHeading: "Most Used App"
                  )),
                  const SizedBox(width: 10),
                  Expanded(child: TopBox(
                    boxColor: const Color(0xff7C2D12),
                    textColor: const Color(0xffFED7AA),
                    textContent: focusSessions,
                    textHeading: "Focus Sessions"
                  )),
                ],
              ),
            ],
          );
        }
        
        // Use a Row layout for wider screens
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: TopBox(
              boxColor: const Color(0xff263A8A),
              textColor: const Color(0xffBFDBFE),
              textContent: totalScreenTime,
              textHeading: "Total Screen Time"
            )),
            const SizedBox(width: 10),
            Expanded(child: TopBox(
              boxColor: const Color(0xff14532D),
              textColor: const Color(0xffBBF7D0),
              textContent: totalProductiveTime,
              textHeading: "Productive Time"
            )),
            const SizedBox(width: 10),
            Expanded(child: TopBox(
              boxColor: const Color(0xff581C87),
              textColor: const Color(0xffE8D5FF),
              textContent: mostUsedApp,
              textHeading: "Most Used App"
            )),
            const SizedBox(width: 10),
            Expanded(child: TopBox(
              boxColor: const Color(0xff7C2D12),
              textColor: const Color(0xffFED7AA),
              textContent: focusSessions,
              textHeading: "Focus Sessions"
            )),
          ],
        );
      }
    );
  }
}

class TopBox extends StatelessWidget {
  final Color boxColor;
  final Color textColor;
  final String textHeading;
  final String textContent;
  
  const TopBox({
    super.key,
    required this.boxColor,
    required this.textColor,
    required this.textContent,
    required this.textHeading
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.15,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: boxColor,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            textHeading,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                textContent,
                style: TextStyle(
                  color: textColor,
                  fontSize: textHeading == 'Most Used App' 
                    ? (textContent.length > 15 ? 16 : 18) 
                    : 28,
                  fontWeight: FontWeight.w700
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: textHeading == 'Most Used App' ? 2 : 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Header extends StatelessWidget {
  final VoidCallback refresh;
  const Header({
    super.key,
    required this.refresh
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // For smaller screens, stack the elements vertically
        if (constraints.maxWidth < 640) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Today's Overview",
                style: FluentTheme.of(context).typography.subtitle,
              ),
              const SizedBox(height: 10),
              Button(
                style: ButtonStyle(
                  padding: WidgetStateProperty.all(
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12)
                  )
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(FluentIcons.red_eye, size: 20),
                    SizedBox(width: 10),
                    Text('Start Focus Mode', style: TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
                onPressed: () => debugPrint('pressed focus mode button'),
              ),
            ],
          );
        }
        
        // For larger screens, use the original row layout
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Today's Overview",
              style: FluentTheme.of(context).typography.subtitle,
            ),
            Row(
              children: [
                Button(
                  style: ButtonStyle(
                    padding: WidgetStateProperty.all(
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 12)
                    )
                  ),
                  child: const Row(
                    children: [
                      Icon(FluentIcons.refresh, size: 15),
                      SizedBox(width: 10),
                      Text('Refresh', style: TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                  onPressed: () => refresh(),
                ),
                const SizedBox(width: 20),
                Button(
                  style: ButtonStyle(
                    padding: WidgetStateProperty.all(
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 12)
                    )
                  ),
                  child: const Row(
                    children: [
                      Icon(FluentIcons.red_eye, size: 20),
                      SizedBox(width: 10),
                      Text('Start Focus Mode', style: TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                  onPressed: () => debugPrint('pressed focus mode button'),
                ),

              ],
            )
          ],
        );
      }
    );
  }
}