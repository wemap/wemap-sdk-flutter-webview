import 'package:flutter/services.dart';
import 'package:maplibre_gl_platform_interface/maplibre_gl_platform_interface.dart';

typedef void OnMapReadyCallback();
typedef void OnPinpointOpenCallback(dynamic pinpoint);
typedef void OnPinpointCloseCallback();
typedef void OnContentUpdatedCallback(List<dynamic> pinpoints);

class LivemapController {
  late MethodChannel _channel;
  final OnMapReadyCallback? onMapReady;
  final OnPinpointOpenCallback? onPinpointOpen;
  final OnPinpointCloseCallback? onPinpointClose;
  final OnContentUpdatedCallback? onContentUpdated;

  final onMapReadyPlatform = ArgumentCallbacks<void>();
  final onPinpointOpenPlatform = ArgumentCallbacks<dynamic>();
  final onPinpointClosePlatform = ArgumentCallbacks<void>();
  final onContentUpdatedPlatform = ArgumentCallbacks<List<dynamic>>();

  LivemapController(int id,
      {this.onMapReady,
      this.onPinpointOpen,
      this.onPinpointClose,
      this.onContentUpdated}) {
    _channel = MethodChannel('MapView/$id');
    _channel.setMethodCallHandler(_handleMethod);

    onMapReadyPlatform.add((_) {
      if (onMapReady != null) {
        onMapReady!();
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

    onContentUpdatedPlatform.add((List<dynamic> pinpoints) {
      if (onContentUpdated != null) {
        onContentUpdated!(pinpoints);
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
      case 'onPinpointOpen':
        dynamic pinpoint = call.arguments as dynamic;
        onPinpointOpenPlatform(pinpoint);
        break;
      case 'onPinpointClose':
        onPinpointClosePlatform(null);
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

  Future<void> setCenter() async {
    await _channel.invokeMethod('setCenter');
  }
}
