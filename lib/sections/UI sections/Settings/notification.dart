import 'package:fluent_ui/fluent_ui.dart';
import 'package:screentime/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:screentime/sections/settings.dart';
import 'package:screentime/sections/UI sections/Settings/resuables.dart';
// ============== NOTIFICATION SECTION ==============

class NotificationSection extends StatelessWidget {
  const NotificationSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = context.watch<SettingsProvider>();

    return SettingsCard(
      title: l10n.notificationsSection,
      icon: FluentIcons.ringer,
      iconColor: Colors.purple,
      trailing: StatusBadge(
        isActive: settings.notificationsEnabled,
        activeText: 'On',
        inactiveText: 'Off',
      ),
      children: [
        SettingRow(
          title: l10n.notificationsTitle,
          description: l10n.notificationsAllDescription,
          control: ToggleSwitch(
            checked: settings.notificationsEnabled,
            onChanged: (value) =>
                settings.updateSetting('notificationsEnabled', value),
          ),
        ),
        if (settings.notificationsEnabled) ...[
          SettingRow(
            title: l10n.focusModeNotificationsTitle,
            description: l10n.focusModeNotificationsDescription,
            isSubSetting: true,
            control: ToggleSwitch(
              checked: settings.notificationsFocusMode,
              onChanged: (value) =>
                  settings.updateSetting('notificationsFocusMode', value),
            ),
          ),
          SettingRow(
            title: l10n.screenTimeNotificationsTitle,
            description: l10n.screenTimeNotificationsDescription,
            isSubSetting: true,
            control: ToggleSwitch(
              checked: settings.notificationsScreenTime,
              onChanged: (value) =>
                  settings.updateSetting('notificationsScreenTime', value),
            ),
          ),
          SettingRow(
            title: l10n.appScreenTimeNotificationsTitle,
            description: l10n.appScreenTimeNotificationsDescription,
            isSubSetting: true,
            control: ToggleSwitch(
              checked: settings.notificationsAppScreenTime,
              onChanged: (value) =>
                  settings.updateSetting('notificationsAppScreenTime', value),
            ),
          ),
          SettingRow(
            title: l10n.frequentAlertsTitle,
            description: l10n.frequentAlertsDescription,
            isSubSetting: true,
            showDivider: false,
            control: ComboBox<String>(
              value: settings.getReminderFrequency().toString(),
              items: [1, 5, 15, 30, 60].map((val) {
                return ComboBoxItem<String>(
                  value: val.toString(),
                  child: Text('$val min'),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  settings.updateSetting('reminderFrequency', int.parse(value));
                }
              },
            ),
          ),
        ],
      ],
    );
  }
}
