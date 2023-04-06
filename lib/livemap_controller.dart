import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/services.dart';
import 'package:maplibre_gl_platform_interface/maplibre_gl_platform_interface.dart';

typedef void OnMapReadyCallback();
typedef OnPinpointOpenCallback = void Function(dynamic pinpoint);
typedef void OnPinpointCloseCallback();
typedef void OnContentUpdatedCallback(List<dynamic> pinpoints);
typedef void OnIndoorFeatureClickCallback(dynamic data);
typedef void OnIndoorLevelChangedCallback(dynamic data);
typedef void OnIndoorLevelsChangedCallback(List<dynamic> data);
typedef void OnMapClickCallback(dynamic coordinates);
// typedef void OnContentUpdatedCallback(List<dynamic> pinpoints);
typedef void OnPinpointUpdatedCallback(List<dynamic> pinpoints);
typedef void OnEventUpdatedCallback(List<dynamic> events);

typedef void OnUserLoginCallback();
typedef GetZoomCallback = void Function(dynamic zoomLevel);
typedef FindNearestPinpointsCallback = void Function(List<dynamic> pinpoints);

class LivemapController {
  late MethodChannel _channel;
  final OnMapReadyCallback? onMapReady;
  final OnPinpointOpenCallback? onPinpointOpen;
  final OnPinpointCloseCallback? onPinpointClose;
  final OnContentUpdatedCallback? onContentUpdated;
  final OnIndoorFeatureClickCallback? onIndoorFeatureClick;
  // final OnFloorChangedCallback? onFloorChanged;
  final OnIndoorLevelChangedCallback? onIndoorLevelChanged;
  final OnIndoorLevelsChangedCallback? onIndoorLevelsChanged;
  final OnMapClickCallback? onMapClick;
  final OnPinpointUpdatedCallback? onPinpointUpdated;
  final OnEventUpdatedCallback? onEventUpdated;

  final OnUserLoginCallback? onUserLogin;

  final onMapReadyPlatform = ArgumentCallbacks<void>();
  final onPinpointOpenPlatform = ArgumentCallbacks<dynamic>();
  final onPinpointClosePlatform = ArgumentCallbacks<void>();
  final onContentUpdatedPlatform = ArgumentCallbacks<List<dynamic>>();
  final onIndoorFeatureClickPlatform = ArgumentCallbacks<dynamic>();
  // final onFloorChangedPlatform = ArgumentCallbacks<dynamic>();
  final onIndoorLevelChangedPlatform = ArgumentCallbacks<dynamic>();
  final onIndoorLevelsChangedPlatform = ArgumentCallbacks<List<dynamic>>();
  final onMapClickPlatform = ArgumentCallbacks<dynamic>();
  final onPinpointUpdatedPlatform = ArgumentCallbacks<List<dynamic>>();
  final onEventUpdatedPlatform = ArgumentCallbacks<List<dynamic>>();

  final onUserLoginPlatform = ArgumentCallbacks<void>();

  LivemapController(int id,
      {this.onMapReady,
      this.onPinpointOpen,
      this.onPinpointClose,
      this.onContentUpdated,
      this.onIndoorFeatureClick,
      //this.onFloorChanged,
      this.onIndoorLevelChanged,
      this.onIndoorLevelsChanged,
      this.onMapClick,
      // this.onContentUpdated,
      this.onPinpointUpdated,
      this.onEventUpdated,
      this.onUserLogin}) {
    _channel = MethodChannel('MapView/$id');
    _channel.setMethodCallHandler(_handleMethod);

    onMapReadyPlatform.add((_) {
      if (onMapReady != null) {
        onMapReady!();
      }
    });

    onMapClickPlatform.add((dynamic coordinates) {
      if (onMapClick != null) {
        onMapClick!(coordinates);
      }
    });

    onPinpointOpenPlatform.add((dynamic pinpointId) {
      if (onPinpointOpen != null) {
        onPinpointOpen!(pinpointId);
      }
    });

    onPinpointClosePlatform.add((_) {
      if (onPinpointClose != null) {
        onPinpointClose!();
      }
    });

    // onContentUpdatedPlatform.add((Map<String, dynamic> contentUpdated) {
    //   print(contentUpdated);
    //   if (onContentUpdated != null) {
    //     onContentUpdated!(contentUpdated);
    //   }
    // });

    onPinpointUpdatedPlatform.add((List<dynamic> pinpoints) {
      if (onPinpointUpdated != null) {
        onPinpointUpdated!(pinpoints);
      }
    });

    onEventUpdatedPlatform.add((List<dynamic> events) {
      if (onEventUpdated != null) {
        onEventUpdated!(events);
      }
    });

    onUserLoginPlatform.add((_) {
      if (onUserLogin != null) {
        onUserLogin!();
      }
    });

    onIndoorFeatureClickPlatform.add((dynamic indoorFeature) {
      if (onIndoorFeatureClick != null) {
        onIndoorFeatureClick!(indoorFeature);
      }
    });

    // onFloorChangedPlatform.add((dynamic data) {
    //   if (onFloorChanged != null) {
    //     onFloorChanged!(data);
    //   }
    // });

    onIndoorLevelChangedPlatform.add((dynamic data) {
      if (onIndoorLevelChanged != null) {
        onIndoorLevelChanged!(data);
      }
    });

    onIndoorLevelsChangedPlatform.add((List<dynamic> data) {
      if (onIndoorLevelsChanged != null) {
        onIndoorLevelsChanged!(data);
      }
    });
  }

  Future<dynamic> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case 'sendFromNative':
        String text = call.arguments as String;
        return Future.value("Text from native: $text");
      case 'onMapReady':
        onMapReadyPlatform(null);
        break;
      case 'onMapClick':
        dynamic coordinates = call.arguments as dynamic;
        onMapClickPlatform(coordinates);
        break;
      case 'onPinpointOpen':
        dynamic pinpoint = call.arguments as dynamic;
        onPinpointOpenPlatform(pinpoint);
        break;
      case 'onPinpointClose':
        onPinpointClosePlatform(null);
        break;
      case 'onIndoorFeatureClick':
        dynamic indoorFeature = call.arguments as dynamic;
        onIndoorFeatureClickPlatform(indoorFeature);
        break;
      case 'onFloorChanged':
        dynamic data = call.arguments as dynamic;
        // onFloorChangedPlatform(data);
        break;
      case 'onIndoorLevelChanged':
        dynamic data = call.arguments as dynamic;
        onIndoorLevelChangedPlatform(data);
        break;
      case 'onIndoorLevelsChanged':
        dynamic data = call.arguments as dynamic;
        onIndoorLevelsChangedPlatform(data);
        break;
      case 'onPinpointUpdated':
        List<dynamic> pinpoints = call.arguments as List<dynamic>;
        onPinpointUpdatedPlatform(pinpoints);
        break;
      case 'onEventUpdated':
        List<dynamic> pinpoints = call.arguments as List<dynamic>;
        onEventUpdatedPlatform(pinpoints);
        break;
      case 'onUserLogin':
        onUserLoginPlatform(null);
        break;
    }
  }

  Future<void> receiveFromFlutter(String text) async {
    try {
      final String result =
          await _channel.invokeMethod('receiveFromFlutter', {"text": text});
      print("Result from native: $result");
    } on PlatformException catch (e) {
      print("Error from native: $e.message");
    }
  }

  Future<void> openPinpoint(int pinpointId,
      {Map<String, dynamic>? options}) async {
    print('Pinpoint: $pinpointId');
    Map<String, dynamic> args = {"pinpoint": pinpointId};
    if (options != null) {
      args['options'] = options!;
    }
    await _channel.invokeMethod('openPinpoint', args);
  }

  Future<void> closePinpoint() async {
    await _channel.invokeMethod('closePinpoint');
  }

  Future<void> setCenter({required Map<String, dynamic> center}) async {
    await _channel.invokeMethod('setCenter', {"center": center});
  }

  Future<void> setZoom({required double zoom}) async {
    await _channel.invokeMethod('setZoom', {"zoom": zoom});
  }

  Future<void> centerTo(
      {required Map<String, dynamic> center, required double zoom}) async {
    await _channel.invokeMethod('centerTo', {"center": center, "zoom": zoom});
  }

  Future<void> easeTo(
      {required Map<String, dynamic> center,
      double? zoom,
      double? bearing,
      double? pitch,
      double? duration,
      bool? animate,
      Map<String, dynamic>? padding,
        }) async {
    Map<String, dynamic> easeToOptions = {"center": center};
    if (zoom != null) {
      easeToOptions['zoom'] = zoom!;
    }
    if (padding != null) {
      easeToOptions['padding'] = padding!;
    }
    if (bearing != null) {
      easeToOptions['bearing'] = bearing!;
    }
    if (pitch != null) {
      easeToOptions['pitch'] = pitch!;
    }
    if (duration != null) {
      easeToOptions['duration'] = duration!;
    }
    if (animate != null) {
      easeToOptions['animate'] = animate!;
    }
    return _channel.invokeMethod('easeTo', {"easeToOptions" : easeToOptions});
  }

  Future<void> setIndoorFeatureState(
      {required int id, required Map<String, dynamic> state}) async {
    _channel.invokeMethod('setIndoorFeatureState', {'id': id, 'state': state});
  }

  Future<void> openEvent(int eventId) async {
    await _channel.invokeMethod('openEvent', {"event": eventId});
  }

  Future<void> closeEvent() async {
    await _channel.invokeMethod('closeEvent');
  }

  Future<void> openList(int listId) async {
    await _channel.invokeMethod('openList', {"list": listId});
  }

  Future<void> closeList() async {
    await _channel.invokeMethod('closeList');
  }

  Future<void> closePopin() async {
    await _channel.invokeMethod('closePopin');
  }

  Future<void> setFilters({required Map<String, dynamic> filters}) async {
    await _channel.invokeMethod('setFilters', {"filters": filters});
  }

  Future<void> navigateToPinpoint(int pinpointId) async {
    await _channel.invokeMethod('navigateToPinpoint', {"pinpoint": pinpointId});
  }

  Future<void> stopNavigation() async {
    await _channel.invokeMethod('stopNavigation');
  }

  Future<void> signInByToken({required String accessToken}) async {
    await _channel.invokeMethod('signInByToken', {"accessToken": accessToken});
  }

  Future<void> enableSidebar() async {
    await _channel.invokeMethod('enableSidebar');
  }

  Future<void> disableSidebar() async {
    await _channel.invokeMethod('disableSidebar');
  }

  Future<void> signOut() async {
    await _channel.invokeMethod('signOut');
  }

  Future<void> setSourceLists({required List<int> sourceLists}) async {
    await _channel.invokeMethod('setSourceLists', {"sourceLists": sourceLists});
  }

  Future<void> setPinpoints(
      {required List<Map<String, dynamic>> pinpoints}) async {
    await _channel.invokeMethod('setPinpoints', {"pinpoints": pinpoints});
  }

  Future<void> setEvents({required List<Map<String, dynamic>> events}) async {
    await _channel.invokeMethod('setEvents', {"events": events});
  }

  Future<void> aroundMe() async {
    await _channel.invokeMethod('aroundMe');
  }

  Future<void> enableAnalytics() async {
    await _channel.invokeMethod('enableAnalytics');
  }

  Future<void> disableAnalytics() async {
    await _channel.invokeMethod('disableAnalytics');
  }

  Future<void> drawPolyline(
      {required List<Map<String, dynamic>> coordinates}) async {
    await _channel.invokeMethod('drawPolyline', {"coordinates": coordinates});
  }

  Future<void> removePolyline({required String polylineId}) async {
    await _channel.invokeMethod('removePolyline', {"polylineId": polylineId});
  }

  Future<void> addmarker({required Map<String, dynamic> marker}) async {
    await _channel.invokeMethod('addmarker', {"marker": marker});
  }

  Future<void> removeMarker({required String markerId}) async {
    await _channel.invokeMethod('removeMarker', {"markerId": markerId});
  }

  Future<void> findNearestPinpoints(
      {required Map<String, dynamic> center,
      required FindNearestPinpointsCallback
          findNearestPinpointsCallback}) async {
    try {
      final List<dynamic> result = await _channel
          .invokeMethod('findNearestPinpoints', {"center": center});
      findNearestPinpointsCallback(result);
      print("Result(findNearestPinpoints) from native: $result");
    } on PlatformException catch (e) {
      print("Error from native: $e.message");
    }
  }

  Future<void> getZoom({required GetZoomCallback getZoomCallback}) async {
    try {
      final double result = await _channel.invokeMethod('getZoom');
      getZoomCallback(result);
      print("Result from native: $result");
    } on PlatformException catch (e) {
      print("Error from native: $e.message");
    }
  }





}
