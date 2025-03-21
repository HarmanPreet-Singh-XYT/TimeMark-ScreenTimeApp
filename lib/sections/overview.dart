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
  String totalScreenTime = "8h 45m";
  String totalProductiveTime = "8h 45m";
  String mostUsedApp = "8h 45m";
  String focusSessions = "8h 45m";
  // Middle
  //[{"name":"VS Code","category":"Development","screenTime":"3h 15m","percentageOfTotalTime":90},{"name":"VS Code","category":"Development","screenTime":"3h 15m","percentageOfTotalTime":90}]
  List<dynamic> topApplications = [];
  //[{"name":"Development","totalScreenTime":"3h 15m","percentageOfTotalTime":90},{"name":"Development","totalScreenTime":"3h 15m","percentageOfTotalTime":90}]
  List<dynamic> categoryApplications = [];
  // Bottom
  //[{"name":"VS Code","category":"Development","dailyLimit":"3h 15m","percentageOfLimit":50,"percentageOfTotalTime":80},{"name":"VS Code","category":"Development","dailyLimit":"3h 15m","percentageOfLimit":50,"percentageOfTotalTime":80}]
  List<dynamic> applicationLimits = [];
  double screenTime = 0.5;
  double productiveScore = 0.4;
  
  // Add loading state
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  // Function to load data and update state
  Future<void> _loadData() async {
    try {
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
      });
    } catch (e) {
      print('Error loading overview data: $e');
      setState(() {
        _isLoading = false;
        // You could set some error state here if needed
      });
    }
  }

  // Function to manually refresh data
  Future<void> refreshData() async {
    setState(() {
      _isLoading = true;
    });
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading 
      ? const Center(child: ProgressRing())
      : SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Header(),
                const SizedBox(height: 10,),
                TopBoxes(
                  totalProductiveTime: totalProductiveTime,
                  totalScreenTime: totalScreenTime,
                  mostUsedApp: mostUsedApp,
                  focusSessions: focusSessions,
                ),
                const SizedBox(height: 10,),
                MidSection(
                  topApplications: topApplications,
                  categoryApplications: categoryApplications,
                ),
                const SizedBox(height: 10,),
                BottomSection(
                  screenTime: screenTime,
                  productiveScore: productiveScore,
                  applicationLimits: applicationLimits,
                )
              ],
            ),
          ),
        );
  }
}

class MidSection extends StatelessWidget {
  final List<dynamic> topApplications;
  final List<dynamic> categoryApplications;
  const MidSection({
    super.key,
    required this.topApplications,
    required this.categoryApplications
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 5,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 15),
            height: MediaQuery.of(context).size.height * 0.45,
            width: MediaQuery.of(context).size.width * 0.35,
            decoration: BoxDecoration(
              color: FluentTheme.of(context).micaBackgroundColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: FluentTheme.of(context).inactiveBackgroundColor,width: 1)
            ),
            child:TopApplications(data:topApplications),
          ),
        ),
        const SizedBox(width: 15,),
        Expanded(
          flex: 5,
          child: Container(
            padding:const EdgeInsets.symmetric(horizontal: 20,vertical: 15),
            height: MediaQuery.of(context).size.height * 0.45,
            width: MediaQuery.of(context).size.width * 0.35,
            decoration: BoxDecoration(
              color: FluentTheme.of(context).micaBackgroundColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: FluentTheme.of(context).inactiveBackgroundColor,width: 1)
            ),
            child:CategoryBreakdown(data: categoryApplications,),
          ),
        ),
      ],
    );
  }
}

class TopApplications extends StatelessWidget {
  final List<dynamic> data;
  const TopApplications({
    super.key,
    required this.data,
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
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: data.map((app) => Column(
                children: [
                  Application(
                    name: app['name'],
                    category: app['category'],
                    screenTime: app['screenTime'],
                    percentageOfTotalTime: app['percentageOfTotalTime'],
                    barColor: const Color(0xff263A8A), // Customize color if needed
                  ),
                  const SizedBox(height: 20),
                ],
              )).toList(),
            ),
          ),
        ),
      ],
    );
  }
}


class ApplicationLimits extends StatelessWidget {
  final List<dynamic> data;
  const ApplicationLimits({
    super.key,
    required this.data
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
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: data.map((app) => Column(
                children: [
                  Application(
                    name: app['name'],
                    category: app['category'],
                    screenTime: app['dailyLimit'],
                    percentageOfTotalTime: app['percentageOfTotalTime'],
                    barColor: const Color(0xff263A8A), // Customize color if needed
                  ),
                  const SizedBox(height: 20),
                ],
              )).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class CategoryBreakdown extends StatelessWidget {
  final List<dynamic> data;
  const CategoryBreakdown({
    super.key,
    required this.data,
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
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: data.map((category) => Column(
                children: [
                  Category(
                    name: category['name'],
                    totalScreenTime: category['totalScreenTime'],
                    percentageOfTotalTime: category['percentageOfTotalTime'],
                    barColor: const Color(0xff14532D), // Customize color if needed
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
        SizedBox(
          width: 100,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name,style:const TextStyle(fontWeight: FontWeight.w600),),
              Text(category,style:const TextStyle(fontSize: 14),),
            ],
          ),
        ),
        LinearPercentIndicator(
          width: MediaQuery.of(context).size.width * 0.2,
          animation: true,
          lineHeight: 25.0,
          animationDuration: 2000,
          percent: (percentageOfTotalTime/100),
          barRadius:const Radius.circular(100),
          progressColor: barColor,
        ),
        SizedBox(width:60,child: Text(screenTime,style:const TextStyle(fontWeight: FontWeight.bold),)),
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
        SizedBox(
          width: 100,
          child: Text(name,style:const TextStyle(fontWeight: FontWeight.w600),),
        ),
        LinearPercentIndicator(
          width: MediaQuery.of(context).size.width * 0.18,
          animation: true,
          lineHeight: 25.0,
          animationDuration: 2000,
          percent: percentageOfTotalTime/100,
          barRadius:const Radius.circular(100),
          progressColor: barColor,
        ),
        SizedBox(width:60,child: Text(totalScreenTime,style: TextStyle(fontWeight: FontWeight.bold),)),
      ],
    );
  }
}

class BottomSection extends StatelessWidget {
  final List<dynamic> applicationLimits;
  final double screenTime;
  final double productiveScore;
  const BottomSection({
    super.key,
    required this.applicationLimits,
    required this.screenTime,
    required this.productiveScore
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 6,
          child: Container(
            padding:const EdgeInsets.symmetric(horizontal: 20,vertical: 15),
            height: MediaQuery.of(context).size.height * 0.24,
            width: MediaQuery.of(context).size.width * 0.38,
            decoration: BoxDecoration(
              color: FluentTheme.of(context).micaBackgroundColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: FluentTheme.of(context).inactiveBackgroundColor,width: 1)
            ),
            child:ApplicationLimits(data: applicationLimits,),
          ),
        ),
        const SizedBox(width: 20,),
        Expanded(
          flex: 2,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.24,
            width: MediaQuery.of(context).size.width * 0.15,
            decoration: BoxDecoration(
              color: FluentTheme.of(context).micaBackgroundColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: FluentTheme.of(context).inactiveBackgroundColor,width: 1)
            ),
            child: Center(
              child:CircularPercentIndicator(
              radius: 70.0,
              lineWidth: 22.0,
              animation: true,
              percent: screenTime/100,
              center:const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                 Text(
                    "Screen",
                    style:
                       TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                  ),
                 Text(
                    "Time",
                    style:
                       TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                  ),
                ],
              ),
              circularStrokeCap: CircularStrokeCap.round,
              progressColor: Colors.purple,
                        ),
            ),
          ),
        ),
        const SizedBox(width: 20,),
        Expanded(
          flex: 2,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.24,
            width: MediaQuery.of(context).size.width * 0.15,
            decoration: BoxDecoration(
              color: FluentTheme.of(context).micaBackgroundColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: FluentTheme.of(context).inactiveBackgroundColor,width: 1)
            ),
            child: Center(
              child:CircularPercentIndicator(
              radius: 70.0,
              lineWidth: 22.0,
              animation: true,
              percent: productiveScore,
              center:const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                 Text(
                    "Productive",
                    style:
                       TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                  ),
                 Text(
                    "Score",
                    style:
                       TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TopBox(boxColor:const Color(0xff263A8A),textColor:const Color(0xffBFDBFE),textContent: totalScreenTime, textHeading: "Total Screen Time"),
        const SizedBox(width: 10,),
        TopBox(boxColor:const Color(0xff14532D),textColor:const Color(0xffBBF7D0),textContent: totalProductiveTime, textHeading: "Productive Time"),
        const SizedBox(width: 10,),
        TopBox(boxColor:const Color(0xff581C87),textColor:const Color(0xffE8D5FF),textContent: mostUsedApp, textHeading: "Most Used App"),
        const SizedBox(width: 10,),
        TopBox(boxColor:const Color(0xff7C2D12),textColor:const Color(0xffFED7AA),textContent: focusSessions, textHeading: "Focus Sessions"),
      ],
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
    return Expanded(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.15,
        padding:const EdgeInsets.only(left: 20,right: 20, top: 18, bottom: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color:boxColor,
        ),
        child:Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(textHeading,style:const TextStyle(color:Colors.white,fontSize: 14,fontWeight: FontWeight.w600),),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: 225,  // Set your desired width
                  child: Text(
                    textContent,
                    style: TextStyle(
                      color: textColor,
                      fontSize: textHeading != 'Most Used App' ? 28 : 18,
                      fontWeight: FontWeight.w700
                    ),
                    overflow: TextOverflow.visible,  // Change from ellipsis to visible
                    softWrap: true,  // Enable text wrapping
                    maxLines: null,  // Allow unlimited lines
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
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
        Text("Today's Overview",style: FluentTheme.of(context).typography.subtitle,),
        Row(
          children: [
            Button(
              style: ButtonStyle(padding: WidgetStateProperty.all(const EdgeInsets.only(top: 8,bottom: 8,left: 12,right: 12))),
              child:const Row(
                children: [
                  Icon(FluentIcons.red_eye,size: 20,),
                  SizedBox(width: 10,),
                  Text('Start Focus Mode',style: TextStyle(fontWeight: FontWeight.w600),),
                ],
              ),
              onPressed: () => debugPrint('pressed button'),
            ),
            // const SizedBox(width: 25,),
            // Button(
            //   style: ButtonStyle(padding: WidgetStateProperty.all(const EdgeInsets.only(top: 8,bottom: 8,left: 14,right: 14))),
            //   child:const Row(
            //     children: [
            //       Icon(FluentIcons.app_icon_default_list,size: 18,),
            //       SizedBox(width: 10,),
            //       Text('Add Application',style: TextStyle(fontWeight: FontWeight.w600),),
            //     ],
            //   ),
            //   onPressed: () => debugPrint('pressed button'),
            // ),
          ],
        )
      ],
    );
  }
}