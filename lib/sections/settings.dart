import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:screentime/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:screentime/sections/controller/app_data_controller.dart';
import 'package:screentime/sections/controller/settings_data_controller.dart';
import 'package:screentime/sections/controller/application_controller.dart';
import 'UI sections/import_export_dialog.dart' as ied;
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';
import 'package:screentime/sections/UI sections/Settings/resuables.dart';
import 'package:screentime/sections/UI sections/Settings/general.dart';
import 'package:screentime/sections/UI sections/Settings/tracking.dart';
import 'package:screentime/sections/UI sections/Settings/notification.dart';
import 'package:screentime/sections/UI sections/Settings/footer.dart';
import 'package:screentime/sections/UI sections/Settings/data.dart';
import 'package:screentime/sections/UI sections/Settings/about.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:screentime/sections/UI sections/Settings/theme_customization_section.dart';

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

  /// Enable all notification settings at once
  /// Useful after user grants permission on macOS
  Future<void> enableAllNotifications() async {
    await updateSetting('notificationsEnabled', true);
    await updateSetting('notificationsFocusMode', true);
    await updateSetting('notificationsScreenTime', true);
    await updateSetting('notificationsAppScreenTime', true);
  }

  /// Disable all notification settings
  /// Called when permission is denied or revoked
  Future<void> disableAllNotifications() async {
    await updateSetting('notificationsEnabled', false);
    await updateSetting('notificationsFocusMode', false);
    await updateSetting('notificationsScreenTime', false);
    await updateSetting('notificationsAppScreenTime', false);
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
  Future<void> launchAppropriateUrl(String url) async {
    if (Platform.isWindows) {
      // Windows-specific implementation
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
        throw Exception('Could not launch $url on Windows');
      }
    } else {
      // Other platforms
      final Uri uri = Uri.parse(url);
      if (!await launchUrl(uri)) {
        throw Exception('Could not launch $url');
      }
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
            delegate: StickyHeaderDelegate(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: theme.micaBackgroundColor.withValues(alpha: 0.95),
                  border: Border(
                    bottom: BorderSide(
                      color:
                          theme.inactiveBackgroundColor.withValues(alpha: 0.5),
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
                    QuickActionButton(
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
                                const ied.BackupRestoreSection(),
                                const SizedBox(height: 20),
                                const ThemeCustomizationSection(),
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
                        const ied.BackupRestoreSection(),
                        const SizedBox(height: 20),
                        const ThemeCustomizationSection(),
                        const SizedBox(height: 20),
                        const AboutSection(),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
                FooterSection(
                  onContact: () => launchAppropriateUrl(urlContact),
                  onReport: () => launchAppropriateUrl(urlReport),
                  onFeedback: () => launchAppropriateUrl(urlFeedback),
                  onGithub: () => launchAppropriateUrl(github),
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
              color: theme.accentColor.withValues(alpha: 0.1),
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
                    color: theme.inactiveBackgroundColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: theme.accentColor.withValues(alpha: 0.3),
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
          WarningBanner(
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
                ? theme.accentColor.withValues(alpha: 0.15)
                : _isHovered
                    ? theme.inactiveBackgroundColor.withValues(alpha: 0.5)
                    : theme.inactiveBackgroundColor.withValues(alpha: 0.2),
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
