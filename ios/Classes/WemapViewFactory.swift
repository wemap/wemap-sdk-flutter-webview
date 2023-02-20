//
//  WemapViewFactory.swift
//  flutter_wemap_sdk
//
//  Created by Bertrand Mathieu-Daudé on 20/02/2023.
//

import Foundation
import Flutter

public class WemapViewFactory: NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger

    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }

    public func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?)-> FlutterPlatformView {
            return WemapView(frame, viewId: viewId, args: args, binaryMessenger: messenger)
        }

    public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}
