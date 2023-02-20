import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_wemap_sdk_method_channel.dart';

abstract class FlutterWemapSdkPlatform extends PlatformInterface {
  /// Constructs a FlutterWemapSdkPlatform.
  FlutterWemapSdkPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterWemapSdkPlatform _instance = MethodChannelFlutterWemapSdk();

  /// The default instance of [FlutterWemapSdkPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterWemapSdk].
  static FlutterWemapSdkPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterWemapSdkPlatform] when
  /// they register themselves.
  static set instance(FlutterWemapSdkPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
