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

  final onMapReadyPlatform = ArgumentCallbacks<void>();
  final onPinpointOpenPlatform = ArgumentCallbacks<dynamic>();
  final onPinpointClosePlatform = ArgumentCallbacks<void>();
  final onContentUpdatedPlatform = ArgumentCallbacks<List<dynamic>>();
  final onIndoorFeatureClickPlatform = ArgumentCallbacks<dynamic>();
  // final onFloorChangedPlatform = ArgumentCallbacks<dynamic>();
  final onIndoorLevelChangedPlatform = ArgumentCallbacks<dynamic>();
  final onIndoorLevelsChangedPlatform = ArgumentCallbacks<List<dynamic>>();
  final onMapClickPlatform = ArgumentCallbacks<dynamic>();

  LivemapController(int id,
      {this.onMapReady,
      this.onPinpointOpen,
      this.onPinpointClose,
      this.onContentUpdated,
      this.onIndoorFeatureClick,
      //this.onFloorChanged,
      this.onIndoorLevelChanged,
      this.onIndoorLevelsChanged,
      this.onMapClick}) {
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

    onContentUpdatedPlatform.add((List<dynamic> pinpoints) {
      if (onContentUpdated != null) {
        onContentUpdated!(pinpoints);
      }
    });

    onIndoorFeatureClickPlatform.add((dynamic data) {
      if (onIndoorFeatureClick != null) {
        onIndoorFeatureClick!(data);
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
        dynamic data = call.arguments as dynamic;
        onIndoorFeatureClickPlatform(data);
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
      case 'onContentUpdated':
        List<dynamic> pinpoints = call.arguments as List<dynamic>;
        onContentUpdatedPlatform(pinpoints);
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
      Map<String, dynamic>? options,
      Map<String, dynamic>? padding}) async {
    Map<String, dynamic> args = {"center": center};
    if (zoom != null) {
      args['zoom'] = zoom!;
    }
    if (padding != null) {
      args['padding'] = padding!;
    }
    return _channel.invokeMethod('easeTo', args);
  }

  Future<void> setIndoorFeatureState(
      {required int id, required Map<String, dynamic> state}) async {
    _channel.invokeMethod('setIndoorFeatureState', {'id': id, 'state': state});
  }

}
