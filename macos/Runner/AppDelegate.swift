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
  override func applicationDidFinishLaunching(_ aNotification: Notification) {
    let controller = mainFlutterWindow?.contentViewController as! FlutterViewController
    let registrar = controller.registrar(forPlugin: "ForegroundWindowPlugin")
    
    // Add this line:
    ForegroundWindowPlugin.register(with: registrar)
  }
}