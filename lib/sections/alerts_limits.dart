import 'package:fluent_ui/fluent_ui.dart';
class AlertsLimits extends StatefulWidget {
  const AlertsLimits({super.key});

  @override
  State<AlertsLimits> createState() => _AlertsLimitsState();
}

class _AlertsLimitsState extends State<AlertsLimits> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20,top: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Header(),
              const SizedBox(height: 20),
              Container(
                height: 100,
                width: MediaQuery.of(context).size.width * 1,
                padding:const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: FluentTheme.of(context).micaBackgroundColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: FluentTheme.of(context).inactiveBackgroundColor,width: 1)
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Notifications Settings",style: TextStyle(fontSize: 18,fontWeight: FontWeight.w600),),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            ToggleSwitch(
                              checked: true,
                              onChanged: (v) => setState(() => print(v)),
                            ),
                            const SizedBox(width: 15,),
                            const Text("Tracking",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w600),),
                          ],
                        ),
                        Row(
                          children: [
                            ToggleSwitch(
                              checked: true,
                              onChanged: (v) => setState(() => print(v)),
                            ),
                            const SizedBox(width: 15,),
                            const Text("Tracking",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w600),),
                          ],
                        ),
                        Row(
                          children: [
                            ToggleSwitch(
                              checked: true,
                              onChanged: (v) => setState(() => print(v)),
                            ),
                            const SizedBox(width: 15,),
                            const Text("Tracking",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w600),),
                          ],
                        ),
                        Row(
                          children: [
                            ToggleSwitch(
                              checked: true,
                              onChanged: (v) => setState(() => print(v)),
                            ),
                            const SizedBox(width: 15,),
                            const Text("Tracking",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w600),),
                          ],
                        ),
                      ],
                    )
                  ]
                ),
              ),
              const SizedBox(height: 20),
              const ApplicationLimits(),
              const SizedBox(height: 20),
              Container(
                height: 300,
                padding:const EdgeInsets.only(top: 15,bottom: 15,left: 20,right: 20),
                width: MediaQuery.of(context).size.width * 1,
                decoration: BoxDecoration(
                  color: FluentTheme.of(context).micaBackgroundColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: FluentTheme.of(context).inactiveBackgroundColor,width: 1)
                ),
                child:const Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Usage Trends",style: TextStyle(fontSize: 18,fontWeight: FontWeight.w600),),
                    
                  ]
                ),
              ),
              const SizedBox(height: 20)
            ],
          ),
        ),
      );
  }
}

class ApplicationLimits extends StatelessWidget {
  const ApplicationLimits({super.key});

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
        border: Border.all(color: FluentTheme.of(context).inactiveBackgroundColor,width: 1)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Application Limits",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(width: 120, child: Text("Name", style: TextStyle(fontWeight: FontWeight.w600))),
                SizedBox(width: 120, child: Text("Category", style: TextStyle(fontWeight: FontWeight.w600))),
                SizedBox(width: 72, child: Text("Daily Limit", style: TextStyle(fontWeight: FontWeight.w600))),
                SizedBox(width: 100, child: Text("Current Usage", style: TextStyle(fontWeight: FontWeight.w600))),
                SizedBox(width: 55, child: Text("Status", style: TextStyle(fontWeight: FontWeight.w600))),
                SizedBox(width: 85, child: Text("Actions", style: TextStyle(fontWeight: FontWeight.w600))),
              ],
            ),
          ),
          Container(height: 1, color: FluentTheme.of(context).inactiveBackgroundColor),
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
                    dailyLimit: "4h",
                    currentUsage: "2h",
                    status: "Active",
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
  final String dailyLimit;
  final String currentUsage;
  final String status;
  const Application({
    super.key,
    required this.name,
    required this.category,
    required this.currentUsage,
    required this.dailyLimit,
    required this.status
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
              SizedBox(width: 120,height: 20,child: Text(name)),
              SizedBox(width: 120,height: 20,child: Text(category)),
              SizedBox(width: 72,height: 20,child: Text(dailyLimit)),
              SizedBox(width: 100,height: 20,child: Text(currentUsage)),
              SizedBox(width: 55,height: 20,child: Text(status)),
              SizedBox(width: 85,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SmallIconButton(
                    child: IconButton(
                      icon:const Icon(FluentIcons.edit_solid12, size: 20.0,color: Color(0xff6B5CF5),),
                      onPressed: () => debugPrint('pressed button'),
                    ),
                  ),
                  SmallIconButton(
                    child: IconButton(
                      icon: Icon(FluentIcons.status_circle_error_x, size: 20.0,color: Colors.red,),
                      onPressed: () => debugPrint('pressed button'),
                    ),
                  ),
                ],
                )
              ,),
            ],
          ),
        ),
        Container(height: 1, color: FluentTheme.of(context).inactiveBackgroundColor),
      ],
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
        Text("Alerts & Limits",style: FluentTheme.of(context).typography.subtitle,),
        Row(
          children: [
            Button(
              style: ButtonStyle(padding: WidgetStateProperty.all(const EdgeInsets.only(top: 8,bottom: 8,left: 20,right: 20))),
              child:const Row(
                children: [
                  Icon(FluentIcons.sync,size: 16,),
                  SizedBox(width: 10,),
                  Text('Reset All',style: TextStyle(fontWeight: FontWeight.w600),),
                ],
              ),
              onPressed: () => debugPrint('pressed button'),
            ),
          ],
        )
      ],
    );
  }
}