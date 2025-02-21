import 'package:fluent_ui/fluent_ui.dart';
class Reports extends StatefulWidget {
  const Reports({super.key});

  @override
  State<Reports> createState() => _ReportsState();
}

class _ReportsState extends State<Reports> {
  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      content: SingleChildScrollView(
        child: Padding(
          padding:const EdgeInsets.only(left: 20,right: 20,bottom: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Header(),
              const SizedBox(height: 20,),
              const TopBoxes(),
              const SizedBox(height: 20,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 6,
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.45,
                      decoration: BoxDecoration(
                        color: FluentTheme.of(context).micaBackgroundColor,
                        borderRadius: BorderRadius.circular(10)
                      ),
                    ),
                  ),
                  const SizedBox(width: 20,),
                  Expanded(
                    flex: 3,
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.45,
                      decoration: BoxDecoration(
                        color: FluentTheme.of(context).micaBackgroundColor,
                        borderRadius: BorderRadius.circular(10)
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20,),
              Container(
                constraints:const BoxConstraints(minHeight: 100),
                width: MediaQuery.of(context).size.width * 1,
                decoration: BoxDecoration(
                  color: FluentTheme.of(context).micaBackgroundColor,
                  borderRadius: BorderRadius.circular(10)
                ),
                child:const ApplicationUsage(),
              )
            ],
          ),
        ),
      ),
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
        TopBox(boxColor: Color(0xff263A8A),textColor: Color(0xffBFDBFE),textContent: "8h 45m", textHeading: "Total Screen Time",summary: "+12% vs last week",),
        TopBox(boxColor: Color(0xff14532D),textColor: Color(0xffBBF7D0),textContent: "8h 45m", textHeading: "Productive Time",summary: "+12% vs last week"),
        TopBox(boxColor: Color(0xff581C87),textColor: Color(0xffE8D5FF),textContent: "8h 45m", textHeading: "Most Used App",summary: "3h 15m total usage", isDark: true,),
        TopBox(boxColor: Color(0xff7C2D12),textColor: Color(0xffFED7AA),textContent: "8h 45m", textHeading: "Focus Sessions",summary: "+12% vs last week"),
      ],
    );
  }
}

class TopBox extends StatelessWidget {
  final Color boxColor;
  final Color textColor;
  final String textHeading;
  final String textContent;
  final bool isDark;
  final String summary;
  const TopBox({
    super.key,
    required this.boxColor,
    required this.textColor,
    required this.textContent,
    required this.textHeading,
    this.isDark = false,
    required this.summary
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.18,
      width: MediaQuery.of(context).size.width * 0.15,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(summary,style:TextStyle(color:isDark ? const Color(0xff767676) : const Color(0xff379777),fontSize: 14,fontWeight: FontWeight.w600),),
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
        Text("Reports",style: FluentTheme.of(context).typography.subtitle,),
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
  const ApplicationUsage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints:const BoxConstraints(
        minHeight: 200,
        maxHeight: 400
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
          Container(height: 1, color: FluentTheme.of(context).inactiveColor),
          const SizedBox(height: 10),
          // Wrap List of Applications in Expanded and SingleChildScrollView
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: List.generate(
                  5,
                  (index) => const Application(
                    name: "Twitter",
                    category: "Social Media",
                    totalTime: "4h",
                    productivity: true,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
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
          padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(width: 100,height: 20,child: Text(name)),
              SizedBox(width: 100,height: 20,child: Text(category)),
              SizedBox(width: 100,height: 20,child: Text(totalTime)),
              SizedBox(width: 100,height: 20,child: Text(productivity ? "Productive" : "Non-Productive")),
              SizedBox(width: 100,
              child: SmallIconButton(child: 
                IconButton(
                  icon:Icon(FluentIcons.view, size: 20.0,color: Colors.blue,),
                  onPressed: () => debugPrint('pressed button'),
                ),
              ),),
            ],
          ),
        ),
        Container(height: 1, color: FluentTheme.of(context).inactiveColor),
      ],
    );
  }
}