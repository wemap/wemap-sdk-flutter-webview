package com.getwemap.flutter_wemap_sdk

import android.content.Context
import android.graphics.Color
import android.os.Handler
import android.os.Looper
import android.view.View
import androidx.annotation.NonNull
import com.getwemap.livemap.sdk.Livemap
import com.getwemap.livemap.sdk.LivemapView
import com.getwemap.livemap.sdk.callback.DrawPolylineCallback
import com.getwemap.livemap.sdk.callback.FindNearestPinpointsCallback
import com.getwemap.livemap.sdk.callback.GetZoomCallback
import com.getwemap.livemap.sdk.callback.LivemapReadyCallback
import com.getwemap.livemap.sdk.listener.*
import com.getwemap.livemap.sdk.model.*
import com.getwemap.livemap.sdk.options.EaseToOptions
import com.getwemap.livemap.sdk.options.LivemapOptions
import com.getwemap.livemap.sdk.options.PolylineOptions
import com.google.gson.Gson
import com.google.gson.GsonBuilder
import com.google.gson.ToNumberPolicy
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.platform.PlatformView
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
    MapClickListener,
    IndoorFeatureClickListener,
    IndoorLevelChangedListener,
    IndoorLevelsChangedListener,
    UserLoginListener,
    MapMovedListener
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
        val pinpointMap = gson.fromJson(pinpoint?.toJson().toString(), HashMap<String, Any>().javaClass)
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
        val pps = pinpoints?.map {gson.fromJson(it.toJson().toString(), HashMap<String, Any>().javaClass) }
        uiThreadHandler.post {
            channel.invokeMethod("onPinpointUpdated", pps)
        }
    }

    override fun onEventsUpdated(p0: Query?, events: MutableList<Event>?) {
        val evts = events?.map {gson.fromJson(it.toJson().toString(), HashMap<String, Any>().javaClass) }
        uiThreadHandler.post {
            channel.invokeMethod("onEventUpdated", evts)
        }
    }

     override fun onLivemapReady(@NonNull livemap: Livemap) {
        this.livemap = livemap

         livemap.addPinpointOpenListener(this);
         livemap.addPinpointCloseListener(this);
         livemap.addContentUpdatedListener(this);
         livemap.addMapClickListener(this);
         livemap.addIndoorFeatureClickListener(this);
         livemap.addIndoorLevelChangedListener(this);
         livemap.addIndoorLevelsChangedListener(this);
         livemap.addUserLoginListener(this);
         livemap.addMapMovedListener(this);


         uiThreadHandler.post {
             sendOnMapReady()
         }
    }

    override fun onMapClick(coordinates: Coordinates?) {
        val coords = gson.fromJson(coordinates?.toJson().toString() , HashMap<String, Double>().javaClass)
        uiThreadHandler.post {
            channel.invokeMethod("onMapClick", coords)
        }
    }

    override fun onIndoorFeatureClick(indoorFeature: IndoorFeature?) {
            val indoorftrs = gson.fromJson(indoorFeature?.toJson().toString() , HashMap<String, Any>().javaClass)
            uiThreadHandler.post {
                    channel.invokeMethod("onIndoorFeatureClick", indoorftrs)
            }
    }

    override fun onIndoorLevelChanged(level: Level?) {
        val lvl = gson.fromJson(level?.toJson().toString() , HashMap<String, Any>().javaClass)
        uiThreadHandler.post {
            channel.invokeMethod("onIndoorLevelChanged", lvl)
        }
    }

    override fun onIndoorLevelsChanged(levels: Array<out Level>?) {
        val lvls = levels?.map {gson.fromJson(it.toJson().toString(), HashMap<String, Any>().javaClass) }
        uiThreadHandler.post {
            channel.invokeMethod("onIndoorLevelsChanged", lvls)
        }
    }

    override fun onUserLogin() {
        uiThreadHandler.post {
            channel.invokeMethod("onUserLogin", null)
        }
    }

    override fun onMapMoved(zoom: Double?, bounds: BoundingBox?, point: Coordinates?) {
        val result = JSONObject()
        val northEastJson = JSONObject()
        val southWestJson = JSONObject()
        if (bounds != null) {
            northEastJson.put("latitude", bounds.northEast.lat)
            northEastJson.put("longitude", bounds.northEast.lng)
            southWestJson.put("latitude", bounds.southWest.lat)
            southWestJson.put("longitude", bounds.southWest.lng)
        }
        result.put("northEast", northEastJson)
        result.put("southWest", southWestJson)
        val bnds = gson.fromJson(result.toString() , HashMap<String, Any>().javaClass)
        val mapMoved = HashMap<String, Any>()
        if (point != null) {
            mapMoved["latitude"] = point.lat
            mapMoved["longitude"] = point.lng
        }
        mapMoved["bounds"] = bnds
        mapMoved["zoom"] = zoom as Any
        uiThreadHandler.post {
            channel.invokeMethod("onMapMoved", mapMoved)
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
            "easeTo" -> easeTo(methodCall, result)
            "setIndoorFeatureState" -> setIndoorFeatureState(methodCall, result)
            "getZoom" -> getZoom(methodCall, result)
            "setZoom" -> setZoom(methodCall, result)

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
        val pinpoints: List<HashMap<String, Any>> = params.get("pinpoints") as List<HashMap<String, Any>>
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
        val polylineOptions: HashMap<String, Any>? = params["polylineOptions"] as HashMap<String, Any>?
        val polylineOpts = PolylineOptions()
        val colorString = polylineOptions?.get("color") as String?
        if (colorString != null) {
            val color = Color.parseColor(colorString)
            polylineOpts.color = color
        }
        val opacity = polylineOptions?.get("opacity") as Double?
        val width = polylineOptions?.get("width") as Double?
        val useNetwork = polylineOptions?.get("useNetwork") as Boolean?

        polylineOpts.opacity = opacity?.toFloat()
        polylineOpts.width = width?.toFloat()
        polylineOpts.useNetwork = useNetwork
        val coordsList: List<Coordinates> = coordinates.map {
            val jsonObject = JSONObject(it as Map<*, *>)
            Coordinates.fromJson(jsonObject)
        }

        livemap.drawPolyline(coordsList, polylineOpts, DrawPolylineCallback{
            id -> result.success(id)
        })
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
            val pinList : kotlin.collections.List<HashMap<String, Any?>>  = pinpoints.map {pinpoint ->
                val pinHashMap = HashMap<String, Any?>()
                pinHashMap["id"] = pinpoint.id
                pinHashMap["name"] = pinpoint.name
                val coordinatesMap = HashMap<String, Double>()
                coordinatesMap["latitude"] = pinpoint.latLngAlt.lat
                coordinatesMap["longitude"] = pinpoint.latLngAlt.lng
                pinHashMap["coordinates"] = coordinatesMap
                pinHashMap["address"] = pinpoint.address
                pinHashMap["description"] = pinpoint.description
                pinHashMap["imageUrl"] = pinpoint.imageUrl
                pinHashMap["linkUrl"] = pinpoint.linkUrl
                pinHashMap["tags"] = pinpoint.tags.asList()
////                pinHashMap["externalData"] = pinpoint.externalData
                pinHashMap["type"] = pinpoint.type
                pinHashMap["category"] = pinpoint.category
                pinHashMap["mediaUrl"] = pinpoint.mediaUrl
                pinHashMap["mediaType"] = pinpoint.mediaType
////                pinHashMap["geoEntityShape"] = pinpoint.geoEntityShape
                pinHashMap
            }
            result.success(pinList)
        })
    }

    private fun easeTo(methodCall: MethodCall, result: MethodChannel.Result) {
        val params: HashMap<String, Any> = methodCall.arguments as HashMap<String, Any>
        val easeToOptionsMap: HashMap<String, Any> = params["easeToOptions"] as HashMap<String, Any>
        val centerMap: HashMap<String, Double> = easeToOptionsMap.get("center") as HashMap<String, Double>
        val centerJsonObject = JSONObject(centerMap as Map<*, *>)
        val center: Coordinates = Coordinates.fromJson(centerJsonObject)
        val paddingMap: HashMap<String, Float>? = easeToOptionsMap.get("padding") as HashMap<String, Float>?
        val easeToOptions = EaseToOptions()
        val padding = Padding()
        if (paddingMap != null){
            if (paddingMap["right"] != null)
                padding.right = (paddingMap["right"] as Double).toFloat()
            if (paddingMap["left"] != null)
                padding.left = (paddingMap["left"] as Double).toFloat()
            if (paddingMap["top"] != null)
                padding.top = (paddingMap["top"] as Double).toFloat()
            if (paddingMap["bottom"] != null)
                padding.bottom = (paddingMap["bottom"] as Double).toFloat()
            easeToOptions.padding = padding
        }

        easeToOptions.center = center
        easeToOptions.zoom = (easeToOptionsMap.get("zoom") as Double?)?.toFloat()
        easeToOptions.animate = easeToOptionsMap.get("animate") as Boolean?
        easeToOptions.bearing = (easeToOptionsMap.get("bearing") as Double?)?.toFloat()
        easeToOptions.duration = (easeToOptionsMap.get("duration") as Double?)?.toFloat()
        easeToOptions.pitch = (easeToOptionsMap.get("pitch") as Double?)?.toFloat()
        livemap.easeTo(easeToOptions)
    }

    private fun setIndoorFeatureState(methodCall: MethodCall, result: MethodChannel.Result) {
        val params: HashMap<String, Any> = methodCall.arguments as HashMap<String, Any>
        val id: Int = params["id"] as Int
        val stateMap : HashMap<String, Any> = params["state"] as HashMap<String, Any>
        val indoorFeatureState = IndoorFeatureState()
        indoorFeatureState.selected = stateMap["selected"] as Boolean
        livemap.setIndoorFeatureState(id, indoorFeatureState)
    }


    private fun getZoom(methodCall: MethodCall, result: MethodChannel.Result) {
            livemap.getZoom(GetZoomCallback{zoomLevel->
                result.success(zoomLevel);
            })
        }

    private fun setZoom(methodCall: MethodCall, result: MethodChannel.Result) {
        val params: HashMap<String, Any> = methodCall.arguments as HashMap<String, Any>
        val zoomLevel: Float = (params["zoom"] as Double).toFloat()
        livemap.setZoom(zoomLevel)
    }


    override fun dispose() {
        channel.setMethodCallHandler(null)
    }




}
