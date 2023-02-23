package com.getwemap.flutter_wemap_sdk

import android.content.Context
import android.os.Handler
import android.os.Looper
import android.view.View
import androidx.annotation.NonNull
import com.getwemap.livemap.sdk.Livemap
import com.getwemap.livemap.sdk.LivemapView
import com.getwemap.livemap.sdk.callback.LivemapReadyCallback
import com.getwemap.livemap.sdk.listener.ContentUpdatedListener
import com.getwemap.livemap.sdk.listener.PinpointCloseListener
import com.getwemap.livemap.sdk.listener.PinpointOpenListener
import com.getwemap.livemap.sdk.model.Coordinates
import com.getwemap.livemap.sdk.model.Event
import com.getwemap.livemap.sdk.model.Pinpoint
import com.getwemap.livemap.sdk.model.Query
import com.getwemap.livemap.sdk.options.LivemapOptions
import com.google.gson.Gson
import com.google.gson.GsonBuilder
import com.google.gson.ToNumberPolicy
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.platform.PlatformView

val gson: Gson = GsonBuilder()
    .setObjectToNumberStrategy(ToNumberPolicy.LONG_OR_DOUBLE)
    .create()

class FlutterLivemapViewContainer(context: Context,
                                  messenger: BinaryMessenger,
                                  id: Int,
                                  args: Map<String, Any>):
    PlatformView,
    MethodCallHandler,
    LivemapReadyCallback,
    PinpointOpenListener,
    PinpointCloseListener,
    ContentUpdatedListener {

    private var view: View
    private var channel: MethodChannel
    private var mContext: Context
    lateinit var livemap: Livemap
    private val uiThreadHandler = Handler(Looper.getMainLooper())

    init {
        val token = args.get("token") as String?
        val emmid = args.get("emmid") as Int?
        val livemapOptions = LivemapOptions()
        livemapOptions.emmid = emmid
        livemapOptions.token = token
        view = LivemapView(context, livemapOptions)
        mContext = context;

        channel = MethodChannel(messenger, "MapView/$id")
        channel.setMethodCallHandler(this)

        // trigger callbacks
        (view as LivemapView).getLivemapAsync(this);
    }

    override fun getView(): View {
        return view
    }

    // livemap handlers
    override fun onPinpointOpen(pinpoint: Pinpoint?) {
        val pinpointMap = gson.fromJson(pinpoint?.toJson().toString(), HashMap<String, Object>().javaClass)
        uiThreadHandler.post {
            channel.invokeMethod("onPinpointOpen", pinpointMap)
        }
    }

    override fun onPinpointClose() {
        uiThreadHandler.post {
            channel.invokeMethod("onPinpointClose", null)
        }
    }

    override fun onPinpointsUpdated(p0: Query?, pinpoints: MutableList<Pinpoint>?) {
        val pps = pinpoints?.map {gson.fromJson(it.toJson().toString(), HashMap<String, Object>().javaClass) }
        uiThreadHandler.post {
            channel.invokeMethod("onContentUpdated", pps)
        }
    }

    override fun onEventsUpdated(p0: Query?, p1: MutableList<Event>?) {
        TODO("Not yet implemented")
    }

     override fun onLivemapReady(@NonNull livemap: Livemap) {
        this.livemap = livemap

         livemap.addPinpointOpenListener(this);
         livemap.addPinpointCloseListener(this);
         livemap.addContentUpdatedListener(this);

         uiThreadHandler.post {
             sendOnMapReady()
         }
    }

    override fun onMethodCall(methodCall: MethodCall, result: MethodChannel.Result) {
        when (methodCall.method) {
            "openPinpoint" -> openPinpoint(methodCall, result)
            "closePinpoint" -> closePinpoint(methodCall, result)
            "setCenter" -> setCenter(methodCall, result)
            "centerTo" -> centerTo(methodCall, result)
            else -> result.notImplemented()
        }
    }

    // methods
    private fun sendOnMapReady() {
        channel.invokeMethod("onMapReady", null)
    }

    private fun openPinpoint(methodCall: MethodCall, result: MethodChannel.Result) {
        val params: HashMap<String, Any> = methodCall.arguments as HashMap<String, Any>
        val pinpointId: Int = params.get("pinpoint") as Int
        livemap.openPinpoint(pinpointId)
        // result.success(null)
    }

    private fun closePinpoint(methodCall: MethodCall, result: MethodChannel.Result) {
        livemap.closePinpoint()
        // result.success(null)
    }

    private fun setCenter(methodCall: MethodCall, result: MethodChannel.Result) {
        val params: HashMap<String, Any> = methodCall.arguments as HashMap<String, Any>
        val center: HashMap<String, Double> = params.get("center") as HashMap<String, Double>
        val coords = Coordinates(center.get("latitude")!!, center.get("longitude")!!)
        livemap.setCenter(coords)
        // result.success(null)
    }

    private fun centerTo(methodCall: MethodCall, result: MethodChannel.Result) {
        val params: HashMap<String, Any> = methodCall.arguments as HashMap<String, Any>
        val center: HashMap<String, Double> = params.get("center") as HashMap<String, Double>
        val zoom: Double = params.get("zoom") as Double
        val coords = Coordinates(center.get("latitude")!!, center.get("longitude")!!)
        livemap.centerTo(coords, zoom)
        // result.success(null)
    }

    override fun dispose() {
        channel.setMethodCallHandler(null)
    }
}
