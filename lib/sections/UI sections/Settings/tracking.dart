import 'package:fluent_ui/fluent_ui.dart';
import 'package:screentime/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:screentime/sections/settings.dart';
import 'package:screentime/sections/UI sections/Settings/resuables.dart';
// ============== TRACKING SECTION ==============

class TrackingSection extends StatefulWidget {
  const TrackingSection({super.key});

  @override
  State<TrackingSection> createState() => _TrackingSectionState();
}

class _TrackingSectionState extends State<TrackingSection> {
  bool _showAdvanced = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = context.watch<SettingsProvider>();
    final theme = FluentTheme.of(context);

    return SettingsCard(
      title: l10n.activityTrackingSection,
      icon: FluentIcons.view,
      iconColor: Colors.teal,
      trailing: StatusBadge(
        isActive: settings.idleDetectionEnabled,
        activeText: 'Active',
        inactiveText: 'Disabled',
      ),
      children: [
        SettingRow(
          title: l10n.idleDetectionTitle,
          description: l10n.idleDetectionDescription,
          control: ToggleSwitch(
            checked: settings.idleDetectionEnabled,
            onChanged: (value) =>
                settings.updateSetting('idleDetectionEnabled', value),
          ),
        ),
        if (settings.idleDetectionEnabled) ...[
          SettingRow(
            title: l10n.idleTimeoutTitle,
            description: l10n
                .idleTimeoutDescription(settings.getFormattedIdleTimeout(l10n)),
            control: TimeoutButton(
              value: settings.getFormattedIdleTimeout(l10n),
              onPressed: () => _showIdleTimeoutDialog(context, settings, l10n),
            ),
          ),
        ],
        // Advanced Toggle
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: GestureDetector(
            onTap: () => setState(() => _showAdvanced = !_showAdvanced),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.inactiveBackgroundColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(FluentIcons.developer_tools, size: 14),
                    const SizedBox(width: 8),
                    Text(
                      'Advanced Options',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(width: 8),
                    AnimatedRotation(
                      turns: _showAdvanced ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(FluentIcons.chevron_down, size: 10),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: Column(
            children: [
              WarningBanner(
                message: l10n.advancedWarning,
                icon: FluentIcons.warning,
                color: Colors.orange,
              ),
              const SizedBox(height: 12),
              SettingRow(
                title: l10n.monitorAudioTitle,
                description: l10n.monitorAudioDescription,
                isSubSetting: true,
                control: ToggleSwitch(
                  checked: settings.monitorAudio,
                  onChanged: (value) =>
                      settings.updateSetting('monitorAudio', value),
                ),
              ),
              if (settings.monitorAudio)
                SettingRow(
                  title: l10n.audioSensitivityTitle,
                  description: l10n.audioSensitivityDescription(
                      settings.audioThreshold.toStringAsFixed(4)),
                  isSubSetting: true,
                  control: SizedBox(
                    width: 150,
                    child: Slider(
                      value: settings.audioThreshold,
                      min: 0.0001,
                      max: 0.1,
                      divisions: 100,
                      onChanged: (value) =>
                          settings.updateSetting('audioThreshold', value),
                    ),
                  ),
                ),
              SettingRow(
                title: l10n.monitorControllersTitle,
                description: l10n.monitorControllersDescription,
                isSubSetting: true,
                control: ToggleSwitch(
                  checked: settings.monitorControllers,
                  onChanged: (value) =>
                      settings.updateSetting('monitorControllers', value),
                ),
              ),
              SettingRow(
                title: l10n.monitorHIDTitle,
                description: l10n.monitorHIDDescription,
                isSubSetting: true,
                showDivider: false,
                control: ToggleSwitch(
                  checked: settings.monitorHIDDevices,
                  onChanged: (value) =>
                      settings.updateSetting('monitorHIDDevices', value),
                ),
              ),
            ],
          ),
          secondChild: const SizedBox.shrink(),
          crossFadeState: _showAdvanced
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          duration: const Duration(milliseconds: 200),
        ),
      ],
    );
  }

  Future<void> _showIdleTimeoutDialog(BuildContext context,
      SettingsProvider settings, AppLocalizations l10n) async {
    final result = await showDialog<int>(
      context: context,
      builder: (context) => IdleTimeoutDialog(
        currentValue: settings.idleTimeout,
        presets: settings.idleTimeoutPresets,
        l10n: l10n,
      ),
    );

    if (result != null) {
      settings.updateSetting('idleTimeout', result);
    }
  }
}
