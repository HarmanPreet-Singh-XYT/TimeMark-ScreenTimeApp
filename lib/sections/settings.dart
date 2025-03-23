import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:screentime/sections/controller/app_data_controller.dart';
import 'controller/settings_data_controller.dart';
import '../../auto_launch/launch_at_startup.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

// Create a SettingsProvider to centralize state management
class SettingsProvider extends ChangeNotifier {
  final SettingsManager _settingsManager = SettingsManager();
  final Map<String, String> version = {"version": "1.0.0", "type": "Stable Build"};
  
  String _theme = "";
  String _language = "English";
  bool _launchAtStartupVar = false;
  bool _notificationsEnabled = false;
  bool _notificationsFocusMode = false;
  bool _notificationsScreenTime = false;
  bool _notificationsAppScreenTime = false;
  
  // Getters
  String get theme => _theme;
  String get language => _language;
  bool get launchAtStartupVar => _launchAtStartupVar;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get notificationsFocusMode => _notificationsFocusMode;
  bool get notificationsScreenTime => _notificationsScreenTime;
  bool get notificationsAppScreenTime => _notificationsAppScreenTime;
  Map<String, String> get appVersion => version;
  
  // List<dynamic> themeOptions = ["System","Dark","Light"];
  // List<dynamic> languageOptions = [ 'English'];
  List<dynamic> get themeOptions => _settingsManager.getAvailableThemes();
  List<dynamic> get languageOptions => _settingsManager.getAvailableLanguages();
  
  SettingsProvider() {
    _loadSettings();
  }
  
  void _loadSettings() {
    _theme = _settingsManager.getSetting("theme.selected");
    _language = _settingsManager.getSetting("language.selected");
    _launchAtStartupVar = _settingsManager.getSetting("launchAtStartup");
    _notificationsEnabled = _settingsManager.getSetting("notifications.enabled");
    _notificationsFocusMode = _settingsManager.getSetting("notifications.focusMode");
    _notificationsScreenTime = _settingsManager.getSetting("notifications.screenTime");
    _notificationsAppScreenTime = _settingsManager.getSetting("notifications.appScreenTime");
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
        // Handle startup setting with proper await
        if (value) {
          await launchAtStartup.enable();
        } else {
          await launchAtStartup.disable();
        }
        _launchAtStartupVar = value;
        _settingsManager.updateSetting("launchAtStartup", value);
        break;
      case 'notificationsEnabled':
        _notificationsEnabled = value;
        _settingsManager.updateSetting("notifications.enabled", value);
        break;
      case 'notificationsScreenTime':
        _notificationsScreenTime = value;
        _settingsManager.updateSetting("notifications.screenTime", value);
        break;
      case 'notificationsFocusMode':
        _notificationsFocusMode = value;
        _settingsManager.updateSetting("notifications.focusMode", value);
        break;
      case 'notificationsAppScreenTime':
        _notificationsAppScreenTime = value;
        _settingsManager.updateSetting("notifications.appScreenTime", value);
        break;
    }
    notifyListeners();
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
  const Settings({super.key});
  
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SettingsProvider(),
      child: const SettingsContent(),
    );
  }
}

class SettingsContent extends StatefulWidget {
  const SettingsContent({super.key});

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
    if (snapshot.hasError) {
      return Text('Error: ${snapshot.error}');
    } else {
      return const Text('');
    }
  }
  
  final String urlContact = 'https://harman.vercel.app/details/screentime';
  final String urlReport = 'https://harman.vercel.app/details/screentime';
  final String urlFeedback = 'https://harman.vercel.app/details/screentime';
  
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Header(),
            const SizedBox(height: 30),
            const GeneralSection(),
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
                  child: const Row(
                    children: [
                      Icon(FluentIcons.canned_chat, size: 18),
                      SizedBox(width: 10),
                      Text('Contact', style: TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                  onPressed: () => setState(() {
                    _launched = _launchInBrowser(urlContact);
                  }),
                ),
                const SizedBox(width: 25),
                Button(
                  style: ButtonStyle(padding: WidgetStateProperty.all(const EdgeInsets.only(top: 8, bottom: 8, left: 14, right: 14))),
                  child: const Row(
                    children: [
                      Icon(FluentIcons.bug, size: 18),
                      SizedBox(width: 10),
                      Text('Report Bug', style: TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                  onPressed: () => setState(() {
                    _launched = _launchInBrowser(urlReport);
                  }),
                ),
                const SizedBox(width: 25),
                Button(
                  style: ButtonStyle(padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 8, horizontal: 12))),
                  child: const Row(
                    children: [
                      Icon(FluentIcons.red_eye, size: 20),
                      SizedBox(width: 10),
                      Text('Submit Feedback', style: TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                  onPressed: () => setState(() {
                    _launched = _launchInBrowser(urlFeedback);
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
  const GeneralSection({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("General", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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
                title: "Theme",
                description: "Color theme of the application (Change Requires Restart)",
                settingType: "theme",
                changeValue: (key, value) => settings.updateSetting(key, value, context),
                optionsValue: settings.theme,
                options: settings.themeOptions,
              ),
              OptionSetting(
                title: "Language",
                description: "Language of the application",
                settingType: "language",
                changeValue: (key, value) => settings.updateSetting(key, value),
                optionsValue: settings.language,
                options: settings.languageOptions,
              ),
              OptionSetting(
                title: "Startup Behaviour",
                description: "Launch at OS startup",
                optionType: "switch",
                settingType: "launchAtStartup",
                changeValue: (key, value) => settings.updateSetting(key, value),
                isChecked: settings.launchAtStartupVar,
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
    final settings = context.watch<SettingsProvider>();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Notifications", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 15),
        Container(
          height: 240,
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
                title: "Notifications",
                description: "All notifications of the application",
                optionType: "switch",
                settingType: "notificationsEnabled",
                changeValue: (key, value) => settings.updateSetting(key, value),
                isChecked: settings.notificationsEnabled,
              ),
              OptionSetting(
                title: "Focus Mode",
                description: "All Notifications for focus mode",
                optionType: "switch",
                settingType: "notificationsFocusMode",
                changeValue: (key, value) => settings.updateSetting(key, value),
                isChecked: settings.notificationsFocusMode,
              ),
              OptionSetting(
                title: "Screen Time",
                description: "All Notifications for screen time restriction",
                optionType: "switch",
                settingType: "notificationsScreenTime",
                changeValue: (key, value) => settings.updateSetting(key, value),
                isChecked: settings.notificationsScreenTime,
              ),
              OptionSetting(
                title: "Application Screen Time",
                description: "All Notifications for application screen time restriction",
                optionType: "switch",
                settingType: "notificationsAppScreenTime",
                changeValue: (key, value) => settings.updateSetting(key, value),
                isChecked: settings.notificationsAppScreenTime,
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
    final settings = Provider.of<SettingsProvider>(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Data", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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
                title: "Clear Data",
                description: "Clear all the history and other related data",
                optionType: "button",
                buttonType: "data",
                settingType: "clearData",
                onButtonPressed: () => _showDataDialog(context, settings),
              ),
              OptionSetting(
                title: "Reset Settings",
                description: "Reset all the settings",
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
    await showDialog<String>(
      context: context,
      builder: (context) => ContentDialog(
        title: const Text('Clear Data?'),
        content: const Text(
          'This will clear all history and related data. You won\'t be able to recover it. Do you want to proceed?',
        ),
        actions: [
          Button(
            child: const Text('Clear Data'),
            onPressed: () {
              settings.clearData();
              Navigator.pop(context, 'User cleared data');
            },
          ),
          FilledButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context, 'User canceled dialog'),
          ),
        ],
      ),
    );
  }

  Future<void> _showSettingsDialog(BuildContext context, SettingsProvider settings) async {
    await showDialog<String>(
      context: context,
      builder: (context) => ContentDialog(
        title: const Text('Reset Settings?'),
        content: const Text(
          'This will reset all settings to their default values. Do you want to proceed?',
        ),
        actions: [
          Button(
            child: const Text('Reset'),
            onPressed: () {
              settings.resetSettings();
              Navigator.pop(context, 'User reset settings');
            },
          ),
          FilledButton(
            child: const Text('Cancel'),
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
    final settings = Provider.of<SettingsProvider>(context);
    final version = settings.appVersion;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Version", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Version", style: TextStyle(fontWeight: FontWeight.bold)),
                      Text("Current version of the app", style: TextStyle(fontSize: 12, color: Color(0xff555555))),
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

// The OptionSetting widget remains largely the same
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
    this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
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
        _buildOptionWidget(buttonType, isChecked, optionsValue, options),
      ],
    );
  }

  Widget _buildOptionWidget(String buttonType, bool isChecked, String optionsValue, List<dynamic> options) {
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
            buttonType == "data" ? "Clear Data" : "Reset Settings",
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        );
      default:
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("Settings", style: FluentTheme.of(context).typography.subtitle),
      ],
    );
  }
}