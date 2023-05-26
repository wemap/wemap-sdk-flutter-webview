part of flutter_wemap;


///@nodoc
class FlutterWemapSdk {
  Future<String?> getPlatformVersion() {
    return FlutterWemapSdkPlatform.instance.getPlatformVersion();
  }
}

/// The Livemap widget, to display the map
///
/// launch the map using token and emmid on the options attribute.
/// different events are being listened and provided (as attributes), add your custom callback to the event
class Livemap extends StatefulWidget {
  final Map<String, dynamic> options;
  /// When the LiveMap is created, a livemapController is ready to be used, to interact with the map
  final Function(LivemapController)? onMapCreated;
  /// The callback to be used when the map is ready
  final OnMapReadyCallback? onMapReady;
  /// The callback to be used when a pinpoint is opened
  final OnPinpointOpenCallback? onPinpointOpen;
  /// The callback to be used when a pinpoint is closed
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
  final OnMapMovedCallback? onMapMoved;

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
      this.onUserLogin,
      this.onMapMoved});

  ///@nodoc
  @override
  LivemapState createState() => LivemapState();
}
///@nodoc
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
        onMapMoved: widget.onMapMoved
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
