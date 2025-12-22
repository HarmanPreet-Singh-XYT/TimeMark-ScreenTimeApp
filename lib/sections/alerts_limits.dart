import 'package:fluent_ui/fluent_ui.dart';
import 'package:screentime/sections/controller/data_controllers/alerts_limits_data_controller.dart';
import 'package:screentime/sections/controller/settings_data_controller.dart';
import 'package:screentime/l10n/app_localizations.dart';

class AlertsLimits extends StatefulWidget {
  final ScreenTimeDataController? controller;
  final SettingsManager? settingsManager;
  
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
  
  // Add variables for overall limit
  bool overallLimitEnabled = false;
  double overallLimitHours = 2.0;
  double overallLimitMinutes = 0.0;

  // This will store app summaries for UI updates
  List<AppUsageSummary> appSummaries = [];
  bool isLoading = true;
  String? errorMessage;
  
  // Add variable to track total daily screen time
  Duration totalScreenTime = Duration.zero;

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
    
    // Load overall limit settings
    overallLimitEnabled = settingsManager.getSetting("limitsAlerts.overallLimit.enabled") ?? false;
    overallLimitHours = settingsManager.getSetting("limitsAlerts.overallLimit.hours")?.toDouble() ?? 2.0;
    overallLimitMinutes = settingsManager.getSetting("limitsAlerts.overallLimit.minutes")?.toDouble() ?? 0.0;
    
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
          
          // Calculate total screen time by summing all app usages
          totalScreenTime = Duration(minutes: appSummaries.fold(0, 
              (sum, app) => sum + app.currentUsage.inMinutes));
              
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = AppLocalizations.of(context)!.failedToLoadData(e.toString());
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
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
      case 'overallLimitEnabled':
        setState(() {
          overallLimitEnabled = value;
          settingsManager.updateSetting("limitsAlerts.overallLimit.enabled", value);
          
          // Update controller with overall limit
          if (value) {
            final duration = Duration(
              hours: overallLimitHours.round(),
              minutes: (overallLimitMinutes.round() ~/ 5 * 5),
            );
            controller.updateOverallLimit(duration, true);
          } else {
            controller.updateOverallLimit(Duration.zero, false);
          }
        });
        break;
    }
  }

  void _updateOverallLimit() {
    final duration = Duration(
      hours: overallLimitHours.round(),
      minutes: (overallLimitMinutes.round() ~/ 5 * 5),
    );
    
    // Update settings
    settingsManager.updateSetting("limitsAlerts.overallLimit.hours", overallLimitHours.round());
    settingsManager.updateSetting("limitsAlerts.overallLimit.minutes", overallLimitMinutes.round() ~/ 5 * 5);
    
    // Update controller
    controller.updateOverallLimit(duration, overallLimitEnabled);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
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
              child: Text(l10n.retry),
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
                        Text(
                          l10n.notificationsSettings,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 15),
                        _buildToggleRow(l10n.popupAlerts, popupAlerts, (v) => setSetting('popup', v)),
                        const SizedBox(height: 10),
                        _buildToggleRow(l10n.frequentAlerts, frequentAlerts, (v) => setSetting('frequent', v)),
                        const SizedBox(height: 10),
                        _buildToggleRow(l10n.soundAlerts, soundAlerts, (v) => setSetting('sound', v)),
                        const SizedBox(height: 10),
                        _buildToggleRow(l10n.systemAlerts, systemAlerts, (v) => setSetting('system', v)),
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
                        Text(
                          l10n.notificationsSettings,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildToggleRow(l10n.frequentAlerts, frequentAlerts, (v) => setSetting('frequent', v)),
                            _buildToggleRow(l10n.systemAlerts, systemAlerts, (v) => setSetting('system', v)),
                          ],
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 20),
            // Overall Screen Time Limit section
            LayoutBuilder(
              builder: (context, constraints) {
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.overallScreenTimeLimit,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                          ToggleSwitch(
                            checked: overallLimitEnabled,
                            onChanged: (v) => setSetting('overallLimitEnabled', v),
                          ),
                        ],
                      ),
                      
                      if(overallLimitEnabled) const SizedBox(height: 15),
                      
                      if (overallLimitEnabled) Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(l10n.dailyTotalLimit, 
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                              Text(
                                '${overallLimitHours.round()}h ${(overallLimitMinutes.round() ~/ 5 * 5)}m',
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 10),
                          
                          // Make sliders stretch to full width
                          Row(
                            children: [
                              Text(l10n.hours),
                              Expanded(
                                child: Slider(
                                  value: overallLimitHours,
                                  min: 0,
                                  max: 12,
                                  divisions: 12,
                                  label: overallLimitHours.round().toString(),
                                  onChanged: (value) {
                                    setState(() {
                                      overallLimitHours = value;
                                      _updateOverallLimit();
                                    });
                                  },
                                ),
                              ),
                              SizedBox(
                                width: 30,
                                child: Text(overallLimitHours.round().toString()),
                              ),
                            ],
                          ),
                          
                          Row(
                            children: [
                              Text(l10n.minutes),
                              Expanded(
                                child: Slider(
                                  value: overallLimitMinutes,
                                  min: 0,
                                  max: 55,
                                  divisions: 12,
                                  label: (overallLimitMinutes.round() ~/ 5 * 5).toString(),
                                  onChanged: (value) {
                                    setState(() {
                                      overallLimitMinutes = (value ~/ 5 * 5).toDouble();
                                      _updateOverallLimit();
                                    });
                                  },
                                ),
                              ),
                              SizedBox(
                                width: 30,
                                child: Text((overallLimitMinutes.round() ~/ 5 * 5).toString()),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 10),
                          
                          // Make progress bar stretch to full width
                          Row(
                            children: [
                              Text(l10n.currentUsage, 
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                              Text(
                                _formatDuration(totalScreenTime),
                                style: TextStyle(
                                  fontSize: 14, 
                                  fontWeight: FontWeight.w600,
                                  color: _getOverallStatusColor(),
                                ),
                              ),
                              
                              const SizedBox(width: 10),
                              
                              if (overallLimitEnabled && _getOverallLimitProgress() > 0)
                                Expanded(
                                  child: ProgressBar(
                                    value: _getOverallLimitProgress(),
                                    backgroundColor: FluentTheme.of(context).inactiveBackgroundColor,
                                    activeColor: _getOverallStatusColor(),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            // Application Limits section
            ApplicationLimits(
              appSummaries: appSummaries,
              controller: controller,
              onDataChanged: _loadData,
            ),
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

  double _getOverallLimitProgress() {
    if (!overallLimitEnabled) return 0;
    
    final limitDuration = Duration(
      hours: overallLimitHours.round(),
      minutes: (overallLimitMinutes.round() ~/ 5 * 5),
    );
    
    if (limitDuration.inMinutes == 0) return 0;
    
    double progress = totalScreenTime.inMinutes / limitDuration.inMinutes;
    return progress > 1 ? 1 : progress;
  }

  Color _getOverallStatusColor() {
    if (!overallLimitEnabled) {
      return Colors.grey;
    }
    
    final limitDuration = Duration(
      hours: overallLimitHours.round(),
      minutes: (overallLimitMinutes.round() ~/ 5 * 5),
    );
    
    if (limitDuration == Duration.zero) {
      return Colors.white;
    }

    if (totalScreenTime >= limitDuration) {
      return Colors.red;
    }

    double percentage = totalScreenTime.inMinutes / limitDuration.inMinutes;
    
    if (percentage > 0.9) {
      return Colors.orange;
    }

    if (percentage > 0.75) {
      return Colors.yellow;
    }

    return Colors.green;
  }

  String _formatDuration(Duration duration) {
    final l10n = AppLocalizations.of(context)!;
    
    if (duration == Duration.zero) {
      return l10n.durationNone;
    }

    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0 && minutes > 0) {
      return l10n.durationHoursMinutes(hours, minutes);
    } else if (hours > 0) {
      return "${hours}h";
    } else {
      return l10n.durationMinutesOnly(minutes);
    }
  }

  void _resetAllLimits() {
    final l10n = AppLocalizations.of(context)!;
    
    try {
      // Reset app-specific limits
      final apps = controller.getAllAppsSummary();
      for (final app in apps) {
        controller.updateAppLimit(app.appName, Duration.zero, false);
      }
      
      // Reset overall limit
      setState(() {
        overallLimitEnabled = false;
        overallLimitHours = 2.0;
        overallLimitMinutes = 0.0;
        settingsManager.updateSetting("limitsAlerts.overallLimit.enabled", false);
        settingsManager.updateSetting("limitsAlerts.overallLimit.hours", 2);
        settingsManager.updateSetting("limitsAlerts.overallLimit.minutes", 0);
      });
      
      controller.updateOverallLimit(Duration.zero, false);
      
      // Reload data to update UI
      _loadData();
    } catch (e) {
      setState(() {
        errorMessage = l10n.failedToLoadData(e.toString());
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
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      constraints: const BoxConstraints(
        minHeight: 200,
        maxHeight: 475,
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
              Text(
                l10n.applicationLimits,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              Button(
                child: Text(l10n.addLimit),
                onPressed: () => _showAddLimitDialog(context),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(width: 120, child: Text(l10n.tableName, style: const TextStyle(fontWeight: FontWeight.w600))),
                SizedBox(width: 120, child: Text(l10n.tableCategory, style: const TextStyle(fontWeight: FontWeight.w600))),
                SizedBox(width: 72, child: Text(l10n.tableDailyLimit, style: const TextStyle(fontWeight: FontWeight.w600))),
                SizedBox(width: 100, child: Text(l10n.tableCurrentUsage, style: const TextStyle(fontWeight: FontWeight.w600))),
                SizedBox(width: 55, child: Text(l10n.tableStatus, style: const TextStyle(fontWeight: FontWeight.w600))),
                SizedBox(width: 85, child: Text(l10n.tableActions, style: const TextStyle(fontWeight: FontWeight.w600))),
              ],
            ),
          ),
          Container(height: 1, color: FluentTheme.of(context).inactiveBackgroundColor),
          const SizedBox(height: 10),
          Expanded(
            child: widget.appSummaries.isEmpty 
              ? Center(child: Text(l10n.noApplicationsToDisplay))
              : SingleChildScrollView(
                  child: Column(
                    children: widget.appSummaries
                        .where((app) => app.appName.trim().isNotEmpty)
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
    final l10n = AppLocalizations.of(context)!;
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
            title: Text(l10n.addApplicationLimit),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.selectApplication),
                const SizedBox(height: 8),
                ComboBox<String>(
                  placeholder: Text(l10n.selectApplicationPlaceholder),
                  isExpanded: true,
                  items: allApps
                      .where((app) => app.appName.trim().isNotEmpty)
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
                    Text(l10n.enableLimit),
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
                    Text(l10n.hours),
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
                    Text(l10n.minutes),
                    SizedBox(
                      width: 200,
                      child: Slider(
                        value: minutes,
                        min: 0,
                        max: 55,
                        divisions: 12,
                        label: (minutes.round() ~/ 5 * 5).toString(),
                        onChanged: (value) {
                          setState(() {
                            minutes = (value ~/ 5 * 5).toDouble();
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
                child: Text(l10n.cancel),
                onPressed: () => Navigator.pop(context),
              ),
              FilledButton(
                child: Text(l10n.add),
                onPressed: () {
                  if (selectedApp != null) {
                    try {
                      final duration = Duration(
                        hours: hours.round(),
                        minutes: (minutes.round() ~/ 5 * 5),
                      );
                      widget.controller.updateAppLimit(selectedApp!, duration, limitEnabled);
                      widget.onDataChanged();
                      Navigator.pop(context);
                    } catch (e) {
                      showDialog(
                        context: context,
                        builder: (context) => ContentDialog(
                          title: Text(l10n.error),
                          content: Text(l10n.failedToLoadData(e.toString())),
                          actions: [
                            Button(
                              child: Text(l10n.ok),
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
    final l10n = AppLocalizations.of(context)!;
    double hours = app.dailyLimit.inHours.toDouble();
    double minutes = (app.dailyLimit.inMinutes % 60).toDouble();
    bool limitEnabled = app.limitStatus;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return ContentDialog(
            title: Text(l10n.editLimitTitle(app.appName)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(l10n.enableLimit),
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
                    Text(l10n.hours),
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
                    Text(l10n.minutes),
                    SizedBox(
                      width: 200,
                      child: Slider(
                        value: minutes,
                        min: 0,
                        max: 55,
                        divisions: 12,
                        label: (minutes.round() ~/ 5 * 5).toString(),
                        onChanged: (value) {
                          setState(() {
                            minutes = (value ~/ 5 * 5).toDouble();
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
                child: Text(l10n.cancel),
                onPressed: () => Navigator.pop(context),
              ),
              FilledButton(
                child: Text(l10n.save),
                onPressed: () {
                  try {
                    final duration = Duration(
                      hours: hours.round(),
                      minutes: (minutes.round() ~/ 5 * 5),
                    );
                    widget.controller.updateAppLimit(app.appName, duration, limitEnabled);
                    widget.onDataChanged();
                    Navigator.pop(context);
                  } catch (e) {
                    showDialog(
                      context: context,
                      builder: (context) => ContentDialog(
                        title: Text(l10n.error),
                        content: Text(l10n.failedToLoadData(e.toString())),
                        actions: [
                          Button(
                            child: Text(l10n.ok),
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
    final l10n = AppLocalizations.of(context)!;
    
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(width: 120, height: 20, child: Text(app.appName)),
              SizedBox(width: 120, height: 20, child: Text(app.category)),
              SizedBox(width: 72, height: 20, child: Text(_formatDuration(app.dailyLimit, l10n))),
              SizedBox(width: 100, height: 20, child: Text(_formatDuration(app.currentUsage, l10n))),
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
                    Text(app.limitStatus ? l10n.statusActive : l10n.statusOff),
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

  String _formatDuration(Duration duration, AppLocalizations l10n) {
    if (duration == Duration.zero) {
      return l10n.durationNone;
    }

    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0 && minutes > 0) {
      return l10n.durationHoursMinutes(hours, minutes);
    } else if (hours > 0) {
      return "${hours}h";
    } else {
      return l10n.durationMinutesOnly(minutes);
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
    final l10n = AppLocalizations.of(context)!;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(l10n.alertsLimitsTitle, style: FluentTheme.of(context).typography.subtitle),
        Row(
          children: [
            Button(
              onPressed: onRefresh,
              child: Row(
                children: [
                  const Icon(FluentIcons.refresh, size: 16),
                  const SizedBox(width: 10),
                  Text(l10n.refresh, style: const TextStyle(fontWeight: FontWeight.w600)),
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
              child: Row(
                children: [
                  const Icon(FluentIcons.sync, size: 16),
                  const SizedBox(width: 10),
                  Text(l10n.resetAll, style: const TextStyle(fontWeight: FontWeight.w600)),
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
    final l10n = AppLocalizations.of(context)!;
    
    await showDialog<String>(
      context: context,
      builder: (context) => ContentDialog(
        title: Text(l10n.resetSettingsTitle),
        content: Text(l10n.resetSettingsContent),
        actions: [
          Button(
            child: Text(l10n.resetAll),
            onPressed: () {
              Navigator.pop(context, 'Reset confirmed');
              onReset();
            },
          ),
          FilledButton(
            child: Text(l10n.cancel),
            onPressed: () => Navigator.pop(context, 'User canceled dialog'),
          ),
        ],
      ),
    );
  }
}