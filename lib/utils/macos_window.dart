import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class MacOSWindow {
  static const _channel = MethodChannel('timemark/macos_window');

  static bool get isMacOS => Platform.isMacOS;

  static Future<bool> hide() async {
    if (!isMacOS) return false;
    try {
      debugPrint('🍎 MacOSWindow.hide() called');
      final result = await _channel.invokeMethod<bool>('hide');
      debugPrint('🍎 MacOSWindow.hide() result: $result');
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('❌ macOS hide PlatformException: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('❌ macOS hide failed: $e');
      return false;
    }
  }

  static Future<bool> show() async {
    if (!isMacOS) return false;
    try {
      debugPrint('🍎 MacOSWindow.show() called');
      final result = await _channel.invokeMethod<bool>('show');
      debugPrint('🍎 MacOSWindow.show() result: $result');
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('❌ macOS show PlatformException: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('❌ macOS show failed: $e');
      return false;
    }
  }

  static Future<bool> minimize() async {
    if (!isMacOS) return false;
    try {
      final result = await _channel.invokeMethod<bool>('minimize');
      return result ?? false;
    } catch (e) {
      debugPrint('❌ macOS minimize failed: $e');
      return false;
    }
  }

  static Future<bool> maximize() async {
    if (!isMacOS) return false;
    try {
      final result = await _channel.invokeMethod<bool>('maximize');
      return result ?? false;
    } catch (e) {
      debugPrint('❌ macOS maximize failed: $e');
      return false;
    }
  }

  static Future<bool> hideTrafficLights() async {
    if (!isMacOS) return false;
    try {
      final result = await _channel.invokeMethod<bool>('hideTrafficLights');
      return result ?? false;
    } catch (e) {
      debugPrint('❌ macOS hideTrafficLights failed: $e');
      return false;
    }
  }

  static Future<bool> exit() async {
    if (!isMacOS) return false;
    try {
      final result = await _channel.invokeMethod<bool>('exit');
      return result ?? false;
    } catch (e) {
      debugPrint('❌ macOS exit failed: $e');
      return false;
    }
  }
}
