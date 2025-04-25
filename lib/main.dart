import 'dart:io';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:screentime/sections/controller/app_data_controller.dart';
import 'package:screentime/sections/controller/notification_controller.dart';
import './sections/overview.dart';
import './sections/applications.dart';
import './sections/alerts_limits.dart';
import './sections/focus_mode.dart';
import './sections/reports.dart';
import './sections/settings.dart';
import './sections/help.dart';
import 'sections/controller/settings_data_controller.dart';
import './adaptive_fluent/adaptive_theme_fluent_ui.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:tray_manager/tray_manager.dart';
import './sections/controller/application_controller.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  // Create an instance of the controller
  final bool wasSystemLaunched = args.contains('--auto-launched');
  // Check the launch type
  await SettingsManager().init();
  final bool isMinimizeAtLaunch = await SettingsManager().getSetting("launchAsMinimized") ?? false;
  await NotificationController().initialize();
  // Get the saved theme preference
  final String savedTheme = SettingsManager().getSetting("theme.selected") ?? "System";
  final AdaptiveThemeMode initialTheme;
  
  // Convert string theme setting to AdaptiveThemeMode
  switch (savedTheme) {
    case "Dark":
      initialTheme = AdaptiveThemeMode.dark;
      break;
    case "Light":
      initialTheme = AdaptiveThemeMode.light;
      break;
    case "System":
    default:
      initialTheme = AdaptiveThemeMode.system;
      break;
  }
  final tracker = BackgroundAppTracker();
  tracker.initializeTracking();
  runApp(MyApp(initialTheme: initialTheme));
  doWhenWindowReady(() {
    final win = appWindow;
    const String appName = 'TimeMark - Track Screen Time & App Usage';
    const initialSize = Size(1280, 800);
    win.minSize = initialSize;
    win.size = initialSize;
    win.alignment = Alignment.center;
    win.title = appName;
    if(wasSystemLaunched || isMinimizeAtLaunch){
      win.hide();
    }else{
      win.show();
    }
  });
}

class MyApp extends StatefulWidget {
  final AdaptiveThemeMode initialTheme;
  
  const MyApp({super.key, this.initialTheme = AdaptiveThemeMode.system});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with TrayListener,WidgetsBindingObserver {
  bool notificationsEnabled = true;
  final String appVersion = "v1.0.1";
  bool focusMode = false;
  int selectedIndex = 0;
  final AppDataStore _dataStore = AppDataStore();
  void changeIndex(int value){
    setState(() {
      selectedIndex = value;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initDataStore();
    _initTray();
    trayManager.addListener(this);
  }
  Future<void> _initDataStore() async {
    await _dataStore.init();
  }
  Future<void> _initTray() async {
    await trayManager.setIcon(
      Platform.isWindows
        ? 'assets/icons/tray_icon.ico'
        : 'assets/icons/tray_icon.png',
    );
    await trayManager.setToolTip("TimeMark");
    await _updateTrayMenu();
  }

  Future<void> _updateTrayMenu() async {
    await trayManager.setContextMenu(
      Menu(items: [
        MenuItem(label: 'Show Window', onClick: (_) => _showApp()),
        // MenuItem(label: !focusMode ? 'Start Focus Mode' : 'Stop Focus Mode', onClick: (_) => _startFocusMode()),
        MenuItem.separator(),
        MenuItem(label: 'Reports', onClick: (_) => _openReports()),
        MenuItem(label: 'Alerts & Limits', onClick: (_) => _openAlerts()),
        MenuItem(label: 'Applications', onClick: (_) => _openApplications()),
        MenuItem.separator(),
        // MenuItem(disabled:true,label: notificationsEnabled ? 'Disable Notifications' : 'Enable Notifications', onClick: (_) => _toggleNotifications()),
        MenuItem(disabled:true,label: 'Version: $appVersion', checked: false),
        MenuItem.separator(),
        MenuItem(label: 'Exit', onClick: (_) => _exitApp()),
      ]),
    );
  }

  void _showApp(){
    appWindow.show();
  }

  void _exitApp() {
    appWindow.close();
  }

  // void _startFocusMode() {
  //   // Implement focus mode activation
    
  // }

  void _openReports() {
    // Implement opening reports section
    if(!appWindow.isVisible){
      changeIndex(3);
      appWindow.show();
      setState(() {});
    }else{
      setState(() {
        changeIndex(3);
      });
    }
  }

  void _openAlerts() {
    // Implement opening alerts section
    if(!appWindow.isVisible){
      changeIndex(2);
      appWindow.show();
      setState(() {});
    }else{
      setState(() {
        changeIndex(2);
      });
    }
  }

  void _openApplications() {
    // Implement opening applications section
    if(!appWindow.isVisible){
      changeIndex(1);
      appWindow.show();
      setState(() {});
    }else{
      setState(() {
        changeIndex(1);
      });
    }
  }

  void _toggleNotifications() {
    setState(() {
      notificationsEnabled = !notificationsEnabled;
    });
    _updateTrayMenu();
  }

  @override
  void onTrayIconMouseDown() {
    appWindow.show();
  }
  @override
  void onTrayIconRightMouseDown() {
    trayManager.popUpContextMenu();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    if (menuItem.label == 'Show Window') {
      appWindow.show();
    } else if (menuItem.label == 'Exit') {
      _exitApp();
    } 
    // else if (menuItem.label == 'Start Focus Mode') {
    //   // _startFocusMode();
    // } 
    else if (menuItem.label == 'Reports') {
      _openReports();
    } else if (menuItem.label == 'Alerts & Limits') {
      _openAlerts();
    } else if (menuItem.label == 'Applications') {
      _openApplications();
    } else if (menuItem.label!.contains('Notifications')) {
      _toggleNotifications();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    BackgroundAppTracker().dispose();
    _dataStore.dispose().then((_) {
      Hive.close();
    });
    trayManager.removeListener(this);
    super.dispose();
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _dataStore.handleAppLifecycleState(state);
  }
  @override
  Widget build(BuildContext context) {
    return FluentAdaptiveTheme(
      light: FluentThemeData.light(),
      dark: FluentThemeData(
          brightness: Brightness.dark,
          cardColor: const Color(0xff202020),
          scaffoldBackgroundColor: const Color.fromARGB(255, 20, 20, 20)
      ),
      initial: widget.initialTheme, // Use the initial theme from settings
      builder: (theme, darkTheme) => FluentApp(
        title: 'Fluent Adaptive Theme Demo',
        theme: theme,
        darkTheme: darkTheme,
        home: HomePage(selectedIndex: selectedIndex, changeIndex: changeIndex),
      ),
    );
  }
}


class HomePage extends StatefulWidget {
  final int selectedIndex;
  final Function(int) changeIndex;
  const HomePage({
    super.key,
    required this.selectedIndex,
    required this.changeIndex
    });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  PaneDisplayMode displayMode = PaneDisplayMode.compact;

  List<NavigationPaneItem> items = [
    PaneItem(
      icon: const Icon(FluentIcons.home, size: 20),
      title: const Text('Overview', style: TextStyle(fontWeight: FontWeight.w500)),
      body: const Overview(),
    ),
    PaneItem(
      icon: const Icon(FluentIcons.app_icon_default_list, size: 20),
      title: const Text('Applications', style: TextStyle(fontWeight: FontWeight.w500)),
      body: const Applications(),
    ),
    PaneItem(
      icon: const Icon(FluentIcons.alert_settings, size: 20),
      title: const Text('Alerts & Limits', style: TextStyle(fontWeight: FontWeight.w500)),
      body: const AlertsLimits(),
    ),
    PaneItem(
      icon: const Icon(FluentIcons.analytics_report, size: 20),
      title: const Text('Reports', style: TextStyle(fontWeight: FontWeight.w500)),
      body: const Reports(),
    ),
    PaneItem(
      icon: const Icon(FluentIcons.red_eye, size: 20),
      title: const Text('Focus Mode', style: TextStyle(fontWeight: FontWeight.w500)),
      body: const FocusMode(),
    ),
    PaneItem(
      icon: const Icon(FluentIcons.settings, size: 20),
      title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.w500)),
      body: const Settings(),
    ),
    PaneItem(
      icon: const Icon(FluentIcons.chat_bot, size: 20),
      title: const Text('Help', style: TextStyle(fontWeight: FontWeight.w500)),
      body: const Help(),
    ),
  ];

  @override
Widget build(BuildContext context) {
  return Column(
    children: [
      const TitleBar(), // Add the Title Bar at the top
      Expanded(
        child: WindowBorder(
          color:FluentTheme.of(context).micaBackgroundColor,
          child: NavigationView(
            pane: NavigationPane(
              selected: widget.selectedIndex,
              onChanged: (index) => setState(() => widget.changeIndex(index)),
              displayMode: displayMode,
              items: items,
              header: _buildSidebarHeader(context),
            ),
          ),
        ),
      ),
    ],
  );
}

  Widget _buildSidebarHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ScreenTime',
            style: FluentTheme.of(context).typography.title,
          ),
          Text(
            'Open Source',
            style: FluentTheme.of(context).typography.caption?.copyWith(
                  fontSize: 14,
                  color: const Color(0xff555555),
                ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

/// Custom Window Title Bar
class TitleBar extends StatelessWidget {
  const TitleBar({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = FluentTheme.of(context).brightness == Brightness.dark;

    final Color backgroundColor = FluentTheme.of(context).micaBackgroundColor;
    final Color textColor = isDarkMode ? Colors.white : const Color.fromARGB(255, 20, 20, 20);

    return WindowTitleBarBox(
      child: Container(
        color: backgroundColor, // Dynamically change color
        child: Row(
          children: [
            Expanded(
              child: MoveWindow(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Productive ScreenTime",
                        style: FluentTheme.of(context).typography.body?.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: textColor, // Change text color dynamically
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const WindowButtons(),
          ],
        ),
      ),
    );
  }
}



/// Window Buttons (Minimize, Maximize, Close)
final buttonColors = WindowButtonColors(
    iconNormal: Colors.purple,
    mouseOver: Colors.purple,
    mouseDown: Colors.red,
    iconMouseOver: Colors.red,
    iconMouseDown: Colors.purple);

final closeButtonColors = WindowButtonColors(
    mouseOver: const Color(0xFFD32F2F),
    mouseDown: const Color(0xFFB71C1C),
    iconNormal: const Color(0xFF805306),
    iconMouseOver: Colors.white);

class WindowButtons extends StatelessWidget {
  const WindowButtons({super.key});
  // void showExitDialog(BuildContext context) async {
  // final result = await showDialog<String>(
  //   context: context,
  //   barrierDismissible: false,
  //   builder: (context) => ContentDialog(
  //       title: const Text('Exit Program?'),
  //       content: const Text(
  //         'The window will be hidden. To fully exit the program, use the system menu.',
  //       ),
  //       actions: [
  //         Button(
  //           child: const Text('Cancel'),
  //           onPressed: () => Navigator.pop(context, 'User canceled'),
  //         ),
  //         FilledButton(
  //           child: const Text('Exit'),
  //           onPressed: () {
  //             Navigator.pop(context, 'User confirmed exit');
  //             appWindow.hide(); // Hides the window instead of closing
  //           },
  //         ),
  //       ],
  //     ),
  //   );

  //   debugPrint('Dialog result: $result'); // Optional: Check result in debug console
  // }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MinimizeWindowButton(colors: buttonColors),
        MaximizeWindowButton(colors: buttonColors),
        CloseWindowButton(
          colors: closeButtonColors,
          onPressed: () => {appWindow.hide()},
        ),
      ],
    );
  }
}