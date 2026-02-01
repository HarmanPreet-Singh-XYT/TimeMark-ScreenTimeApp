import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }
  // override func applicationDidFinishLaunching(_ aNotification: Notification) {
  //   let controller = mainFlutterWindow?.contentViewController as! FlutterViewController
  //   let registrar = controller.registrar(forPlugin: "ForegroundWindowPlugin")
    
  //   // Add this line:
  //   ForegroundWindowPlugin.register(with: registrar)
  // }
  override func applicationDidFinishLaunching(_ aNotification: Notification) {
    guard let controller =
      mainFlutterWindow?.contentViewController as? FlutterViewController
    else {
      return
    }

    // Existing plugin registration
    let registrar = controller.registrar(forPlugin: "ForegroundWindowPlugin")
    ForegroundWindowPlugin.register(with: registrar)

    // ADD: Launch detection channel
    let launchChannel = FlutterMethodChannel(
      name: "timemark/launch",
      binaryMessenger: controller.engine.binaryMessenger
    )

    launchChannel.setMethodCallHandler { call, result in
      if call.method == "wasLaunchedAtLogin" {
        // If app isn't active yet, it was auto-launched
        result(!NSApp.isActive)
      } else {
        result(FlutterMethodNotImplemented)
      }
    }

    super.applicationDidFinishLaunching(aNotification)
  }
  
}