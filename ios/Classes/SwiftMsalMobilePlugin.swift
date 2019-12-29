import Flutter
import UIKit
import MSAL

public class SwiftMsalMobilePlugin: NSObject, FlutterPlugin {    
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "com.gbwisx.msal_mobile", binaryMessenger: registrar.messenger())
    let instance = SwiftMsalMobilePlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let viewController: UIViewController = (UIApplication.shared.delegate?.window??.rootViewController)!
    AuthMethodHandler.getInstance(viewController: viewController)?.onMethodCall(call: call, result: result)
  }
}
