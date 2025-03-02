import 'package:fluent_ui/fluent_ui.dart';
import './sections/overview.dart';
import './sections/applications.dart';
import './sections/alerts_limits.dart';
import './sections/focus_mode.dart';
import './sections/reports.dart';
import './sections/settings.dart';
import './sections/help.dart';
import './variables/settings_data.dart';
import 'package:adaptive_theme_fluent_ui/adaptive_theme_fluent_ui.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:tray_manager/tray_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SettingsManager().init();
  runApp(const MyApp());
  doWhenWindowReady(() {
    final win = appWindow;
    const initialSize = Size(1280, 800);
    win.minSize = initialSize;
    win.size = initialSize;
    win.alignment = Alignment.center;
    win.title = "Productive ScreenTime";
    win.show();
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with TrayListener {
  bool notificationsEnabled = true;
  final String appVersion = "v1.0.0";

  @override
  void initState() {
    super.initState();
    _initTray();
    trayManager.addListener(this);
  }

  Future<void> _initTray() async {
    await trayManager.setIcon('assets/tray_icon.png'); // Set tray icon
    await trayManager.setToolTip("Productive ScreenTime");
    await _updateTrayMenu();
  }

  Future<void> _updateTrayMenu() async {
    await trayManager.setContextMenu(
      Menu(items: [
        MenuItem(label: 'Show Window', onClick: (_) => appWindow.show()),
        MenuItem(label: 'Start Focus Mode', onClick: (_) => _startFocusMode()),
        MenuItem.separator(),
        MenuItem(label: 'Reports', onClick: (_) => _openReports()),
        MenuItem(label: 'Alerts & Limits', onClick: (_) => _openAlerts()),
        MenuItem(label: 'Applications', onClick: (_) => _openApplications()),
        MenuItem.separator(),
        MenuItem(label: notificationsEnabled ? 'Disable Notifications' : 'Enable Notifications', onClick: (_) => _toggleNotifications()),
        MenuItem(label: 'Version: $appVersion', checked: false),
        MenuItem.separator(),
        MenuItem(label: 'Exit', onClick: (_) => _exitApp()),
      ]),
    );
  }

  void _exitApp() {
    appWindow.hide(); // Minimize to tray instead of exiting
  }

  void _startFocusMode() {
    // Implement focus mode activation
    debugPrint("Focus Mode Started");
  }

  void _openReports() {
    // Implement opening reports section
    debugPrint("Reports Opened");
  }

  void _openAlerts() {
    // Implement opening alerts section
    debugPrint("Alerts Opened");
  }

  void _openApplications() {
    // Implement opening applications section
    debugPrint("Applications Opened");
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
    } else if (menuItem.label == 'Start Focus Mode') {
      _startFocusMode();
    } else if (menuItem.label == 'Reports') {
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
    trayManager.removeListener(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FluentAdaptiveTheme(
      light: FluentThemeData(
          brightness: Brightness.dark,
          cardColor: const Color(0xff202020),
          scaffoldBackgroundColor: const Color.fromARGB(255, 20, 20, 20)),
      dark: FluentThemeData(
          brightness: Brightness.dark,
          cardColor: const Color(0xff202020),
          scaffoldBackgroundColor: const Color.fromARGB(255, 20, 20, 20)),
      initial: AdaptiveThemeMode.dark,
      builder: (theme, darkTheme) => FluentApp(
        title: 'Fluent Adaptive Theme Demo',
        theme: theme,
        darkTheme: darkTheme,
        home: const HomePage(),
      ),
    );
  }
}


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;
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
              selected: selectedIndex,
              onChanged: (index) => setState(() => selectedIndex = index),
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
  const TitleBar({Key? key}) : super(key: key);

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
  const WindowButtons({Key? key}) : super(key: key);
  void showExitDialog(BuildContext context) async {
  final result = await showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (context) => ContentDialog(
        title: const Text('Exit Program?'),
        content: const Text(
          'The window will be hidden. To fully exit the program, use the system menu.',
        ),
        actions: [
          Button(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context, 'User canceled'),
          ),
          FilledButton(
            child: const Text('Exit'),
            onPressed: () {
              Navigator.pop(context, 'User confirmed exit');
              appWindow.hide(); // Hides the window instead of closing
            },
          ),
        ],
      ),
    );

    debugPrint('Dialog result: $result'); // Optional: Check result in debug console
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MinimizeWindowButton(colors: buttonColors),
        MaximizeWindowButton(colors: buttonColors),
        CloseWindowButton(
          colors: closeButtonColors,
          onPressed: () => showExitDialog(context),
        ),
      ],
    );
  }
}