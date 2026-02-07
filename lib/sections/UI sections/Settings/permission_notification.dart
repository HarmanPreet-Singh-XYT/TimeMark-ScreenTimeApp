import 'package:fluent_ui/fluent_ui.dart';
import 'package:screentime/l10n/app_localizations.dart';
import 'package:screentime/utils/app_restart.dart';

/// A notification banner that appears when Input Monitoring permission is missing
class InputMonitoringPermissionBanner extends StatelessWidget {
  final VoidCallback onOpenSettings;

  const InputMonitoringPermissionBanner({
    super.key,
    required this.onOpenSettings,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(FluentIcons.warning, size: 16, color: Colors.orange),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.inputMonitoringPermissionTitle,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.inputMonitoringPermissionDescription,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[100],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: onOpenSettings,
            style: ButtonStyle(
              padding: WidgetStateProperty.all(
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              ),
            ),
            child: Text(
              l10n.openSettings,
              style: const TextStyle(fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}

/// A dialog that shows after user has granted permission, prompting for restart
class RestartRequiredDialog extends StatelessWidget {
  const RestartRequiredDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ContentDialog(
      title: Text(l10n.restartRequiredTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.restartRequiredDescription),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Icon(FluentIcons.info, size: 14, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.restartNote,
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        Button(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.restartLater),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.restartNow),
        ),
      ],
    );
  }

  /// Shows the restart dialog and restarts the app if user confirms
  static Future<void> show(BuildContext context) async {
    final shouldRestart = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const RestartRequiredDialog(),
    );

    if (shouldRestart == true) {
      try {
        await AppRestart.restart();
      } catch (e) {
        // Show error dialog if restart fails
        if (context.mounted) {
          await showDialog<void>(
            context: context,
            builder: (context) => ContentDialog(
              title: Text(AppLocalizations.of(context)!.restartFailedTitle),
              content: Text(AppLocalizations.of(context)!.restartFailedMessage),
              actions: [
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(AppLocalizations.of(context)!.ok),
                ),
              ],
            ),
          );
        }
      }
    }
  }
}
