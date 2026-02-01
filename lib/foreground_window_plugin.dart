// lib/foreground_window_plugin.dart
// Main plugin file that works on both Windows and macOS

import 'dart:io';
import 'package:flutter/services.dart';

// Import your Windows FFI implementation
import 'foreground_window_plugin_windows.dart' as windows;

// Export WindowInfo so it's available to users of the plugin
export 'foreground_window_plugin_windows.dart' show WindowInfo, AppLaunchInfo;

class ForegroundWindowPlugin {
  static const MethodChannel _channel = MethodChannel('foreground_window_plugin');

  /// Get foreground window information
  /// - On Windows: Uses FFI (your existing implementation)
  /// - On macOS: Uses MethodChannel with Swift plugin
  static Future<windows.WindowInfo> getForegroundWindowInfo() async {
    if (Platform.isWindows) {
      // Use your existing Windows FFI implementation directly
      return await windows.ForegroundWindowPlugin.getForegroundWindowInfo();
    } else if (Platform.isMacOS) {
      // Use MethodChannel for macOS
      try {
        final result = await _channel.invokeMethod('getForegroundWindow');
        final data = Map<String, dynamic>.from(result);
        
        // Create WindowInfo from the map
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
      throw UnsupportedError('Platform ${Platform.operatingSystem} is not supported');
    }
  }
}