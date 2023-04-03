import 'package:flutter/material.dart';
import 'package:flutter_wemap_sdk/flutter_wemap_sdk.dart';
import 'package:flutter_wemap_sdk/livemap_controller.dart';

class MapView extends StatelessWidget {
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;
  MapView({super.key, required this.scaffoldMessengerKey});

  void onNativeMapReady() {
    const snackBar = SnackBar(content: Text('Map is Ready'));
    scaffoldMessengerKey.currentState?.showSnackBar(snackBar);
  }

  void onPinpointOpen(dynamic pinpoint) {
    var snackBar = SnackBar(content: Text('Open Pinpoint: ${pinpoint.name}'));

    scaffoldMessengerKey.currentState?.clearSnackBars();
    scaffoldMessengerKey.currentState?.showSnackBar(snackBar);
  }

  void onPinpointClose() {
    const snackBar = SnackBar(content: Text('Close Pinpoint'));

    scaffoldMessengerKey.currentState?.clearSnackBars();
    scaffoldMessengerKey.currentState?.showSnackBar(snackBar);
  }

  void onPinpointUpdated(List<dynamic> pinpoints) {
    var snackBar =
        SnackBar(content: Text('Updated Pinpoints count: ${pinpoints.length}'));
    scaffoldMessengerKey.currentState?.clearSnackBars();
    scaffoldMessengerKey.currentState?.showSnackBar(snackBar);
  }

  void onEventUpdated(List<dynamic> events) {
    var snackBar =
    SnackBar(content: Text('Updated Events count: ${events.length}'));
    scaffoldMessengerKey.currentState?.clearSnackBars();
    scaffoldMessengerKey.currentState?.showSnackBar(snackBar);
  }

  // bind controller
  void _onMapCreated(LivemapController mapController) {
    const snackBar = SnackBar(content: Text('Livemap created'));
    scaffoldMessengerKey.currentState?.showSnackBar(snackBar);
    // whatever with mapController
  }

  void onUserLogin(){
    const snackBar = SnackBar(content: Text('User Logged in'));

    scaffoldMessengerKey.currentState?.clearSnackBars();
    scaffoldMessengerKey.currentState?.showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    const Map<String, dynamic> creationParams = <String, dynamic>{
      "token": "GUHTU6TYAWWQHUSR5Z5JZNMXX",
      "emmid": 22418
    };

    return Livemap(
      options: creationParams,
      onMapCreated: _onMapCreated,
      onMapReady: onNativeMapReady,
      onPinpointOpen: onPinpointOpen,
      onPinpointClose: onPinpointClose,
      onPinpointUpdated: onPinpointUpdated,
      onEventUpdated: onEventUpdated,
      onUserLogin: onUserLogin,
    );
  }
}
