import 'package:fluent_ui/fluent_ui.dart';
import 'package:screentime/sections/controller/app_data_controller.dart';
import 'controller/settings_data_controller.dart';
import './controller/data_controllers/applications_data_controller.dart';
import './controller/categories_controller.dart';
import 'dart:async';
class Applications extends StatefulWidget {
  const Applications({super.key});

  @override
  State<Applications> createState() => _ApplicationsState();
}

class _ApplicationsState extends State<Applications> {
  SettingsManager settingsManager = SettingsManager();
  bool isTracking = false;
  bool isHidden = false;
  // {"name":"Google Chrome","category":"Browser","screenTime":"3h 15m","isTracking":true,"isHidden":false}
  List<dynamic> apps = [];
  String selectedCategory = "All";
  String searchValue = '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    isTracking = settingsManager.getSetting("applications.tracking");
    isHidden = settingsManager.getSetting("applications.isHidden");
    selectedCategory = settingsManager.getSetting("applications.selectedCategory");
    _loadData();
  }
  bool _isLoading = true;
  
  // Function to load data and update state
  Future<void> _loadData() async {
    try {
      // Get list of all applications
      final appDataProvider = ApplicationsDataProvider();
      final List<ApplicationBasicDetail> allApps = await appDataProvider.fetchAllApplications();


      // Update state with fetched data
      setState(() {
        // Middle section - Top Applications
        apps = allApps.map((app) => {
          "name": app.name,
          "category": app.category,
          "screenTime": app.formattedScreenTime,
          "isTracking": app.isTracking,
          "isHidden": app.isHidden
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
    void setSetting(String key, dynamic value) {
      switch (key) {
        case 'tracking':
          setState(() {
            isTracking = value;
            settingsManager.updateSetting("applications.tracking", value);
          });
          break;
        case 'isHidden':
          setState(() {
            isHidden = value;
            settingsManager.updateSetting("applications.isHidden", value);
          });
          break;
      }
    }
    void changeCategory(String category) {
      setState(() {
        selectedCategory = category;
        settingsManager.updateSetting("applications.selectedCategory", category);
      });
    }
    void changeIndividualParam(String type, bool value, String name){
      switch (type) {
        case 'isTracking':
          apps = apps.map((app) => {
            "name": app['name'],
            "category": app['category'],
            "screenTime": app['screenTime'],
            "isTracking": name==app['name'] ? value : app['isTracking'],
            "isHidden": app['isHidden']
          }).toList();
          setState(() {
            AppDataStore().updateAppMetadata(name,isTracking: value);
          });
          break;
        case 'isHidden':
          apps = apps.map((app) => {
            "name": app['name'],
            "category": app['category'],
            "screenTime": app['screenTime'],
            "isTracking": app['isTracking'],
            "isHidden": name==app['name'] ? value : app['isHidden']
          }).toList();
          setState(() {
            AppDataStore().updateAppMetadata(name,isVisible: value); 
          });
          break;
      }
    }
    void changeSearchValue(String value) {
      if (_debounce?.isActive ?? false) _debounce!.cancel();

      _debounce = Timer(const Duration(milliseconds: 300), () {
        if (searchValue != value) {
          setState(() {
            searchValue = value;
          });
        }
      });
    }
    return _isLoading ? const Center(child: ProgressRing(),) : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20,top: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Header(changeSearchValue: changeSearchValue,),
              const SizedBox(height: 20),
              Container(
                height: 60,
                padding:const EdgeInsets.only(left: 20,right: 20),
                width: MediaQuery.of(context).size.width * 1,
                decoration: BoxDecoration(
                  color: FluentTheme.of(context).micaBackgroundColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: FluentTheme.of(context).inactiveBackgroundColor,width: 1)
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                  Row(
                    children: [
                      ToggleSwitch(
                        checked: isTracking,
                        onChanged: (v) => setSetting('tracking', v),
                      ),
                      const SizedBox(width: 10,),
                      const Text("Tracking",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w600),),
                      const SizedBox(width: 40,),
                      ToggleSwitch(
                        checked: isHidden,
                        onChanged: (v) => setSetting('isHidden', v),
                      ),
                      const SizedBox(width: 10,),
                      const Text("Hidden/Visible",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w600),),
                    ]
                  ),
                  DropDownButton(
                    title: Text(
                      selectedCategory=='All' ? 'Select a Category' : selectedCategory,
                      style:const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    items: AppCategories.categories
                        .map((category) => MenuFlyoutItem(
                              text: Text(category.name),
                              onPressed: () {
                                changeCategory(category.name);
                              },
                            ))
                        .toList(),
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
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: FluentTheme.of(context).inactiveBackgroundColor,width: 1)
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
                          Container(width: 2,color: FluentTheme.of(context).inactiveBackgroundColor),
                          const Expanded(
                            flex: 1,
                            child: Center(
                              child: Text("Category",style: TextStyle(fontSize: 14,fontWeight: FontWeight.w600))
                          )),
                          Container(width: 2,color: FluentTheme.of(context).inactiveBackgroundColor),
                          const Expanded(
                            flex: 1,
                            child: Center(
                              child: Text("Screen Time",style: TextStyle(fontSize: 14,fontWeight: FontWeight.w600))
                          )),
                          Container(width: 2,color: FluentTheme.of(context).inactiveBackgroundColor),
                          const Expanded(
                            flex: 1,
                            child: Center(
                              child: Text("Tracking",style: TextStyle(fontSize: 14,fontWeight: FontWeight.w600))
                          )),
                          Container(width: 2,color: FluentTheme.of(context).inactiveBackgroundColor),
                          const Expanded(
                            flex: 1,
                            child: Center(
                              child: Text("Hidden/Visible",style: TextStyle(fontSize: 14,fontWeight: FontWeight.w600))
                          )),
                          Container(width: 2,color: FluentTheme.of(context).inactiveBackgroundColor),
                          const Expanded(
                            flex: 1,
                            child: Center(
                              child: Text("Show Details",style: TextStyle(fontSize: 14,fontWeight: FontWeight.w600))
                          )),
                        ],
                      ),
                    ),
                    Container(width: MediaQuery.of(context).size.width * 1,height: 1,color: FluentTheme.of(context).inactiveBackgroundColor),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: apps.where((app) =>
                            (app["isTracking"] == isTracking && app["isHidden"] == isHidden) &&
                            app["screenTime"] != "0s" &&
                            (selectedCategory == "All" || selectedCategory.contains(app["category"])) &&
                            (searchValue.isEmpty || app["name"].toLowerCase().contains(searchValue.toLowerCase()))
                          ).map((app) => 
                            Application(
                              name: app["name"],
                              category: app["category"],
                              screenTime: app["screenTime"],
                              tracking: app["isTracking"],
                              isHidden: app["isHidden"],
                              changeIndividualParam: changeIndividualParam,
                            ),
                          ).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
  final void Function(String type, bool value, String name) changeIndividualParam;
  const Application({
    super.key,
    required this.name,
    required this.category,
    required this.screenTime,
    required this.tracking,
    required this.isHidden,
    required this.changeIndividualParam
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(width: MediaQuery.of(context).size.width * 1,height: 1,color: FluentTheme.of(context).inactiveBackgroundColor),
        SizedBox(
          height: 45,
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Center(
                  child: Text(name,style:const TextStyle(fontSize: 14))
              )),
              Container(width: 1,color: FluentTheme.of(context).inactiveBackgroundColor),
              Expanded(
                flex: 1,
                child: Center(
                  child: Text(category,style:const TextStyle(fontSize: 14))
              )),
              Container(width: 1,color: FluentTheme.of(context).inactiveBackgroundColor),
              Expanded(
                flex: 1,
                child: Center(
                  child: Text(screenTime,style:const TextStyle(fontSize: 14))
              )),
              Container(width: 1,color: FluentTheme.of(context).inactiveBackgroundColor),
              Expanded(
                flex: 1,
                child: Center(
                  child: ToggleSwitch(checked: tracking, onChanged: (v)=>{changeIndividualParam('isTracking',v,name)})
              )),
              Container(width: 1,color: FluentTheme.of(context).inactiveBackgroundColor),
              Expanded(
                flex: 1,
                child: Center(
                  child: ToggleSwitch(checked: isHidden, onChanged: (v)=>{changeIndividualParam('isHidden',v,name)})
              )),
              Container(width: 1,color: FluentTheme.of(context).inactiveBackgroundColor),
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
  final void Function(String value) changeSearchValue;
  const Header({
    super.key,
    required this.changeSearchValue
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
              child:TextBox(
                placeholder: 'Search Application',
                // decoration: WidgetStateProperty.all<BoxDecoration>(
                //   border: const BorderRadius.only(topRight: Radius.circular(100),bottomRight: Radius.circular(100)),
                // ),
                onChanged: (value) => {
                  changeSearchValue(value)
                },
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