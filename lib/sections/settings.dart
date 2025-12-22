import 'package:fluent_ui/fluent_ui.dart';
import 'package:screentime/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:screentime/sections/controller/app_data_controller.dart';
import 'controller/settings_data_controller.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

// Create a SettingsProvider to centralize state management
class SettingsProvider extends ChangeNotifier {
  final SettingsManager _settingsManager = SettingsManager();
  final Map<String, String> version = SettingsManager().versionInfo;
  
  String _theme = "";
  String _language = "en";
  bool _launchAtStartupVar = false;
  bool _launchAsMinimized = false;
  bool _notificationsEnabled = false;
  bool _notificationsFocusMode = false;
  bool _notificationsScreenTime = false;
  bool _notificationsAppScreenTime = false;
  
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
  
  List<dynamic> get themeOptions => _settingsManager.getAvailableThemes();
  List<Map<String, String>> get languageOptions => _settingsManager.getAvailableLanguages();
  int _reminderFrequency = 60;
  int get reminderFrequency => _reminderFrequency;
  
  SettingsProvider() {
    _loadSettings();
  }
  
  void _loadSettings() {
    _theme = _settingsManager.getSetting("theme.selected");
    _language = _settingsManager.getSetting("language.selected") ?? "en";
    _launchAtStartupVar = _settingsManager.getSetting("launchAtStartup");
    _launchAsMinimized = _settingsManager.getSetting("launchAsMinimized") ?? false;
    _notificationsEnabled = _settingsManager.getSetting("notifications.enabled");
    _notificationsFocusMode = _settingsManager.getSetting("notifications.focusMode");
    _notificationsScreenTime = _settingsManager.getSetting("notifications.screenTime");
    _notificationsAppScreenTime = _settingsManager.getSetting("notifications.appScreenTime");
    _reminderFrequency = _settingsManager.getSetting("notificationController.reminderFrequency");
  }
  
  Future<void> updateSetting(String key, dynamic value, [BuildContext? context]) async {
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
        _settingsManager.updateSetting("notificationController.reminderFrequency", value);
        break;
    }
    notifyListeners();
  }
  
  int getReminderFrequency() {
    return _settingsManager.getSetting("notificationController.reminderFrequency") ?? 60;
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
  
  final String urlContact = 'https://harmanita.com/details/screentime';
  final String urlReport = 'https://harmanita.com/details/screentime';
  final String urlFeedback = 'https://harmanita.com/details/screentime';
  final String github = 'https://github.com/HarmanPreet-Singh-XYT/TimeMark-ScreenTimeApp';
  
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Header(),
            const SizedBox(height: 30),
            GeneralSection(setLocale: widget.setLocale),
            const SizedBox(height: 30),
            const NotificationSection(),
            const SizedBox(height: 30),
            const DataSection(),
            const SizedBox(height: 30),
            const AboutSection(),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Button(
                  style: ButtonStyle(padding: WidgetStateProperty.all(const EdgeInsets.only(top: 8, bottom: 8, left: 14, right: 14))),
                  child: Row(
                    children: [
                      const Icon(FluentIcons.canned_chat, size: 18),
                      const SizedBox(width: 10),
                      Text(l10n.contactButton, style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                  onPressed: () => setState(() {
                    _launched = _launchInBrowser(urlContact);
                  }),
                ),
                const SizedBox(width: 25),
                Button(
                  style: ButtonStyle(padding: WidgetStateProperty.all(const EdgeInsets.only(top: 8, bottom: 8, left: 14, right: 14))),
                  child: Row(
                    children: [
                      const Icon(FluentIcons.bug, size: 18),
                      const SizedBox(width: 10),
                      Text(l10n.reportBugButton, style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                  onPressed: () => setState(() {
                    _launched = _launchInBrowser(urlReport);
                  }),
                ),
                const SizedBox(width: 25),
                Button(
                  style: ButtonStyle(padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 8, horizontal: 12))),
                  child: Row(
                    children: [
                      const Icon(FluentIcons.red_eye, size: 20),
                      const SizedBox(width: 10),
                      Text(l10n.submitFeedbackButton, style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                  onPressed: () => setState(() {
                    _launched = _launchInBrowser(urlFeedback);
                  }),
                ),
                const SizedBox(width: 25),
                Button(
                  style: ButtonStyle(padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 8, horizontal: 12))),
                  child: Text(l10n.githubButton, style: const TextStyle(fontWeight: FontWeight.w600)),
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
        Text(l10n.generalSection, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 15),
        Container(
          height: 180,
          padding: const EdgeInsets.all(20),
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: FluentTheme.of(context).micaBackgroundColor,
            border: Border.all(color: FluentTheme.of(context).inactiveBackgroundColor, width: 1)
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OptionSetting(
                title: l10n.themeTitle,
                description: l10n.themeDescription,
                settingType: "theme",
                changeValue: (key, value) => settings.updateSetting(key, value, context),
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

class NotificationSection extends StatelessWidget {
  const NotificationSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = context.watch<SettingsProvider>();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.notificationsSection, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 15),
        Container(
          height: 300,
          padding: const EdgeInsets.all(20),
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: FluentTheme.of(context).micaBackgroundColor,
            border: Border.all(color: FluentTheme.of(context).inactiveBackgroundColor, width: 1)
          ),
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
                changeValue: (key, value) => settings.updateSetting(key, int.parse(value)),
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
        Text(l10n.dataSection, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 15),
        Container(
          height: 120,
          padding: const EdgeInsets.all(20),
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: FluentTheme.of(context).micaBackgroundColor,
            border: Border.all(color: FluentTheme.of(context).inactiveBackgroundColor, width: 1)
          ),
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

  Future<void> _showDataDialog(BuildContext context, SettingsProvider settings) async {
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

  Future<void> _showSettingsDialog(BuildContext context, SettingsProvider settings) async {
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
        Text(l10n.versionSection, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 15),
        Container(
          height: 77,
          padding: const EdgeInsets.all(20),
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: FluentTheme.of(context).micaBackgroundColor,
            border: Border.all(color: FluentTheme.of(context).inactiveBackgroundColor, width: 1)
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.versionTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(l10n.versionDescription, style: const TextStyle(fontSize: 12, color: Color(0xff555555))),
                    ]
                  ),
                  Column(
                    children: [
                      Text("${version["version"]}", style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text("${version["type"]}", style: const TextStyle(fontSize: 12, color: Color(0xff555555))),
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
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(description, style: const TextStyle(fontSize: 12, color: Color(0xff555555))),
          ],
        ),
        _buildOptionWidget(l10n, buttonType, isChecked, optionsValue, options, languageOptions),
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
            padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 20, vertical: 8)),
          ),
          onPressed: onButtonPressed,
          child: Text(
            buttonType == "data" ? l10n.clearDataButtonLabel : l10n.resetButtonLabel,
            style: const TextStyle(fontWeight: FontWeight.w600),
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
        Text(l10n.settingsTitle, style: FluentTheme.of(context).typography.subtitle),
      ],
    );
  }
}