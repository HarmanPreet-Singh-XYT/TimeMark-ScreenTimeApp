import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:screentime/l10n/app_localizations.dart';
import 'package:screentime/main.dart';
import '../../controller/notification_controller.dart';
import '../../controller/settings_data_controller.dart';
import 'dart:io' show Platform;

class NotificationPermissionBanner extends StatefulWidget {
  const NotificationPermissionBanner({super.key});

  @override
  State<NotificationPermissionBanner> createState() =>
      _NotificationPermissionBannerState();
}

class _NotificationPermissionBannerState
    extends State<NotificationPermissionBanner> with RouteAware {
  final NotificationController _notificationController =
      NotificationController();
  final SettingsManager _settingsManager = SettingsManager();
  bool _isDismissed = false;
  bool _isCheckingPermission = false;

  @override
  void initState() {
    super.initState();
    _loadDismissedState();
    _checkNotificationPermission();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh permission status when returning to this screen
    _checkNotificationPermission();
  }

  void _loadDismissedState() {
    final dismissed = _settingsManager
            .getSetting('focusModeSettings.notificationBannerDismissed') ??
        false;
    setState(() {
      _isDismissed = dismissed;
    });
  }

  Future<void> _checkNotificationPermission() async {
    if (!Platform.isMacOS) return;

    setState(() {
      _isCheckingPermission = true;
    });

    // Refresh permission status from system
    await _notificationController.refreshPermissionStatus();

    // Check if notifications are enabled in app settings
    final notificationsEnabled =
        _settingsManager.getSetting('notifications.enabled') ?? true;
    final focusModeNotificationsEnabled =
        _settingsManager.getSetting('notifications.focusMode') ?? true;

    setState(() {
      _isCheckingPermission = false;
    });

    // If permissions are now granted and notifications are enabled, dismiss the banner
    if (_notificationController.canSendNotifications &&
        notificationsEnabled &&
        focusModeNotificationsEnabled) {
      setState(() {
        _isDismissed = true;
      });
    }
  }

  void _dismissBanner({bool permanent = false}) {
    if (permanent) {
      _settingsManager.updateSetting(
          'focusModeSettings.notificationBannerDismissed', true);
    }
    setState(() {
      _isDismissed = true;
    });
  }

  Future<void> _navigateToSettings() async {
    // Navigate to settings screen
    // Get the navigation state provider
    context.read<NavigationState>().changeIndex(5, params: {
      'highlightSection': 'notifications',
      'reason': 'enable_notifications',
    });

    // When returning from settings, check permission again
    if (mounted) {
      await _checkNotificationPermission();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Only show on macOS
    if (!Platform.isMacOS) {
      return const SizedBox.shrink();
    }

    // Don't show if dismissed permanently
    if (_isDismissed) {
      return const SizedBox.shrink();
    }

    // Don't show if checking permission
    if (_isCheckingPermission) {
      return const SizedBox.shrink();
    }

    // Check notification settings
    final notificationsEnabled =
        _settingsManager.getSetting('notifications.enabled') ?? true;
    final focusModeNotificationsEnabled =
        _settingsManager.getSetting('notifications.focusMode') ?? true;
    final systemPermissionGranted =
        _notificationController.canSendNotifications;

    // Don't show if everything is enabled
    if (systemPermissionGranted &&
        notificationsEnabled &&
        focusModeNotificationsEnabled) {
      return const SizedBox.shrink();
    }

    // Determine the message to show
    String message;
    String actionText;
    final l10n = AppLocalizations.of(context)!;
    if (!systemPermissionGranted) {
      message = l10n.systemNotificationsDisabled;
      actionText = l10n.openSystemSettings;
    } else if (!notificationsEnabled) {
      message = l10n.appNotificationsDisabled;
      actionText = l10n.goToSettings;
    } else if (!focusModeNotificationsEnabled) {
      message = l10n.focusModeNotificationsDisabled;
      actionText = l10n.goToSettings;
    } else {
      return const SizedBox.shrink();
    }

    return _buildBanner(context, message, actionText, !systemPermissionGranted);
  }

  Widget _buildBanner(BuildContext context, String message, String actionText,
      bool isSystemSettings) {
    final l10n = AppLocalizations.of(context)!;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFF9800).withValues(alpha: 0.1),
            const Color(0xFFF57C00).withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFF9800).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Warning icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFF9800).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              FluentIcons.warning,
              color: Color(0xFFFF9800),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),

          // Message
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.notificationsDisabled,
                  style:
                      FluentTheme.of(context).typography.bodyStrong?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFFF9800),
                          ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: FluentTheme.of(context).typography.caption?.copyWith(
                        color: FluentTheme.of(context)
                            .typography
                            .caption
                            ?.color
                            ?.withValues(alpha: 0.8),
                      ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // Action buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Enable button
              FilledButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(
                    const Color(0xFFFF9800).withValues(alpha: 0.15),
                  ),
                  foregroundColor: WidgetStateProperty.all(
                    const Color(0xFFFF9800),
                  ),
                  padding: WidgetStateProperty.all(
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
                onPressed: _navigateToSettings,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                        isSystemSettings
                            ? FluentIcons.system
                            : FluentIcons.settings,
                        size: 14),
                    const SizedBox(width: 6),
                    Text(actionText),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Don't show again button
              Button(
                style: ButtonStyle(
                  padding: WidgetStateProperty.all(
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
                onPressed: () => _dismissBanner(permanent: true),
                child: Text(l10n.dontShowAgain),
              ),
              const SizedBox(width: 8),

              // Close button
              IconButton(
                icon: const Icon(FluentIcons.chrome_close, size: 12),
                onPressed: () => _dismissBanner(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showSystemSettingsInfo() async {
    final l10n = AppLocalizations.of(context)!;
    await showDialog(
      context: context,
      builder: (context) => ContentDialog(
        title: Row(
          children: [
            Icon(FluentIcons.system, size: 20),
            SizedBox(width: 12),
            Text(l10n.systemSettingsRequired),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.notificationsDisabledSystemLevel,
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 16),
            Text(l10n.step1OpenSystemSettings),
            SizedBox(height: 8),
            Text(l10n.step2GoToNotifications),
            SizedBox(height: 8),
            Text(l10n.step3FindApp),
            SizedBox(height: 8),
            Text(l10n.step4EnableNotifications),
            SizedBox(height: 16),
            Text(
              l10n.returnToAppMessage,
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          Button(
            child: Text(l10n.cancel),
            onPressed: () => Navigator.pop(context),
          ),
          FilledButton(
            child: Text(l10n.gotIt),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

/// Compact version of notification permission banner
class CompactNotificationBanner extends StatefulWidget {
  const CompactNotificationBanner({super.key});

  @override
  State<CompactNotificationBanner> createState() =>
      _CompactNotificationBannerState();
}

class _CompactNotificationBannerState extends State<CompactNotificationBanner> {
  final NotificationController _notificationController =
      NotificationController();
  final SettingsManager _settingsManager = SettingsManager();
  bool _isDismissed = false;
  bool _isExpanded = false;
  bool _isCheckingPermission = false;

  @override
  void initState() {
    super.initState();
    _loadDismissedState();
    _checkNotificationPermission();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh permission status when returning to this screen
    _checkNotificationPermission();
  }

  void _loadDismissedState() {
    final dismissed = _settingsManager
            .getSetting('focusModeSettings.notificationBannerDismissed') ??
        false;
    setState(() {
      _isDismissed = dismissed;
    });
  }

  Future<void> _checkNotificationPermission() async {
    if (!Platform.isMacOS) return;

    setState(() {
      _isCheckingPermission = true;
    });

    // Refresh permission status from system
    await _notificationController.refreshPermissionStatus();

    // Check if notifications are enabled in app settings
    final notificationsEnabled =
        _settingsManager.getSetting('notifications.enabled') ?? true;
    final focusModeNotificationsEnabled =
        _settingsManager.getSetting('notifications.focusMode') ?? true;

    setState(() {
      _isCheckingPermission = false;
    });

    // If permissions are now granted and notifications are enabled, dismiss the banner
    if (_notificationController.canSendNotifications &&
        notificationsEnabled &&
        focusModeNotificationsEnabled) {
      setState(() {
        _isDismissed = true;
      });
    }
  }

  void _dismissBanner({bool permanent = false}) {
    if (permanent) {
      _settingsManager.updateSetting(
          'focusModeSettings.notificationBannerDismissed', true);
    }
    setState(() {
      _isDismissed = true;
    });
  }

  Future<void> _navigateToSettings() async {
    // Navigate to settings screen
    context.read<NavigationState>().changeIndex(5, params: {
      'highlightSection': 'notifications',
      'reason': 'enable_notifications',
    });

    // When returning from settings, check permission again
    if (mounted) {
      await _checkNotificationPermission();
    }
  }

  Future<void> _showSystemSettingsInfo() async {
    await showDialog(
      context: context,
      builder: (context) => ContentDialog(
        title: const Row(
          children: [
            Icon(FluentIcons.system, size: 20),
            SizedBox(width: 12),
            Text('System Settings Required'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notifications are disabled at the system level. To enable:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 16),
            Text('1. Open System Settings (System Preferences)'),
            SizedBox(height: 8),
            Text('2. Go to Notifications'),
            SizedBox(height: 8),
            Text('3. Find and select TimeMark'),
            SizedBox(height: 8),
            Text('4. Enable "Allow notifications"'),
            SizedBox(height: 16),
            Text(
              'Then return to this app and notifications will work.',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          Button(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          FilledButton(
            child: const Text('Got it'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!Platform.isMacOS || _isDismissed || _isCheckingPermission) {
      return const SizedBox.shrink();
    }

    // Check notification settings
    final notificationsEnabled =
        _settingsManager.getSetting('notifications.enabled') ?? true;
    final focusModeNotificationsEnabled =
        _settingsManager.getSetting('notifications.focusMode') ?? true;
    final systemPermissionGranted =
        _notificationController.canSendNotifications;

    // Don't show if everything is enabled
    if (systemPermissionGranted &&
        notificationsEnabled &&
        focusModeNotificationsEnabled) {
      return const SizedBox.shrink();
    }

    // Determine the message to show
    String shortMessage;
    String longMessage;
    String actionText;
    bool isSystemSettings;

    if (!systemPermissionGranted) {
      shortMessage = 'Notifications disabled';
      longMessage =
          'Enable notifications in System Settings to receive focus session alerts.';
      actionText = 'Open System Settings';
      isSystemSettings = true;
    } else if (!notificationsEnabled) {
      shortMessage = 'Notifications disabled';
      longMessage =
          'Enable notifications in app settings to receive focus session alerts.';
      actionText = 'Go to Settings';
      isSystemSettings = false;
    } else if (!focusModeNotificationsEnabled) {
      shortMessage = 'Focus notifications disabled';
      longMessage =
          'Enable focus mode notifications in settings to receive session alerts.';
      actionText = 'Go to Settings';
      isSystemSettings = false;
    } else {
      return const SizedBox.shrink();
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          // Compact banner
          GestureDetector(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFF9800).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFFFF9800).withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    FluentIcons.warning,
                    color: Color(0xFFFF9800),
                    size: 16,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      shortMessage,
                      style: FluentTheme.of(context).typography.body?.copyWith(
                            color: const Color(0xFFFF9800),
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _isExpanded
                          ? FluentIcons.chevron_up
                          : FluentIcons.chevron_down,
                      size: 12,
                    ),
                    onPressed: () => setState(() => _isExpanded = !_isExpanded),
                  ),
                  IconButton(
                    icon: const Icon(FluentIcons.chrome_close, size: 10),
                    onPressed: () => _dismissBanner(),
                  ),
                ],
              ),
            ),
          ),

          // Expanded content
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: FluentTheme.of(context)
                    .inactiveBackgroundColor
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    longMessage,
                    style: FluentTheme.of(context).typography.caption,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          onPressed: isSystemSettings
                              ? _showSystemSettingsInfo
                              : _navigateToSettings,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                  isSystemSettings
                                      ? FluentIcons.system
                                      : FluentIcons.settings,
                                  size: 14),
                              const SizedBox(width: 6),
                              Text(actionText),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Button(
                        onPressed: () => _dismissBanner(permanent: true),
                        child: const Text('Don\'t show again'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
