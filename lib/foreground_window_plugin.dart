// lib/foreground_window_plugin.dart

import 'dart:io';
import 'package:flutter/services.dart';

import 'foreground_window_plugin_windows.dart' as windows;

export 'foreground_window_plugin_windows.dart' show WindowInfo, AppLaunchInfo;

class ForegroundWindowPlugin {
  static const MethodChannel _channel =
      MethodChannel('foreground_window_plugin');

  static Future<windows.WindowInfo> getForegroundWindowInfo() async {
    if (Platform.isWindows) {
      return await windows.ForegroundWindowPlugin.getForegroundWindowInfo();
    } else if (Platform.isMacOS || Platform.isLinux) {
      try {
        final result = await _channel.invokeMethod('getForegroundWindow');
        final data = Map<String, dynamic>.from(result);

        return windows.WindowInfo(
          windowTitle: data['windowTitle'] as String? ?? 'Unknown',
          processName: data['processName'] as String? ?? 'Unknown',
          executableName: data['executableName'] as String? ?? 'Unknown',
          programName: data['programName'] as String? ?? 'Unknown',
          processId: data['processId'] as int? ?? 0,
          parentProcessId: data['parentProcessId'] as int? ?? 0,
          parentProcessName: data['parentProcessName'] as String? ?? 'Unknown',
        );
      } catch (e) {
        throw Exception('Failed to get foreground window: $e');
      }
    } else {
      throw UnsupportedError(
          'Platform ${Platform.operatingSystem} is not supported');
    }
  }
}
