import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'flutter_wemap_sdk_platform_interface.dart';
import 'livemap_controller.dart';

class FlutterWemapSdk {
  Future<String?> getPlatformVersion() {
    return FlutterWemapSdkPlatform.instance.getPlatformVersion();
  }
}

class Livemap extends StatefulWidget {
  final Map<String, dynamic> options;
  final Function(LivemapController)? onMapCreated;
  final OnMapReadyCallback? onMapReady;
  final OnPinpointOpenCallback? onPinpointOpen;
  final OnPinpointCloseCallback? onPinpointClose;
  final OnIndoorFeatureClickCallback? onIndoorFeatureClick;
  // final OnFloorChangedCallback? onFloorChanged;
  final OnIndoorLevelChangedCallback? onIndoorLevelChanged;
  final OnIndoorLevelsChangedCallback? onIndoorLevelsChanged;
  final OnMapClickCallback? onMapClick;
  // final OnContentUpdatedCallback? onContentUpdated;
  final OnPinpointUpdatedCallback? onPinpointUpdated;
  final OnEventUpdatedCallback? onEventUpdated;

  final OnUserLoginCallback? onUserLogin;

  const Livemap(
      {super.key,
      required this.options,
      this.onMapCreated,
      this.onMapReady,
      this.onPinpointOpen,
      this.onPinpointClose,
      this.onIndoorFeatureClick,
      // this.onFloorChanged,
      this.onIndoorLevelChanged,
      this.onIndoorLevelsChanged,
      this.onMapClick,
      // this.onContentUpdated,
      this.onPinpointUpdated,
      this.onEventUpdated,
      this.onUserLogin});

  @override
  LivemapState createState() => LivemapState();
}

class LivemapState extends State<Livemap> {
  late LivemapController _mapController;

  void _onPlatformViewCreated(int id) {
    setState(() {
      _mapController = LivemapController(
        id,
        onMapReady: widget.onMapReady,
        onPinpointOpen: widget.onPinpointOpen,
        onPinpointClose: widget.onPinpointClose,
        onIndoorFeatureClick: widget.onIndoorFeatureClick,
        // onFloorChanged: widget.onFloorChanged,
        onIndoorLevelChanged: widget.onIndoorLevelChanged,
        onIndoorLevelsChanged: widget.onIndoorLevelsChanged,
        onMapClick: widget.onMapClick,
        // onContentUpdated: widget.onContentUpdated,
        onPinpointUpdated: widget.onPinpointUpdated,
        onEventUpdated: widget.onEventUpdated,

        onUserLogin: widget.onUserLogin,
      );
    });

    // share livemapController
    if (widget.onMapCreated == null) {
      return;
    }
    widget.onMapCreated!(_mapController);
  }

  @override
  Widget build(BuildContext context) {
    const String viewType = 'WemapView';

    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidView(
        viewType: viewType,
        layoutDirection: TextDirection.ltr,
        creationParams: widget.options,
        onPlatformViewCreated: _onPlatformViewCreated,
        creationParamsCodec: const StandardMessageCodec(),
      );
    }

    return UiKitView(
      viewType: viewType,
      creationParams: widget.options,
      onPlatformViewCreated: _onPlatformViewCreated,
      creationParamsCodec: const StandardMessageCodec(),
    );
  }
}
