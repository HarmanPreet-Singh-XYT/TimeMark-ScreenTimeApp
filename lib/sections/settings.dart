import 'package:fluent_ui/fluent_ui.dart';
import 'package:screentime/sections/controller/app_data_controller.dart';
import 'controller/settings_data_controller.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';
class Settings extends StatefulWidget { 
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final Map<String, String> version = {"version":"1.0.0","type":"Stable Build"};
  SettingsManager settingsManager = SettingsManager();
  String theme = "";
  String language = "English";
  bool launchAtStartupVar = false;
  bool notificationsEnabled = false;
  bool notificationsFocusMode = false;
  bool notificationsScreenTime = false;
  bool notificationsAppScreenTime = false;
  @override
  void initState() {
    super.initState();
    theme = settingsManager.getSetting("theme.selected");
    language = settingsManager.getSetting("language.selected");
    launchAtStartupVar = settingsManager.getSetting("launchAtStartup");
    notificationsEnabled = settingsManager.getSetting("notifications.enabled");
    notificationsFocusMode = settingsManager.getSetting("notifications.focusMode");
    notificationsScreenTime = settingsManager.getSetting("notifications.screenTime");
    notificationsAppScreenTime = settingsManager.getSetting("notifications.appScreenTime");
  }
  void setSetting(String key, dynamic value) async {
    switch (key) {
      case 'theme':
        setState(() {
          theme = value;
          settingsManager.updateSetting("theme", value);
        });
        break;
      case 'language':
        setState(() {
          language = value;
          settingsManager.updateSetting("language", value);
        });
        break;
      case 'launchAtStartup':
        () async {
          value ? await launchAtStartup.enable() : await launchAtStartup.disable();
          setState(() {
            launchAtStartupVar = value;
            settingsManager.updateSetting("launchAtStartup", value);
          });
        };
        break;
      case 'notificationsEnabled':
        setState(() {
          notificationsEnabled = value;
          settingsManager.updateSetting("notifications.enabled", value);
        });
        break;
      case 'notificationsScreenTime':
        setState(() {
          notificationsScreenTime = value;
          settingsManager.updateSetting("notifications.screenTime", value);
        });
        break;
      case 'notificationsFocusMode':
        setState(() {
          notificationsFocusMode = value;
          settingsManager.updateSetting("notifications.focusMode", value);
        });
        break;
      case 'notificationsAppScreenTime':
        setState(() {
          notificationsAppScreenTime = value;
          settingsManager.updateSetting("notifications.appScreenTime", value);
        });
        break;
    }
  }
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
  @override
  String urlContact = 'https://harman.vercel.app/details/screentime';
  String urlReport = 'https://harman.vercel.app/details/screentime';
  String urlFeedback = 'https://harman.vercel.app/details/screentime';
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20,top: 10),
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
              AboutSection(version: version),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Button(
                    style: ButtonStyle(padding: WidgetStateProperty.all(const EdgeInsets.only(top: 8,bottom: 8,left: 14,right: 14))),
                    child:const Row(
                      children: [
                        Icon(FluentIcons.canned_chat,size: 18,),
                        SizedBox(width: 10,),
                        Text('Contact',style: TextStyle(fontWeight: FontWeight.w600),),
                      ],
                    ),
                    onPressed: () => setState(() {
                    _launched = _launchInBrowser(urlContact);
                    }),
                ),
                  const SizedBox(width: 25,),
                  Button(
                    style: ButtonStyle(padding: WidgetStateProperty.all(const EdgeInsets.only(top: 8,bottom: 8,left: 14,right: 14))),
                    child:const Row(
                      children: [
                        Icon(FluentIcons.bug,size: 18,),
                        SizedBox(width: 10,),
                        Text('Report Bug',style: TextStyle(fontWeight: FontWeight.w600),),
                      ],
                    ),
                    onPressed: () => setState(() {
                    _launched = _launchInBrowser(urlReport);
                    }),
                  ),
                  const SizedBox(width: 25,),
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
              const SizedBox(height: 20)
            ],
          ),
        ),
      );
  }
}


class GeneralSection extends StatefulWidget {
  const GeneralSection({
    super.key,
  });

  @override
  State<GeneralSection> createState() => _GeneralSectionState();
}

class _GeneralSectionState extends State<GeneralSection> {
  SettingsManager settingsManager = SettingsManager();
  String theme = "";
  String language = "English";
  List<dynamic> themeOptions = ["System","Dark"];
  List<dynamic> languageOptions = ["English"];
  bool launchAtStartup = false;
  @override
  void initState() {
    super.initState();
    theme = settingsManager.getSetting("theme.selected");
    language = settingsManager.getSetting("language.selected");
    themeOptions = settingsManager.getSetting("theme.available");
    languageOptions = settingsManager.getSetting("language.available");
    launchAtStartup = settingsManager.getSetting("launchAtStartup");
  }
  void setSetting(String key, dynamic value) {
    switch (key) {
      case 'theme':
        setState(() {
          theme = value;
          settingsManager.updateSetting("theme.selected", value);
        });
        break;
      case 'language':
        setState(() {
          language = value;
          settingsManager.updateSetting("language.selected", value);
        });
        break;
      case 'launchAtStartup':
        setState(() {
          launchAtStartup = value;
          settingsManager.updateSetting("launchAtStartup", value);
        });
        break;
    }
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("General",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w600),),
        const SizedBox(height: 15,),
        Container(
          height: 180,
          padding:const EdgeInsets.all(20),
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: FluentTheme.of(context).micaBackgroundColor,
            border: Border.all(color: FluentTheme.of(context).inactiveBackgroundColor,width: 1)
          ),
          child:Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OptionSetting(title: "Theme",description: "Color theme of the application",settingType: "theme",changeValue: setSetting,optionsValue: theme,options: themeOptions,),
              OptionSetting(title: "Language",description: "Language of the application",settingType: "language",changeValue: setSetting, optionsValue: language,options: languageOptions,),
              OptionSetting(title: "Startup Behaviour",description: "Launch at OS startup",optionType: "switch",settingType: "launchAtStartup",changeValue: setSetting,isChecked: launchAtStartup,),
            ],
          ),
        )
      ],
    );
  }
}
class NotificationSection extends StatefulWidget {
  const NotificationSection({
    super.key,
  });

  @override
  State<NotificationSection> createState() => _NotificationSectionState();
}

class _NotificationSectionState extends State<NotificationSection> {
  SettingsManager settingsManager = SettingsManager();
  bool notificationsEnabled = false;
  bool notificationsFocusMode = false;
  bool notificationsScreenTime = false;
  bool notificationsAppScreenTime = false;
  @override
  void initState() {
    super.initState();
    notificationsEnabled = settingsManager.getSetting("notifications.enabled");
    notificationsFocusMode = settingsManager.getSetting("notifications.focusMode");
    notificationsScreenTime = settingsManager.getSetting("notifications.screenTime");
    notificationsAppScreenTime = settingsManager.getSetting("notifications.appScreenTime");
  }
  void setSetting(String key, dynamic value) {
    switch (key) {
      case 'notificationsEnabled':
        setState(() {
          notificationsEnabled = value;
          settingsManager.updateSetting("notifications.enabled", value);
        });
        break;
      case 'notificationsScreenTime':
        setState(() {
          notificationsScreenTime = value;
          settingsManager.updateSetting("notifications.screenTime", value);
        });
        break;
      case 'notificationsFocusMode':
        setState(() {
          notificationsFocusMode = value;
          settingsManager.updateSetting("notifications.focusMode", value);
        });
        break;
      case 'notificationsAppScreenTime':
        setState(() {
          notificationsAppScreenTime = value;
          settingsManager.updateSetting("notifications.appScreenTime", value);
        });
        break;
    }
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Notifications",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w600),),
        const SizedBox(height: 15,),
        Container(
          height: 240,
          padding:const EdgeInsets.all(20),
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: FluentTheme.of(context).micaBackgroundColor,
            border: Border.all(color: FluentTheme.of(context).inactiveBackgroundColor,width: 1)
          ),
          child:Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OptionSetting(title: "Notifications",description: "All notifications of the application",optionType: "switch",settingType: "notificationsEnabled",changeValue: setSetting,isChecked: notificationsEnabled,),
              OptionSetting(title: "Focus Mode",description: "All Notifications for focus mode",optionType: "switch",settingType: "notificationsFocusMode",changeValue: setSetting,isChecked: notificationsFocusMode,),
              OptionSetting(title: "Screen Time",description: "All Notifications for screen time restriction",optionType: "switch",settingType: "notificationsScreenTime",changeValue: setSetting,isChecked: notificationsScreenTime,),
              OptionSetting(title: "Application Screen Time",description: "All Notifications for application screen time restriction",optionType: "switch",settingType: "notificationsAppScreenTime",changeValue: setSetting,isChecked: notificationsAppScreenTime,),
            ],
          ),
        )
      ],
    );
  }
}

class DataSection extends StatefulWidget {
  const DataSection({
    super.key,
  });

  @override
  State<DataSection> createState() => _DataSectionState();
}

class _DataSectionState extends State<DataSection> {
  SettingsManager settingsManager = SettingsManager();
  Future<void> _clearData() async{
    final AppDataStore _dataStore = AppDataStore();
    await _dataStore.init();
    await _clearData();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Data",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w600),),
        const SizedBox(height: 15,),
        Container(
          height: 120,
          padding:const EdgeInsets.all(20),
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: FluentTheme.of(context).micaBackgroundColor,
            border: Border.all(color: FluentTheme.of(context).inactiveBackgroundColor,width: 1)
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OptionSetting(
                title: "Clear Data",
                description: "Clear all the history and other related data",
                optionType: "button",
                buttonType: "data",
                settingType: "",
                // Pass the dialog function to the OptionSetting
                onButtonPressed: () => showDataDialog(context),
              ),
              OptionSetting(
                title: "Reset Settings",
                description: "Reset all the settings",
                optionType: "button",
                buttonType: "settings",
                settingType: "",
                // Pass the dialog function to the OptionSetting
                onButtonPressed: () => showSettingsDialog(context),
              ),
            ],
          ),
        )
      ],
    );
  }

  void showDataDialog(BuildContext context) async {
    final result = await showDialog<String>(
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
              _clearData();
              Navigator.pop(context, 'User cleared data');
              // Clear data implementation here
            },
          ),
          FilledButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context, 'User canceled dialog'),
          ),
        ],
      ),
    );
    setState(() {});
  }

  void showSettingsDialog(BuildContext context) async {
    final result = await showDialog<String>(
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
              settingsManager.resetSettings();
              Navigator.pop(context, 'User reset settings');
              // Reset settings implementation here
            },
          ),
          FilledButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context, 'User canceled dialog'),
          ),
        ],
      ),
    );
    setState(() {});
  }
}
class AboutSection extends StatelessWidget {
  final Map<String, String> version;
  const AboutSection({
    super.key,
    required this.version

  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Version",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w600),),
        const SizedBox(height: 15,),
        Container(
          height: 77,
          padding:const EdgeInsets.all(20),
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: FluentTheme.of(context).micaBackgroundColor,
            border: Border.all(color: FluentTheme.of(context).inactiveBackgroundColor,width: 1)
          ),
          child:Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    Text("Version",style: TextStyle(fontWeight: FontWeight.bold),),
                    Text("Current version of the app",style: TextStyle(fontSize: 12,color: Color(0xff555555)),),
                  ]),
                  Column(
                    children: [
                      Text("${version["version"]}",style:const TextStyle(fontWeight: FontWeight.bold),),
                      Text("${version["type"]}",style:const TextStyle(fontSize: 12,color: Color(0xff555555)),),
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
  // Add new callback for button press
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
    // Make the new callback optional
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
          // Use the new callback instead of the old one
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
              value: content,
              child: Text(content),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              if (changeValue != null) {
                changeValue!(settingType, value);
              }
            }
          },
        );
    }
  }
}



class Header extends StatelessWidget {
  const Header({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("Settings",style: FluentTheme.of(context).typography.subtitle,),
      ],
    );
  }
}