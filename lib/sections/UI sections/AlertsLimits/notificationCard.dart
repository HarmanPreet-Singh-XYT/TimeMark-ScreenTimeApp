import 'package:fluent_ui/fluent_ui.dart';
import 'package:screentime/l10n/app_localizations.dart';
import './reusable.dart' as rub;

// Notification Settings Card
class NotificationSettingsCard extends StatelessWidget {
  final bool frequentAlerts;
  final bool systemAlerts;
  final bool soundAlerts;
  final bool popupAlerts;
  final Function(String, bool) onChanged;

  const NotificationSettingsCard({
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

    return rub.Card(
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
          rub.SettingTile(
            icon: FluentIcons.comment,
            title: l10n.popupAlerts,
            subtitle: 'Show popup notifications',
            value: popupAlerts,
            onChanged: (v) => onChanged('popup', v),
          ),
          rub.SettingTile(
            icon: FluentIcons.timer,
            title: l10n.frequentAlerts,
            subtitle: 'More frequent reminders',
            value: frequentAlerts,
            onChanged: (v) => onChanged('frequent', v),
          ),
          rub.SettingTile(
            icon: FluentIcons.volume3,
            title: l10n.soundAlerts,
            subtitle: 'Play sound with alerts',
            value: soundAlerts,
            onChanged: (v) => onChanged('sound', v),
          ),
          rub.SettingTile(
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
