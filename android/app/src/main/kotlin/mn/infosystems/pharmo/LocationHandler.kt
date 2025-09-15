package mn.infosystems.pharmo

import android.Manifest
import android.annotation.SuppressLint
import android.content.Context
import android.content.pm.PackageManager
import android.location.Location
import android.os.Looper
import androidx.core.app.ActivityCompat
import com.google.android.gms.location.*
import io.flutter.plugin.common.EventChannel

class LocationHandler(private val context: Context) {
    private var fusedClient: FusedLocationProviderClient =
            LocationServices.getFusedLocationProviderClient(context)

    private var locationCallback: LocationCallback? = null

    // Байршлын шинэчлэл эхлүүлэх
    @SuppressLint("MissingPermission")
    fun start(eventSink: EventChannel.EventSink) {
        if (!hasPermission()) {
            eventSink.error("PERMISSION", "Location permission not granted", null)
            return
        }

        val request =
                LocationRequest.Builder(Priority.PRIORITY_HIGH_ACCURACY, 10000)
                        .setMinUpdateDistanceMeters(10f)
                        .build()

        locationCallback =
                object : LocationCallback() {
                    override fun onLocationResult(result: LocationResult) {
                        val loc: Location = result.lastLocation ?: return
                        eventSink.success(mapOf("lat" to loc.latitude, "lng" to loc.longitude))
                    }
                }

        fusedClient.requestLocationUpdates(
                request,
                locationCallback as LocationCallback,
                Looper.getMainLooper()
        )
    }

    fun stop() {
        locationCallback?.let { fusedClient.removeLocationUpdates(it) }
    }

    private fun hasPermission(): Boolean {
        return ActivityCompat.checkSelfPermission(
                context,
                Manifest.permission.ACCESS_FINE_LOCATION
        ) == PackageManager.PERMISSION_GRANTED &&
                ActivityCompat.checkSelfPermission(
                        context,
                        Manifest.permission.ACCESS_BACKGROUND_LOCATION
                ) == PackageManager.PERMISSION_GRANTED
    }
}
