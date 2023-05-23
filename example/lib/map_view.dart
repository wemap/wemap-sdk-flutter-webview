import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_wemap_sdk/flutter_wemap.dart';
import 'package:flutter_wemap_sdk_example/second_widget.dart';

class MapView extends StatelessWidget {
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;
  MapView({super.key, required this.scaffoldMessengerKey});

  late LivemapController _mapController;
  void onNativeMapReady() {
    const snackBar = SnackBar(content: Text('Map is Ready'));
    scaffoldMessengerKey.currentState?.showSnackBar(snackBar);

    //_mapController.centerTo(center: {"latitude" : 43.123, "longitude" : 17.1245}, zoom: 10);
    /*
    _mapController.easeTo(center: {"latitude" : 43.123, "longitude" : 17.1245}, zoom: 15, padding: {
      "bottom" : 2.1, "top" : 2.1, "left" : 2.1, "right" : 2.1
    },bearing: 12.2);

    String polylineID = "";
    _mapController.drawPolyline(coordinates: [{"latitude" : 43.123, "longitude" : 17.1245},
      {"latitude" : 43.123, "longitude" : 18.1245}],
        polylineOptions: {"color" : "#FF0000", "opacity" : 10.2,"width" : 5.4 , "useNetwork" : false},
        drawPolylineCallback: (id){
      polylineID = id;
    });

    void remove() {
      _mapController.removePolyline(polylineId: polylineID);
    }
    Timer(const Duration(seconds: 10),
        remove
    );
*/

  }

  void onMapClick(dynamic coordinates) {
    const snackBar = SnackBar(content: Text('Map is clicked'));
    scaffoldMessengerKey.currentState?.showSnackBar(snackBar);
    // _mapController.easeTo(center: {"latitude" : 43.123, "longitude" : 17.1245}, zoom: 15.0, duration: 2000,
    // padding: {
    //   "right" : 1.2,
    //   "top" : 2.1,
    //   "left" : 1.2,
    //   "bottom" : 1.3
    // }
    // );
    // _mapController.findNearestPinpoints(center: {"latitude": coordinates["latitude"], "longitude": coordinates["longitude"]} ,
    // findNearestPinpointsCallback: (pinpoints){
    //   print("pin --> ${pinpoints.toString()}");
    // });

  }

  void onIndoorFeatureClick(dynamic indoorFeature) {
    const snackBar = SnackBar(content: Text('indoor feature is clicked'));
    scaffoldMessengerKey.currentState?.showSnackBar(snackBar);
  }

  void onIndoorLevelChanged(dynamic level) {
    const snackBar = SnackBar(content: Text('indoor level is changed'));
    scaffoldMessengerKey.currentState?.showSnackBar(snackBar);
  }

  void onIndoorLevelsChanged(List<dynamic> levels) {
    const snackBar = SnackBar(content: Text('indoor levels are changed'));
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
    _mapController = mapController;
    const snackBar = SnackBar(content: Text('Livemap created'));
    scaffoldMessengerKey.currentState?.showSnackBar(snackBar);
    // whatever with mapController
  }

  void onUserLogin() {
    const snackBar = SnackBar(content: Text('User Logged in'));

    scaffoldMessengerKey.currentState?.clearSnackBars();
    scaffoldMessengerKey.currentState?.showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    const Map<String, dynamic> creationParams = <String, dynamic>{
      "token": "at57ea248c510508.01219386", //"GUHTU6TYAWWQHUSR5Z5JZNMXX",
      "emmid": 22764 //22418
    };

    return Livemap(
      options: creationParams,
      onMapCreated: _onMapCreated,
      onMapReady: onNativeMapReady,
      onMapClick: (coords){
        const snackBar = SnackBar(content: Text('Map is clicked'));
        scaffoldMessengerKey.currentState?.showSnackBar(snackBar);
        // _mapController.easeTo(center: {"latitude" : 43.123, "longitude" : 17.1245}, zoom: 15.0, duration: 2000,
        // padding: {
        //   "right" : 1.2,
        //   "top" : 2.1,
        //   "left" : 1.2,
        //   "bottom" : 1.3
        // }
        // );
        // _mapController.findNearestPinpoints(center: {"latitude": coordinates["latitude"], "longitude": coordinates["longitude"]} ,
        // findNearestPinpointsCallback: (pinpoints){
        //   print("pin --> ${pinpoints.toString()}");
        // });
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SecondWidget()),
        );
      },
      onPinpointOpen: onPinpointOpen,
      onPinpointClose: onPinpointClose,
      onPinpointUpdated: onPinpointUpdated,
      onEventUpdated: onEventUpdated,
      onUserLogin: onUserLogin,
      onIndoorFeatureClick: onIndoorFeatureClick,
      onIndoorLevelChanged: onIndoorLevelChanged,
      onIndoorLevelsChanged: onIndoorLevelsChanged,
    );
  }
}

