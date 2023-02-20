import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_wemap_sdk/flutter_wemap_sdk_method_channel.dart';

void main() {
  MethodChannelFlutterWemapSdk platform = MethodChannelFlutterWemapSdk();
  const MethodChannel channel = MethodChannel('flutter_wemap_sdk');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
