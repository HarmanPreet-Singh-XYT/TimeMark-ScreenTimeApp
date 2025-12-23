import 'dart:io';
import 'package:bitsdojo_window/bitsdojo_window.dart';

class SingleInstanceIPC {
  static const int _port = 45999;

  /// Call ONLY in the primary instance
  static Future<void> startServer() async {
    try {
      final server = await ServerSocket.bind(
        InternetAddress.loopbackIPv4,
        _port,
        shared: false,
      );

      server.listen((client) {
        client.listen((data) {
          final msg = String.fromCharCodes(data).trim();

          if (msg == 'SHOW') {
            appWindow.show();
            appWindow.restore();
          }
        });
      });
    } catch (e) {
      // If bind fails, assume server already exists
    }
  }

  /// Call ONLY in secondary instance
  static Future<void> requestShow() async {
    try {
      final socket = await Socket.connect(
        InternetAddress.loopbackIPv4,
        _port,
        timeout: const Duration(milliseconds: 500),
      );

      socket.write('SHOW');
      await socket.flush();
      await socket.close();
    } catch (_) {
      // Primary not ready yet → ignore
    }
  }
}
