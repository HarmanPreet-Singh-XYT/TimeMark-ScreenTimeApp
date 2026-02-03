import 'package:fluent_ui/fluent_ui.dart';
import 'package:screentime/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:screentime/sections/settings.dart';
import 'package:screentime/sections/UI sections/Settings/resuables.dart';
import 'package:local_notifier/local_notifier.dart';
import 'dart:io' show Platform;

// ============== NOTIFICATION SECTION ==============

class NotificationSection extends StatefulWidget {
  const NotificationSection({super.key});

  @override
  State<NotificationSection> createState() => _NotificationSectionState();
}

class _NotificationSectionState extends State<NotificationSection>
    with WidgetsBindingObserver {
  NotificationPermissionStatus? _permissionStatus;
  bool _isCheckingPermission = false;
  bool _isRequestingPermission = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (Platform.isMacOS) {
      _checkPermissionStatus();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // When app comes back to foreground, re-check permission
    // This handles cases where user changed permission in System Settings
    if (state == AppLifecycleState.resumed && Platform.isMacOS) {
      _checkPermissionStatus();
    }
  }

  Future<void> _checkPermissionStatus() async {
    setState(() => _isCheckingPermission = true);
    try {
      final status = await localNotifier.checkPermission();
      if (mounted) {
        setState(() {
          _permissionStatus = status;
          _isCheckingPermission = false;
        });
      }
    } catch (e) {
      debugPrint('Error checking notification permission: $e');
      if (mounted) {
        setState(() => _isCheckingPermission = false);
      }
    }
  }

  Future<void> _requestPermission(SettingsProvider settings) async {
    setState(() => _isRequestingPermission = true);
    try {
      final granted = await localNotifier.requestPermission();

      if (mounted) {
        if (granted) {
          // Permission granted - enable all notifications
          await _enableAllNotifications(settings);
          await _checkPermissionStatus();

          // No InfoBar shown - the badge update is enough feedback
        } else {
          // Permission denied
          if (mounted) {
            await _showPermissionDeniedDialog(context);
          }
        }
      }
    } catch (e) {
      debugPrint('Error requesting notification permission: $e');
      if (mounted) {
        _showErrorInfoBar(context, e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isRequestingPermission = false);
      }
    }
  }

  Future<void> _enableAllNotifications(SettingsProvider settings) async {
    await settings.updateSetting('notificationsEnabled', true);
    await settings.updateSetting('notificationsFocusMode', true);
    await settings.updateSetting('notificationsScreenTime', true);
    await settings.updateSetting('notificationsAppScreenTime', true);
  }

  Future<void> _openSystemSettings() async {
    try {
      final opened = await localNotifier.openNotificationSettings();
      if (!opened && mounted) {
        _showErrorInfoBar(context, 'Failed to open System Settings');
      }
    } catch (e) {
      debugPrint('Error opening system settings: $e');
      if (mounted) {
        _showErrorInfoBar(context, e.toString());
      }
    }
  }

  void _showErrorInfoBar(BuildContext context, String error) {
    displayInfoBar(context, builder: (context, close) {
      return InfoBar(
        title: const Text('Permission Error'),
        content: Text(error),
        severity: InfoBarSeverity.error,
        onClose: close,
      );
    });
  }

  Future<void> _showPermissionDeniedDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;

    await showDialog<void>(
      context: context,
      builder: (context) => ContentDialog(
        title: const Text('Notification Permission Denied'),
        content: const Text(
          'ScreenTime needs notification permission to send you alerts and reminders.\n\n'
          'Would you like to open System Settings to enable notifications?',
        ),
        actions: [
          Button(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _openSystemSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleNotificationToggle(
      bool value, SettingsProvider settings) async {
    if (!Platform.isMacOS) {
      // Non-macOS platforms - just toggle
      settings.updateSetting('notificationsEnabled', value);
      return;
    }

    // macOS - always check current permission status first
    await _checkPermissionStatus();

    if (value) {
      // User wants to enable notifications
      if (_permissionStatus?.isNotDetermined ?? false) {
        // Permission not yet requested - request it
        await _requestPermission(settings);
      } else if (_permissionStatus?.isDenied ?? false) {
        // Permission was denied - show dialog to open settings
        await _showPermissionDeniedDialog(context);
      } else if (_permissionStatus?.isGranted ?? false) {
        // Permission already granted - just enable
        settings.updateSetting('notificationsEnabled', value);
      } else {
        // Unknown status - try requesting
        await _requestPermission(settings);
      }
    } else {
      // User wants to disable notifications - just disable
      settings.updateSetting('notificationsEnabled', value);
    }
  }

  Widget _buildPermissionWarning(BuildContext context) {
    if (!Platform.isMacOS) return const SizedBox.shrink();
    if (_isCheckingPermission) return const SizedBox.shrink();
    if (_permissionStatus == null) return const SizedBox.shrink();

    final theme = FluentTheme.of(context);

    if (_permissionStatus!.isDenied) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          border: Border.all(color: Colors.orange.withOpacity(0.3)),
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
                    'Notification Permission Denied',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Open System Settings to enable notifications for ScreenTime.',
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
              onPressed: _openSystemSettings,
              style: ButtonStyle(
                padding: WidgetStateProperty.all(
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
              ),
              child:
                  const Text('Open Settings', style: TextStyle(fontSize: 11)),
            ),
          ],
        ),
      );
    }

    if (_permissionStatus!.isNotDetermined) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.accentColor.withOpacity(0.1),
          border: Border.all(color: theme.accentColor.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Icon(FluentIcons.info, size: 16, color: theme.accentColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notification Permission Required',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: theme.accentColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'ScreenTime needs permission to send you notifications.',
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
              onPressed: _isRequestingPermission
                  ? null
                  : () => _requestPermission(context.read<SettingsProvider>()),
              child: _isRequestingPermission
                  ? const SizedBox(
                      width: 12,
                      height: 12,
                      child: ProgressRing(strokeWidth: 2),
                    )
                  : const Text('Allow Notifications',
                      style: TextStyle(fontSize: 11)),
            ),
          ],
        ),
      );
    }

    // Permission granted - don't show banner
    return const SizedBox.shrink();
  }

  Widget _buildPermissionStatusBadge() {
    if (!Platform.isMacOS) return const SizedBox.shrink();
    if (_isCheckingPermission) {
      return const SizedBox(
        width: 12,
        height: 12,
        child: ProgressRing(strokeWidth: 2),
      );
    }
    if (_permissionStatus == null) return const SizedBox.shrink();

    Color color;
    String text;

    if (_permissionStatus!.isGranted) {
      color = Colors.green;
      text = 'Allowed';
    } else if (_permissionStatus!.isDenied) {
      color = Colors.orange;
      text = 'Denied';
    } else {
      color = Colors.grey;
      text = 'Not Set';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = context.watch<SettingsProvider>();

    // On macOS, if permission is denied or not determined, force notifications off
    final bool canEnableNotifications =
        !Platform.isMacOS || (_permissionStatus?.isGranted ?? false);

    final bool notificationsEnabled =
        settings.notificationsEnabled && canEnableNotifications;

    return SettingsCard(
      title: l10n.notificationsSection,
      icon: FluentIcons.ringer,
      iconColor: Colors.purple,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (Platform.isMacOS) ...[
            _buildPermissionStatusBadge(),
            const SizedBox(width: 8),
          ],
          StatusBadge(
            isActive: notificationsEnabled,
            activeText: 'On',
            inactiveText: 'Off',
          ),
        ],
      ),
      children: [
        _buildPermissionWarning(context),
        SettingRow(
          title: l10n.notificationsTitle,
          description:
              Platform.isMacOS && !(_permissionStatus?.isGranted ?? false)
                  ? 'Enable notification permission to receive alerts'
                  : l10n.notificationsAllDescription,
          control: ToggleSwitch(
            checked: notificationsEnabled,
            onChanged: (value) => _handleNotificationToggle(value, settings),
          ),
        ),
        if (notificationsEnabled) ...[
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
              value: settings.reminderFrequency.toString(),
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
