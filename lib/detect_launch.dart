import 'package:fluent_ui/fluent_ui.dart';

import 'foreground_window_plugin.dart';

class LaunchDetectionController {
  AppLaunchInfo? _launchInfo;
  String _launchStatus = "Checking launch type...";
  bool _isLoading = true;

  AppLaunchInfo? get launchInfo => _launchInfo;
  String get launchStatus => _launchStatus;
  bool get isLoading => _isLoading;

  Future<void> checkLaunchType() async {
    try {
      // Simple approach - just get a boolean
      final wasSystemLaunched = await ForegroundWindowPlugin.wasLaunchedBySystem();
      
      // Detailed approach - get full launch info
      final launchInfo = await ForegroundWindowPlugin.getAppLaunchInfo();
      
      _launchInfo = launchInfo;
      _launchStatus = wasSystemLaunched 
          ? "App was launched by the system automatically"
          : "App was launched by the user manually";
      _isLoading = false;
      
      // Take different actions based on launch type
      if (wasSystemLaunched) {
        // App was launched by system, perhaps minimize to tray or show different UI
        debugPrint("System launched - perhaps show minimal UI");
      } else {
        // App was launched by user, show full UI
        debugPrint("User launched - showing full UI");
      }
      
    } catch (e) {
      _launchStatus = "Error detecting launch type: $e";
      _isLoading = false;
    }
  }
}