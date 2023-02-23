package com.getwemap.flutter_wemap_sdk

import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin

/** FlutterLivemap */
class FlutterLivemap: FlutterPlugin {

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {

    val viewFactory = FlutterLivemapFactory(flutterPluginBinding.binaryMessenger)
    flutterPluginBinding.platformViewRegistry.registerViewFactory("WemapView", viewFactory)
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {}
}

