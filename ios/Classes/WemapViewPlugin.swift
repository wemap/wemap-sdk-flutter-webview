//
//  WemapViewPlugin.swift
//  flutter_wemap_sdk
//
//  Created by Bertrand Mathieu-Daudé on 20/02/2023.
//

import Flutter
import UIKit

class MapViewPlugin: NSObject, FlutterPlugin {
 public static func register(with registrar: FlutterPluginRegistrar) {
   let viewFactory = WemapViewFactory(messenger: registrar.messenger())
   registrar.register(viewFactory, withId: "WemapView")
 }
}
