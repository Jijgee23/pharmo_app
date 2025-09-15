package mn.infosystems.pharmo

import android.Manifest
import android.content.pm.PackageManager
import androidx.core.content.ContextCompat
import com.google.android.gms.location.*
import com.google.android.gms.location.LocationRequest
import com.google.android.gms.location.LocationServices
import com.google.android.gms.maps.MapsInitializer
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel

class MainActivity : FlutterActivity() {
    private lateinit var locationHandler: LocationHandler
    private val channel = "bg_location_stream"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Initialize Google Maps SDK
        MapsInitializer.initialize(applicationContext, MapsInitializer.Renderer.LATEST, null) {
            // Renderer initialization is complete
        }

        // Initialize location handler and set it as the stream handler
        locationHandler = LocationHandler(this)
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, channel)
                .setStreamHandler(locationHandler)
    }

    override fun onDestroy() {
        super.onDestroy()
        locationHandler.stopLocationUpdates()
    }
}

class LocationHandler(private val context: MainActivity) : EventChannel.StreamHandler {

    private var eventSink: EventChannel.EventSink? = null
    private val fusedLocationClient: FusedLocationProviderClient =
            LocationServices.getFusedLocationProviderClient(context)
    private lateinit var locationCallback: LocationCallback
    private var isTracking = false

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        this.eventSink = events
        startLocationUpdates()
    }

    override fun onCancel(arguments: Any?) {
        stopLocationUpdates()
        this.eventSink = null
    }

    private fun startLocationUpdates() {
        if (ContextCompat.checkSelfPermission(context, Manifest.permission.ACCESS_FINE_LOCATION) !=
                        PackageManager.PERMISSION_GRANTED &&
                        ContextCompat.checkSelfPermission(
                                context,
                                Manifest.permission.ACCESS_COARSE_LOCATION
                        ) != PackageManager.PERMISSION_GRANTED
        ) {
            // Permission check: You should handle permission requests in your Flutter or native
            // code
            return
        }

        if (isTracking) return

        val locationRequest =
                LocationRequest.Builder(10000L)
                        .apply {
                            setMinUpdateIntervalMillis(5000L)
                            setPriority(Priority.PRIORITY_HIGH_ACCURACY)
                        }
                        .build()

        locationCallback =
                object : LocationCallback() {
                    override fun onLocationResult(locationResult: LocationResult) {
                        for (location in locationResult.locations) {
                            val locationData =
                                    mapOf("lat" to location.latitude, "lng" to location.longitude)
                            context.runOnUiThread { eventSink?.success(locationData) }
                        }
                    }
                }

        fusedLocationClient.requestLocationUpdates(locationRequest, locationCallback, null)
        isTracking = true
    }

    fun stopLocationUpdates() {
        if (isTracking) {
            fusedLocationClient.removeLocationUpdates(locationCallback)
            isTracking = false
        }
    }
}
