part of flutter_wemap;


typedef OnMapReadyCallback = void Function();
typedef OnPinpointOpenCallback = void Function(dynamic pinpoint);
typedef OnPinpointCloseCallback = void Function();
typedef OnContentUpdatedCallback = void Function(List<dynamic> pinpoints);
typedef OnIndoorFeatureClickCallback = void Function(dynamic data);
typedef OnIndoorLevelChangedCallback = void Function(dynamic data);
typedef OnIndoorLevelsChangedCallback = void Function(List<dynamic> data);
typedef OnMapClickCallback = void Function(dynamic coordinates);
typedef OnPinpointUpdatedCallback = void Function(List<dynamic> pinpoints);
typedef OnEventUpdatedCallback = void Function(List<dynamic> events);
typedef OnUserLoginCallback = void Function();
typedef GetZoomCallback = void Function(dynamic zoomLevel);
typedef FindNearestPinpointsCallback = void Function(List<dynamic> pinpoints);
typedef DrawPolylineCallback = void Function(String polylineID);
