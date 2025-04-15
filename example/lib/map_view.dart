import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:flutter_wemap_sdk/flutter_wemap.dart';

class MapView extends StatefulWidget {
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;

  const MapView({super.key, required this.scaffoldMessengerKey});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  late LivemapController _mapController;
  List<Map<String, dynamic>> pinpointList = [];
  List<dynamic> searchResults = [];
  bool isSearching = false;
  final FocusNode _searchFocus = FocusNode();
  int? _selectedPOIId;

  @override
  void dispose() {
    _searchFocus.dispose();
    super.dispose();
  }

  Future<void> searchPOIs(String query) async {
    if (query.isEmpty) {
      setState(() {
        searchResults = [];
        isSearching = false;
      });
      return;
    }

    setState(() {
      isSearching = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
            'https://api.getwemap.com/v3.0/pinpoints/search?livemap=29301&query=$query'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          // Assuming the response has a 'results' or similar field containing the array of POIs
          searchResults = data['results'] ??
              []; // Update this key based on the actual response structure
          isSearching = false;
        });

        // Debug print to see the response structure
        print('API Response: $data');
      } else {
        print(
            'Error searching POIs: ${response.statusCode} - ${response.body}');
        setState(() {
          searchResults = [];
          isSearching = false;
        });
      }
    } catch (e) {
      print('Error searching POIs: $e');
      setState(() {
        searchResults = [];
        isSearching = false;
      });
    }
  }

  void selectPOI(dynamic poi) {
    // Unselect previous POI if exists
    if (_selectedPOIId != null) {
      _mapController.setIndoorFeatureState(
          id: _selectedPOIId!, state: {"selected": false});
    }

    Timer(const Duration(milliseconds: 500),
        // Center map to the selected POI
        () {
      _mapController.centerTo(
        center: {"latitude": poi['latitude'], "longitude": poi['longitude']},
        zoom: 20,
      );
    });

    // Set indoor feature state if POI has an ID
    if (poi['id'] != null) {
      Timer(const Duration(milliseconds: 700), () {
        _mapController
            .setIndoorFeatureState(id: poi['id'], state: {"selected": true});
        _selectedPOIId = poi['id']; // Store the newly selected POI ID
      });
    }

    // Clear search results and unfocus keyboard
    setState(() {
      searchResults = [];
      _searchFocus.unfocus();
    });
  }

  void onNativeMapReady() {
    const snackBar = SnackBar(content: Text('Map is Ready'));
    widget.scaffoldMessengerKey.currentState?.showSnackBar(snackBar);
    // _mapController.centerTo(center: {"latitude" : 48.969696026791894,
    //   "longitude" : 2.5168694369494915}, zoom: 15);
    // _mapController.easeTo(center: {"latitude" : 43.123, "longitude" : 17.1245}, zoom: 15, padding: {
    //   "bottom" : 2.1, "top" : 2.1, "left" : 2.1, "right" : 2.1
    // },bearing: 12.2);
    //
    // String polylineID = "";
    // _mapController.drawPolyline(coordinates: [
    //   {"latitude" : 43.123, "longitude" : 17.1245},
    //   {"latitude" : 43.123, "longitude" : 18.1245}
    // ],
    //     polylineOptions: {"color" : "#FF0000", "opacity" : 10.2,"width" : 5.4 , "useNetwork" : false},
    //     drawPolylineCallback: (id){
    //   polylineID = id;
    // });
    //
    // void remove() {
    //   _mapController.removePolyline(polylineId: polylineID);
    // }
    // Timer(const Duration(seconds: 10),
    //     remove
    // );

    // const Map<String, dynamic> bounding = {
    //   "northEast": {
    //     "latitude": 12.2,
    //     "longitude": 12.2
    //   },
    //   "southWest": {
    //     "latitude": 12.2,
    //     "longitude": 12.2
    //   }
    // };
    // const Map<String, dynamic> options = {
    //     "padding": {
    //       "right" : 1.2,
    //       "top" : 2.1,
    //       "left" : 1.2,
    //       "bottom" : 1.3
    //     },
    //   "animate": true
    //   };
    // const Map<String, dynamic> bounding = {
    //   "southWest": {
    //     "latitude": 48.968855503285106,
    //     "longitude": 2.5184824268717643
    //   },
    //   "northEast": {
    //     "latitude": 48.970208377530255,
    //     "longitude": 2.518835336138232
    //   }
    // };
    // const Map<String, dynamic> options = {
    //   "padding": {
    //     "right" : 10.0,
    //     "top" : 10.0,
    //     "left" : 10.0,
    //     "bottom" : 10.0
    //   },
    //   "animate": true
    // };
    // Timer(const Duration(seconds: 10),
    //         _mapController.fitBounds(boundingBox: bounding, options: options) as void Function()
    //     );

    // Timer(const Duration(seconds: 10),
    //     // _mapController.navigateToPinpoint(75695423) as void Function()
    //     _mapController.centerTo(center: {"latitude" : 48.969696026791894,
    //       "longitude" : 2.5168694369494915}, zoom: 20) as void Function()
    // );
    // Timer(const Duration(seconds: 20),
    //     _mapController.setIndoorFeatureState(id: 75695416, state: {
    //       "selected": true
    //     }) as void Function()
    // );
  }

  void onMapClick(dynamic coordinates) {
    const snackBar = SnackBar(content: Text('Map is clicked'));
    widget.scaffoldMessengerKey.currentState?.showSnackBar(snackBar);
    var random = Random();
    int randomId = random.nextInt(100);
    Map<String, dynamic> pin = {
      'coordinates': {
        'longitude': coordinates["longitude"],
        'latitude': coordinates["latitude"],
      },
      'id': randomId,
      'name': 'User position',
      'image_url':
          'https://www.kangama.com/wp-content/uploads/2021/11/cropped-icone-kangama-50x50.png',
      "tags": ["test", "pin"],
      "description": "tes pin"
    };
    pinpointList.add(pin);
    _mapController.setPinpoints(pinpoints: pinpointList);

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

    // _mapController.getZoom(getZoomCallback: (zoom){
    //   print("zoom level : $zoom");
    // });
  }

  void onIndoorFeatureClick(dynamic indoorFeature) {
    const snackBar = SnackBar(content: Text('indoor feature is clicked'));
    print("wemapMap : indoor clicked => $indoorFeature");
    widget.scaffoldMessengerKey.currentState?.showSnackBar(snackBar);
    // _mapController.centerTo(center: {"latitude" : 48.969696026791894,
    //   "longitude" : 2.5168694369494915}, zoom: 20);
  }

  void onIndoorLevelChanged(dynamic level) {
    const snackBar = SnackBar(content: Text('indoor level is changed'));
    widget.scaffoldMessengerKey.currentState?.showSnackBar(snackBar);
  }

  void onIndoorLevelsChanged(List<dynamic> levels) {
    const snackBar = SnackBar(content: Text('indoor levels are changed'));
    widget.scaffoldMessengerKey.currentState?.showSnackBar(snackBar);
  }

  void onPinpointOpen(dynamic pinpoint) {
    var snackBar = SnackBar(content: Text('Open Pinpoint: ${pinpoint.name}'));

    widget.scaffoldMessengerKey.currentState?.clearSnackBars();
    widget.scaffoldMessengerKey.currentState?.showSnackBar(snackBar);
  }

  void onPinpointClose() {
    const snackBar = SnackBar(content: Text('Close Pinpoint'));

    widget.scaffoldMessengerKey.currentState?.clearSnackBars();
    widget.scaffoldMessengerKey.currentState?.showSnackBar(snackBar);
  }

  void onPinpointUpdated(List<dynamic> pinpoints) {
    var snackBar =
        SnackBar(content: Text('Updated Pinpoints count: ${pinpoints.length}'));
    widget.scaffoldMessengerKey.currentState?.clearSnackBars();
    widget.scaffoldMessengerKey.currentState?.showSnackBar(snackBar);
    print("wemapMap : pins updated ==> $pinpoints");
  }

  void onEventUpdated(List<dynamic> events) {
    var snackBar =
        SnackBar(content: Text('Updated Events count: ${events.length}'));
    widget.scaffoldMessengerKey.currentState?.clearSnackBars();
    widget.scaffoldMessengerKey.currentState?.showSnackBar(snackBar);
  }

  // bind controller
  void _onMapCreated(LivemapController mapController) {
    _mapController = mapController;
    const snackBar = SnackBar(content: Text('Livemap created'));
    widget.scaffoldMessengerKey.currentState?.showSnackBar(snackBar);
    // whatever with mapController
  }

  void onUserLogin() {
    const snackBar = SnackBar(content: Text('User Logged in'));

    widget.scaffoldMessengerKey.currentState?.clearSnackBars();
    widget.scaffoldMessengerKey.currentState?.showSnackBar(snackBar);
  }

  void onMapMoved(dynamic mapMoved) {
    const snackBar = SnackBar(content: Text('Map Moved'));

    widget.scaffoldMessengerKey.currentState?.clearSnackBars();
    widget.scaffoldMessengerKey.currentState?.showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    const Map<String, dynamic> creationParams = <String, dynamic>{
      "token": "", //"GUHTU6TYAWWQHUSR5Z5JZNMXX",
      "emmid": 29301
    };

    return Stack(
      children: [
        Livemap(
          options: creationParams,
          onMapCreated: _onMapCreated,
          onMapReady: onNativeMapReady,
          onMapClick: onMapClick,
          onPinpointOpen: onPinpointOpen,
          onPinpointClose: onPinpointClose,
          // onPinpointUpdated: onPinpointUpdated,
          // onEventUpdated: onEventUpdated,
          // onUserLogin: onUserLogin,
          onIndoorFeatureClick: onIndoorFeatureClick,
          onIndoorLevelChanged: onIndoorLevelChanged,
          onIndoorLevelsChanged: onIndoorLevelsChanged,
          // onMapMoved: onMapMoved,
        ),
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                focusNode: _searchFocus,
                decoration: InputDecoration(
                  hintText: 'Search location...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.search),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onChanged: (value) => searchPOIs(value),
              ),
            ),
            if (searchResults.isNotEmpty)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  // maxHeight: 300,  // Limit the height of the results list
                  itemCount: searchResults.length,
                  itemBuilder: (context, index) {
                    final poi = searchResults[index];
                    return ListTile(
                      title: Text(poi['name'] ?? 'Unnamed location'),
                      subtitle: Text(poi['address'] ?? ''),
                      // Changed to show address instead of description
                      onTap: () => selectPOI(poi),
                    );
                  },
                ),
              ),
            if (isSearching)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ],
    );
  }
}
