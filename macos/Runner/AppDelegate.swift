import Cocoa
import FlutterMacOS
import bitsdojo_window_macos

@main
class AppDelegate: FlutterAppDelegate, NSWindowDelegate {
  
  // ✅ CRITICAL FIX: Change to FALSE
  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return false
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }

  override func applicationDidFinishLaunching(_ aNotification: Notification) {
    setupMethodChannel()
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
      self.setupWindowDelegate()
    }
    guard let controller =
      mainFlutterWindow?.contentViewController as? FlutterViewController
    else {
      return
    }

    // Existing plugin registration
    let registrar = controller.registrar(forPlugin: "ForegroundWindowPlugin")
    ForegroundWindowPlugin.register(with: registrar)

    // Launch detection channel
    let launchChannel = FlutterMethodChannel(
      name: "timemark/launch",
      binaryMessenger: controller.engine.binaryMessenger
    )

    launchChannel.setMethodCallHandler { call, result in
      if call.method == "wasLaunchedAtLogin" {
        result(!NSApp.isActive)
      } else {
        result(FlutterMethodNotImplemented)
      }
    }

    super.applicationDidFinishLaunching(aNotification)
  }
  
  override func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
    if !flag {
      showWindow()
    }
    return true
  }
  
  private func setupWindowDelegate() {
    if let window = NSApplication.shared.windows.first {
      window.delegate = self
      window.isReleasedWhenClosed = false // ✅ Add this for safety
    }
  }
  
  // INTERCEPT native close button/Cmd+W - hide instead of close
  func windowShouldClose(_ sender: NSWindow) -> Bool {
    sender.orderOut(nil)
    return false
  }
  
  private func setupMethodChannel() {
    guard let window = mainFlutterWindow,
          let controller = window.contentViewController as? FlutterViewController else {
      return
    }
    
    let channel = FlutterMethodChannel(
      name: "timemark/macos_window",
      binaryMessenger: controller.engine.binaryMessenger
    )
    
    channel.setMethodCallHandler { [weak self] (call, result) in
      switch call.method {
      case "hide":
        self?.hideWindow()
        result(true)
      case "show":
        self?.showWindow()
        result(true)
      case "minimize":
        self?.minimizeWindow()
        result(true)
      case "maximize":
        self?.maximizeWindow()
        result(true)
      case "hideTrafficLights":
        self?.hideTrafficLights()
        result(true)
      case "exit":
        self?.exitApp()
        result(true)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
  
  private func hideWindow() {
    DispatchQueue.main.async {
      NSApplication.shared.windows.first?.orderOut(nil)
    }
  }
  
  private func showWindow() {
    DispatchQueue.main.async {
      NSApp.unhide(nil)
      if let window = NSApplication.shared.windows.first {
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
      }
    }
  }
  
  private func minimizeWindow() {
    DispatchQueue.main.async {
      NSApplication.shared.windows.first?.miniaturize(nil)
    }
  }
  
  private func maximizeWindow() {
    DispatchQueue.main.async {
      NSApplication.shared.windows.first?.zoom(nil)
    }
  }
  
  private func hideTrafficLights() {
    DispatchQueue.main.async {
      if let window = NSApplication.shared.windows.first {
        window.standardWindowButton(.closeButton)?.isHidden = true
        window.standardWindowButton(.miniaturizeButton)?.isHidden = true
        window.standardWindowButton(.zoomButton)?.isHidden = true
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
      }
    }
  }
  
  private func exitApp() {
    DispatchQueue.main.async {
      NSApplication.shared.terminate(nil)
    }
  }
}