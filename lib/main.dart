import 'dart:io';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:screentime/l10n/app_localizations.dart';
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
import 'package:flutter_single_instance/flutter_single_instance.dart';
import 'utils/single_instance_ipc.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  final bool wasSystemLaunched = args.contains('--auto-launched');
  final singleInstance = FlutterSingleInstance();

  // SECOND INSTANCE → ask primary to show & exit
  if (!await singleInstance.isFirstInstance()) {
    await SingleInstanceIPC.requestShow();
    exit(0);
  }
  await SingleInstanceIPC.startServer();
  await SettingsManager().init();
  final bool isMinimizeAtLaunch = await SettingsManager().getSetting("launchAsMinimized") ?? false;
  await NotificationController().initialize();
  await windowManager.ensureInitialized();
  // Get saved theme and locale preferences
  final String savedTheme = SettingsManager().getSetting("theme.selected") ?? "System";
  String? savedLocale = SettingsManager().getSetting("language.selected");
  
  // Auto-detect system locale if no saved preference exists
  if (savedLocale == null) {
    savedLocale = _detectSystemLocale();
    if (savedLocale != null) {
      // Save the detected locale
      SettingsManager().updateSetting("language.selected", savedLocale);
      debugPrint('🌍 Auto-detected and saved system locale: $savedLocale');
    } else {
      // Fallback to default
      savedLocale = LanguageOptions.defaultLanguage;
    }
  }
  
  final AdaptiveThemeMode initialTheme;
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
  
  // Initialize tracker with locale (loads localizations internally)
  final tracker = BackgroundAppTracker();
  await tracker.initializeTracking(locale: savedLocale);
  
  runApp(MyApp(
    initialTheme: initialTheme,
    savedLocale: savedLocale,
  ));
  
  doWhenWindowReady(() async {
      final win = appWindow;

      const initialSize = Size(1280, 800);
      win.minSize = initialSize;
      win.size = initialSize;
      win.alignment = Alignment.center;
      win.title = 'TimeMark - Track Screen Time & App Usage';

      if(wasSystemLaunched || isMinimizeAtLaunch){
        win.hide();
      }else{
        win.show();
      }
    });

}

// Global navigator key for accessing context outside widget tree
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Detects the system locale and returns it if supported, otherwise null
String? _detectSystemLocale() {
  try {
    // Get the system locale
    final String systemLocale = Platform.localeName; // e.g., "en_US", "zh_CN", "es_ES"
    
    // Extract language code (before underscore)
    final String languageCode = systemLocale.split('_').first.toLowerCase();
    
    debugPrint('🔍 System locale detected: $systemLocale (language: $languageCode)');
    
    // Check if the language is supported
    final bool isSupported = LanguageOptions.available.any(
      (lang) => lang['code'] == languageCode
    );
    
    if (isSupported) {
      debugPrint('✅ Language $languageCode is supported');
      return languageCode;
    } else {
      debugPrint('⚠️ Language $languageCode is not supported, using default');
      return null;
    }
  } catch (e) {
    debugPrint('❌ Error detecting system locale: $e');
    return null;
  }
}


class MyApp extends StatefulWidget {
  final AdaptiveThemeMode initialTheme;
  final String? savedLocale;
  
  const MyApp({
    super.key, 
    this.initialTheme = AdaptiveThemeMode.system,
    this.savedLocale,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with TrayListener, WidgetsBindingObserver {
  bool notificationsEnabled = true;
  final String appVersion = "v${SettingsManager().versionInfo["version"]}";
  bool focusMode = false;
  int selectedIndex = 0;
  final AppDataStore _dataStore = AppDataStore();
  Locale? _locale;
  
  void changeIndex(int value){
    setState(() {
      selectedIndex = value;
    });
  }

  void setLocale(Locale locale) async {
    setState(() {
      _locale = locale;
    });
    
    // Update settings
    SettingsManager().updateSetting("language.selected", locale.languageCode);
    
    // Update background tracker with new locale (reloads localizations)
    await BackgroundAppTracker().updateLocale(locale.languageCode);
    
    // Wait for the widget tree to rebuild with new locale before updating tray
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateTrayMenu();
    });
    
    debugPrint('🌍 Locale changed to: ${locale.languageCode}');
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initDataStore();
    _initTray();
    trayManager.addListener(this);
    
    // Initialize locale from saved preference
    if (widget.savedLocale != null) {
      _locale = Locale(widget.savedLocale!);
    }
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
    // Get the current context to access localizations
    final context = navigatorKey.currentContext;
    if (context == null) return;
    
    final l10n = AppLocalizations.of(context)!;
    
    await trayManager.setContextMenu(
      Menu(items: [
        MenuItem(label: l10n.trayShowWindow, onClick: (_) => _showApp()),
        MenuItem.separator(),
        MenuItem(label: l10n.navReports, onClick: (_) => _openReports()),
        MenuItem(label: l10n.navAlertsLimits, onClick: (_) => _openAlerts()),
        MenuItem(label: l10n.navApplications, onClick: (_) => _openApplications()),
        MenuItem.separator(),
        MenuItem(disabled:true, label: l10n.trayVersion(appVersion), checked: false),
        MenuItem.separator(),
        MenuItem(label: l10n.trayExit, onClick: (_) => _exitApp()),
      ]),
    );
  }

  void _showApp(){
    appWindow.show();
  }

  void _exitApp() {
    appWindow.close();
  }

  void _openReports() {
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
    final context = navigatorKey.currentContext;
    if (context == null) return;
    
    final l10n = AppLocalizations.of(context)!;
    
    if (menuItem.label == l10n.trayShowWindow) {
      appWindow.show();
    } else if (menuItem.label == l10n.trayExit) {
      _exitApp();
    } else if (menuItem.label == l10n.navReports) {
      _openReports();
    } else if (menuItem.label == l10n.navAlertsLimits) {
      _openAlerts();
    } else if (menuItem.label == l10n.navApplications) {
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
      initial: widget.initialTheme,
      builder: (theme, darkTheme) => FluentApp(
        title: 'Productive ScreenTime',
        theme: theme,
        darkTheme: darkTheme,
        navigatorKey: navigatorKey, // Add global navigator key
        // Localization configuration
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: _locale,
        home: HomePage(
          selectedIndex: selectedIndex, 
          changeIndex: changeIndex,
          setLocale: setLocale,
        ),
      ),
    );
  }
}


class HomePage extends StatefulWidget {
  final int selectedIndex;
  final Function(int) changeIndex;
  final Function(Locale) setLocale;
  
  const HomePage({
    super.key,
    required this.selectedIndex,
    required this.changeIndex,
    required this.setLocale,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  PaneDisplayMode displayMode = PaneDisplayMode.compact;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    List<NavigationPaneItem> items = [
      PaneItem(
        icon: const Icon(FluentIcons.home, size: 20),
        title: Text(l10n.navOverview, style: const TextStyle(fontWeight: FontWeight.w500)),
        body: const Overview(),
      ),
      PaneItem(
        icon: const Icon(FluentIcons.app_icon_default_list, size: 20),
        title: Text(l10n.navApplications, style: const TextStyle(fontWeight: FontWeight.w500)),
        body: const Applications(),
      ),
      PaneItem(
        icon: const Icon(FluentIcons.alert_settings, size: 20),
        title: Text(l10n.navAlertsLimits, style: const TextStyle(fontWeight: FontWeight.w500)),
        body: const AlertsLimits(),
      ),
      PaneItem(
        icon: const Icon(FluentIcons.analytics_report, size: 20),
        title: Text(l10n.navReports, style: const TextStyle(fontWeight: FontWeight.w500)),
        body: const Reports(),
      ),
      PaneItem(
        icon: const Icon(FluentIcons.red_eye, size: 20),
        title: Text(l10n.navFocusMode, style: const TextStyle(fontWeight: FontWeight.w500)),
        body: const FocusMode(),
      ),
      PaneItem(
        icon: const Icon(FluentIcons.settings, size: 20),
        title: Text(l10n.navSettings, style: const TextStyle(fontWeight: FontWeight.w500)),
        body: Settings(setLocale: widget.setLocale),
      ),
      PaneItem(
        icon: const Icon(FluentIcons.chat_bot, size: 20),
        title: Text(l10n.navHelp, style: const TextStyle(fontWeight: FontWeight.w500)),
        body: const Help(),
      ),
    ];

    return Column(
      children: [
        const TitleBar(),
        Expanded(
          child: WindowBorder(
            color: FluentTheme.of(context).micaBackgroundColor,
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
    final l10n = AppLocalizations.of(context)!;
    
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.sidebarTitle,
            style: FluentTheme.of(context).typography.title,
          ),
          Text(
            l10n.sidebarSubtitle,
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
    final l10n = AppLocalizations.of(context)!;
    final Color backgroundColor = FluentTheme.of(context).micaBackgroundColor;
    final Color textColor = isDarkMode ? Colors.white : const Color.fromARGB(255, 20, 20, 20);

    return WindowTitleBarBox(
      child: Container(
        color: backgroundColor,
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
                        l10n.appTitle,
                        style: FluentTheme.of(context).typography.body?.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: textColor,
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