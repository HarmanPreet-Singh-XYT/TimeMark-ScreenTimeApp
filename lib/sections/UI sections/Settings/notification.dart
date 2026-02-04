import 'package:fluent_ui/fluent_ui.dart';
import 'package:screentime/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:screentime/sections/settings.dart';
import 'package:screentime/sections/UI sections/Settings/resuables.dart';
import 'package:local_notifier/local_notifier.dart';
import 'dart:io' show Platform;

// ============== NOTIFICATION SECTION ==============

class NotificationSection extends StatefulWidget {
  final bool isHighlighted;

  const NotificationSection({
    super.key,
    this.isHighlighted = false,
  });

  @override
  State<NotificationSection> createState() => _NotificationSectionState();
}

class _NotificationSectionState extends State<NotificationSection>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  NotificationPermissionStatus? _permissionStatus;
  bool _isCheckingPermission = false;
  bool _isRequestingPermission = false;

  // Highlight animation
  late AnimationController _highlightController;
  late Animation<double> _highlightAnimation;
  bool _isHighlighted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Setup highlight animation controller
    _highlightController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5000),
    );

    _highlightAnimation = CurvedAnimation(
      parent: _highlightController,
      curve: Curves.easeInOut,
    );

    // Add listener to clear highlight when animation completes
    _highlightController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() => _isHighlighted = false);
          }
        });
      }
    });

    if (Platform.isMacOS) {
      _checkPermissionStatus();
    }

    // Start highlight if needed
    if (widget.isHighlighted) {
      _startHighlight();
    }
  }

  @override
  void didUpdateWidget(NotificationSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Start highlight when isHighlighted changes from false to true
    if (widget.isHighlighted && !oldWidget.isHighlighted) {
      _startHighlight();
    }
  }

  void _startHighlight() {
    setState(() => _isHighlighted = true);
    _highlightController.forward(from: 0);

    // Optionally repeat the pulse effect
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted && _isHighlighted) {
        _highlightController.forward(from: 0);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _highlightController.dispose();
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
      final l10n = AppLocalizations.of(context)!;
      return InfoBar(
        title: Text(l10n.permission_error),
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
        title: Text(l10n.notification_permission_denied),
        content: Text(l10n.notification_permission_denied_message),
        actions: [
          Button(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _openSystemSettings();
            },
            child: Text(l10n.open_settings),
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
    final l10n = AppLocalizations.of(context)!;

    if (_permissionStatus!.isDenied) {
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
                    l10n.notification_permission_denied,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.notification_permission_denied_hint,
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
              child: Text(l10n.open_settings,
                  style: const TextStyle(fontSize: 11)),
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
          color: theme.accentColor.withValues(alpha: 0.1),
          border: Border.all(color: theme.accentColor.withValues(alpha: 0.3)),
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
                    l10n.notification_permission_required,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: theme.accentColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.notification_permission_required_message,
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
                  : Text(l10n.allow_notifications,
                      style: const TextStyle(fontSize: 11)),
            ),
          ],
        ),
      );
    }

    // Permission granted - don't show banner
    return const SizedBox.shrink();
  }

  Widget _buildPermissionStatusBadge() {
    final l10n = AppLocalizations.of(context)!;
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
      text = l10n.permission_allowed;
    } else if (_permissionStatus!.isDenied) {
      color = Colors.orange;
      text = l10n.permission_denied;
    } else {
      color = Colors.grey;
      text = l10n.permission_not_set;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
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

  Color _getHighlightColor(FluentThemeData theme, bool isDark) {
    final baseColor = theme.accentColor;
    return isDark
        ? baseColor.withValues(alpha: 0.15)
        : baseColor.withValues(alpha: 0.08);
  }

  Border? _getHighlightBorder(FluentThemeData theme) {
    if (!_isHighlighted) return null;
    return Border.all(
      color: theme.accentColor.withValues(alpha: 0.4),
      width: 2,
    );
  }

  BoxShadow? _getHighlightShadow(FluentThemeData theme) {
    if (!_isHighlighted) return null;
    return BoxShadow(
      color: theme.accentColor.withValues(alpha: 0.2),
      blurRadius: 12,
      spreadRadius: 0,
      offset: const Offset(0, 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = context.watch<SettingsProvider>();
    final theme = FluentTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bool canEnableNotifications =
        !Platform.isMacOS || (_permissionStatus?.isGranted ?? false);

    final bool notificationsEnabled =
        settings.notificationsEnabled && canEnableNotifications;

    return AnimatedBuilder(
      animation: _highlightAnimation,
      builder: (context, child) {
        // Calculate pulsing opacity
        final pulseValue = _isHighlighted
            ? (0.3 + (0.7 * (1 - _highlightAnimation.value).abs()))
            : 0.0;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: _isHighlighted
                ? _getHighlightColor(theme, isDark).withValues(
                    alpha: _getHighlightColor(theme, isDark).a * pulseValue)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: _getHighlightBorder(theme),
            boxShadow: _isHighlighted && _getHighlightShadow(theme) != null
                ? [_getHighlightShadow(theme)!]
                : null,
          ),
          child: child,
        );
      },
      child: SettingsCard(
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
              activeText: l10n.on,
              inactiveText: l10n.off,
            ),
          ],
        ),
        children: [
          _buildPermissionWarning(context),
          SettingRow(
            title: l10n.notificationsTitle,
            description:
                Platform.isMacOS && !(_permissionStatus?.isGranted ?? false)
                    ? l10n.enable_notification_permission_hint
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
                    child: Text(l10n.minutes_format(val)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    settings.updateSetting(
                        'reminderFrequency', int.parse(value));
                  }
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
