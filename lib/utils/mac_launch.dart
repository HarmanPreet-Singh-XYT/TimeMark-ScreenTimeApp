import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class MacOSLaunchService {
  static const _channel = MethodChannel('timemark/launch');

  /// Check if app was launched as a login item (auto-start at login)
  /// Uses native AppleEvent detection for accurate results
  static Future<bool> wasLaunchedAtLogin() async {
    if (!Platform.isMacOS) return false;

    try {
      final result = await _channel.invokeMethod<bool>('wasLaunchedAtLogin');
      debugPrint('🍎 Native login item detection result: $result');
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('⚠️ PlatformException checking login launch: $e');
      return false;
    } on MissingPluginException {
      debugPrint('⚠️ timemark/launch channel not registered');
      return false;
    } catch (e) {
      debugPrint('⚠️ Unknown error checking login launch: $e');
      return false;
    }
  }
}
