package mn.infosystems.pharmo

import android.Manifest
import android.app.Activity
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.plugin.common.EventChannel

class LocationStreamHandler(private val activity: Activity) : EventChannel.StreamHandler {
    private var eventSink: EventChannel.EventSink? = null
    private var isSubscribed = false
    override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
        // if(!hasBackgroundPermission()){
        //     requestBackgroundPermission();
        // }
        eventSink = events
        isSubscribed = true
        LocationService.setEventSink(events)
        when {
            hasForegroundPermission() -> ensureBackgroundPermissionThenStart()
            else -> requestForegroundPermission()
        }
    }

    override fun onCancel(arguments: Any?) {
        android.util.Log.d("LocationTrack", "Flutter-ээс зогсоох хүсэлт ирлээ")
        isSubscribed = false
        stopService()
        LocationService.setEventSink(null)
        eventSink = null
    }

    fun handlePermissionResult(requestCode: Int, grantResults: IntArray) {
        when (requestCode) {
            REQUEST_CODE_FOREGROUND -> handleForegroundPermissionResult(grantResults)
            REQUEST_CODE_BACKGROUND -> handleBackgroundPermissionResult(grantResults)
        }
    }

    private fun handleForegroundPermissionResult(grantResults: IntArray) {
        val granted =
                grantResults.isNotEmpty() &&
                        grantResults.all { it == PackageManager.PERMISSION_GRANTED }
        if (!granted) {
            permissionDenied("Foreground location permission denied")
            return
        }
        ensureBackgroundPermissionThenStart()
    }

    private fun handleBackgroundPermissionResult(grantResults: IntArray) {
        val granted =
                grantResults.isNotEmpty() &&
                        grantResults.all { it == PackageManager.PERMISSION_GRANTED }
        if (!granted) {
            permissionDenied("Background location permission denied")
            return
        }
        startService()
    }

    private fun hasForegroundPermission(): Boolean {
        val fineGranted =
                ContextCompat.checkSelfPermission(
                        activity,
                        Manifest.permission.ACCESS_FINE_LOCATION
                ) == PackageManager.PERMISSION_GRANTED
        val coarseGranted =
                ContextCompat.checkSelfPermission(
                        activity,
                        Manifest.permission.ACCESS_COARSE_LOCATION
                ) == PackageManager.PERMISSION_GRANTED
        return fineGranted || coarseGranted
    }

    private fun hasBackgroundPermission(): Boolean {
        return if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
            true
        } else {
            ContextCompat.checkSelfPermission(
                    activity,
                    Manifest.permission.ACCESS_BACKGROUND_LOCATION
            ) == PackageManager.PERMISSION_GRANTED
        }
    }

    private fun needsBackgroundPermission(): Boolean =
            Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q

    private fun requestForegroundPermission() {
        ActivityCompat.requestPermissions(
                activity,
                arrayOf(
                        Manifest.permission.ACCESS_FINE_LOCATION,
                        Manifest.permission.ACCESS_COARSE_LOCATION,
                        Manifest.permission.POST_NOTIFICATIONS
                ),
                REQUEST_CODE_FOREGROUND
        )
    }

    private fun requestBackgroundPermission() {
        if (!needsBackgroundPermission() || hasBackgroundPermission()) {
            startService()
            return
        }
        ActivityCompat.requestPermissions(
                activity,
                arrayOf(Manifest.permission.ACCESS_BACKGROUND_LOCATION),
                REQUEST_CODE_BACKGROUND
        )
    }

    private fun ensureBackgroundPermissionThenStart() {
        if (needsBackgroundPermission() && !hasBackgroundPermission()) {
            requestBackgroundPermission()
        } else {
            startService()
        }
    }

    private fun startService() {
        val intent = Intent(activity, LocationService::class.java)
        ContextCompat.startForegroundService(activity, intent)
    }

    private fun stopService() {
        val intent = Intent(activity, LocationService::class.java)
        activity.stopService(intent)
    }

    private fun permissionDenied(message: String) {
        LocationService.setEventSink(null)
        stopService()
        eventSink?.error("permission_denied", message, null)
    }

    companion object {
        const val REQUEST_CODE_FOREGROUND = 9021
        const val REQUEST_CODE_BACKGROUND = 9022
    }
}
