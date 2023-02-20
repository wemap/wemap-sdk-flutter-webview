
import 'flutter_wemap_sdk_platform_interface.dart';

class FlutterWemapSdk {
  Future<String?> getPlatformVersion() {
    return FlutterWemapSdkPlatform.instance.getPlatformVersion();
  }
}
