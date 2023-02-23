package com.getwemap.flutter_wemap_sdk

import android.content.Context
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class FlutterLivemapFactory(private val messenger: BinaryMessenger) :
        PlatformViewFactory(StandardMessageCodec.INSTANCE){

    override fun create(context: Context,
                        id: Int,
                        args: Any?): PlatformView {
        val params = args as Map<String, Any>

        return FlutterLivemapViewContainer(context,
            messenger,
            id,
            args)
    }
}