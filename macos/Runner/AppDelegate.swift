import Cocoa
import FlutterMacOS

@NSApplicationMain
class AppDelegate: FlutterAppDelegate {
    @IBOutlet weak var window: NSWindow!
  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }
}
