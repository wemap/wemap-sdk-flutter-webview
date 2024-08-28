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
        
        channel.setMethodCallHandler({ (call: FlutterMethodCall, result:@escaping FlutterResult) -> Void in
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
            
            case "setPinpoints":
                if let params = call.arguments as? [String: Any],
                   let pinpoints = params["pinpoints"] as? [[String: Any]] {

                    let pnpts: [WemapPinpoint] = pinpoints.map { pinpoint in
                        let point = pinpoint["coordinates"] as! [String: Double]
//                        let coords = Coordinates(latitude: point["latitude"]!, longitude: point["longitude"]!)

                        let tagsList = pinpoint["tags"] as? [String]
                        let json: NSDictionary = [
                            "id": pinpoint["id"] as! Int,
                            "name": pinpoint["name"] as? String ?? "",
                            "latitude":  point["latitude"]!,
                            "longitude":  point["longitude"]!,
                            "description": pinpoint["description"] as? String ?? "",
                            "image_url": pinpoint["image_url"] as? String,
//                            "media_url": pinpoint["media_url"] as? String,
                            "tags": tagsList
                        ]
                        return WemapPinpoint(
                            json
                        )
                    }
                    self.wemap.setPinpoints(WemapPinpoints: pnpts)
                }


                
            case "setZoom":
                guard let args = call.arguments as? [String: Any],
                    let zoom = args["zoom"] as? Double else {
                        return result(FlutterError(code: "-1", message: "Error", details: nil))
                    }
                self.wemap.setZoom(zoom: zoom)
                
            case "closePinpoint":
                self.wemap.closePinpoint()
                
            case "setIndoorFeatureState":
                guard let args = call.arguments as? [String: Any],
                    let pinpointId = args["id"] as? Int,
                      let state = args["state"] as? [String: Any] else {
                        return result(FlutterError(code: "-1", message: "Error", details: nil))
                    }
                let selected = state["selected"] as! Bool
                self.wemap.setIndoorFeatureState(id: pinpointId, state: ["selected": selected])

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
  
            case "easeTo":
                guard let args = call.arguments as? [String: Any],
                      let easeToOptions = args["easeToOptions"] as? [String: Any],
                      let center = easeToOptions["center"] as? [String: Any],
                      let latitude = center["latitude"] as? Double,
                      let longitude = center["longitude"] as? Double

                else {
                    return result(FlutterError(code: "-1", message: "Error", details: nil))
                }
                
                let zoom = easeToOptions["zoom"] as? Double
                let padding = easeToOptions["padding"] as? [String: Double]
                let bearing = easeToOptions["bearing"] as? Double
                let pitch = easeToOptions["pitch"] as? Double
                let duration = easeToOptions["duration"] as? Double
                let animate = easeToOptions["animate"] as? Bool
                 self.wemap.easeTo(center: Coordinates(latitude: latitude, longitude: longitude),
                        zoom: zoom,
                        padding: padding,
                        bearing : bearing,
                        pitch: pitch,
                        duration: duration,
                        animate: animate
                                   )

            case "drawPolyline":
                var coordsList : [Coordinates] = []
                var polylineOpts : PolylineOptions? = nil
                guard let args = call.arguments as? [String: Any],
                      let coordinates = args["coordinates"] as? [NSDictionary]
                      else{
                        return result(FlutterError(code: "-1", message: "Error", details: nil))
                      }
                for coordinate in coordinates {
                       coordsList.append(Coordinates.fromDictionary(coordinate))
                  }
                print("outside")
                if let polylineOptions = args["polylineOptions"] as? NSDictionary{
                    var opacityFloat : Float? = nil
                    var widthFloat : Float? = nil
                    if let opacity = polylineOptions["opacity"] as? Double{
                        opacityFloat = Float(opacity)
                    }
                    if let width = polylineOptions["width"] as? Double{
                        widthFloat = Float(width)
                    }
                    print("inside")

                    let dictionary: NSDictionary = [
                        "color" : polylineOptions["color"] as? String,
                        "width" : widthFloat,
                        "opacity" : opacityFloat,
                        "useNetwork" : polylineOptions["useNetwork"] as? Bool
                    ]
                    
                     polylineOpts = PolylineOptions.fromDictionary(dictionary)
                }
                
                if #available(iOS 14.0, *) {
                    self.wemap.drawPolyline(coordinatesList: coordsList,options: polylineOpts, completion: { id in return result(id); })
                }
            
            case "removePolyline":
                guard let args = call.arguments as? [String: Any],
                      let polylineId = args["polylineId"] as? String
                        else{
                    return result(FlutterError(code: "-1", message: "Error", details: nil))
                  }
                self.wemap.removePolyline(id: polylineId)
                
            case "getZoom":  
                if #available(iOS 14.0, *) {
                    self.wemap.getZoom { zoom in
                        return result(zoom);
                    }
                }
            
            case "fitBounds":
                
                guard let args = call.arguments as? [String: Any],
                      let boundingBoxMap = args["boundingBox"] as? NSDictionary

                else {
                    return result(FlutterError(code: "-1", message: "Error", details: nil))
                }
                
                let boundingBox = BoundingBox.fromDictionary(boundingBoxMap)
                var options = [
                    "padding": ["right": 0.0]
                ]
                if let optionsMap = args["options"] as? [String: Any]{
                    options = [
                    "padding": optionsMap["padding"] as! [String: Double]
                    ]
                }
                    
                self.wemap.fitBounds(bounds: boundingBox, options:  options)
                


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
    
    func sendOnMapClick(_ coordinates: Coordinates) {
        channel.invokeMethod("onMapClick", arguments: coordinates.toJSONObject())
    }
    
    func sendOnPinpointOpen(_ pinpoint: WemapPinpoint) {
        channel.invokeMethod("onPinpointOpen", arguments: pinpoint.toJSONObject())
    }
    
    func sendOnPinpointClose() {
        channel.invokeMethod("onPinpointClose", arguments: nil)
    }
    
    func sendOnContentUpdated(_ pinpoints: [WemapPinpoint]) {
        channel.invokeMethod("onPinpointUpdated", arguments: pinpoints.map {$0.toJSONObject()})
    }
    
    func sendOnIndoorFeatureClick(_ data: [String: Any]) {
        channel.invokeMethod("onIndoorFeatureClick", arguments: data)
    }
    
    func sendOnIndoorLevelChanged(_ data: [String: Any]) {
        channel.invokeMethod("onIndoorLevelChanged", arguments: data)
    }
    
    func sendOnIndoorLevelsChanged(_ data: Array<Any>) {
        channel.invokeMethod("onIndoorLevelsChanged", arguments: data)
    }
    
    func sendOnMapMoved(_ mapMoved: MapMoved) {
        channel.invokeMethod("onMapMoved", arguments: mapMoved.toJSONObject())
    }
    
    func receiveFromFlutter(text: String) {}
    
    // subscribe to wemap-sdk events
    @objc public func waitForReady(_ wemapController: wemapsdk) {
        print("Livemap is Ready")
        sendOnMapReady()
    }
    
    @objc public func onMapClick(_ wemapController: wemapsdk, coordinates: Coordinates) {
        sendOnMapClick(coordinates)
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
          sendOnContentUpdated(pinpoints)
       }
    
    @objc public func onIndoorFeatureClick(_ wemapController: wemapsdk, data: [String: Any]) {
        sendOnIndoorFeatureClick(data)
    }

    @objc public func onIndoorLevelChanged(_ wemapController: wemapsdk, data: [String: Any]) {
        sendOnIndoorLevelChanged(data)
    }

    @objc public func onIndoorLevelsChanged(_ wemapController: wemapsdk, data: Array<Any>) {
        sendOnIndoorLevelsChanged(data)
    }
    
    @objc public func onMapMoved(_ wemapController: wemapsdk, mapMoved: MapMoved) {
        sendOnMapMoved(mapMoved)
    }
}
