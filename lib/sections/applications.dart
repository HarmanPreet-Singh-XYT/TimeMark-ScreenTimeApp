import 'package:fluent_ui/fluent_ui.dart';

class Applications extends StatefulWidget {
  const Applications({super.key});

  @override
  State<Applications> createState() => _ApplicationsState();
}

class _ApplicationsState extends State<Applications> {
  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      content: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Header(),
              const SizedBox(height: 20),
              Container(
                height: 60,
                padding:const EdgeInsets.only(left: 20,right: 20),
                width: MediaQuery.of(context).size.width * 1,
                decoration: BoxDecoration(
                  color: FluentTheme.of(context).micaBackgroundColor,
                  borderRadius: BorderRadius.circular(10)
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                  Row(
                    children: [
                      ToggleSwitch(
                        checked: true,
                        onChanged: (v) => setState(() => print(v)),
                      ),
                      const SizedBox(width: 10,),
                      const Text("Tracking",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w600),),
                      const SizedBox(width: 40,),
                      ToggleSwitch(
                        checked: true,
                        onChanged: (v) => setState(() => print(v)),
                      ),
                      const SizedBox(width: 10,),
                      const Text("Hidden/Visible",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w600),),
                    ]
                  ),
                  DropDownButton(
                    title:const Text('Email'),
                    items: [
                      MenuFlyoutItem(text: const Text('Send'), onPressed: () {}),
                    ],
                  )
                ],),
              ),
              const SizedBox(height: 20),
              Container(
                padding:const EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                height: MediaQuery.of(context).size.height * 0.72,
                width: MediaQuery.of(context).size.width * 1,
                decoration: BoxDecoration(
                  color: FluentTheme.of(context).micaBackgroundColor,
                  borderRadius: BorderRadius.circular(10)
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: 45,
                      child: Row(
                        children: [
                          const Expanded(
                            flex: 2,
                            child: Center(
                              child: Text("Name",style: TextStyle(fontSize: 14,fontWeight: FontWeight.w600))
                          )),
                          Container(width: 2,color: FluentTheme.of(context).inactiveColor),
                          const Expanded(
                            flex: 1,
                            child: Center(
                              child: Text("Category",style: TextStyle(fontSize: 14,fontWeight: FontWeight.w600))
                          )),
                          Container(width: 2,color: FluentTheme.of(context).inactiveColor),
                          const Expanded(
                            flex: 1,
                            child: Center(
                              child: Text("Screen Time",style: TextStyle(fontSize: 14,fontWeight: FontWeight.w600))
                          )),
                          Container(width: 2,color: FluentTheme.of(context).inactiveColor),
                          const Expanded(
                            flex: 1,
                            child: Center(
                              child: Text("Tracking",style: TextStyle(fontSize: 14,fontWeight: FontWeight.w600))
                          )),
                          Container(width: 2,color: FluentTheme.of(context).inactiveColor),
                          const Expanded(
                            flex: 1,
                            child: Center(
                              child: Text("Hidden/Visible",style: TextStyle(fontSize: 14,fontWeight: FontWeight.w600))
                          )),
                          Container(width: 2,color: FluentTheme.of(context).inactiveColor),
                          const Expanded(
                            flex: 1,
                            child: Center(
                              child: Text("Show Details",style: TextStyle(fontSize: 14,fontWeight: FontWeight.w600))
                          )),
                        ],
                      ),
                    ),
                    Container(width: MediaQuery.of(context).size.width * 1,height: 1,color: FluentTheme.of(context).inactiveColor),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: List.generate(
                            15,
                            (index) => const Application(name: "Google Chrome",category: "Browser",screenTime: "1h 20m",tracking: true,isHidden: false),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Application extends StatelessWidget {
  final String name;
  final String category;
  final String screenTime;
  final bool tracking;
  final bool isHidden;
  const Application({
    super.key,
    required this.name,
    required this.category,
    required this.screenTime,
    required this.tracking,
    required this.isHidden
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(width: MediaQuery.of(context).size.width * 1,height: 1,color: FluentTheme.of(context).inactiveColor),
        SizedBox(
          height: 45,
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Center(
                  child: Text(name,style:const TextStyle(fontSize: 14))
              )),
              Container(width: 1,color: FluentTheme.of(context).inactiveColor),
              Expanded(
                flex: 1,
                child: Center(
                  child: Text(category,style:const TextStyle(fontSize: 14))
              )),
              Container(width: 1,color: FluentTheme.of(context).inactiveColor),
              Expanded(
                flex: 1,
                child: Center(
                  child: Text(screenTime,style:const TextStyle(fontSize: 14))
              )),
              Container(width: 1,color: FluentTheme.of(context).inactiveColor),
              Expanded(
                flex: 1,
                child: Center(
                  child: ToggleSwitch(checked: tracking, onChanged: (v)=>{print(v)})
              )),
              Container(width: 1,color: FluentTheme.of(context).inactiveColor),
              Expanded(
                flex: 1,
                child: Center(
                  child: ToggleSwitch(checked: isHidden, onChanged: (v)=>{print(v)})
              )),
              Container(width: 1,color: FluentTheme.of(context).inactiveColor),
              Expanded(
                flex: 1,
                child: Center(
                  child: SmallIconButton(
                    child: IconButton(
                      icon: Icon(FluentIcons.line_chart, size: 20.0,color: Colors.blue,),
                      onPressed: () => debugPrint('pressed button'),
                    ),
                  )
              )),
            ],
          ),
        ),
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
        Text("Applications",style: FluentTheme.of(context).typography.subtitle,),
        Row(
          children: [
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                borderRadius:const BorderRadius.only(topLeft: Radius.circular(100),bottomLeft: Radius.circular(100)),
                color: FluentTheme.of(context).micaBackgroundColor
              ),
              child:const Icon(FluentIcons.search, color: Colors.white,
              )),
            Container(
              width: 280,
              height: 40,
              margin:const EdgeInsets.only(right: 10),
              child:const TextBox(
                placeholder: 'Search Application',
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(topRight: Radius.circular(100),bottomRight: Radius.circular(100)),
                ),
                style: TextStyle(
                  color: Color(0xFF5178BE),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}