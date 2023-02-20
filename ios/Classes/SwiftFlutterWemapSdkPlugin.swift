import Flutter
import UIKit

public class Livemap: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let factory = WemapViewFactory(messenger: registrar.messenger())
        registrar.register(factory, withId: "WemapView")
    }
}

//public class SwiftFlutterWemapSdkPlugin: NSObject, FlutterPlugin {
//  public static func register(with registrar: FlutterPluginRegistrar) {
//    let channel = FlutterMethodChannel(name: "flutter_wemap_sdk", binaryMessenger: registrar.messenger())
//    let instance = SwiftFlutterWemapSdkPlugin()
//    registrar.addMethodCallDelegate(instance, channel: channel)
//  }
//
//  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
//    result("iOS " + UIDevice.current.systemVersion)
//  }
//}
