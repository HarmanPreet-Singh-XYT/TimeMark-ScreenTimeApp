import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as mt;
import 'package:screentime/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:screentime/sections/controller/app_data_controller.dart';
import 'package:screentime/sections/controller/settings_data_controller.dart';
import 'package:screentime/sections/controller/application_controller.dart';
import 'UI sections/import_export_dialog.dart';
import 'controller/settings_data_controller.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

// ============== SETTINGS PROVIDER (unchanged logic) ==============
class SettingsProvider extends ChangeNotifier {
  final SettingsManager _settingsManager = SettingsManager();
  final BackgroundAppTracker _tracker = BackgroundAppTracker();
  final Map<String, String> version = SettingsManager().versionInfo;

  String _theme = "";
  String _language = "en";
  bool _launchAtStartupVar = false;
  bool _launchAsMinimized = false;
  bool _notificationsEnabled = false;
  bool _notificationsFocusMode = false;
  bool _notificationsScreenTime = false;
  bool _notificationsAppScreenTime = false;

  bool _idleDetectionEnabled = true;
  int _idleTimeout = IdleTimeoutOptions.defaultTimeout;
  bool _monitorAudio = true;
  bool _monitorControllers = true;
  bool _monitorHIDDevices = true;
  double _audioThreshold = 0.001;

  // All getters remain the same...
  String get theme => _theme;
  String get language => _language;
  bool get launchAtStartupVar => _launchAtStartupVar;
  bool get launchAsMinimized => _launchAsMinimized;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get notificationsFocusMode => _notificationsFocusMode;
  bool get notificationsScreenTime => _notificationsScreenTime;
  bool get notificationsAppScreenTime => _notificationsAppScreenTime;
  Map<String, String> get appVersion => version;

  bool get idleDetectionEnabled => _idleDetectionEnabled;
  int get idleTimeout => _idleTimeout;
  bool get monitorAudio => _monitorAudio;
  bool get monitorControllers => _monitorControllers;
  bool get monitorHIDDevices => _monitorHIDDevices;
  double get audioThreshold => _audioThreshold;

  List<dynamic> get themeOptions => _settingsManager.getAvailableThemes();
  List<Map<String, String>> get languageOptions =>
      _settingsManager.getAvailableLanguages();
  List<Map<String, dynamic>> get idleTimeoutPresets =>
      _settingsManager.getIdleTimeoutPresets();
  int _reminderFrequency = 60;
  int get reminderFrequency => _reminderFrequency;

  SettingsProvider() {
    _loadSettings();
  }

  void _loadSettings() {
    _theme = _settingsManager.getSetting("theme.selected");
    _language = _settingsManager.getSetting("language.selected") ?? "en";
    _launchAtStartupVar = _settingsManager.getSetting("launchAtStartup");
    _launchAsMinimized =
        _settingsManager.getSetting("launchAsMinimized") ?? false;
    _notificationsEnabled =
        _settingsManager.getSetting("notifications.enabled");
    _notificationsFocusMode =
        _settingsManager.getSetting("notifications.focusMode");
    _notificationsScreenTime =
        _settingsManager.getSetting("notifications.screenTime");
    _notificationsAppScreenTime =
        _settingsManager.getSetting("notifications.appScreenTime");
    _reminderFrequency =
        _settingsManager.getSetting("notificationController.reminderFrequency");

    _idleDetectionEnabled =
        _settingsManager.getSetting("tracking.idleDetection") ?? true;
    _idleTimeout = _settingsManager.getSetting("tracking.idleTimeout") ??
        IdleTimeoutOptions.defaultTimeout;
    _monitorAudio =
        _settingsManager.getSetting("tracking.monitorAudio") ?? true;
    _monitorControllers =
        _settingsManager.getSetting("tracking.monitorControllers") ?? true;
    _monitorHIDDevices =
        _settingsManager.getSetting("tracking.monitorHIDDevices") ?? true;
    _audioThreshold =
        _settingsManager.getSetting("tracking.audioThreshold") ?? 0.001;
  }

  Future<void> updateSetting(String key, dynamic value,
      [BuildContext? context]) async {
    switch (key) {
      case 'theme':
        _theme = value;
        _settingsManager.updateSetting("theme.selected", value, context);
        break;
      case 'language':
        _language = value;
        _settingsManager.updateSetting("language.selected", value);
        break;
      case 'launchAtStartup':
        _launchAtStartupVar = value;
        _settingsManager.updateSetting("launchAtStartup", value);
        break;
      case 'launchAsMinimized':
        _launchAsMinimized = value;
        _settingsManager.updateSetting("launchAsMinimized", value);
        break;
      case 'notificationsEnabled':
        _notificationsEnabled = value;
        _settingsManager.updateSetting("notifications.enabled", value);
        break;
      case 'notificationsFocusMode':
        _notificationsFocusMode = value;
        _settingsManager.updateSetting("notifications.focusMode", value);
        break;
      case 'notificationsScreenTime':
        _notificationsScreenTime = value;
        _settingsManager.updateSetting("notifications.screenTime", value);
        break;
      case 'notificationsAppScreenTime':
        _notificationsAppScreenTime = value;
        _settingsManager.updateSetting("notifications.appScreenTime", value);
        break;
      case 'reminderFrequency':
        _reminderFrequency = value;
        _settingsManager.updateSetting(
            "notificationController.reminderFrequency", value);
        break;
      case 'idleDetectionEnabled':
        _idleDetectionEnabled = value;
        _settingsManager.updateSetting("tracking.idleDetection", value);
        await _tracker.updateIdleDetection(value);
        break;
      case 'idleTimeout':
        _idleTimeout = value;
        _settingsManager.updateSetting("tracking.idleTimeout", value);
        await _tracker.updateIdleTimeout(value);
        break;
      case 'monitorAudio':
        _monitorAudio = value;
        _settingsManager.updateSetting("tracking.monitorAudio", value);
        await _tracker.updateAudioMonitoring(value);
        break;
      case 'monitorControllers':
        _monitorControllers = value;
        _settingsManager.updateSetting("tracking.monitorControllers", value);
        await _tracker.updateControllerMonitoring(value);
        break;
      case 'monitorHIDDevices':
        _monitorHIDDevices = value;
        _settingsManager.updateSetting("tracking.monitorHIDDevices", value);
        await _tracker.updateHIDMonitoring(value);
        break;
      case 'audioThreshold':
        _audioThreshold = value;
        _settingsManager.updateSetting("tracking.audioThreshold", value);
        await _tracker.updateAudioThreshold(value);
        break;
    }
    notifyListeners();
  }

  int getReminderFrequency() {
    return _settingsManager
            .getSetting("notificationController.reminderFrequency") ??
        60;
  }

  Future<void> clearData() async {
    final dataStore = AppDataStore();
    await dataStore.init();
    await dataStore.clearAllData();
    notifyListeners();
  }

  Future<void> resetSettings() async {
    await _settingsManager.resetSettings();
    _loadSettings();
    notifyListeners();
  }

  String formatTimeout(int seconds, AppLocalizations l10n) {
    if (seconds < 60) {
      return l10n.timeFormatSeconds(seconds);
    } else if (seconds == 60) {
      return l10n.timeFormatMinute;
    } else {
      final minutes = seconds ~/ 60;
      final remainingSeconds = seconds % 60;
      if (remainingSeconds == 0) {
        return l10n.timeFormatMinutes(minutes);
      } else {
        return l10n.timeFormatMinutesSeconds(minutes, remainingSeconds);
      }
    }
  }

  String getFormattedIdleTimeout(AppLocalizations l10n) =>
      formatTimeout(_idleTimeout, l10n);
}

// ============== MAIN SETTINGS WIDGET ==============
class Settings extends StatelessWidget {
  final Function(Locale) setLocale;

  const Settings({super.key, required this.setLocale});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SettingsProvider(),
      child: SettingsContent(setLocale: setLocale),
    );
  }
}

class SettingsContent extends StatefulWidget {
  final Function(Locale) setLocale;

  const SettingsContent({super.key, required this.setLocale});

  @override
  State<SettingsContent> createState() => _SettingsContentState();
}

class _SettingsContentState extends State<SettingsContent> {
  Future<void>? _launched;

  Future<void> _launchInBrowser(String url) async {
    if (await UrlLauncherPlatform.instance.canLaunch(url)) {
      await UrlLauncherPlatform.instance.launch(
        url,
        useSafariVC: false,
        useWebView: false,
        enableJavaScript: false,
        enableDomStorage: false,
        universalLinksOnly: false,
        headers: <String, String>{},
      );
    } else {
      throw Exception('Could not launch $url');
    }
  }

  final String urlContact =
      'https://harmanita.com/details/screentime?intent=contact';
  final String urlReport =
      'https://harmanita.com/details/screentime?intent=report';
  final String urlFeedback =
      'https://harmanita.com/details/screentime?intent=feedback';
  final String github =
      'https://github.com/HarmanPreet-Singh-XYT/TimeMark-ScreenTimeApp';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = FluentTheme.of(context);

    return ScaffoldPage(
      padding: EdgeInsets.zero,
      content: CustomScrollView(
        slivers: [
          // Sticky Header
          SliverPersistentHeader(
            pinned: true,
            delegate: _StickyHeaderDelegate(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: theme.micaBackgroundColor.withOpacity(0.95),
                  border: Border(
                    bottom: BorderSide(
                      color: theme.inactiveBackgroundColor.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(FluentIcons.settings, size: 24),
                    const SizedBox(width: 12),
                    Text(l10n.settingsTitle,
                        style: theme.typography.subtitle?.copyWith(
                          fontWeight: FontWeight.w600,
                        )),
                    const Spacer(),
                    _QuickActionButton(
                      icon: FluentIcons.refresh,
                      tooltip: l10n.resetSettingsTitle2,
                      onPressed: () => _showSettingsDialog(
                          context, context.read<SettingsProvider>()),
                    ),
                  ],
                ),
              ),
              height: 60,
            ),
          ),
          // Content
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Two-column layout for larger screens
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth > 900) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                GeneralSection(setLocale: widget.setLocale),
                                const SizedBox(height: 20),
                                const NotificationSection(),
                                const SizedBox(height: 20),
                                const DataSection(),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              children: [
                                const TrackingSection(),
                                const SizedBox(height: 20),
                                const BackupRestoreSection(),
                                const SizedBox(height: 20),
                                const AboutSection(),
                              ],
                            ),
                          ),
                        ],
                      );
                    }
                    // Single column for smaller screens
                    return Column(
                      children: [
                        GeneralSection(setLocale: widget.setLocale),
                        const SizedBox(height: 20),
                        const TrackingSection(),
                        const SizedBox(height: 20),
                        const NotificationSection(),
                        const SizedBox(height: 20),
                        const DataSection(),
                        const SizedBox(height: 20),
                        const BackupRestoreSection(),
                        const SizedBox(height: 20),
                        const AboutSection(),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
                _FooterSection(
                  onContact: () =>
                      setState(() => _launched = _launchInBrowser(urlContact)),
                  onReport: () =>
                      setState(() => _launched = _launchInBrowser(urlReport)),
                  onFeedback: () =>
                      setState(() => _launched = _launchInBrowser(urlFeedback)),
                  onGithub: () =>
                      setState(() => _launched = _launchInBrowser(github)),
                ),
                const SizedBox(height: 16),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showSettingsDialog(
      BuildContext context, SettingsProvider settings) async {
    final l10n = AppLocalizations.of(context)!;

    await showDialog<String>(
      context: context,
      builder: (context) => ContentDialog(
        title: Row(
          children: [
            Icon(FluentIcons.warning, color: Colors.orange, size: 20),
            const SizedBox(width: 10),
            Text(l10n.resetSettingsDialogTitle),
          ],
        ),
        content: Text(l10n.resetSettingsDialogContent),
        actions: [
          Button(
            child: Text(l10n.cancelButton),
            onPressed: () => Navigator.pop(context),
          ),
          FilledButton(
            style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(Colors.orange),
            ),
            child: Text(l10n.resetButtonLabel),
            onPressed: () {
              settings.resetSettings();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

// ============== REUSABLE COMPONENTS ==============

class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  _StickyHeaderDelegate({required this.child, required this.height});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => height;
  @override
  double get minExtent => height;
  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      true;
}

class _QuickActionButton extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const _QuickActionButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  State<_QuickActionButton> createState() => _QuickActionButtonState();
}

class _QuickActionButtonState extends State<_QuickActionButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _isHovered
                ? FluentTheme.of(context).inactiveBackgroundColor
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: GestureDetector(
            onTap: widget.onPressed,
            child: Icon(widget.icon, size: 18),
          ),
        ),
      ),
    );
  }
}

// ============== SETTINGS CARD ==============
class SettingsCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color? iconColor;
  final List<Widget> children;
  final Widget? trailing;
  final bool isExpanded;
  final VoidCallback? onExpandToggle;

  const SettingsCard({
    super.key,
    required this.title,
    required this.icon,
    this.iconColor,
    required this.children,
    this.trailing,
    this.isExpanded = true,
    this.onExpandToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.micaBackgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.inactiveBackgroundColor.withOpacity(0.6),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header - Replace mt.InkWell with GestureDetector
          GestureDetector(
            onTap: onExpandToggle,
            child: MouseRegion(
              cursor: onExpandToggle != null
                  ? SystemMouseCursors.click
                  : SystemMouseCursors.basic,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: theme.inactiveBackgroundColor.withOpacity(0.4),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color:
                            (iconColor ?? theme.accentColor).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(icon,
                          size: 16, color: iconColor ?? theme.accentColor),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    if (trailing != null) trailing!,
                    if (onExpandToggle != null) ...[
                      const SizedBox(width: 8),
                      AnimatedRotation(
                        turns: isExpanded ? 0 : -0.25,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(FluentIcons.chevron_down, size: 12),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          // Content
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: children,
              ),
            ),
        ],
      ),
    );
  }
}

// ============== SETTING ROW ==============

class SettingRow extends StatefulWidget {
  final String title;
  final String description;
  final Widget control;
  final IconData? icon;
  final bool isSubSetting;
  final bool showDivider;

  const SettingRow({
    super.key,
    required this.title,
    required this.description,
    required this.control,
    this.icon,
    this.isSubSetting = false,
    this.showDivider = true,
  });

  @override
  State<SettingRow> createState() => _SettingRowState();
}

class _SettingRowState extends State<SettingRow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    return Column(
      children: [
        MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: EdgeInsets.symmetric(
              horizontal: widget.isSubSetting ? 12 : 8,
              vertical: 10,
            ),
            margin: EdgeInsets.only(left: widget.isSubSetting ? 20 : 0),
            decoration: BoxDecoration(
              color: _isHovered
                  ? theme.inactiveBackgroundColor.withOpacity(0.3)
                  : null,
              borderRadius: BorderRadius.circular(6),
              border: widget.isSubSetting
                  ? Border(
                      left: BorderSide(
                        color: theme.accentColor.withOpacity(0.3),
                        width: 2,
                      ),
                    )
                  : null,
            ),
            child: Row(
              children: [
                if (widget.icon != null) ...[
                  Icon(widget.icon, size: 16, color: theme.accentColor),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: widget.isSubSetting ? Colors.grey[100] : null,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.description,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[100],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                widget.control,
              ],
            ),
          ),
        ),
        if (widget.showDivider)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Container(
              height: 1,
              color: theme.inactiveBackgroundColor.withOpacity(0.3),
            ),
          ),
      ],
    );
  }
}

// ============== GENERAL SECTION ==============

class GeneralSection extends StatelessWidget {
  final Function(Locale) setLocale;

  const GeneralSection({super.key, required this.setLocale});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = context.watch<SettingsProvider>();

    // Add safety checks
    final themeValue = settings.themeOptions.contains(settings.theme)
        ? settings.theme
        : (settings.themeOptions.isNotEmpty
            ? settings.themeOptions.first.toString()
            : 'System');

    final languageValue = settings.languageOptions
            .any((lang) => lang['code'] == settings.language)
        ? settings.language
        : 'en';

    return SettingsCard(
      title: l10n.generalSection,
      icon: FluentIcons.settings,
      children: [
        SettingRow(
          title: l10n.themeTitle,
          description: l10n.themeDescription,
          control: SizedBox(
            width: 200,
            child: ComboBox<String>(
              value: themeValue,
              items: settings.themeOptions.map((theme) {
                return ComboBoxItem<String>(
                  value: theme.toString(),
                  child: Text(theme.toString()),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  settings.updateSetting('theme', value, context);
                }
              },
            ),
          ),
        ),
        SettingRow(
          title: l10n.languageTitle,
          description: l10n.languageDescription,
          control: SizedBox(
            width: 200,
            child: ComboBox<String>(
              value: languageValue,
              items: settings.languageOptions.map((lang) {
                return ComboBoxItem<String>(
                  value: lang['code']!,
                  child: Text(lang['name']!),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  settings.updateSetting('language', value);
                  setLocale(Locale(value));
                }
              },
            ),
          ),
        ),
        SettingRow(
          title: l10n.launchMinimizedTitle,
          description: l10n.launchMinimizedDescription,
          showDivider: false,
          control: ToggleSwitch(
            checked: settings.launchAsMinimized,
            onChanged: (value) =>
                settings.updateSetting('launchAsMinimized', value),
          ),
        ),
      ],
    );
  }
}

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
      trailing: _StatusBadge(
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
            control: _TimeoutButton(
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
              _WarningBanner(
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

// ============== HELPER WIDGETS ==============

class _StatusBadge extends StatelessWidget {
  final bool isActive;
  final String activeText;
  final String inactiveText;

  const _StatusBadge({
    required this.isActive,
    required this.activeText,
    required this.inactiveText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? Colors.green.withOpacity(0.1)
            : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive
              ? Colors.green.withOpacity(0.3)
              : Colors.grey.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: isActive ? Colors.green : Colors.grey,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isActive ? activeText : inactiveText,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: isActive ? Colors.green : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeoutButton extends StatefulWidget {
  final String value;
  final VoidCallback onPressed;

  const _TimeoutButton({
    required this.value,
    required this.onPressed,
  });

  @override
  State<_TimeoutButton> createState() => _TimeoutButtonState();
}

class _TimeoutButtonState extends State<_TimeoutButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _isHovered
                ? theme.accentColor.withOpacity(0.1)
                : theme.inactiveBackgroundColor.withOpacity(0.3),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: _isHovered
                  ? theme.accentColor.withOpacity(0.5)
                  : theme.inactiveBackgroundColor,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.value,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _isHovered ? theme.accentColor : null,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                FluentIcons.edit,
                size: 12,
                color: _isHovered ? theme.accentColor : Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WarningBanner extends StatelessWidget {
  final String message;
  final IconData icon;
  final Color color;

  const _WarningBanner({
    required this.message,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(fontSize: 11, color: color.withOpacity(0.8)),
            ),
          ),
        ],
      ),
    );
  }
}

// ============== IDLE TIMEOUT DIALOG ==============

class IdleTimeoutDialog extends StatefulWidget {
  final int currentValue;
  final List<Map<String, dynamic>> presets;
  final AppLocalizations l10n;

  const IdleTimeoutDialog({
    super.key,
    required this.currentValue,
    required this.presets,
    required this.l10n,
  });

  @override
  State<IdleTimeoutDialog> createState() => _IdleTimeoutDialogState();
}

class _IdleTimeoutDialogState extends State<IdleTimeoutDialog> {
  late int _selectedValue;
  bool _isCustom = false;
  final TextEditingController _minutesController = TextEditingController();
  final TextEditingController _secondsController = TextEditingController();
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.currentValue;

    bool matchesPreset = widget.presets.any(
      (preset) =>
          preset['value'] == widget.currentValue && preset['value'] != -1,
    );

    if (!matchesPreset) {
      _isCustom = true;
      _minutesController.text = (widget.currentValue ~/ 60).toString();
      _secondsController.text = (widget.currentValue % 60).toString();
    }
  }

  @override
  void dispose() {
    _minutesController.dispose();
    _secondsController.dispose();
    super.dispose();
  }

  String _formatTimeout(int seconds) {
    if (seconds < 60) {
      return widget.l10n.timeFormatSeconds(seconds);
    } else if (seconds == 60) {
      return widget.l10n.timeFormatMinute;
    } else {
      final minutes = seconds ~/ 60;
      final remainingSeconds = seconds % 60;
      if (remainingSeconds == 0) {
        return widget.l10n.timeFormatMinutes(minutes);
      } else {
        return widget.l10n.timeFormatMinutesSeconds(minutes, remainingSeconds);
      }
    }
  }

  String _getPresetLabel(Map<String, dynamic> preset) {
    switch (preset['value']) {
      case 30:
        return widget.l10n.seconds30;
      case 60:
        return widget.l10n.minute1;
      case 120:
        return widget.l10n.minutes2;
      case 300:
        return widget.l10n.minutes5;
      case 600:
        return widget.l10n.minutes10;
      case -1:
        return widget.l10n.customOption;
      default:
        return preset['label'];
    }
  }

  void _selectPreset(int value) {
    setState(() {
      if (value == -1) {
        _isCustom = true;
        _minutesController.text = (_selectedValue ~/ 60).toString();
        _secondsController.text = (_selectedValue % 60).toString();
      } else {
        _isCustom = false;
        _selectedValue = value;
        _errorMessage = null;
      }
    });
  }

  void _validateCustomInput() {
    final minutes = int.tryParse(_minutesController.text) ?? 0;
    final seconds = int.tryParse(_secondsController.text) ?? 0;
    final totalSeconds = (minutes * 60) + seconds;

    if (totalSeconds < IdleTimeoutOptions.minTimeout) {
      setState(() {
        _errorMessage = widget.l10n
            .minimumError(_formatTimeout(IdleTimeoutOptions.minTimeout));
      });
    } else if (totalSeconds > IdleTimeoutOptions.maxTimeout) {
      setState(() {
        _errorMessage = widget.l10n
            .maximumError(_formatTimeout(IdleTimeoutOptions.maxTimeout));
      });
    } else {
      setState(() {
        _selectedValue = totalSeconds;
        _errorMessage = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    return ContentDialog(
      constraints: const BoxConstraints(maxWidth: 420),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(FluentIcons.timer, size: 18, color: theme.accentColor),
          ),
          const SizedBox(width: 12),
          Text(widget.l10n.setIdleTimeoutTitle),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.l10n.idleTimeoutDialogDescription,
            style: TextStyle(fontSize: 12, color: Colors.grey[100]),
          ),
          const SizedBox(height: 20),

          // Preset Grid
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 2.5,
            physics: const NeverScrollableScrollPhysics(),
            children: widget.presets.map((preset) {
              final isSelected =
                  !_isCustom && _selectedValue == preset['value'];
              final isCustomOption = preset['value'] == -1;
              final isCustomSelected = _isCustom && isCustomOption;

              return _PresetButton(
                label: _getPresetLabel(preset),
                isSelected: isSelected || isCustomSelected,
                onPressed: () => _selectPreset(preset['value']),
              );
            }).toList(),
          ),

          // Custom Input
          AnimatedCrossFade(
            firstChild: Column(
              children: [
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.inactiveBackgroundColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: theme.accentColor.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.l10n.customDurationTitle,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextBox(
                              controller: _minutesController,
                              placeholder: '0',
                              keyboardType: TextInputType.number,
                              onChanged: (_) => _validateCustomInput(),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              widget.l10n.minAbbreviation,
                              style: TextStyle(
                                  fontSize: 11, color: Colors.grey[100]),
                            ),
                          ),
                          Expanded(
                            child: TextBox(
                              controller: _secondsController,
                              placeholder: '0',
                              keyboardType: TextInputType.number,
                              onChanged: (_) => _validateCustomInput(),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Text(
                              widget.l10n.secAbbreviation,
                              style: TextStyle(
                                  fontSize: 11, color: Colors.grey[100]),
                            ),
                          ),
                        ],
                      ),
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          _errorMessage!,
                          style: TextStyle(fontSize: 11, color: Colors.red),
                        ),
                      ] else ...[
                        const SizedBox(height: 8),
                        Text(
                          widget.l10n
                              .totalLabel(_formatTimeout(_selectedValue)),
                          style: TextStyle(
                            fontSize: 11,
                            color: theme.accentColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            secondChild: const SizedBox.shrink(),
            crossFadeState: _isCustom
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 200),
          ),

          const SizedBox(height: 16),
          _WarningBanner(
            message: widget.l10n.rangeInfo(
              _formatTimeout(IdleTimeoutOptions.minTimeout),
              _formatTimeout(IdleTimeoutOptions.maxTimeout),
            ),
            icon: FluentIcons.info,
            color: Colors.blue,
          ),
        ],
      ),
      actions: [
        Button(
          child: Text(widget.l10n.cancelButton),
          onPressed: () => Navigator.pop(context),
        ),
        FilledButton(
          onPressed: _errorMessage != null
              ? null
              : () => Navigator.pop(context, _selectedValue),
          child: Text(widget.l10n.saveButton),
        ),
      ],
    );
  }
}

class _PresetButton extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onPressed;

  const _PresetButton({
    required this.label,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  State<_PresetButton> createState() => _PresetButtonState();
}

class _PresetButtonState extends State<_PresetButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? theme.accentColor.withOpacity(0.15)
                : _isHovered
                    ? theme.inactiveBackgroundColor.withOpacity(0.5)
                    : theme.inactiveBackgroundColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: widget.isSelected
                  ? theme.accentColor
                  : _isHovered
                      ? theme.inactiveBackgroundColor
                      : Colors.transparent,
              width: widget.isSelected ? 2 : 1,
            ),
          ),
          child: Center(
            child: Text(
              widget.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight:
                    widget.isSelected ? FontWeight.w600 : FontWeight.normal,
                color: widget.isSelected ? theme.accentColor : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

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
      trailing: _StatusBadge(
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

// ============== DATA SECTION ==============

class DataSection extends StatelessWidget {
  const DataSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = Provider.of<SettingsProvider>(context);

    return SettingsCard(
      title: l10n.dataSection,
      icon: FluentIcons.database,
      iconColor: Colors.red,
      children: [
        SettingRow(
          title: l10n.clearDataTitle,
          description: l10n.clearDataDescription,
          control: _DangerButton(
            label: l10n.clearDataButtonLabel,
            icon: FluentIcons.delete,
            onPressed: () => _showDataDialog(context, settings),
          ),
        ),
        SettingRow(
          title: l10n.resetSettingsTitle2,
          description: l10n.resetSettingsDescription,
          showDivider: false,
          control: _DangerButton(
            label: l10n.resetButtonLabel,
            icon: FluentIcons.refresh,
            isWarning: true,
            onPressed: () => _showSettingsDialog(context, settings),
          ),
        ),
      ],
    );
  }

  Future<void> _showDataDialog(
      BuildContext context, SettingsProvider settings) async {
    final l10n = AppLocalizations.of(context)!;

    await showDialog<String>(
      context: context,
      builder: (context) => ContentDialog(
        title: Row(
          children: [
            Icon(FluentIcons.warning, color: Colors.red, size: 20),
            const SizedBox(width: 10),
            Text(l10n.clearDataDialogTitle),
          ],
        ),
        content: Text(l10n.clearDataDialogContent),
        actions: [
          Button(
            child: Text(l10n.cancelButton),
            onPressed: () => Navigator.pop(context),
          ),
          FilledButton(
            style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(Colors.red),
            ),
            child: Text(l10n.clearDataButtonLabel),
            onPressed: () {
              settings.clearData();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showSettingsDialog(
      BuildContext context, SettingsProvider settings) async {
    final l10n = AppLocalizations.of(context)!;

    await showDialog<String>(
      context: context,
      builder: (context) => ContentDialog(
        title: Row(
          children: [
            Icon(FluentIcons.warning, color: Colors.orange, size: 20),
            const SizedBox(width: 10),
            Text(l10n.resetSettingsDialogTitle),
          ],
        ),
        content: Text(l10n.resetSettingsDialogContent),
        actions: [
          Button(
            child: Text(l10n.cancelButton),
            onPressed: () => Navigator.pop(context),
          ),
          FilledButton(
            style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(Colors.orange),
            ),
            child: Text(l10n.resetButtonLabel),
            onPressed: () {
              settings.resetSettings();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

class _DangerButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool isWarning;
  final VoidCallback onPressed;

  const _DangerButton({
    required this.label,
    required this.icon,
    this.isWarning = false,
    required this.onPressed,
  });

  @override
  State<_DangerButton> createState() => _DangerButtonState();
}

class _DangerButtonState extends State<_DangerButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.isWarning ? Colors.orange : Colors.red;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _isHovered ? color.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: _isHovered ? color : color.withOpacity(0.5),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 12, color: color),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============== ABOUT SECTION ==============

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = Provider.of<SettingsProvider>(context);
    final version = settings.appVersion;
    final theme = FluentTheme.of(context);

    return SettingsCard(
      title: l10n.versionSection,
      icon: FluentIcons.info,
      iconColor: Colors.grey,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.accentColor.withOpacity(0.05),
                theme.accentColor.withOpacity(0.02),
              ],
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: theme.accentColor.withOpacity(0.1),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child:
                    Icon(FluentIcons.timer, size: 24, color: theme.accentColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TimeMark',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.versionDescription,
                      style: TextStyle(fontSize: 11, color: Colors.grey[100]),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'v${version["version"]}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: theme.accentColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${version["type"]}',
                    style: TextStyle(fontSize: 10, color: Colors.grey[100]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ============== FOOTER SECTION ==============

class _FooterSection extends StatelessWidget {
  final VoidCallback onContact;
  final VoidCallback onReport;
  final VoidCallback onFeedback;
  final VoidCallback onGithub;

  const _FooterSection({
    required this.onContact,
    required this.onReport,
    required this.onFeedback,
    required this.onGithub,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = FluentTheme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: theme.inactiveBackgroundColor.withOpacity(0.5),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _FooterButton(
            icon: FluentIcons.chat,
            label: l10n.contactButton,
            onPressed: onContact,
          ),
          const SizedBox(width: 12),
          _FooterButton(
            icon: FluentIcons.bug,
            label: l10n.reportBugButton,
            onPressed: onReport,
          ),
          const SizedBox(width: 12),
          _FooterButton(
            icon: FluentIcons.feedback,
            label: l10n.submitFeedbackButton,
            onPressed: onFeedback,
          ),
          const SizedBox(width: 12),
          _FooterButton(
            icon: FluentIcons.open_source,
            label: l10n.githubButton,
            onPressed: onGithub,
            isPrimary: true,
          ),
        ],
      ),
    );
  }
}

class _FooterButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool isPrimary;

  const _FooterButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isPrimary = false,
  });

  @override
  State<_FooterButton> createState() => _FooterButtonState();
}

class _FooterButtonState extends State<_FooterButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: widget.isPrimary
                ? (_isHovered
                    ? theme.accentColor.withOpacity(0.15)
                    : theme.accentColor.withOpacity(0.08))
                : (_isHovered
                    ? theme.inactiveBackgroundColor.withOpacity(0.6)
                    : theme.inactiveBackgroundColor.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: widget.isPrimary
                  ? (_isHovered
                      ? theme.accentColor.withOpacity(0.5)
                      : theme.accentColor.withOpacity(0.2))
                  : (_isHovered
                      ? theme.inactiveBackgroundColor
                      : Colors.transparent),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                size: 14,
                color: widget.isPrimary
                    ? theme.accentColor
                    : (_isHovered ? null : Colors.grey[100]),
              ),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: widget.isPrimary
                      ? theme.accentColor
                      : (_isHovered ? null : Colors.grey[100]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============== ANIMATED TOGGLE CARD ==============
// Use this for expandable sections with animation

class AnimatedToggleCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color? iconColor;
  final List<Widget> children;
  final Widget? trailing;
  final bool initiallyExpanded;

  const AnimatedToggleCard({
    super.key,
    required this.title,
    required this.icon,
    this.iconColor,
    required this.children,
    this.trailing,
    this.initiallyExpanded = true,
  });

  @override
  State<AnimatedToggleCard> createState() => _AnimatedToggleCardState();
}

class _AnimatedToggleCardState extends State<AnimatedToggleCard>
    with SingleTickerProviderStateMixin {
  late bool _isExpanded;
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _rotationAnimation = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (_isExpanded) {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.micaBackgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.inactiveBackgroundColor.withOpacity(0.6),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          mt.Material(
            color: Colors.transparent,
            child: mt.InkWell(
              onTap: _toggleExpanded,
              borderRadius: BorderRadius.vertical(
                top: const Radius.circular(8),
                bottom: Radius.circular(_isExpanded ? 0 : 8),
              ),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  border: _isExpanded
                      ? Border(
                          bottom: BorderSide(
                            color:
                                theme.inactiveBackgroundColor.withOpacity(0.4),
                            width: 1,
                          ),
                        )
                      : null,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: (widget.iconColor ?? theme.accentColor)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        widget.icon,
                        size: 16,
                        color: widget.iconColor ?? theme.accentColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    if (widget.trailing != null) widget.trailing!,
                    const SizedBox(width: 8),
                    RotationTransition(
                      turns: _rotationAnimation,
                      child: Icon(FluentIcons.chevron_down, size: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Content
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: widget.children,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============== COMPACT SETTING TILE ==============
// Alternative compact design for dense settings

class CompactSettingTile extends StatefulWidget {
  final String title;
  final String? subtitle;
  final Widget control;
  final IconData? leadingIcon;
  final Color? iconColor;

  const CompactSettingTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.control,
    this.leadingIcon,
    this.iconColor,
  });

  @override
  State<CompactSettingTile> createState() => _CompactSettingTileState();
}

class _CompactSettingTileState extends State<CompactSettingTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: _isHovered
              ? theme.inactiveBackgroundColor.withOpacity(0.3)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            if (widget.leadingIcon != null) ...[
              Icon(
                widget.leadingIcon,
                size: 16,
                color: widget.iconColor ?? theme.accentColor,
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (widget.subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      widget.subtitle!,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[100],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            widget.control,
          ],
        ),
      ),
    );
  }
}

// ============== INFO TOOLTIP WIDGET ==============

class InfoTooltip extends StatelessWidget {
  final String message;

  const InfoTooltip({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: message,
      child: MouseRegion(
        cursor: SystemMouseCursors.help,
        child: Icon(
          FluentIcons.info,
          size: 14,
          color: Colors.grey[100],
        ),
      ),
    );
  }
}

// ============== SEGMENTED OPTION SELECTOR ==============

class SegmentedSelector<T> extends StatelessWidget {
  final List<T> options;
  final T selected;
  final String Function(T) labelBuilder;
  final void Function(T) onChanged;

  const SegmentedSelector({
    super.key,
    required this.options,
    required this.selected,
    required this.labelBuilder,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.inactiveBackgroundColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(6),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: options.map((option) {
          final isSelected = option == selected;
          return GestureDetector(
            onTap: () => onChanged(option),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color:
                    isSelected ? theme.micaBackgroundColor : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                labelBuilder(option),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? theme.accentColor : Colors.grey[100],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ============== PROGRESS INDICATOR BUTTON ==============

class ProgressButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Future<void> Function() onPressed;

  const ProgressButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  State<ProgressButton> createState() => _ProgressButtonState();
}

class _ProgressButtonState extends State<ProgressButton> {
  bool _isLoading = false;

  Future<void> _handlePress() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);
    try {
      await widget.onPressed();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Button(
      onPressed: _isLoading ? null : _handlePress,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isLoading)
            const SizedBox(
              width: 12,
              height: 12,
              child: ProgressRing(strokeWidth: 2),
            )
          else
            Icon(widget.icon, size: 12),
          const SizedBox(width: 8),
          Text(widget.label, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }
}
