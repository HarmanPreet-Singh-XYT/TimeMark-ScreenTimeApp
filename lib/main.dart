import 'package:fluent_ui/fluent_ui.dart';
import './sections/overview.dart';
import './sections/applications.dart';
import './sections/alerts_limits.dart';
import './sections/focus_mode.dart';
import './sections/reports.dart';
import './sections/settings.dart';
import './sections/help.dart';
import 'package:adaptive_theme_fluent_ui/adaptive_theme_fluent_ui.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
void main() {
  runApp(const MyApp());
}



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FluentAdaptiveTheme(
      light: FluentThemeData(
        brightness: Brightness.dark,
        cardColor:const Color(
          0xff202020
        ),
        scaffoldBackgroundColor: const Color.fromARGB(255, 20, 20, 20)
      ),
      dark: FluentThemeData(
        brightness: Brightness.dark,
        cardColor:const Color(
          0xff202020
        ),
      ),
      initial: AdaptiveThemeMode.light,
      builder: (theme, darkTheme) => FluentApp(
        title: 'Fluent Adaptive Theme Demo',
        theme: theme,
        darkTheme: darkTheme,
        home:const HomePage(),
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

  // Define items outside build function
  List<NavigationPaneItem> items = [
    PaneItem(
      icon: const Icon(FluentIcons.home,size: 20),
      title: const Text('Overview',style: TextStyle(fontWeight: FontWeight.w500),),
      body: const _NavigationBodyItem(title: 'overview'),
    ),
    
    PaneItem(
      icon: const Icon(FluentIcons.app_icon_default_list,size: 20),
      title: const Text('Applications',style: TextStyle(fontWeight: FontWeight.w500),),
      body: const _NavigationBodyItem(title: 'applications'),
    ),
    PaneItem(
      icon: const Icon(FluentIcons.alert_settings,size: 20),
      title: const Text('Alerts & Limits',style: TextStyle(fontWeight: FontWeight.w500),),
      body: const _NavigationBodyItem(title: 'alertsLimits'),
    ),
    PaneItem(
      icon: const Icon(FluentIcons.analytics_report,size: 20),
      title: const Text('Reports',style: TextStyle(fontWeight: FontWeight.w500),),
      body: const _NavigationBodyItem(title: 'reports'),
    ),
    PaneItem(
      icon: const Icon(FluentIcons.red_eye,size: 20),
      title: const Text('Focus Mode',style: TextStyle(fontWeight: FontWeight.w500),),
      body: const _NavigationBodyItem(title: 'focusMode'),
    ),
    PaneItem(
      icon: const Icon(FluentIcons.settings,size: 20),
      title: const Text('Settings',style: TextStyle(fontWeight: FontWeight.w500),),
      body: const _NavigationBodyItem(title: 'settings'),
    ),
    PaneItem(
      icon: const Icon(FluentIcons.chat_bot,size: 20),
      title: const Text('Help',style: TextStyle(fontWeight: FontWeight.w500),),
      body: const _NavigationBodyItem(title: 'help'),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      pane: NavigationPane(
        selected: selectedIndex,
        onChanged: (index) => setState(() => selectedIndex = index),
        displayMode: displayMode,
        items: items,
        header: _buildSidebarHeader(context)
      ),
      
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
            style: FluentTheme.of(context).typography.title
          ),
          Text(
            'Open Source',
            style: FluentTheme.of(context).typography.caption?.copyWith(
                  fontSize: 14,
                  color:const Color(0xff555555),
                ),
          ),
          const SizedBox(height: 12), // Adds spacing before buttons
        ],
      ),
    );
  }
}
  // Sidebar header with spacing


class _NavigationBodyItem extends StatelessWidget {
  final String title;
  const _NavigationBodyItem({required this.title});

  @override
  Widget build(BuildContext context) {
    switch (title) {
      case 'overview':
        return const Overview();
      case 'applications':
        return const Applications();
      case 'alertsLimits':
        return const AlertsLimits();
      case 'reports':
        return const Reports();
      case 'focusMode':
        return const FocusMode();
      case 'settings':
        return const Settings();
      case 'help':
        return const Help();
      default:
        return const Center(child: Text("Section does not exist"));
    }
  }
}
