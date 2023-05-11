part of flutter_wemap;

/// The controller gives the ability to control and to interact with the map
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

  final _onMapReadyPlatform = ArgumentCallbacks<void>();
  final _onPinpointOpenPlatform = ArgumentCallbacks<dynamic>();
  final _onPinpointClosePlatform = ArgumentCallbacks<void>();
  final _onContentUpdatedPlatform = ArgumentCallbacks<List<dynamic>>();
  final _onIndoorFeatureClickPlatform = ArgumentCallbacks<dynamic>();

  // final _onFloorChangedPlatform = ArgumentCallbacks<dynamic>();
  final _onIndoorLevelChangedPlatform = ArgumentCallbacks<dynamic>();
  final _onIndoorLevelsChangedPlatform = ArgumentCallbacks<List<dynamic>>();
  final _onMapClickPlatform = ArgumentCallbacks<dynamic>();
  final _onPinpointUpdatedPlatform = ArgumentCallbacks<List<dynamic>>();
  final _onEventUpdatedPlatform = ArgumentCallbacks<List<dynamic>>();
  final _onUserLoginPlatform = ArgumentCallbacks<void>();

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

    _onMapReadyPlatform.add((_) {
      if (onMapReady != null) {
        onMapReady!();
      }
    });

    _onMapClickPlatform.add((dynamic coordinates) {
      if (onMapClick != null) {
        onMapClick!(coordinates);
      }
    });

    _onPinpointOpenPlatform.add((dynamic pinpointId) {
      if (onPinpointOpen != null) {
        onPinpointOpen!(pinpointId);
      }
    });

    _onPinpointClosePlatform.add((_) {
      if (onPinpointClose != null) {
        onPinpointClose!();
      }
    });

    // _onContentUpdatedPlatform.add((Map<String, dynamic> contentUpdated) {
    //   print(contentUpdated);
    //   if (onContentUpdated != null) {
    //     onContentUpdated!(contentUpdated);
    //   }
    // });

    _onPinpointUpdatedPlatform.add((List<dynamic> pinpoints) {
      if (onPinpointUpdated != null) {
        onPinpointUpdated!(pinpoints);
      }
    });

    _onEventUpdatedPlatform.add((List<dynamic> events) {
      if (onEventUpdated != null) {
        onEventUpdated!(events);
      }
    });

    _onUserLoginPlatform.add((_) {
      if (onUserLogin != null) {
        onUserLogin!();
      }
    });

    _onIndoorFeatureClickPlatform.add((dynamic indoorFeature) {
      if (onIndoorFeatureClick != null) {
        onIndoorFeatureClick!(indoorFeature);
      }
    });

    // _onFloorChangedPlatform.add((dynamic data) {
    //   if (onFloorChanged != null) {
    //     onFloorChanged!(data);
    //   }
    // });

    _onIndoorLevelChangedPlatform.add((dynamic data) {
      if (onIndoorLevelChanged != null) {
        onIndoorLevelChanged!(data);
      }
    });

    _onIndoorLevelsChangedPlatform.add((List<dynamic> data) {
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
        _onMapReadyPlatform(null);
        break;
      case 'onMapClick':
        dynamic coordinates = call.arguments as dynamic;
        _onMapClickPlatform(coordinates);
        break;
      case 'onPinpointOpen':
        dynamic pinpoint = call.arguments as dynamic;
        _onPinpointOpenPlatform(pinpoint);
        break;
      case 'onPinpointClose':
        _onPinpointClosePlatform(null);
        break;
      case 'onIndoorFeatureClick':
        dynamic indoorFeature = call.arguments as dynamic;
        _onIndoorFeatureClickPlatform(indoorFeature);
        break;
      case 'onFloorChanged':
        dynamic data = call.arguments as dynamic;
        // _onFloorChangedPlatform(data);
        break;
      case 'onIndoorLevelChanged':
        dynamic data = call.arguments as dynamic;
        _onIndoorLevelChangedPlatform(data);
        break;
      case 'onIndoorLevelsChanged':
        dynamic data = call.arguments as dynamic;
        _onIndoorLevelsChangedPlatform(data);
        break;
      case 'onPinpointUpdated':
        List<dynamic> pinpoints = call.arguments as List<dynamic>;
        _onPinpointUpdatedPlatform(pinpoints);
        break;
      case 'onEventUpdated':
        List<dynamic> pinpoints = call.arguments as List<dynamic>;
        _onEventUpdatedPlatform(pinpoints);
        break;
      case 'onUserLogin':
        _onUserLoginPlatform(null);
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

  /// Open a pinpoint on the map by its Id
  Future<void> openPinpoint(int pinpointId,
      {Map<String, dynamic>? options}) async {
    Map<String, dynamic> args = {"pinpoint": pinpointId};
    if (options != null) {
      args['options'] = options!;
    }
    await _channel.invokeMethod('openPinpoint', args);
  }

  /// Close the current opened pinpoint
  Future<void> closePinpoint() async {
    await _channel.invokeMethod('closePinpoint');
  }

  /// Set the map's geographical center.
  Future<void> setCenter({required Map<String, dynamic> center}) async {
    await _channel.invokeMethod('setCenter', {"center": center});
  }

  /// Set the map's zoom level.
  Future<void> setZoom({required double zoom}) async {
    await _channel.invokeMethod('setZoom', {"zoom": zoom});
  }

  /// Center the map on the given position and set the zoom.
  Future<void> centerTo(
      {required Map<String, dynamic> center, required double zoom}) async {
    await _channel.invokeMethod('centerTo', {"center": center, "zoom": zoom});
  }

  /// Ease the camera to the target location
  Future<void> easeTo({
    required Map<String, dynamic> center,
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
    return _channel.invokeMethod('easeTo', {"easeToOptions": easeToOptions});
  }

  /// Set the indoor feature state
  Future<void> setIndoorFeatureState(
      {required int id, required Map<String, dynamic> state}) async {
    _channel.invokeMethod('setIndoorFeatureState', {'id': id, 'state': state});
  }

  /// Open an event on the map by its Id. This can only be used for maps which use events.
  Future<void> openEvent(int eventId) async {
    await _channel.invokeMethod('openEvent', {"event": eventId});
  }

  /// Close the current opened event. Go to the search view.
  Future<void> closeEvent() async {
    await _channel.invokeMethod('closeEvent');
  }

  /// Open a list on the map by its Id
  Future<void> openList(int listId) async {
    await _channel.invokeMethod('openList', {"list": listId});
  }

  /// Close the current opened list. Go to the search view.
  Future<void> closeList() async {
    await _channel.invokeMethod('closeList');
  }

  /// Close the current opened popin.
  Future<void> closePopin() async {
    await _channel.invokeMethod('closePopin');
  }

  /// Update search filters
  Future<void> setFilters({required Map<String, dynamic> filters}) async {
    await _channel.invokeMethod('setFilters', {"filters": filters});
  }

  /// Start navigation to a pinpoint. The navigation will start with the user location.
  Future<void> navigateToPinpoint(int pinpointId) async {
    await _channel.invokeMethod('navigateToPinpoint', {"pinpoint": pinpointId});
  }

  /// Stop the currently running navigation.
  Future<void> stopNavigation() async {
    await _channel.invokeMethod('stopNavigation');
  }

  /// Sign in to UFE with wemap JWT token.
  Future<void> signInByToken({required String accessToken}) async {
    await _channel.invokeMethod('signInByToken', {"accessToken": accessToken});
  }

  Future<void> enableSidebar() async {
    await _channel.invokeMethod('enableSidebar');
  }

  Future<void> disableSidebar() async {
    await _channel.invokeMethod('disableSidebar');
  }

  /// Sign out the current user.
  Future<void> signOut() async {
    await _channel.invokeMethod('signOut');
  }

  ///
  Future<void> setSourceLists({required List<int> sourceLists}) async {
    await _channel.invokeMethod('setSourceLists', {"sourceLists": sourceLists});
  }

  /// Populates the map with given pinpoints.
  Future<void> setPinpoints(
      {required List<Map<String, dynamic>> pinpoints}) async {
    await _channel.invokeMethod('setPinpoints', {"pinpoints": pinpoints});
  }

  /// Populates the map with given events.
  Future<void> setEvents({required List<Map<String, dynamic>> events}) async {
    await _channel.invokeMethod('setEvents', {"events": events});
  }

  /// Center the map on the user's location.
  Future<void> aroundMe() async {
    await _channel.invokeMethod('aroundMe');
  }

  /// Enable analytics tracking
  Future<void> enableAnalytics() async {
    await _channel.invokeMethod('enableAnalytics');
  }

  /// Disable analytics tracking
  Future<void> disableAnalytics() async {
    await _channel.invokeMethod('disableAnalytics');
  }

  /// Draw a polyline.
  Future<void> drawPolyline({
      required List<Map<String, dynamic>> coordinates,
      Map<String, dynamic>? polylineOptions, DrawPolylineCallback? drawPolylineCallback}) async {
  try{
    final String polylineID = await _channel.invokeMethod('drawPolyline', {"coordinates": coordinates, "polylineOptions": polylineOptions});
    drawPolylineCallback!(polylineID);
    print("Result from native: $polylineID");
  } on PlatformException catch (e) {
    print("Error from native: $e.message");
  }
  }

  /// Remove a polyline by its Id
  Future<void> removePolyline({required String polylineId}) async {
    await _channel.invokeMethod('removePolyline', {"polylineId": polylineId});
  }

  /// Add marker to the map.
  Future<void> addMarker({required Map<String, dynamic> marker}) async {
    await _channel.invokeMethod('addMarker', {"marker": marker});
  }

  /// Remove a previously drawn marker
  Future<void> removeMarker({required String markerId}) async {
    await _channel.invokeMethod('removeMarker', {"markerId": markerId});
  }

  /// Find the nearest pinpoints from a point.
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

  /// Return the map's zoom level.
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
