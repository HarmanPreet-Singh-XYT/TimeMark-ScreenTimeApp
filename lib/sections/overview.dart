import 'package:fluent_ui/fluent_ui.dart';
import 'package:percent_indicator/percent_indicator.dart';
class Overview extends StatefulWidget {
  const Overview({super.key});

  @override
  State<Overview> createState() => _OverviewState();
}

class _OverviewState extends State<Overview> {
  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
        child: Padding(
          padding:EdgeInsets.only(left: 20,right: 20,bottom: 20,top: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Header(),
              SizedBox(height: 10,),
              TopBoxes(),
              SizedBox(height: 10,),
              MidSection(),
              SizedBox(height: 10,),
              BottomSection()
            ],
          ),
        ),
      );
  }
}

class MidSection extends StatelessWidget {
  const MidSection({
    super.key,
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
            child:const TopApplications(),
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
            child:const CategoryBreakdown(),
          ),
        ),
      ],
    );
  }
}

class TopApplications extends StatelessWidget {
  const TopApplications({
    super.key,
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
              children: List.generate(
                5,
                (index) => const Column(
                  children: [
                     Application(barColor: Color(0xff263A8A),),
                     SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ApplicationLimits extends StatelessWidget {
  const ApplicationLimits({
    super.key,
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
              children: List.generate(
                5,
                (index) => const Column(
                  children: [
                     Application(barColor: Color(0xffEA4435),),
                     SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class CategoryBreakdown extends StatelessWidget {
  const CategoryBreakdown({
    super.key,
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
              children: List.generate(
                5,
                (index) => const Column(
                  children: [
                     Category(barColor: Color(0xff14532D),),
                     SizedBox(height: 34),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class Application extends StatelessWidget {
  final Color barColor;
  const Application({
    super.key,
    required this.barColor
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(
          width: 100,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("VS Code",style: TextStyle(fontWeight: FontWeight.w600),),
              Text("Development",style: TextStyle(fontSize: 14),),
            ],
          ),
        ),
        LinearPercentIndicator(
          width: MediaQuery.of(context).size.width * 0.18,
          animation: true,
          lineHeight: 25.0,
          animationDuration: 2000,
          percent: 0.9,
          barRadius:const Radius.circular(100),
          progressColor: barColor,
        ),
        const SizedBox(width:60,child: Text("3h 15m",style: TextStyle(fontWeight: FontWeight.bold),)),
      ],
    );
  }
}
class Category extends StatelessWidget {
  final Color barColor;
  const Category({
    super.key,
    required this.barColor
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(
          width: 100,
          child: Text("Development",style: TextStyle(fontWeight: FontWeight.w600),),
        ),
        LinearPercentIndicator(
          width: MediaQuery.of(context).size.width * 0.18,
          animation: true,
          lineHeight: 25.0,
          animationDuration: 2000,
          percent: 0.9,
          barRadius:const Radius.circular(100),
          progressColor: barColor,
        ),
        const SizedBox(width:60,child: Text("3h 15m",style: TextStyle(fontWeight: FontWeight.bold),)),
      ],
    );
  }
}

class BottomSection extends StatelessWidget {
  const BottomSection({
    super.key,
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
            child:const ApplicationLimits(),
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
              percent: 0.7,
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
              percent: 0.7,
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
  const TopBoxes({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TopBox(boxColor: Color(0xff263A8A),textColor: Color(0xffBFDBFE),textContent: "8h 45m", textHeading: "Total Screen Time"),
        TopBox(boxColor: Color(0xff14532D),textColor: Color(0xffBBF7D0),textContent: "8h 45m", textHeading: "Productive Time"),
        TopBox(boxColor: Color(0xff581C87),textColor: Color(0xffE8D5FF),textContent: "8h 45m", textHeading: "Most Used App"),
        TopBox(boxColor: Color(0xff7C2D12),textColor: Color(0xffFED7AA),textContent: "8h 45m", textHeading: "Focus Sessions"),
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
    return Container(
      height: MediaQuery.of(context).size.height * 0.15,
      width: MediaQuery.of(context).size.width * 0.14,
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
              Text(textContent,style: TextStyle(color: textColor,fontSize: 28,fontWeight: FontWeight.w700),),
            ],
          ),
        ],
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