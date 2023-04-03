package com.getwemap.flutter_wemap_sdk

import android.content.Context
import android.os.Handler
import android.os.Looper
import android.view.View
import androidx.annotation.NonNull
import com.getwemap.livemap.sdk.Livemap
import com.getwemap.livemap.sdk.LivemapView
import com.getwemap.livemap.sdk.callback.FindNearestPinpointsCallback
import com.getwemap.livemap.sdk.callback.GetZoomCallback
import com.getwemap.livemap.sdk.callback.LivemapReadyCallback
import com.getwemap.livemap.sdk.listener.ContentUpdatedListener
import com.getwemap.livemap.sdk.listener.PinpointCloseListener
import com.getwemap.livemap.sdk.listener.PinpointOpenListener
import com.getwemap.livemap.sdk.listener.UserLoginListener
import com.getwemap.livemap.sdk.model.*
import com.getwemap.livemap.sdk.options.LivemapOptions
import com.google.gson.Gson
import com.google.gson.GsonBuilder
import com.google.gson.JsonObject
import com.google.gson.ToNumberPolicy
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.platform.PlatformView
import org.json.JSONArray
import org.json.JSONObject

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
    ContentUpdatedListener,

    UserLoginListener
{

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
            channel.invokeMethod("onPinpointUpdated", pps)
        }
    }

    override fun onEventsUpdated(p0: Query?, events: MutableList<Event>?) {
        val evts = events?.map {gson.fromJson(it.toJson().toString(), HashMap<String, Object>().javaClass) }
        uiThreadHandler.post {
            channel.invokeMethod("onEventUpdated", evts)
        }
    }

     override fun onLivemapReady(@NonNull livemap: Livemap) {
        this.livemap = livemap

         livemap.addPinpointOpenListener(this);
         livemap.addPinpointCloseListener(this);
         livemap.addContentUpdatedListener(this);

         livemap.addUserLoginListener(this);

         uiThreadHandler.post {
             sendOnMapReady()
         }
    }

    override fun onUserLogin() {
        uiThreadHandler.post {
            channel.invokeMethod("onUserLogin", null)
        }
    }

    override fun onMethodCall(methodCall: MethodCall, result: MethodChannel.Result) {
        when (methodCall.method) {
            "openPinpoint" -> openPinpoint(methodCall, result)
            "closePinpoint" -> closePinpoint(methodCall, result)
            "setCenter" -> setCenter(methodCall, result)
            "centerTo" -> centerTo(methodCall, result)
            "openEvent" -> openEvent(methodCall, result)
            "closeEvent" -> closeEvent(methodCall, result)
            "openList" -> openList(methodCall, result)
            "closeList" -> closeList(methodCall, result)
            "closePopin" -> closePopin(methodCall, result)
            "setFilters" -> setFilters(methodCall, result)
            "navigateToPinpoint" -> navigateToPinpoint(methodCall, result)
            "stopNavigation" -> stopNavigation(methodCall, result)
            "signInByToken" -> signInByToken(methodCall, result)
            "enableSidebar" -> enableSidebar(methodCall, result)
            "disableSidebar" -> disableSidebar(methodCall, result)
            "signOut" -> signOut(methodCall, result)
            "setSourceLists" -> setSourceLists(methodCall, result)
            "setPinpoints" -> setPinpoints(methodCall, result)
            "setEvents" -> setEvents(methodCall, result)
            "aroundMe" -> aroundMe(methodCall, result)
            "enableAnalytics" -> enableAnalytics(methodCall, result)
            "disableAnalytics" -> disableAnalytics(methodCall, result)
            "drawPolyline" -> drawPolyline(methodCall, result)
            "removePolyline" -> removePolyline(methodCall, result)
            "addMarker" -> addMarker(methodCall, result)
            "removeMarker" -> removeMarker(methodCall, result)
            "findNearestPinpoints" -> findNearestPinpoints(methodCall, result)

            "getZoom" -> getZoom(methodCall, result)

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

    private fun openEvent(methodCall: MethodCall, result: MethodChannel.Result){
        val params: HashMap<String, Any> = methodCall.arguments as HashMap<String, Any>
        val eventId: Int = params.get("event") as Int
        livemap.openEvent(eventId)
        // result.success(null)
    }

    private fun closeEvent(methodCall: MethodCall, result: MethodChannel.Result) {
        livemap.closeEvent()
        // result.success(null)
    }

    private fun openList(methodCall: MethodCall, result: MethodChannel.Result){
        val params: HashMap<String, Any> = methodCall.arguments as HashMap<String, Any>
        val listId: Int = params.get("list") as Int
        livemap.openList(listId)
        // result.success(null)
    }

    private fun closeList(methodCall: MethodCall, result: MethodChannel.Result) {
        livemap.closeList()
        // result.success(null)
    }

    private fun closePopin(methodCall: MethodCall, result: MethodChannel.Result) {
        livemap.closePopin()
        // result.success(null)
    }

    private fun setFilters(methodCall: MethodCall, result: MethodChannel.Result) {
        val params: HashMap<String, Any> = methodCall.arguments as HashMap<String, Any>
        val filters: HashMap<String, Any> = params.get("filters") as HashMap<String, Any>
        val flts = Filters(
            filters.get("startDate") as String, filters.get("endDate") as String ,
            filters.get("query") as String, filters.get("tags") as Array<String>)
        livemap.setFilters(flts)
        // result.success(null)
    }

    private fun navigateToPinpoint(methodCall: MethodCall, result: MethodChannel.Result) {
        val params: HashMap<String, Any> = methodCall.arguments as HashMap<String, Any>
        val pinpointId: Int = params.get("pinpoint") as Int
        livemap.navigateToPinpoint(pinpointId)
        // result.success(null)
    }

    private fun stopNavigation(methodCall: MethodCall, result: MethodChannel.Result) {
        livemap.stopNavigation()
        // result.success(null)
    }

    private fun signInByToken(methodCall: MethodCall, result: MethodChannel.Result) {
        val params: HashMap<String, Any> = methodCall.arguments as HashMap<String, Any>
        val accessToken: String = params.get("accessToken") as String
        livemap.signInByToken(accessToken)
        // result.success(null)
    }

    private fun enableSidebar(methodCall: MethodCall, result: MethodChannel.Result) {
        livemap.enableSidebar()
        // result.success(null)
    }

    private fun disableSidebar(methodCall: MethodCall, result: MethodChannel.Result) {
        livemap.disableSidebar()
        // result.success(null)
    }

    private fun signOut(methodCall: MethodCall, result: MethodChannel.Result) {
        livemap.signOut()
        // result.success(null)
    }

    private fun setSourceLists(methodCall: MethodCall, result: MethodChannel.Result) {
        val params: HashMap<String, Any> = methodCall.arguments as HashMap<String, Any>
        val sourceLists: List<Int> = params.get("sourceLists") as List<Int>
        livemap.setSourceLists(sourceLists)
        // result.success(null)
    }

    private fun setPinpoints(methodCall: MethodCall, result: MethodChannel.Result) {
        val params: HashMap<String, Any> = methodCall.arguments as HashMap<String, Any>
        val pinpoints: List<HashMap<String, Any>> = params.get("setPinpoints") as List<HashMap<String, Any>>
        val pnpts: List<Pinpoint> = pinpoints.map {
            val point: HashMap<String, Double> = it["coordinates"] as HashMap<String, Double>
            val coords = Coordinates(point.get("latitude")!!, point.get("longitude")!!)
            Pinpoint(it["id"] as Int, it["name"] as String, coords )
        }
        livemap.setPinpoints(pnpts)
        // result.success(null)
    }

    private fun setEvents(methodCall: MethodCall, result: MethodChannel.Result) {
        val params: HashMap<String, Any> = methodCall.arguments as HashMap<String, Any>
        val events: List<HashMap<String, Any>> = params.get("events") as List<HashMap<String, Any>>
        val evts: List<Event> = events.map {event ->
            val pinpointMap: HashMap<String, Any> = event["pinpoint"] as HashMap<String, Any>
            val coordsMap: HashMap<String, Double> = pinpointMap["coordinates"] as HashMap<String, Double>
            val coords = Coordinates(coordsMap.get("latitude")!!, coordsMap.get("longitude")!!)
            val pinpoint = Pinpoint(pinpointMap["id"] as Int, pinpointMap["name"] as String, coords )
            val dates: Array<HashMap<String, String>> = event["dates"] as Array<HashMap<String, String>>
            val eventDateArray: Array<EventDate> = dates.map { eventDate ->
                EventDate(eventDate["start"] as String, eventDate["end"] as String)
            }.toTypedArray()
            Event(event["id"] as Int, event["name"] as String, pinpoint, eventDateArray)
        }
        livemap.setEvents(evts)
        // result.success(null)
    }

    private fun aroundMe(methodCall: MethodCall, result: MethodChannel.Result) {
            livemap.aroundMe()
            // result.success(null)
        }

    private fun enableAnalytics(methodCall: MethodCall, result: MethodChannel.Result) {
            livemap.enableAnalytics()
            // result.success(null)
        }

    private fun disableAnalytics(methodCall: MethodCall, result: MethodChannel.Result) {
            livemap.disableAnalytics()
            // result.success(null)
        }

    private fun drawPolyline(methodCall: MethodCall, result: MethodChannel.Result) {
        val params: HashMap<String, Any> = methodCall.arguments as HashMap<String, Any>
        val coordinates: List<HashMap<String, Double>> = params.get("coordinates") as List<HashMap<String, Double>>

        val coordsList: List<Coordinates> = coordinates.map {
            val jsonObject = JSONObject(it as Map<*, *>)
            Coordinates.fromJson(jsonObject)
        }
        livemap.drawPolyline(coordsList)
        // result.success(null)
    }

    private fun removePolyline(methodCall: MethodCall, result: MethodChannel.Result) {
        val params: HashMap<String, Any> = methodCall.arguments as HashMap<String, Any>
        val polylineId: String = params.get("polylineId") as String
        livemap.removePolyline(polylineId)
            // result.success(null)
        }

    private fun addMarker(methodCall: MethodCall, result: MethodChannel.Result) {
        val params: HashMap<String, Any> = methodCall.arguments as HashMap<String, Any>
        val markerMap: HashMap<String, Any> = params["marker"] as HashMap<String, Any>
        val coordinatesMap: HashMap<String, Double> = markerMap["coordinates"] as HashMap<String, Double>
        val coords:Coordinates =  Coordinates(coordinatesMap["latitude"]!!, coordinatesMap["longitude"]!!)
        val marker:Marker = Marker(coords , markerMap["image"] as String)
        livemap.addMarker(marker)
        // result.success(null)
    }

    private fun removeMarker(methodCall: MethodCall, result: MethodChannel.Result) {
        val params: HashMap<String, Any> = methodCall.arguments as HashMap<String, Any>
        val markerId: String = params["markerId"] as String
        livemap.removeMarker(markerId)
        // result.success(null)
    }

    private fun findNearestPinpoints(methodCall: MethodCall, result: MethodChannel.Result) {
        val params: HashMap<String, Any> = methodCall.arguments as HashMap<String, Any>
        val center: HashMap<String, Double> = params["center"] as HashMap<String, Double>
        val jsonObject = JSONObject(center as Map<*, *>)

        livemap.findNearestPinpoints(Coordinates.fromJson(jsonObject), FindNearestPinpointsCallback{pinpoints ->
            val jsonObject = JSONObject(pinpoints.toString())
            result.success(pinpoints.toString());
        })
    }



    private fun getZoom(methodCall: MethodCall, result: MethodChannel.Result) {
            livemap.getZoom(GetZoomCallback{zoomLevel->
                result.success(zoomLevel);
            })
        }

    override fun dispose() {
        channel.setMethodCallHandler(null)
    }



}
