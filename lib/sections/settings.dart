import 'package:fluent_ui/fluent_ui.dart';
import 'package:screentime/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:screentime/sections/controller/app_data_controller.dart';
import 'package:screentime/sections/controller/settings_data_controller.dart';
import 'package:screentime/sections/controller/application_controller.dart';
import 'UI sections/import_export_dialog.dart';
import 'controller/settings_data_controller.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

// Create a SettingsProvider to centralize state management
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

  // Tracking settings - all default to true
  bool _idleDetectionEnabled = true;
  int _idleTimeout = IdleTimeoutOptions.defaultTimeout;
  bool _monitorAudio = true;
  bool _monitorControllers = true;
  bool _monitorHIDDevices = true;
  double _audioThreshold = 0.001;

  // Getters
  String get theme => _theme;
  String get language => _language;
  bool get launchAtStartupVar => _launchAtStartupVar;
  bool get launchAsMinimized => _launchAsMinimized;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get notificationsFocusMode => _notificationsFocusMode;
  bool get notificationsScreenTime => _notificationsScreenTime;
  bool get notificationsAppScreenTime => _notificationsAppScreenTime;
  Map<String, String> get appVersion => version;

  // Tracking getters
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

    // Load tracking settings with true defaults
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

      // Tracking settings
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

  // Localized time format
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

  Widget _launchStatus(BuildContext context, AsyncSnapshot<void> snapshot) {
    final l10n = AppLocalizations.of(context)!;
    if (snapshot.hasError) {
      return Text(l10n.errorMessage(snapshot.error.toString()));
    } else {
      return const Text('');
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

    return SingleChildScrollView(
      child: Padding(
        padding:
            const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Header(),
            const SizedBox(height: 30),
            GeneralSection(setLocale: widget.setLocale),
            const SizedBox(height: 30),
            const TrackingSection(),
            const SizedBox(height: 30),
            const NotificationSection(),
            const SizedBox(height: 30),
            const DataSection(),
            const SizedBox(height: 30),
            const BackupRestoreSection(),
            const SizedBox(height: 30),
            const AboutSection(),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Button(
                  style: ButtonStyle(
                      padding: WidgetStateProperty.all(const EdgeInsets.only(
                          top: 8, bottom: 8, left: 14, right: 14))),
                  child: Row(
                    children: [
                      const Icon(FluentIcons.canned_chat, size: 18),
                      const SizedBox(width: 10),
                      Text(l10n.contactButton,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                  onPressed: () => setState(() {
                    _launched = _launchInBrowser(urlContact);
                  }),
                ),
                const SizedBox(width: 25),
                Button(
                  style: ButtonStyle(
                      padding: WidgetStateProperty.all(const EdgeInsets.only(
                          top: 8, bottom: 8, left: 14, right: 14))),
                  child: Row(
                    children: [
                      const Icon(FluentIcons.bug, size: 18),
                      const SizedBox(width: 10),
                      Text(l10n.reportBugButton,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                  onPressed: () => setState(() {
                    _launched = _launchInBrowser(urlReport);
                  }),
                ),
                const SizedBox(width: 25),
                Button(
                  style: ButtonStyle(
                      padding: WidgetStateProperty.all(
                          const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 12))),
                  child: Row(
                    children: [
                      const Icon(FluentIcons.red_eye, size: 20),
                      const SizedBox(width: 10),
                      Text(l10n.submitFeedbackButton,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                  onPressed: () => setState(() {
                    _launched = _launchInBrowser(urlFeedback);
                  }),
                ),
                const SizedBox(width: 25),
                Button(
                  style: ButtonStyle(
                      padding: WidgetStateProperty.all(
                          const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 12))),
                  child: Text(l10n.githubButton,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  onPressed: () => setState(() {
                    _launched = _launchInBrowser(github);
                  }),
                ),
              ],
            ),
            FutureBuilder<void>(
              future: _launched,
              builder: _launchStatus,
            ),
            const SizedBox(height: 20)
          ],
        ),
      ),
    );
  }
}

class GeneralSection extends StatelessWidget {
  final Function(Locale) setLocale;

  const GeneralSection({super.key, required this.setLocale});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = context.watch<SettingsProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.generalSection,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 15),
        Container(
          height: 180,
          padding: const EdgeInsets.all(20),
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: FluentTheme.of(context).micaBackgroundColor,
              border: Border.all(
                  color: FluentTheme.of(context).inactiveBackgroundColor,
                  width: 1)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OptionSetting(
                title: l10n.themeTitle,
                description: l10n.themeDescription,
                settingType: "theme",
                changeValue: (key, value) =>
                    settings.updateSetting(key, value, context),
                optionsValue: settings.theme,
                options: settings.themeOptions,
              ),
              OptionSetting(
                title: l10n.languageTitle,
                description: l10n.languageDescription,
                settingType: "language",
                changeValue: (key, value) {
                  settings.updateSetting(key, value);
                  // Update the app locale
                  setLocale(Locale(value));
                },
                optionsValue: settings.language,
                languageOptions: settings.languageOptions,
              ),
              OptionSetting(
                title: l10n.launchMinimizedTitle,
                description: l10n.launchMinimizedDescription,
                optionType: "switch",
                settingType: "launchAsMinimized",
                changeValue: (key, value) => settings.updateSetting(key, value),
                isChecked: settings.launchAsMinimized,
              ),
            ],
          ),
        )
      ],
    );
  }
}

// Tracking settings section with popup dialog for idle timeout
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(l10n.activityTrackingSection,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(width: 10),
            IconButton(
              icon: Icon(
                  _showAdvanced
                      ? FluentIcons.chevron_up
                      : FluentIcons.chevron_down,
                  size: 14),
              onPressed: () => setState(() => _showAdvanced = !_showAdvanced),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Container(
          padding: const EdgeInsets.all(20),
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: FluentTheme.of(context).micaBackgroundColor,
              border: Border.all(
                  color: FluentTheme.of(context).inactiveBackgroundColor,
                  width: 1)),
          child: Column(
            children: [
              // Idle Detection
              OptionSetting(
                title: l10n.idleDetectionTitle,
                description: l10n.idleDetectionDescription,
                optionType: "switch",
                settingType: "idleDetectionEnabled",
                changeValue: (key, value) => settings.updateSetting(key, value),
                isChecked: settings.idleDetectionEnabled,
              ),

              if (settings.idleDetectionEnabled) ...[
                const SizedBox(height: 15),
                // Idle Timeout with popup dialog button
                _buildIdleTimeoutSetting(context, settings, l10n),
              ],

              // Advanced options (collapsible)
              if (_showAdvanced) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(FluentIcons.warning, size: 16, color: Colors.orange),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.advancedWarning,
                          style:
                              TextStyle(fontSize: 11, color: Colors.grey[120]),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                OptionSetting(
                  title: l10n.monitorAudioTitle,
                  description: l10n.monitorAudioDescription,
                  optionType: "switch",
                  settingType: "monitorAudio",
                  changeValue: (key, value) =>
                      settings.updateSetting(key, value),
                  isChecked: settings.monitorAudio,
                ),
                if (settings.monitorAudio) ...[
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: OptionSetting(
                      title: l10n.audioSensitivityTitle,
                      description: l10n.audioSensitivityDescription(
                          settings.audioThreshold.toStringAsFixed(4)),
                      optionType: "slider",
                      settingType: "audioThreshold",
                      changeValue: (key, value) =>
                          settings.updateSetting(key, value),
                      sliderValue: settings.audioThreshold,
                      sliderMin: 0.0001,
                      sliderMax: 0.1,
                      sliderDivisions: 100,
                    ),
                  ),
                ],
                const SizedBox(height: 15),
                OptionSetting(
                  title: l10n.monitorControllersTitle,
                  description: l10n.monitorControllersDescription,
                  optionType: "switch",
                  settingType: "monitorControllers",
                  changeValue: (key, value) =>
                      settings.updateSetting(key, value),
                  isChecked: settings.monitorControllers,
                ),
                const SizedBox(height: 15),
                OptionSetting(
                  title: l10n.monitorHIDTitle,
                  description: l10n.monitorHIDDescription,
                  optionType: "switch",
                  settingType: "monitorHIDDevices",
                  changeValue: (key, value) =>
                      settings.updateSetting(key, value),
                  isChecked: settings.monitorHIDDevices,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIdleTimeoutSetting(
      BuildContext context, SettingsProvider settings, AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.idleTimeoutTitle,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(
                l10n.idleTimeoutDescription(
                    settings.getFormattedIdleTimeout(l10n)),
                style: const TextStyle(fontSize: 12, color: Color(0xff555555)),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Button(
          style: ButtonStyle(
            padding: WidgetStatePropertyAll(
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
          onPressed: () => _showIdleTimeoutDialog(context, settings, l10n),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(settings.getFormattedIdleTimeout(l10n),
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(width: 8),
              const Icon(FluentIcons.edit, size: 14),
            ],
          ),
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

// Idle Timeout Dialog
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

    // Check if current value matches any preset
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
    return ContentDialog(
      title: Text(widget.l10n.setIdleTimeoutTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.l10n.idleTimeoutDialogDescription,
            style: const TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 20),

          // Preset options
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.presets.map((preset) {
              final isSelected =
                  !_isCustom && _selectedValue == preset['value'];
              final isCustomOption = preset['value'] == -1;
              final isCustomSelected = _isCustom && isCustomOption;

              return Button(
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(
                    (isSelected || isCustomSelected)
                        ? FluentTheme.of(context).accentColor.withOpacity(0.2)
                        : null,
                  ),
                  // border: WidgetStatePropertyAll(
                  //   BorderSide(
                  //     color: (isSelected || isCustomSelected)
                  //         ? FluentTheme.of(context).accentColor
                  //         : FluentTheme.of(context).inactiveBackgroundColor,
                  //     width: (isSelected || isCustomSelected) ? 2 : 1,
                  //   ),
                  // ),
                  padding: WidgetStatePropertyAll(
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                ),
                onPressed: () => _selectPreset(preset['value']),
                child: Text(
                  _getPresetLabel(preset),
                  style: TextStyle(
                    fontWeight: (isSelected || isCustomSelected)
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              );
            }).toList(),
          ),

          // Custom input section
          if (_isCustom) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: FluentTheme.of(context)
                    .inactiveBackgroundColor
                    .withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: FluentTheme.of(context).inactiveBackgroundColor,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.l10n.customDurationTitle,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextBox(
                          controller: _minutesController,
                          placeholder: widget.l10n.minutesLabel,
                          keyboardType: TextInputType.number,
                          onChanged: (_) => _validateCustomInput(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(widget.l10n.minAbbreviation),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextBox(
                          controller: _secondsController,
                          placeholder: widget.l10n.secondsLabel,
                          keyboardType: TextInputType.number,
                          onChanged: (_) => _validateCustomInput(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(widget.l10n.secAbbreviation),
                    ],
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ] else ...[
                    const SizedBox(height: 8),
                    Text(
                      widget.l10n.totalLabel(_formatTimeout(_selectedValue)),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xff555555),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.05),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(FluentIcons.info, size: 16, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.l10n.rangeInfo(
                      _formatTimeout(IdleTimeoutOptions.minTimeout),
                      _formatTimeout(IdleTimeoutOptions.maxTimeout),
                    ),
                    style: TextStyle(fontSize: 11, color: Colors.grey[120]),
                  ),
                ),
              ],
            ),
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

class NotificationSection extends StatelessWidget {
  const NotificationSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = context.watch<SettingsProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.notificationsSection,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 15),
        Container(
          height: 300,
          padding: const EdgeInsets.all(20),
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: FluentTheme.of(context).micaBackgroundColor,
              border: Border.all(
                  color: FluentTheme.of(context).inactiveBackgroundColor,
                  width: 1)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OptionSetting(
                title: l10n.notificationsTitle,
                description: l10n.notificationsAllDescription,
                optionType: "switch",
                settingType: "notificationsEnabled",
                changeValue: (key, value) => settings.updateSetting(key, value),
                isChecked: settings.notificationsEnabled,
              ),
              OptionSetting(
                title: l10n.focusModeNotificationsTitle,
                description: l10n.focusModeNotificationsDescription,
                optionType: "switch",
                settingType: "notificationsFocusMode",
                changeValue: (key, value) => settings.updateSetting(key, value),
                isChecked: settings.notificationsFocusMode,
              ),
              OptionSetting(
                title: l10n.screenTimeNotificationsTitle,
                description: l10n.screenTimeNotificationsDescription,
                optionType: "switch",
                settingType: "notificationsScreenTime",
                changeValue: (key, value) => settings.updateSetting(key, value),
                isChecked: settings.notificationsScreenTime,
              ),
              OptionSetting(
                title: l10n.appScreenTimeNotificationsTitle,
                description: l10n.appScreenTimeNotificationsDescription,
                optionType: "switch",
                settingType: "notificationsAppScreenTime",
                changeValue: (key, value) => settings.updateSetting(key, value),
                isChecked: settings.notificationsAppScreenTime,
              ),
              OptionSetting(
                title: l10n.frequentAlertsTitle,
                description: l10n.frequentAlertsDescription,
                optionType: "options",
                settingType: "reminderFrequency",
                changeValue: (key, value) =>
                    settings.updateSetting(key, int.parse(value)),
                optionsValue: settings.getReminderFrequency().toString(),
                options: const [1, 5, 15, 30, 60],
              ),
            ],
          ),
        )
      ],
    );
  }
}

class DataSection extends StatelessWidget {
  const DataSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = Provider.of<SettingsProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.dataSection,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 15),
        Container(
          height: 120,
          padding: const EdgeInsets.all(20),
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: FluentTheme.of(context).micaBackgroundColor,
              border: Border.all(
                  color: FluentTheme.of(context).inactiveBackgroundColor,
                  width: 1)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OptionSetting(
                title: l10n.clearDataTitle,
                description: l10n.clearDataDescription,
                optionType: "button",
                buttonType: "data",
                settingType: "clearData",
                onButtonPressed: () => _showDataDialog(context, settings),
              ),
              OptionSetting(
                title: l10n.resetSettingsTitle2,
                description: l10n.resetSettingsDescription,
                optionType: "button",
                buttonType: "settings",
                settingType: "resetSettings",
                onButtonPressed: () => _showSettingsDialog(context, settings),
              ),
            ],
          ),
        )
      ],
    );
  }

  Future<void> _showDataDialog(
      BuildContext context, SettingsProvider settings) async {
    final l10n = AppLocalizations.of(context)!;

    await showDialog<String>(
      context: context,
      builder: (context) => ContentDialog(
        title: Text(l10n.clearDataDialogTitle),
        content: Text(l10n.clearDataDialogContent),
        actions: [
          Button(
            child: Text(l10n.clearDataButtonLabel),
            onPressed: () {
              settings.clearData();
              Navigator.pop(context, 'User cleared data');
            },
          ),
          FilledButton(
            child: Text(l10n.cancelButton),
            onPressed: () => Navigator.pop(context, 'User canceled dialog'),
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
        title: Text(l10n.resetSettingsDialogTitle),
        content: Text(l10n.resetSettingsDialogContent),
        actions: [
          Button(
            child: Text(l10n.resetButtonLabel),
            onPressed: () {
              settings.resetSettings();
              Navigator.pop(context, 'User reset settings');
            },
          ),
          FilledButton(
            child: Text(l10n.cancelButton),
            onPressed: () => Navigator.pop(context, 'User canceled dialog'),
          ),
        ],
      ),
    );
  }
}

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = Provider.of<SettingsProvider>(context);
    final version = settings.appVersion;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.versionSection,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 15),
        Container(
          height: 77,
          padding: const EdgeInsets.all(20),
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: FluentTheme.of(context).micaBackgroundColor,
              border: Border.all(
                  color: FluentTheme.of(context).inactiveBackgroundColor,
                  width: 1)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.versionTitle,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        Text(l10n.versionDescription,
                            style: const TextStyle(
                                fontSize: 12, color: Color(0xff555555))),
                      ]),
                  Column(
                    children: [
                      Text("${version["version"]}",
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text("${version["type"]}",
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xff555555))),
                    ],
                  )
                ],
              )
            ],
          ),
        )
      ],
    );
  }
}

class OptionSetting extends StatelessWidget {
  final String title;
  final String description;
  final String optionType;
  final String buttonType;
  final bool isChecked;
  final String settingType;
  final void Function(String type, dynamic value)? changeValue;
  final String optionsValue;
  final List<dynamic> options;
  final List<Map<String, String>> languageOptions;
  final VoidCallback? onButtonPressed;

  // Slider properties
  final double sliderValue;
  final double sliderMin;
  final double sliderMax;
  final int? sliderDivisions;

  const OptionSetting({
    super.key,
    required this.title,
    required this.description,
    this.optionType = "options",
    this.buttonType = "",
    this.isChecked = false,
    this.changeValue,
    required this.settingType,
    this.optionsValue = "",
    this.options = const [],
    this.languageOptions = const [],
    this.onButtonPressed,
    this.sliderValue = 0.0,
    this.sliderMin = 0.0,
    this.sliderMax = 100.0,
    this.sliderDivisions,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(description,
                  style:
                      const TextStyle(fontSize: 12, color: Color(0xff555555))),
            ],
          ),
        ),
        const SizedBox(width: 12),
        _buildOptionWidget(l10n, buttonType, isChecked, optionsValue, options,
            languageOptions),
      ],
    );
  }

  Widget _buildOptionWidget(
    AppLocalizations l10n,
    String buttonType,
    bool isChecked,
    String optionsValue,
    List<dynamic> options,
    List<Map<String, String>> languageOptions,
  ) {
    switch (optionType) {
      case "switch":
        return ToggleSwitch(
          checked: isChecked,
          onChanged: (value) {
            if (changeValue != null) {
              changeValue!(settingType, value);
            }
          },
        );
      case "button":
        return Button(
          style: const ButtonStyle(
            padding: WidgetStatePropertyAll(
                EdgeInsets.symmetric(horizontal: 20, vertical: 8)),
          ),
          onPressed: onButtonPressed,
          child: Text(
            buttonType == "data"
                ? l10n.clearDataButtonLabel
                : l10n.resetButtonLabel,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        );
      case "slider":
        return SizedBox(
          width: 200,
          child: Slider(
            value: sliderValue,
            min: sliderMin,
            max: sliderMax,
            divisions: sliderDivisions,
            onChanged: (value) {
              if (changeValue != null) {
                // For audio threshold, pass the double value directly
                if (settingType == "audioThreshold") {
                  changeValue!(settingType, value);
                } else {
                  changeValue!(settingType, value.toInt());
                }
              }
            },
          ),
        );
      default:
        // Handle language options separately
        if (settingType == "language" && languageOptions.isNotEmpty) {
          return ComboBox<String>(
            value: optionsValue,
            items: languageOptions.map((lang) {
              return ComboBoxItem<String>(
                value: lang['code']!,
                child: Text(lang['name']!),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null && changeValue != null) {
                changeValue!(settingType, value);
              }
            },
          );
        }

        // Handle regular options
        return ComboBox<String>(
          value: optionsValue,
          items: options.map((content) {
            return ComboBoxItem<String>(
              value: content.toString(),
              child: Text(content.toString()),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null && changeValue != null) {
              changeValue!(settingType, value);
            }
          },
        );
    }
  }
}

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(l10n.settingsTitle,
            style: FluentTheme.of(context).typography.subtitle),
      ],
    );
  }
}
