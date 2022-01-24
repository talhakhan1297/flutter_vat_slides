import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
    @IBOutlet weak var flutterViewController: FlutterViewController!
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController.init()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)
      
      minSize.width = 400.0
      minSize.height = 400.0
      
//      FlutterColorPanelPlugin.register(
//        with: flutterViewController.registrar(forPlugin: "FLEColorPanelPlugin"))
//      FlutterFileChooserPlugin.register(
//        with: flutterViewController.registrar(forPlugin: "FLEFileChooserPlugin"))
//      FlutterMenubarPlugin.register(
//        with: flutterViewController.registrar(forPlugin: "FLEMenubarPlugin"))
      RecentFilesPlugin.register(
        with: flutterViewController.registrar(forPlugin: "RecentFilesPlugin"))

//      let assets = NSURL.fileURL(withPath: "flutter_assets", relativeTo: Bundle.main.resourceURL)
      // Pass through argument zero, since the Flutter engine expects to be processing a full
      // command line string.
      var arguments = [CommandLine.arguments[0]];

      #if !DEBUG
          arguments.append("--dart-non-checked-mode");
      #endif
//          flutterViewController.launchEngine(
//            withAssetsPath: assets,
//            commandLineArguments: arguments)

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}

class RecentFilesPlugin : NSObject, FlutterPlugin {
  private let channel: FlutterMethodChannel
  static func register(with registrar: FlutterPluginRegistrar) {
  
    let channel = FlutterMethodChannel(name: "FlutterSlides:CustomPlugin",
                                       binaryMessenger: registrar.messenger,
                                       codec: FlutterJSONMethodCodec.sharedInstance())
    let instance = RecentFilesPlugin(channel: channel)
    registrar.addMethodCallDelegate(instance, channel: channel)
  }
  
  init(channel: FlutterMethodChannel) {
    self.channel = channel
  }
  
  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if (call.method == "get") {
      let recentFilePath = UserDefaults.standard.string(forKey: "recent")
      result(recentFilePath)
    } else if (call.method == "set") {
      if let recentPath = call.arguments as? String {
        UserDefaults.standard.set(recentPath, forKey: "recent")
      }
      result(nil)
    } else {
      result(FlutterMethodNotImplemented)
    }
  }
}
