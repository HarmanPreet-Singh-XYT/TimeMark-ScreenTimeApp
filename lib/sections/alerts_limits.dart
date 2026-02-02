import 'package:fluent_ui/fluent_ui.dart';
import 'package:screentime/sections/controller/data_controllers/alerts_limits_data_controller.dart';
import 'package:screentime/sections/controller/settings_data_controller.dart';
import 'package:screentime/l10n/app_localizations.dart';
import 'UI sections/AlertsLimits/applicationlimit.dart';
import 'UI sections/AlertsLimits/notificationCard.dart';
import 'UI sections/AlertsLimits/overalllimit.dart';
import 'UI sections/AlertsLimits/quickStats.dart';

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

  bool overallLimitEnabled = false;
  double overallLimitHours = 2.0;
  double overallLimitMinutes = 0.0;

  List<AppUsageSummary> appSummaries = [];
  bool isLoading = true;
  String? errorMessage;
  Duration totalScreenTime = Duration.zero;

  @override
  void initState() {
    super.initState();
    controller = widget.controller ?? ScreenTimeDataController();
    settingsManager = widget.settingsManager ?? SettingsManager();

    popupAlerts = settingsManager.getSetting("limitsAlerts.popup");
    frequentAlerts = settingsManager.getSetting("limitsAlerts.frequent");
    soundAlerts = settingsManager.getSetting("limitsAlerts.sound");
    systemAlerts = settingsManager.getSetting("limitsAlerts.system");

    overallLimitEnabled =
        settingsManager.getSetting("limitsAlerts.overallLimit.enabled") ??
            false;
    overallLimitHours = settingsManager
            .getSetting("limitsAlerts.overallLimit.hours")
            ?.toDouble() ??
        2.0;
    overallLimitMinutes = settingsManager
            .getSetting("limitsAlerts.overallLimit.minutes")
            ?.toDouble() ??
        0.0;

    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      await controller.initialize();
      final allData = await controller.getAllData();

      if (mounted) {
        setState(() {
          appSummaries = (allData['appSummaries'] as List<dynamic>)
              .map((json) =>
                  AppUsageSummary.fromJson(json as Map<String, dynamic>))
              .toList();

          totalScreenTime = Duration(
              minutes: appSummaries.fold(
                  0, (sum, app) => sum + app.currentUsage.inMinutes));
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage =
              AppLocalizations.of(context)!.failedToLoadData(e.toString());
          isLoading = false;
        });
      }
    }
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
          settingsManager.updateSetting(
              "limitsAlerts.overallLimit.enabled", value);

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

    settingsManager.updateSetting(
        "limitsAlerts.overallLimit.hours", overallLimitHours.round());
    settingsManager.updateSetting("limitsAlerts.overallLimit.minutes",
        overallLimitMinutes.round() ~/ 5 * 5);
    controller.updateOverallLimit(duration, overallLimitEnabled);
  }

  void _resetAllLimits() {
    final l10n = AppLocalizations.of(context)!;

    try {
      final apps = controller.getAllAppsSummary();
      for (final app in apps) {
        controller.updateAppLimit(app.appName, Duration.zero, false);
      }

      setState(() {
        overallLimitEnabled = false;
        overallLimitHours = 2.0;
        overallLimitMinutes = 0.0;
        settingsManager.updateSetting(
            "limitsAlerts.overallLimit.enabled", false);
        settingsManager.updateSetting("limitsAlerts.overallLimit.hours", 2);
        settingsManager.updateSetting("limitsAlerts.overallLimit.minutes", 0);
      });

      controller.updateOverallLimit(Duration.zero, false);
      _loadData();
    } catch (e) {
      setState(() {
        errorMessage = l10n.failedToLoadData(e.toString());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: ProgressRing());
    }

    if (errorMessage != null) {
      return Center(
        child: _ErrorCard(
          message: errorMessage!,
          onRetry: _loadData,
        ),
      );
    }

    // Use SizedBox.expand to take all available space from parent
    return SizedBox.expand(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 1000;
          final isMedium = constraints.maxWidth >= 700;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              // Ensure minimum height fills the viewport
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - 48, // minus padding
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Header(
                    onReset: _resetAllLimits,
                    onRefresh: _loadData,
                  ),
                  const SizedBox(height: 24),

                  // Quick Stats Row
                  QuickStatsRow(
                    totalScreenTime: totalScreenTime,
                    appsWithLimits:
                        appSummaries.where((a) => a.limitStatus).length,
                    appsNearLimit:
                        appSummaries.where((a) => a.isAboutToReachLimit).length,
                    isMedium: isMedium,
                  ),
                  const SizedBox(height: 24),

                  // Main content
                  if (isWide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left - Application Limits (expanded)
                        Expanded(
                          flex: 3,
                          child: ApplicationLimitsCard(
                            appSummaries: appSummaries,
                            controller: controller,
                            onDataChanged: _loadData,
                          ),
                        ),
                        const SizedBox(width: 20),
                        // Right - Settings
                        SizedBox(
                          width: 320,
                          child: Column(
                            children: [
                              NotificationSettingsCard(
                                frequentAlerts: frequentAlerts,
                                systemAlerts: systemAlerts,
                                soundAlerts: soundAlerts,
                                popupAlerts: popupAlerts,
                                onChanged: setSetting,
                              ),
                              const SizedBox(height: 16),
                              OverallLimitCard(
                                enabled: overallLimitEnabled,
                                hours: overallLimitHours,
                                minutes: overallLimitMinutes,
                                totalScreenTime: totalScreenTime,
                                onEnabledChanged: (v) =>
                                    setSetting('overallLimitEnabled', v),
                                onHoursChanged: (v) {
                                  setState(() {
                                    overallLimitHours = v;
                                    _updateOverallLimit();
                                  });
                                },
                                onMinutesChanged: (v) {
                                  setState(() {
                                    overallLimitMinutes = v;
                                    _updateOverallLimit();
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  else
                    Column(
                      children: [
                        if (isMedium)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: NotificationSettingsCard(
                                  frequentAlerts: frequentAlerts,
                                  systemAlerts: systemAlerts,
                                  soundAlerts: soundAlerts,
                                  popupAlerts: popupAlerts,
                                  onChanged: setSetting,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: OverallLimitCard(
                                  enabled: overallLimitEnabled,
                                  hours: overallLimitHours,
                                  minutes: overallLimitMinutes,
                                  totalScreenTime: totalScreenTime,
                                  onEnabledChanged: (v) =>
                                      setSetting('overallLimitEnabled', v),
                                  onHoursChanged: (v) {
                                    setState(() {
                                      overallLimitHours = v;
                                      _updateOverallLimit();
                                    });
                                  },
                                  onMinutesChanged: (v) {
                                    setState(() {
                                      overallLimitMinutes = v;
                                      _updateOverallLimit();
                                    });
                                  },
                                ),
                              ),
                            ],
                          )
                        else ...[
                          NotificationSettingsCard(
                            frequentAlerts: frequentAlerts,
                            systemAlerts: systemAlerts,
                            soundAlerts: soundAlerts,
                            popupAlerts: popupAlerts,
                            onChanged: setSetting,
                          ),
                          const SizedBox(height: 16),
                          OverallLimitCard(
                            enabled: overallLimitEnabled,
                            hours: overallLimitHours,
                            minutes: overallLimitMinutes,
                            totalScreenTime: totalScreenTime,
                            onEnabledChanged: (v) =>
                                setSetting('overallLimitEnabled', v),
                            onHoursChanged: (v) {
                              setState(() {
                                overallLimitHours = v;
                                _updateOverallLimit();
                              });
                            },
                            onMinutesChanged: (v) {
                              setState(() {
                                overallLimitMinutes = v;
                                _updateOverallLimit();
                              });
                            },
                          ),
                        ],
                        const SizedBox(height: 16),
                        ApplicationLimitsCard(
                          appSummaries: appSummaries,
                          controller: controller,
                          onDataChanged: _loadData,
                        ),
                      ],
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// Error Card Widget
class _ErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorCard({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(24),
      constraints: const BoxConstraints(maxWidth: 400),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(FluentIcons.error_badge, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: onRetry,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(FluentIcons.refresh, size: 14),
                const SizedBox(width: 8),
                Text(l10n.retry),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Header Widget
class _Header extends StatelessWidget {
  final VoidCallback onReset;
  final VoidCallback onRefresh;

  const _Header({
    required this.onReset,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = FluentTheme.of(context);

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.alertsLimitsTitle,
                style: theme.typography.title?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Manage your screen time limits and notifications',
                style: theme.typography.caption?.copyWith(
                  color:
                      theme.typography.caption?.color?.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Tooltip(
          message: l10n.refresh,
          child: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child:
                  Icon(FluentIcons.refresh, size: 16, color: theme.accentColor),
            ),
            onPressed: onRefresh,
          ),
        ),
        const SizedBox(width: 8),
        Button(
          style: ButtonStyle(
            padding: WidgetStateProperty.all(
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(FluentIcons.reset, size: 14),
              const SizedBox(width: 8),
              Text(l10n.resetAll),
            ],
          ),
          onPressed: () => _showResetDialog(context),
        ),
      ],
    );
  }

  void _showResetDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;

    await showDialog<String>(
      context: context,
      builder: (context) => ContentDialog(
        title: Row(
          children: [
            Icon(FluentIcons.warning, color: Colors.orange, size: 24),
            const SizedBox(width: 12),
            Text(l10n.resetSettingsTitle),
          ],
        ),
        content: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(l10n.resetSettingsContent),
        ),
        actions: [
          Button(
            child: Text(l10n.cancel),
            onPressed: () => Navigator.pop(context),
          ),
          FilledButton(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(Colors.red),
            ),
            child: Text(l10n.resetAll),
            onPressed: () {
              Navigator.pop(context);
              onReset();
            },
          ),
        ],
      ),
    );
  }
}
