import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';

import 'map_view.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final _scaffoldKey = GlobalKey<ScaffoldMessengerState>();
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: _scaffoldKey,
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Wemap Sample"),
        ),
        body: Container(
          constraints: const BoxConstraints.expand(),
          child: MapView(
            scaffoldMessengerKey: _scaffoldKey,
          ),
        ),
      ),
    );
  }
}
