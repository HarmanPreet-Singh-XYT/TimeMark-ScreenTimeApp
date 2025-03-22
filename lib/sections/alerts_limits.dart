import 'package:fluent_ui/fluent_ui.dart';
import 'package:screentime/sections/graphs/alerts_limits_chart.dart';
import 'package:screentime/sections/controller/data_controllers/alerts_limits_data_controller.dart';
import 'package:screentime/sections/controller/settings_data_controller.dart';

class AlertsLimits extends StatefulWidget {
  final ScreenTimeDataController? controller; // Allow injection for testing
  final SettingsManager? settingsManager; // Allow injection for testing
  
  const AlertsLimits({
    super.key, 
    this.controller,
    this.settingsManager,
  });

  @override
  State<AlertsLimits> createState() => _AlertsLimitsState();
}

class _AlertsLimitsState extends State<AlertsLimits> {
  late final ScreenTimeDataController controller;
  late final SettingsManager settingsManager;
  bool popupAlerts = false;
  bool frequentAlerts = false;
  bool soundAlerts = false;
  bool systemAlerts = false;

  // This will store app summaries for UI updates
  List<AppUsageSummary> appSummaries = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    controller = widget.controller ?? ScreenTimeDataController();
    settingsManager = widget.settingsManager ?? SettingsManager();
    
    // Load settings
    popupAlerts = settingsManager.getSetting("limitsAlerts.popup");
    frequentAlerts = settingsManager.getSetting("limitsAlerts.frequent");
    soundAlerts = settingsManager.getSetting("limitsAlerts.sound");
    systemAlerts = settingsManager.getSetting("limitsAlerts.system");
    
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
      
      // Initialize the controller
      await controller.initialize();

      // Fetch initial data
      final allData = await controller.getAllData();
      if (mounted) {
        setState(() {
          appSummaries = (allData['appSummaries'] as List<dynamic>)
              .map((json) => AppUsageSummary.fromJson(json as Map<String, dynamic>))
              .toList();
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'Failed to load data: ${e.toString()}';
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    // Clean up controller if we created it internally
    // if (widget.controller == null) {
    //   controller.dispose();
    // }
    super.dispose();
  }

  void setSetting(String key, dynamic value) {
    switch (key) {
      case 'popup':
        setState(() {
          popupAlerts = value;
          settingsManager.updateSetting("limitsAlerts.popup", value);
        });
        break;
      case 'frequent':
        setState(() {
          frequentAlerts = value;
          settingsManager.updateSetting("limitsAlerts.frequent", value);
        });
        break;
      case 'sound':
        setState(() {
          soundAlerts = value;
          settingsManager.updateSetting("limitsAlerts.sound", value);
        });
        break;
      case 'system':
        setState(() {
          systemAlerts = value;
          settingsManager.updateSetting("limitsAlerts.system", value);
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: ProgressRing());
    }
    
    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(errorMessage!, style: TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            Button(
              onPressed: _loadData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Header(
              onReset: _resetAllLimits,
              onRefresh: _loadData,
            ),
            const SizedBox(height: 20),
            // Notification settings widget - Made responsive
            LayoutBuilder(
              builder: (context, constraints) {
                // For narrower screens, stack the toggles vertically
                if (constraints.maxWidth < 700) {
                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: FluentTheme.of(context).micaBackgroundColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: FluentTheme.of(context).inactiveBackgroundColor, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Notifications Settings",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 15),
                        // _buildToggleRow('Pop-up Alerts', popupAlerts, (v) => setSetting('popup', v)),
                        // const SizedBox(height: 10),
                        _buildToggleRow('Frequent Alerts', frequentAlerts, (v) => setSetting('frequent', v)),
                        const SizedBox(height: 10),
                        _buildToggleRow('Sound Alerts', soundAlerts, (v) => setSetting('sound', v)),
                        const SizedBox(height: 10),
                        _buildToggleRow('System Alerts', systemAlerts, (v) => setSetting('system', v)),
                      ],
                    ),
                  );
                } else {
                  // For wider screens, use the original horizontal layout
                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: FluentTheme.of(context).micaBackgroundColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: FluentTheme.of(context).inactiveBackgroundColor, width: 1),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Notifications Settings",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildToggleRow('Pop-up Alerts', popupAlerts, (v) => setSetting('popup', v)),
                            _buildToggleRow('Frequent Alerts', frequentAlerts, (v) => setSetting('frequent', v)),
                            _buildToggleRow('Sound Alerts', soundAlerts, (v) => setSetting('sound', v)),
                            _buildToggleRow('System Alerts', systemAlerts, (v) => setSetting('system', v)),
                          ],
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 20),
            // Application Limits section
            ApplicationLimits(
              appSummaries: appSummaries,
              controller: controller,
              onDataChanged: _loadData,
            ),
            // const SizedBox(height: 20),
            // // Usage Trends section
            // Container(
            //   padding: const EdgeInsets.only(top: 15, bottom: 15, left: 20, right: 20),
            //   width: MediaQuery.of(context).size.width * 1,
            //   decoration: BoxDecoration(
            //     color: FluentTheme.of(context).micaBackgroundColor,
            //     borderRadius: BorderRadius.circular(10),
            //     border: Border.all(color: FluentTheme.of(context).inactiveBackgroundColor, width: 1),
            //   ),
            //   child:const Column(
            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       Text("Usage Trends", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            //       // Alert usage chart with direct data
            //       AlertUsageChart(),
            //     ],
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleRow(String label, bool isChecked, Function(bool) onChanged) {
    return Row(
      children: [
        ToggleSwitch(
          checked: isChecked,
          onChanged: onChanged,
        ),
        const SizedBox(width: 15),
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ],
    );
  }

  void _resetAllLimits() {
    try {
      // Get all app summaries from the controller
      final apps = controller.getAllAppsSummary();
      
      // Update each app's limit to zero and disable it
      for (final app in apps) {
        controller.updateAppLimit(app.appName, Duration.zero, false);
      }
      
      // Reload data to update UI
      _loadData();
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to reset limits: ${e.toString()}';
      });
    }
  }
}

class ApplicationLimits extends StatefulWidget {
  final List<AppUsageSummary> appSummaries;
  final ScreenTimeDataController controller;
  final VoidCallback onDataChanged;

  const ApplicationLimits({
    super.key,
    required this.appSummaries,
    required this.controller,
    required this.onDataChanged,
  });

  @override
  State<ApplicationLimits> createState() => _ApplicationLimitsState();
}

class _ApplicationLimitsState extends State<ApplicationLimits> {
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        minHeight: 200,
        maxHeight: 500,
      ),
      padding: const EdgeInsets.only(top: 15, bottom: 15, left: 20, right: 20),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: FluentTheme.of(context).micaBackgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: FluentTheme.of(context).inactiveBackgroundColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Application Limits",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              Button(
                child: const Text("Add Limit"),
                onPressed: () => _showAddLimitDialog(context),
              ),
            ],
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
          Expanded(
            child: widget.appSummaries.isEmpty 
              ? const Center(child: Text("No applications to display"))
              : SingleChildScrollView(
                  child: Column(
                    children: widget.appSummaries
                        .where((app) => app.appName.trim().isNotEmpty) // Filter out empty or null names
                        .map((app) => Application(
                              app: app,
                              onEdit: () => _showEditLimitDialog(context, app),
                            ))
                        .toList(),
                  ),
                ),
          ),
        ],
      ),
    );
  }

  void _showAddLimitDialog(BuildContext context) {
    final allApps = widget.appSummaries;
    String? selectedApp;
    double hours = 1.0;
    double minutes = 0.0;
    bool limitEnabled = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return ContentDialog(
            title: const Text('Add Application Limit'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Select Application'),
                const SizedBox(height: 8),
                ComboBox<String>(
                  placeholder: const Text('Select an application'),
                  isExpanded: true,
                  items: allApps
                      .where((app) => app.appName.trim().isNotEmpty) // Filter out empty or null names
                      .map((app) => ComboBoxItem<String>(
                            value: app.appName,
                            child: Text(app.appName),
                          ))
                      .toList(),
                  value: selectedApp,
                  onChanged: (value) {
                    setState(() {
                      selectedApp = value;
                    });
                  },
                ),

                const SizedBox(height: 20),
                Row(
                  children: [
                    const Text('Enable Limit: '),
                    ToggleSwitch(
                      checked: limitEnabled,
                      onChanged: (value) {
                        setState(() {
                          limitEnabled = value;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Text('Hours: '),
                    SizedBox(
                      width: 200,
                      child: Slider(
                        value: hours,
                        min: 0,
                        max: 12,
                        divisions: 12,
                        label: hours.round().toString(),
                        onChanged: (value) {
                          setState(() {
                            hours = value;
                          });
                        },
                      ),
                    ),
                    Text(hours.round().toString()),
                  ],
                ),
                Row(
                  children: [
                    const Text('Minutes: '),
                    SizedBox(
                      width: 200,
                      child: Slider(
                        value: minutes,
                        min: 0,
                        max: 55,
                        divisions: 12, // Corrected to match 5-minute increments (0, 5, 10, ... 55)
                        label: (minutes.round() ~/ 5 * 5).toString(), // Ensure values are in 5-minute increments
                        onChanged: (value) {
                          setState(() {
                            minutes = (value ~/ 5 * 5).toDouble(); // Round to nearest 5-minute increment
                          });
                        },
                      ),
                    ),
                    Text((minutes.round() ~/ 5 * 5).toString()),
                  ],
                ),
              ],
            ),
            actions: [
              Button(
                child: const Text('Cancel'),
                onPressed: () => Navigator.pop(context),
              ),
              FilledButton(
                child: const Text('Add'),
                onPressed: () {
                  if (selectedApp != null) {
                    try {
                      final duration = Duration(
                        hours: hours.round(),
                        minutes: (minutes.round() ~/ 5 * 5), // Ensure minutes are in 5-minute increments
                      );
                      widget.controller.updateAppLimit(selectedApp!, duration, limitEnabled);
                      widget.onDataChanged(); // Reload data after changes
                      Navigator.pop(context);
                    } catch (e) {
                      showDialog(
                        context: context,
                        builder: (context) => ContentDialog(
                          title: const Text('Error'),
                          content: Text('Failed to update limit: ${e.toString()}'),
                          actions: [
                            Button(
                              child: const Text('OK'),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      );
                    }
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }

  void _showEditLimitDialog(BuildContext context, AppUsageSummary app) {
    double hours = app.dailyLimit.inHours.toDouble();
    double minutes = (app.dailyLimit.inMinutes % 60).toDouble();
    bool limitEnabled = app.limitStatus;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return ContentDialog(
            title: Text('Edit Limit: ${app.appName}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Text('Enable Limit: '),
                    ToggleSwitch(
                      checked: limitEnabled,
                      onChanged: (value) {
                        setState(() {
                          limitEnabled = value;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Text('Hours: '),
                    SizedBox(
                      width: 200,
                      child: Slider(
                        value: hours,
                        min: 0,
                        max: 12,
                        divisions: 12,
                        label: hours.round().toString(),
                        onChanged: (value) {
                          setState(() {
                            hours = value;
                          });
                        },
                      ),
                    ),
                    Text(hours.round().toString()),
                  ],
                ),
                Row(
                  children: [
                    const Text('Minutes: '),
                    SizedBox(
                      width: 200,
                      child: Slider(
                        value: minutes,
                        min: 0,
                        max: 55,
                        divisions: 12, // Corrected to match 5-minute increments
                        label: (minutes.round() ~/ 5 * 5).toString(),
                        onChanged: (value) {
                          setState(() {
                            minutes = (value ~/ 5 * 5).toDouble(); // Round to nearest 5-minute increment
                          });
                        },
                      ),
                    ),
                    Text((minutes.round() ~/ 5 * 5).toString()),
                  ],
                ),
              ],
            ),
            actions: [
              Button(
                child: const Text('Cancel'),
                onPressed: () => Navigator.pop(context),
              ),
              FilledButton(
                child: const Text('Save'),
                onPressed: () {
                  try {
                    final duration = Duration(
                      hours: hours.round(),
                      minutes: (minutes.round() ~/ 5 * 5), // Ensure minutes are in 5-minute increments
                    );
                    widget.controller.updateAppLimit(app.appName, duration, limitEnabled);
                    widget.onDataChanged(); // Reload data after changes
                    Navigator.pop(context);
                  } catch (e) {
                    showDialog(
                      context: context,
                      builder: (context) => ContentDialog(
                        title: const Text('Error'),
                        content: Text('Failed to update limit: ${e.toString()}'),
                        actions: [
                          Button(
                            child: const Text('OK'),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class Application extends StatelessWidget {
  final AppUsageSummary app;
  final VoidCallback onEdit;

  const Application({
    super.key,
    required this.app,
    required this.onEdit,
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
              SizedBox(width: 120, height: 20, child: Text(app.appName)),
              SizedBox(width: 120, height: 20, child: Text(app.category)),
              SizedBox(width: 72, height: 20, child: Text(_formatDuration(app.dailyLimit))),
              SizedBox(width: 100, height: 20, child: Text(_formatDuration(app.currentUsage))),
              SizedBox(
                width: 55,
                height: 20,
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: _getStatusColor(app),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(app.limitStatus ? "Active" : "Off"),
                  ],
                ),
              ),
              SizedBox(
                width: 85,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SmallIconButton(
                      child: IconButton(
                        icon: const Icon(FluentIcons.edit_solid12, size: 20.0, color: Color(0xff6B5CF5)),
                        onPressed: onEdit,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(height: 1, color: FluentTheme.of(context).inactiveBackgroundColor),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    if (duration == Duration.zero) {
      return "None";
    }

    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0 && minutes > 0) {
      return "${hours}h ${minutes}m";
    } else if (hours > 0) {
      return "${hours}h";
    } else {
      return "${minutes}m";
    }
  }

  Color _getStatusColor(AppUsageSummary app) {
    if (!app.limitStatus) {
      return Colors.grey;
    }
    
    if(app.dailyLimit == Duration.zero) {
      return Colors.white;
    }

    if (app.currentUsage >= app.dailyLimit) {
      return Colors.red;
    }

    if (app.isAboutToReachLimit) {
      return Colors.orange;
    }

    if (app.percentageOfLimitUsed > 0.75) {
      return Colors.yellow;
    }

    return Colors.green;
  }
}

class Header extends StatelessWidget {
  final VoidCallback onReset;
  final VoidCallback onRefresh;

  const Header({
    super.key,
    required this.onReset,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("Alerts & Limits", style: FluentTheme.of(context).typography.subtitle),
        Row(
          children: [
            Button(
              onPressed: onRefresh,
              child: const Row(
                children: [
                  Icon(FluentIcons.refresh, size: 16),
                  SizedBox(width: 10),
                  Text('Refresh', style: TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Button(
              style: ButtonStyle(
                padding: WidgetStateProperty.all(
                  const EdgeInsets.only(top: 8, bottom: 8, left: 20, right: 20),
                ),
              ),
              child: const Row(
                children: [
                  Icon(FluentIcons.sync, size: 16),
                  SizedBox(width: 10),
                  Text('Reset All', style: TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
              onPressed: () => showContentDialog(context),
            ),
          ],
        ),
      ],
    );
  }
  
  void showContentDialog(BuildContext context) async {
    await showDialog<String>(
      context: context,
      builder: (context) => ContentDialog(
        title: const Text('Reset Settings?'),
        content: const Text(
          'If you reset settings, you won\'t be able to recover it. Do you want to reset it?',
        ),
        actions: [
          Button(
            child: const Text('Reset All'),
            onPressed: () {
              Navigator.pop(context, 'Reset confirmed');
              onReset();
            },
          ),
          FilledButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context, 'User canceled dialog'),
          ),
        ],
      ),
    );
  }
}