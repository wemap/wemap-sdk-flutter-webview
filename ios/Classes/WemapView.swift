//
//  WemapView.swift
//  flutter_wemap_sdk
//
//  Created by Bertrand Mathieu-Daudé on 20/02/2023.
//

import Foundation
import UIKit
import Flutter
import livemap_ios_sdk

class MapView: UIView {
    public var map: livemap_ios_sdk.wemapsdk?
    
    init(map: livemap_ios_sdk.wemapsdk) {
        self.map = map
        super.init(frame: CGRect.zero)
        addSubview(map)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let _map = map {
            _map.frame = frame
            _map.loadMapUrl()
        }
    }
}

public class WemapView: NSObject, FlutterPlatformView, wemapsdkViewDelegate {
    let frame: CGRect
    let viewId: Int64
    let channel: FlutterMethodChannel
    
    private var _view: UIView
    private let wemap = wemapsdk.sharedInstance
    
    init(_ frame: CGRect, viewId: Int64, args: Any?, binaryMessenger messenger: FlutterBinaryMessenger?) {
        self.frame = frame
        self.viewId = viewId
        
        if let ags = args as? [String: Any?] {
            let emmid = ags["emmid"] as? Int
            let token = ags["token"] as? String
            
            if emmid != nil {
                let map = wemap.configure(
                    config: wemapsdk_config(
                        token: token,
                        mapId: emmid
                    )
                )
                _view = MapView(map: map)
            } else {
                _view = UIView()
            }
            
        } else {
            _view = UIView()
        }

        self.channel = FlutterMethodChannel(name: "MapView/\(self.viewId)",
                                           binaryMessenger: messenger!)
        
        super.init()

        wemap.delegate = self
        
        channel.setMethodCallHandler({ (call: FlutterMethodCall, result: FlutterResult) -> Void in
            switch call.method {
            case "receiveFromFlutter":
                guard let args = call.arguments as? [String: Any],
                    let text = args["text"] as? String else {
                        return result(FlutterError(code: "-1", message: "Error", details: nil))
                    }
                self.receiveFromFlutter(text: text)
                
                result("receiveFromFlutter success")
                
            case "openPinpoint":
                guard let args = call.arguments as? [String: Any],
                    let pinpointId = args["pinpoint"] as? Int else {
                        return result(FlutterError(code: "-1", message: "Error", details: nil))
                    }
                self.wemap.openPinpoint(WemapPinpointId: pinpointId)

            case "closePinpoint":
                self.wemap.closePinpoint()

            case "setCenter":
                guard let args = call.arguments as? [String: Any],
                let center = args["center"] as? [String: Any],
                let latitude = center["latitude"] as? Double,
                let longitude = center["longitude"] as? Double else {
                    return result(FlutterError(code: "-1", message: "Error", details: nil))
                }
                self.wemap.setCenter(center: Coordinates(latitude: latitude, longitude: longitude))

            case "centerTo":
                guard let args = call.arguments as? [String: Any],
                let center = args["center"] as? [String: Any],
                let latitude = center["latitude"] as? Double,
                let longitude = center["longitude"] as? Double,
                let zoom = args["zoom"] as? Double else {
                    return result(FlutterError(code: "-1", message: "Error", details: nil))
                }
                self.wemap.centerTo(center: Coordinates(latitude: latitude, longitude: longitude), zoom: zoom)

            default:
                result(FlutterMethodNotImplemented)
            }
        })
    }
    
    public func view() -> UIView {
        return _view;
    }
    
    func sendFromNative(_ text: String) {
        channel.invokeMethod("sendFromNative", arguments: text)
    }
    
    func sendOnMapReady() {
        channel.invokeMethod("onMapReady", arguments: nil)
    }
    
    func sendOnPinpointOpen(_ pinpoint: WemapPinpoint) {
        channel.invokeMethod("onPinpointOpen", arguments: pinpoint.toJSONObject())
    }
    
    func sendOnPinpointClose() {
        channel.invokeMethod("onPinpointClose", arguments: nil)
    }
    
    func sendOnContentUpdated(_ pinpoints: [WemapPinpoint]) {
        channel.invokeMethod("onContentUpdated", arguments: pinpoints.map {$0.toJSONObject()})
    }
    
    func receiveFromFlutter(text: String) {}
    
    // subscribe to wemap-sdk events
    @objc public func waitForReady(_ wemapController: wemapsdk) {
        print("Livemap is Ready")
        sendOnMapReady()
    }
    
    @objc public func onPinpointOpen(_ wemapController: wemapsdk, pinpoint: WemapPinpoint) {
        print("Pinpoint opened: \(pinpoint.id)")
        sendOnPinpointOpen(pinpoint)
    }
    
    @objc public func onPinpointClose(_ wemapController: wemapsdk) {
        print("Pinpoint closed")
        sendOnPinpointClose()
    }
    
    @objc public func onContentUpdated(_ wemapController: wemapsdk, pinpoints: [WemapPinpoint], contentUpdatedQuery: ContentUpdatedQuery) {
          print("Content Updated (WemapPinpoint):")
          sendOnContentUpdated(pinpoints)
       }
}
