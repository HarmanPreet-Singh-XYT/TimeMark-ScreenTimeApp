import 'package:fluent_ui/fluent_ui.dart';
import 'package:ProductiveScreenTime/sections/controller/app_data_controller.dart';
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
          "isHidden": app.isHidden,
          "isProductive": app.isProductive,
          "dailyLimit": app.dailyLimit,
          "limitStatus": app.limitStatus
        }).toList();
        
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading overview data: $e');
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
  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
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
          apps = apps.map((app) => app['name'] == name 
            ? {...app, "isTracking": value}
            : app
          ).toList();
          setState(() {
            AppDataStore().updateAppMetadata(name, isTracking: value);
          });
          break;
        case 'isHidden':
          apps = apps.map((app) => app['name'] == name 
            ? {...app, "isHidden": value}
            : app
          ).toList();
          setState(() {
            AppDataStore().updateAppMetadata(name, isVisible: value); 
          });
          break;
      }
    }
    
    return _isLoading ? const Center(child: ProgressRing(),) : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Header(changeSearchValue: changeSearchValue),
              const SizedBox(height: 20),
              Container(
                height: 60,
                padding: const EdgeInsets.only(left: 20, right: 20),
                width: MediaQuery.of(context).size.width * 1,
                decoration: BoxDecoration(
                  color: FluentTheme.of(context).micaBackgroundColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: FluentTheme.of(context).inactiveBackgroundColor, width: 1)
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
                      const Text("Tracking", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),),
                      const SizedBox(width: 40,),
                      ToggleSwitch(
                        checked: isHidden,
                        onChanged: (v) => setSetting('isHidden', v),
                      ),
                      const SizedBox(width: 10,),
                      const Text("Hidden/Visible", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),),
                    ]
                  ),
                  DropDownButton(
                    title: Text(
                      selectedCategory == 'All' ? 'Select a Category' : selectedCategory,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                height: MediaQuery.of(context).size.height * 0.72,
                width: MediaQuery.of(context).size.width * 1,
                decoration: BoxDecoration(
                  color: FluentTheme.of(context).micaBackgroundColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: FluentTheme.of(context).inactiveBackgroundColor, width: 1)
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
                              child: Text("Name", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600))
                          )),
                          Container(width: 2, color: FluentTheme.of(context).inactiveBackgroundColor),
                          const Expanded(
                            flex: 1,
                            child: Center(
                              child: Text("Category", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600))
                          )),
                          Container(width: 2, color: FluentTheme.of(context).inactiveBackgroundColor),
                          const Expanded(
                            flex: 1,
                            child: Center(
                              child: Text("Screen Time", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600))
                          )),
                          Container(width: 2, color: FluentTheme.of(context).inactiveBackgroundColor),
                          const Expanded(
                            flex: 1,
                            child: Center(
                              child: Text("Tracking", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600))
                          )),
                          Container(width: 2, color: FluentTheme.of(context).inactiveBackgroundColor),
                          const Expanded(
                            flex: 1,
                            child: Center(
                              child: Text("Hidden/Visible", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600))
                          )),
                          Container(width: 2, color: FluentTheme.of(context).inactiveBackgroundColor),
                          const Expanded(
                            flex: 1,
                            child: Center(
                              child: Text("Edit", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600))
                          )),
                        ],
                      ),
                    ),
                    Container(width: MediaQuery.of(context).size.width * 1, height: 1, color: FluentTheme.of(context).inactiveBackgroundColor),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: apps.where((app) =>
                            (app["isTracking"] == isTracking && app["isHidden"] == isHidden) &&
                            app["screenTime"] != "0s" && app['name'] != '' &&
                            (selectedCategory == "All" || selectedCategory.contains(app["category"])) &&
                            (searchValue.isEmpty || app["name"].toLowerCase().contains(searchValue.toLowerCase()))
                          ).map((app) => 
                            Application(
                              name: app["name"],
                              category: app["category"],
                              screenTime: app["screenTime"],
                              tracking: app["isTracking"],
                              isHidden: app["isHidden"],
                              isProductive: app["isProductive"] ?? false,
                              dailyLimit: app["dailyLimit"] ?? const Duration(),
                              limitStatus: app["limitStatus"] ?? false,
                              changeIndividualParam: changeIndividualParam,
                              refreshData: refreshData,
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
  final bool isProductive;
  final Duration dailyLimit;
  final bool limitStatus;
  final void Function(String type, bool value, String name) changeIndividualParam;
  final Future<void> Function() refreshData;
  
  const Application({
    super.key,
    required this.name,
    required this.category,
    required this.screenTime,
    required this.tracking,
    required this.isHidden,
    required this.isProductive,
    required this.dailyLimit,
    required this.limitStatus,
    required this.changeIndividualParam,
    required this.refreshData,
  });

  String _formatDuration(Duration duration) {
    if (duration == Duration.zero) return "None";
    
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    
    if (hours > 0) {
      return "${hours}h ${minutes}m";
    } else {
      return "${minutes}m";
    }
  }

  void _showEditDialog(BuildContext context) {
    String selectedCategory = category;
    bool isProductiveValue = isProductive;
    bool isTrackingValue = tracking;
    bool isVisibleValue = !isHidden;
    bool limitStatusValue = limitStatus;
    int limitHours = dailyLimit.inHours;
    int limitMinutes = dailyLimit.inMinutes.remainder(60);
    bool isCustomCategory = !AppCategories.categories.any((c) => c.name == selectedCategory);
    final customCategoryController = TextEditingController(
      text: isCustomCategory ? selectedCategory : '',
    );

    // Define fixed colors for icons
    const Color productivityColor = Color(0xFF0078D7);
    const Color timerColor = Color(0xFF107C10);
    const Color viewColor = Color(0xFF5C2D91);
    const Color clockColor = Color(0xFFCA5010);

    showDialog(
      context: context,
      builder: (context) {
        return ContentDialog(
          title: Text('Edit $name', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category Section
                      _buildSectionHeader('Category'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: ComboBox<String>(
                              value: isCustomCategory ? 'Custom' : selectedCategory,
                              items: [
                                ...AppCategories.categories
                                    .map((category) => ComboBoxItem<String>(
                                          value: category.name,
                                          child: Text(category.name),
                                        ))
                                    .toList(),
                                const ComboBoxItem<String>(
                                  value: 'Custom',
                                  child: Text('Custom'),
                                ),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    if (value == 'Custom') {
                                      isCustomCategory = true;
                                    } else {
                                      isCustomCategory = false;
                                      selectedCategory = value;
                                    }
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      // Show custom category text field if custom is selected
                      AnimatedSize(
                        duration: const Duration(milliseconds: 200),
                        child: isCustomCategory
                            ? Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: TextBox(
                                  controller: customCategoryController,
                                  placeholder: 'Enter custom category name',
                                  onChanged: (value) {
                                    setState(() {
                                      selectedCategory = value;
                                    });
                                  },
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                      const SizedBox(height: 20),
                      
                      // Toggle Switches Section
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildToggleRow(
                                'Is Productive',
                                isProductiveValue,
                                (value) {
                                  setState(() {
                                    isProductiveValue = value;
                                  });
                                },
                                icon: FluentIcons.graph_symbol,
                                iconColor: productivityColor,
                              ),
                              const Divider(),
                              _buildToggleRow(
                                'Track Usage',
                                isTrackingValue,
                                (value) {
                                  setState(() {
                                    isTrackingValue = value;
                                  });
                                },
                                icon: FluentIcons.timer,
                                iconColor: timerColor,
                              ),
                              const Divider(),
                              _buildToggleRow(
                                'Visible in Reports',
                                isVisibleValue,
                                (value) {
                                  setState(() {
                                    isVisibleValue = value;
                                  });
                                },
                                icon: FluentIcons.view,
                                iconColor: viewColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Time Limit Section
                      _buildSectionHeader('Time Limits'),
                      const SizedBox(height: 8),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildToggleRow(
                                'Enable Daily Limit',
                                limitStatusValue,
                                (value) {
                                  setState(() {
                                    limitStatusValue = value;
                                  });
                                },
                                icon: FluentIcons.clock,
                                iconColor: clockColor,
                              ),
                              AnimatedSize(
                                duration: const Duration(milliseconds: 200),
                                child: limitStatusValue
                                    ? Padding(
                                        padding: const EdgeInsets.only(top: 16.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text('Set daily time limit:',
                                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                                            const SizedBox(height: 8),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                _buildTimeInput(
                                                  'Hours',
                                                  limitHours,
                                                  0,
                                                  24,
                                                  (value) {
                                                    setState(() {
                                                      limitHours = value?.toInt() ?? 0;
                                                    });
                                                  },
                                                ),
                                                const SizedBox(width: 10),
                                                _buildTimeInput(
                                                  'Minutes',
                                                  limitMinutes,
                                                  0,
                                                  59,
                                                  (value) {
                                                    setState(() {
                                                      limitMinutes = value?.toInt() ?? 0;
                                                    });
                                                  },
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          actions: [
            Button(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            FilledButton(
              child: const Text('Save Changes'),
              onPressed: () async {
                // If custom is selected, use the value from the text field
                final finalCategory = isCustomCategory 
                    ? customCategoryController.text.isNotEmpty 
                        ? customCategoryController.text 
                        : 'Uncategorized'
                    : selectedCategory;
                
                // Calculate new duration from hours and minutes
                final newDailyLimit = Duration(
                  hours: limitHours,
                  minutes: limitMinutes,
                );
                
                // Update app metadata with new values
                await AppDataStore().updateAppMetadata(
                  name,
                  category: finalCategory,
                  isProductive: isProductiveValue,
                  isTracking: isTrackingValue,
                  isVisible: isVisibleValue,
                  dailyLimit: newDailyLimit,
                  limitStatus: limitStatusValue,
                );
                
                // Refresh the data to show updated values
                await refreshData();
                
                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
            ),
          ],
        );
      },
    );
  }

  // Helper method to build section headers
  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0078D7), // Microsoft blue color constant
          ),
        ),
        const SizedBox(width: 8),
        const Expanded(
          child: Divider(), // Using default divider without color parameter
        ),
      ],
    );
  }

  // Helper method to build toggle switch rows with icons
  Widget _buildToggleRow(
    String label,
    bool value,
    Function(bool) onChanged,
    {IconData? icon, Color iconColor = const Color(0xFF0078D7)}
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: iconColor), // Using const color
                const SizedBox(width: 10),
              ],
              Text(
                label, 
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500, // Added medium weight for better visibility
                ),
              ),
            ],
          ),
          ToggleSwitch(
            checked: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  // Helper method to build time input fields
  Widget _buildTimeInput(
    String label,
    int value,
    int min,
    int max,
    Function(num?) onChanged,
  ) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label, 
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF0078D7), // Microsoft blue color constant
            ),
          ),
          const SizedBox(height: 4),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF0078D7).withOpacity(0.3)),
              borderRadius: BorderRadius.circular(4),
            ),
            child: NumberBox(
              value: value,
              min: min,
              max: max,
              mode: SpinButtonPlacementMode.inline,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(width: MediaQuery.of(context).size.width * 1, height: 1, color: FluentTheme.of(context).inactiveBackgroundColor),
        SizedBox(
          height: 45,
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Center(
                  child: Text(name, style: const TextStyle(fontSize: 14))
              )),
              Container(width: 1, color: FluentTheme.of(context).inactiveBackgroundColor),
              Expanded(
                flex: 1,
                child: Center(
                  child: Text(category, style: const TextStyle(fontSize: 14))
              )),
              Container(width: 1, color: FluentTheme.of(context).inactiveBackgroundColor),
              Expanded(
                flex: 1,
                child: Center(
                  child: Text(screenTime, style: const TextStyle(fontSize: 14))
              )),
              Container(width: 1, color: FluentTheme.of(context).inactiveBackgroundColor),
              Expanded(
                flex: 1,
                child: Center(
                  child: ToggleSwitch(
                    checked: tracking, 
                    onChanged: (v) => {changeIndividualParam('isTracking', v, name)}
                  )
              )),
              Container(width: 1, color: FluentTheme.of(context).inactiveBackgroundColor),
              Expanded(
                flex: 1,
                child: Center(
                  child: ToggleSwitch(
                    checked: isHidden, 
                    onChanged: (v) => {changeIndividualParam('isHidden', v, name)}
                  )
              )),
              Container(width: 1, color: FluentTheme.of(context).inactiveBackgroundColor),
              Expanded(
                flex: 1,
                child: Center(
                  child: IconButton(
                    icon: Icon(FluentIcons.edit, size: 20.0, color: Colors.blue),
                    onPressed: () => _showEditDialog(context),
                  ),
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
        Text("Applications", style: FluentTheme.of(context).typography.subtitle),
        Row(
          children: [
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(100), bottomLeft: Radius.circular(100)),
                color: FluentTheme.of(context).micaBackgroundColor
              ),
              child: const Icon(FluentIcons.search, color: Colors.white)
            ),
            Container(
              width: 280,
              height: 40,
              margin: const EdgeInsets.only(right: 10),
              child: TextBox(
                placeholder: 'Search Application',
                onChanged: (value) => {
                  changeSearchValue(value)
                },
                style: const TextStyle(
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