import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_wemap_sdk_platform_interface.dart';

/// An implementation of [FlutterWemapSdkPlatform] that uses method channels.
class MethodChannelFlutterWemapSdk extends FlutterWemapSdkPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_wemap_sdk');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
