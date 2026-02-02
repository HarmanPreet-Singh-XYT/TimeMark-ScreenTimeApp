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
    final l10n = AppLocalizations.of(context)!;
    final theme = FluentTheme.of(context);

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
                  _QuickStatsRow(
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
                          child: _ApplicationLimitsCard(
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
                              _NotificationSettingsCard(
                                frequentAlerts: frequentAlerts,
                                systemAlerts: systemAlerts,
                                soundAlerts: soundAlerts,
                                popupAlerts: popupAlerts,
                                onChanged: setSetting,
                              ),
                              const SizedBox(height: 16),
                              _OverallLimitCard(
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
                                child: _NotificationSettingsCard(
                                  frequentAlerts: frequentAlerts,
                                  systemAlerts: systemAlerts,
                                  soundAlerts: soundAlerts,
                                  popupAlerts: popupAlerts,
                                  onChanged: setSetting,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _OverallLimitCard(
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
                          _NotificationSettingsCard(
                            frequentAlerts: frequentAlerts,
                            systemAlerts: systemAlerts,
                            soundAlerts: soundAlerts,
                            popupAlerts: popupAlerts,
                            onChanged: setSetting,
                          ),
                          const SizedBox(height: 16),
                          _OverallLimitCard(
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
                        _ApplicationLimitsCard(
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
        color: Colors.red.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.2)),
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
                  color: theme.typography.caption?.color?.withOpacity(0.7),
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
                color: theme.accentColor.withOpacity(0.1),
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

// Quick Stats Row
class _QuickStatsRow extends StatelessWidget {
  final Duration totalScreenTime;
  final int appsWithLimits;
  final int appsNearLimit;
  final bool isMedium;

  const _QuickStatsRow({
    required this.totalScreenTime,
    required this.appsWithLimits,
    required this.appsNearLimit,
    required this.isMedium,
  });

  @override
  Widget build(BuildContext context) {
    final cards = [
      _StatChip(
        icon: FluentIcons.clock,
        label: 'Today\'s Screen Time',
        value: _formatDuration(totalScreenTime),
        color: const Color(0xFF3B82F6),
        lightBg: const Color(0xFFEFF6FF),
      ),
      _StatChip(
        icon: FluentIcons.shield,
        label: 'Active Limits',
        value: appsWithLimits.toString(),
        color: const Color(0xFF10B981),
        lightBg: const Color(0xFFECFDF5),
      ),
      _StatChip(
        icon: FluentIcons.warning,
        label: 'Near Limit',
        value: appsNearLimit.toString(),
        color: appsNearLimit > 0
            ? const Color(0xFFF59E0B)
            : const Color(0xFF6B7280),
        lightBg: appsNearLimit > 0
            ? const Color(0xFFFFFBEB)
            : const Color(0xFFF9FAFB),
      ),
    ];

    if (isMedium) {
      return Row(
        children: [
          Expanded(child: cards[0]),
          const SizedBox(width: 12),
          Expanded(child: cards[1]),
          const SizedBox(width: 12),
          Expanded(child: cards[2]),
        ],
      );
    } else {
      return Column(
        children: [
          cards[0],
          const SizedBox(height: 8),
          cards[1],
          const SizedBox(height: 8),
          cards[2],
        ],
      );
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours > 0) return '${hours}h ${minutes}m';
    return '${minutes}m';
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color lightBg;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.lightBg,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? color.withOpacity(0.15) : lightBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? color.withOpacity(0.3) : color.withOpacity(0.15),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? color.withOpacity(0.2) : color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? Colors.white.withOpacity(0.6)
                        : const Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Notification Settings Card
class _NotificationSettingsCard extends StatelessWidget {
  final bool frequentAlerts;
  final bool systemAlerts;
  final bool soundAlerts;
  final bool popupAlerts;
  final Function(String, bool) onChanged;

  const _NotificationSettingsCard({
    required this.frequentAlerts,
    required this.systemAlerts,
    required this.soundAlerts,
    required this.popupAlerts,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = FluentTheme.of(context);

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(FluentIcons.ringer,
                    size: 18, color: theme.accentColor),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.notificationsSettings,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _SettingTile(
            icon: FluentIcons.comment,
            title: l10n.popupAlerts,
            subtitle: 'Show popup notifications',
            value: popupAlerts,
            onChanged: (v) => onChanged('popup', v),
          ),
          _SettingTile(
            icon: FluentIcons.timer,
            title: l10n.frequentAlerts,
            subtitle: 'More frequent reminders',
            value: frequentAlerts,
            onChanged: (v) => onChanged('frequent', v),
          ),
          _SettingTile(
            icon: FluentIcons.volume3,
            title: l10n.soundAlerts,
            subtitle: 'Play sound with alerts',
            value: soundAlerts,
            onChanged: (v) => onChanged('sound', v),
          ),
          _SettingTile(
            icon: FluentIcons.system,
            title: l10n.systemAlerts,
            subtitle: 'System tray notifications',
            value: systemAlerts,
            onChanged: (v) => onChanged('system', v),
            showDivider: false,
          ),
        ],
      ),
    );
  }
}

class _SettingTile extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final Function(bool) onChanged;
  final bool showDivider;

  const _SettingTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.showDivider = true,
  });

  @override
  State<_SettingTile> createState() => _SettingTileState();
}

class _SettingTileState extends State<_SettingTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: _isHovered
                  ? theme.accentColor.withOpacity(0.05)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(widget.icon,
                    size: 16, color: theme.accentColor.withOpacity(0.7)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        widget.subtitle,
                        style: theme.typography.caption?.copyWith(
                          fontSize: 11,
                          color:
                              theme.typography.caption?.color?.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                ToggleSwitch(
                  checked: widget.value,
                  onChanged: widget.onChanged,
                ),
              ],
            ),
          ),
        ),
        if (widget.showDivider)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Container(
              height: 1,
              color: theme.inactiveBackgroundColor.withOpacity(0.5),
            ),
          ),
      ],
    );
  }
}

// Overall Limit Card
class _OverallLimitCard extends StatelessWidget {
  final bool enabled;
  final double hours;
  final double minutes;
  final Duration totalScreenTime;
  final Function(bool) onEnabledChanged;
  final Function(double) onHoursChanged;
  final Function(double) onMinutesChanged;

  const _OverallLimitCard({
    required this.enabled,
    required this.hours,
    required this.minutes,
    required this.totalScreenTime,
    required this.onEnabledChanged,
    required this.onHoursChanged,
    required this.onMinutesChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = FluentTheme.of(context);
    final limitDuration = Duration(
      hours: hours.round(),
      minutes: (minutes.round() ~/ 5 * 5),
    );
    final progress = _calculateProgress(limitDuration);
    final statusColor = _getStatusColor(limitDuration);

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child:
                    Icon(FluentIcons.stopwatch, size: 18, color: statusColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.overallScreenTimeLimit,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              ToggleSwitch(
                checked: enabled,
                onChanged: onEnabledChanged,
              ),
            ],
          ),
          if (enabled) ...[
            const SizedBox(height: 20),

            // Time display
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: statusColor.withOpacity(0.15)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _TimeDisplay(
                        value: hours.round(),
                        label: l10n.hours,
                        color: statusColor,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          ':',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w300,
                            color: statusColor,
                          ),
                        ),
                      ),
                      _TimeDisplay(
                        value: minutes.round() ~/ 5 * 5,
                        label: l10n.minutes,
                        color: statusColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: SizedBox(
                      height: 6,
                      width: double.infinity,
                      child: ProgressBar(
                        value: progress * 100,
                        backgroundColor: theme.inactiveBackgroundColor,
                        activeColor: statusColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_formatDuration(totalScreenTime)} / ${_formatDuration(limitDuration)} used',
                    style: TextStyle(
                      fontSize: 12,
                      color: statusColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Sliders
            _SliderRow(
              label: l10n.hours,
              value: hours,
              max: 12,
              divisions: 12,
              onChanged: onHoursChanged,
            ),
            const SizedBox(height: 8),
            _SliderRow(
              label: l10n.minutes,
              value: minutes,
              max: 55,
              divisions: 11,
              step: 5,
              onChanged: onMinutesChanged,
            ),
          ],
        ],
      ),
    );
  }

  double _calculateProgress(Duration limit) {
    if (!enabled || limit.inMinutes == 0) return 0;
    final progress = totalScreenTime.inMinutes / limit.inMinutes;
    return progress > 1 ? 1 : progress;
  }

  Color _getStatusColor(Duration limit) {
    if (!enabled) return Colors.grey;
    if (limit == Duration.zero) return Colors.grey;

    final percentage = totalScreenTime.inMinutes / limit.inMinutes;

    if (percentage >= 1) return Colors.red;
    if (percentage > 0.9) return Colors.orange;
    if (percentage > 0.75) return const Color(0xFFEAB308);
    return const Color(0xFF10B981);
  }

  String _formatDuration(Duration duration) {
    final h = duration.inHours;
    final m = duration.inMinutes % 60;
    if (h > 0 && m > 0) return '${h}h ${m}m';
    if (h > 0) return '${h}h';
    return '${m}m';
  }
}

class _TimeDisplay extends StatelessWidget {
  final int value;
  final String label;
  final Color color;

  const _TimeDisplay({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value.toString().padLeft(2, '0'),
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: color.withOpacity(0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _SliderRow extends StatelessWidget {
  final String label;
  final double value;
  final double max;
  final int divisions;
  final int step;
  final Function(double) onChanged;

  const _SliderRow({
    required this.label,
    required this.value,
    required this.max,
    required this.divisions,
    this.step = 1,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final displayValue =
        step > 1 ? (value.round() ~/ step * step) : value.round();

    return Row(
      children: [
        SizedBox(
          width: 55,
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          child: Slider(
            value: value,
            min: 0,
            max: max,
            divisions: divisions,
            onChanged: (v) =>
                onChanged(step > 1 ? (v ~/ step * step).toDouble() : v),
          ),
        ),
        Container(
          width: 36,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: theme.accentColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            displayValue.toString(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: theme.accentColor,
            ),
          ),
        ),
      ],
    );
  }
}

// Application Limits Card
class _ApplicationLimitsCard extends StatelessWidget {
  final List<AppUsageSummary> appSummaries;
  final ScreenTimeDataController controller;
  final VoidCallback onDataChanged;

  const _ApplicationLimitsCard({
    required this.appSummaries,
    required this.controller,
    required this.onDataChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = FluentTheme.of(context);
    final filteredApps =
        appSummaries.where((app) => app.appName.trim().isNotEmpty).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        return _Card(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(FluentIcons.app_icon_default,
                          size: 18, color: theme.accentColor),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            l10n.applicationLimits,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '${filteredApps.length} applications tracked',
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.typography.caption?.color
                                  ?.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    FilledButton(
                      style: ButtonStyle(
                        padding: WidgetStateProperty.all(
                          const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(FluentIcons.add, size: 12),
                          const SizedBox(width: 6),
                          Text(l10n.addLimit),
                        ],
                      ),
                      onPressed: () => _showAddLimitDialog(context),
                    ),
                  ],
                ),
              ),

              // Table header - FIXED column spacing
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: theme.accentColor.withOpacity(0.03),
                  border: Border(
                    top: BorderSide(
                        color: theme.inactiveBackgroundColor.withOpacity(0.5)),
                    bottom: BorderSide(
                        color: theme.inactiveBackgroundColor.withOpacity(0.5)),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text('Application', style: _headerStyle),
                    ),
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text('Category', style: _headerStyle),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text('Daily Limit', style: _headerStyle),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text('Current Usage', style: _headerStyle),
                      ),
                    ),
                    const SizedBox(
                      width: 50,
                      child: Text('Edit',
                          style: _headerStyle, textAlign: TextAlign.center),
                    ),
                  ],
                ),
              ),

              // App list
              if (filteredApps.isEmpty)
                Container(
                  height: 300, // Fixed height for empty state
                  padding: const EdgeInsets.all(40),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          FluentIcons.app_icon_default,
                          size: 48,
                          color: theme.inactiveColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.noApplicationsToDisplay,
                          style: TextStyle(color: theme.inactiveColor),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...filteredApps.asMap().entries.map((entry) {
                  final index = entry.key;
                  final app = entry.value;
                  return _AppRow(
                    app: app,
                    onEdit: () => _showEditLimitDialog(context, app),
                    isLast: index == filteredApps.length - 1,
                  );
                }),

              // Bottom padding
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  static const _headerStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: Color(0xFF6B7280),
  );

  void _showAddLimitDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = FluentTheme.of(context);
    String? selectedApp;
    double hours = 1.0;
    double minutes = 0.0;
    bool limitEnabled = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final totalMinutes = (hours * 60 + minutes).round();
          final formattedTime = _formatDuration(hours.round(), minutes.round());

          return ContentDialog(
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    FluentIcons.add,
                    color: theme.accentColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    l10n.addApplicationLimit,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: 420,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionLabel(l10n.selectApplication),
                  const SizedBox(height: 8),
                  ComboBox<String>(
                    placeholder: Text(
                      l10n.selectApplicationPlaceholder,
                      style: TextStyle(
                        color: theme.resources.textFillColorSecondary,
                      ),
                    ),
                    isExpanded: true,
                    items: appSummaries
                        .where((app) => app.appName.trim().isNotEmpty)
                        .map((app) => ComboBoxItem<String>(
                              value: app.appName,
                              child: Text(
                                app.appName,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ))
                        .toList(),
                    value: selectedApp,
                    onChanged: (value) => setState(() => selectedApp = value),
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  _buildToggleRow(
                    context: context,
                    label: l10n.enableLimit,
                    value: limitEnabled,
                    onChanged: (value) => setState(() => limitEnabled = value),
                  ),
                  const SizedBox(height: 24),
                  AnimatedOpacity(
                    opacity: limitEnabled ? 1.0 : 0.5,
                    duration: const Duration(milliseconds: 200),
                    child: IgnorePointer(
                      ignoring: !limitEnabled,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionLabel(l10n.dailyLimit),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: theme.accentColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              formattedTime,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: theme.accentColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _SliderRow(
                            label: l10n.hours,
                            value: hours,
                            max: 12,
                            divisions: 12,
                            onChanged: (v) => setState(() => hours = v),
                          ),
                          const SizedBox(height: 12),
                          _SliderRow(
                            label: l10n.minutes,
                            value: minutes,
                            max: 55,
                            divisions: 11,
                            step: 5,
                            onChanged: (v) => setState(() => minutes = v),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              Button(
                child: Text(l10n.cancel),
                onPressed: () => Navigator.pop(context),
              ),
              FilledButton(
                onPressed: selectedApp != null && totalMinutes > 0
                    ? () {
                        final duration = Duration(
                          hours: hours.round(),
                          minutes: (minutes.round() ~/ 5 * 5),
                        );
                        controller.updateAppLimit(
                            selectedApp!, duration, limitEnabled);
                        onDataChanged();
                        Navigator.pop(context);
                      }
                    : null,
                child: Text(l10n.add),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showEditLimitDialog(BuildContext context, AppUsageSummary app) {
    final l10n = AppLocalizations.of(context)!;
    final theme = FluentTheme.of(context);
    double hours = app.dailyLimit.inHours.toDouble();
    double minutes = (app.dailyLimit.inMinutes % 60).toDouble();
    bool limitEnabled = app.limitStatus;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final formattedTime = _formatDuration(hours.round(), minutes.round());

          return ContentDialog(
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    FluentIcons.edit,
                    color: theme.accentColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    l10n.editLimitTitle(app.appName),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: 420,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildToggleRow(
                    context: context,
                    label: l10n.enableLimit,
                    value: limitEnabled,
                    onChanged: (value) => setState(() => limitEnabled = value),
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  AnimatedOpacity(
                    opacity: limitEnabled ? 1.0 : 0.5,
                    duration: const Duration(milliseconds: 200),
                    child: IgnorePointer(
                      ignoring: !limitEnabled,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionLabel(l10n.dailyLimit),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: theme.accentColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              formattedTime,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: theme.accentColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _SliderRow(
                            label: l10n.hours,
                            value: hours,
                            max: 12,
                            divisions: 12,
                            onChanged: (v) => setState(() => hours = v),
                          ),
                          const SizedBox(height: 12),
                          _SliderRow(
                            label: l10n.minutes,
                            value: minutes,
                            max: 55,
                            divisions: 11,
                            step: 5,
                            onChanged: (v) => setState(() => minutes = v),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              Button(
                child: Text(l10n.cancel),
                onPressed: () => Navigator.pop(context),
              ),
              FilledButton(
                child: Text(l10n.save),
                onPressed: () {
                  final duration = Duration(
                    hours: hours.round(),
                    minutes: (minutes.round() ~/ 5 * 5),
                  );
                  controller.updateAppLimit(
                      app.appName, duration, limitEnabled);
                  onDataChanged();
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      ),
    );
  }

  // Helper Widgets

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
    );
  }

  Widget _buildToggleRow({
    required BuildContext context,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = FluentTheme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: theme.resources.dividerStrokeColorDefault,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          ToggleSwitch(
            checked: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  String _formatDuration(int hours, int minutes) {
    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else if (minutes > 0) {
      return '${minutes}m';
    }
    return '0m';
  }
}

class _AppRow extends StatefulWidget {
  final AppUsageSummary app;
  final VoidCallback onEdit;
  final bool isLast;

  const _AppRow({
    required this.app,
    required this.onEdit,
    this.isLast = false,
  });

  @override
  State<_AppRow> createState() => _AppRowState();
}

class _AppRowState extends State<_AppRow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final statusColor = _getStatusColor();
    final progress = _calculateProgress();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: _isHovered
                  ? theme.accentColor.withOpacity(0.04)
                  : Colors.transparent,
            ),
            child: Row(
              children: [
                // App name with icon - flex 3
                Expanded(
                  flex: 3,
                  child: Row(
                    children: [
                      // Container(
                      //   width: 32,
                      //   height: 32,
                      //   decoration: BoxDecoration(
                      //     color: statusColor.withOpacity(0.1),
                      //     borderRadius: BorderRadius.circular(6),
                      //   ),
                      //   child: Center(
                      //     child: Text(
                      //       widget.app.appName.isNotEmpty
                      //           ? widget.app.appName[0].toUpperCase()
                      //           : '?',
                      //       style: TextStyle(
                      //         fontWeight: FontWeight.w600,
                      //         fontSize: 13,
                      //         color: statusColor,
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      // const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.app.appName,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: statusColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  widget.app.limitStatus ? 'Active' : 'Off',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: statusColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Category - flex 2
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      widget.app.category,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.typography.body?.color?.withOpacity(0.7),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),

                // Daily limit - flex 2
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      _formatDuration(widget.app.dailyLimit, l10n),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color:
                            widget.app.limitStatus ? null : theme.inactiveColor,
                      ),
                    ),
                  ),
                ),

                // Current usage with progress bar - flex 3
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Row(
                      children: [
                        Text(
                          _formatDuration(widget.app.currentUsage, l10n),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                        if (widget.app.limitStatus &&
                            widget.app.dailyLimit != Duration.zero) ...[
                          const SizedBox(width: 10),
                          Expanded(
                            child: Container(
                              height: 4,
                              decoration: BoxDecoration(
                                color: theme.inactiveBackgroundColor,
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: progress.clamp(0.0, 1.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: statusColor,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${(progress * 100).toInt()}%',
                            style: TextStyle(
                              fontSize: 10,
                              color: theme.typography.caption?.color
                                  ?.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // Edit button - fixed width
                SizedBox(
                  width: 50,
                  child: Center(
                    child: IconButton(
                      icon: Icon(
                        FluentIcons.edit,
                        size: 14,
                        color: _isHovered
                            ? theme.accentColor
                            : theme.inactiveColor,
                      ),
                      onPressed: widget.onEdit,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (!widget.isLast)
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            color: theme.inactiveBackgroundColor.withOpacity(0.3),
          ),
      ],
    );
  }

  double _calculateProgress() {
    if (!widget.app.limitStatus || widget.app.dailyLimit == Duration.zero) {
      return 0;
    }
    final progress =
        widget.app.currentUsage.inMinutes / widget.app.dailyLimit.inMinutes;
    return progress > 1 ? 1 : progress;
  }

  Color _getStatusColor() {
    if (!widget.app.limitStatus) return Colors.grey;
    if (widget.app.dailyLimit == Duration.zero) return Colors.grey;
    if (widget.app.currentUsage >= widget.app.dailyLimit) return Colors.red;
    if (widget.app.isAboutToReachLimit) return Colors.orange;
    if (widget.app.percentageOfLimitUsed > 0.75) {
      return const Color(0xFFEAB308);
    }
    return const Color(0xFF10B981);
  }

  String _formatDuration(Duration duration, AppLocalizations l10n) {
    if (duration == Duration.zero) return l10n.durationNone;
    final h = duration.inHours;
    final m = duration.inMinutes % 60;
    if (h > 0 && m > 0) return l10n.durationHoursMinutes(h, m);
    if (h > 0) return '${h}h';
    return l10n.durationMinutesOnly(m);
  }
}

// Reusable Card Widget
class _Card extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;

  const _Card({required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    return Container(
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.micaBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.inactiveBackgroundColor,
          width: 1,
        ),
      ),
      child: child,
    );
  }
}
