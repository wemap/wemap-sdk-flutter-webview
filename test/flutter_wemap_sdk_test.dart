import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_wemap_sdk/flutter_wemap_sdk.dart';
import 'package:flutter_wemap_sdk/flutter_wemap_sdk_platform_interface.dart';
import 'package:flutter_wemap_sdk/flutter_wemap_sdk_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterWemapSdkPlatform
    with MockPlatformInterfaceMixin
    implements FlutterWemapSdkPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FlutterWemapSdkPlatform initialPlatform = FlutterWemapSdkPlatform.instance;

  test('$MethodChannelFlutterWemapSdk is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterWemapSdk>());
  });

  test('getPlatformVersion', () async {
    FlutterWemapSdk flutterWemapSdkPlugin = FlutterWemapSdk();
    MockFlutterWemapSdkPlatform fakePlatform = MockFlutterWemapSdkPlatform();
    FlutterWemapSdkPlatform.instance = fakePlatform;

    expect(await flutterWemapSdkPlugin.getPlatformVersion(), '42');
  });
}
