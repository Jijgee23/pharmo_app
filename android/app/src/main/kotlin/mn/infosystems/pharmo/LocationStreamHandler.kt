package mn.infosystems.pharmo

import android.Manifest
import android.app.Activity
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.util.Log
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.plugin.common.EventChannel

class LocationStreamHandler(private val activity: Activity) : EventChannel.StreamHandler {
    private var eventSink: EventChannel.EventSink? = null
    private var isSubscribed = false
    private var isListening = false
    override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
        Log.d(TAG, "📡 onListen called - Setting EventSink")

        eventSink = events
        isListening = true

        // ✅ CRITICAL: Set EventSink to Service IMMEDIATELY
        LocationService.setEventSink(events)

        Log.d(TAG, "✅ EventSink set successfully")

        // Check if service is already running
        if (LocationService.isRunning()) {
            Log.d(TAG, "Service already running, EventSink reconnected")
            return
        }

        // If not running, start with permissions
        when {
            hasForegroundPermission() -> ensureBackgroundPermissionThenStart()
            else -> requestForegroundPermission()
        }
    }

    override fun onCancel(arguments: Any?) {
        Log.d(TAG, "🛑 onCancel called")

        isListening = false

        // DON'T stop service here - only clear EventSink
        // Service should be controlled via MethodChannel
        LocationService.setEventSink(null)
        eventSink = null

        Log.d(TAG, "✅ EventSink cleared")
    }

    fun checkAndRequestFullLocationPermissions() {
        when {
            // 1. Foreground зөвшөөрөл байхгүй бол (Fine эсвэл Coarse)
            !hasForegroundPermission() -> {
                requestForegroundPermission()
            }

            // 2. Foreground байна, гэвч Background хэрэгтэй бөгөөд байхгүй бол
            needsBackgroundPermission() && !hasBackgroundPermission() -> {
                // Энд хэрэглэгчид тайлбар өгөх Dialog харуулбал зүгээр байдаг (заавал биш)
                requestBackgroundPermission()
            }

            // 3. Бүх зөвшөөрөл OK бол шууд Service-ээ эхлүүлнэ
            else -> {
                startService()
            }
        }
    }
    // LocationStreamHandler.kt доторх үр дүн боловсруулах хэсэг

    fun handlePermissionResult(requestCode: Int, grantResults: IntArray) {
        val isGranted =
                grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED

        when (requestCode) {
            REQUEST_CODE_FOREGROUND -> {
                if (isGranted) {
                    // Foreground авчихлаа, одоо шууд дараагийнхыг нь асууна
                    if (needsBackgroundPermission()) {
                        requestBackgroundPermission()
                    } else {
                        startService()
                    }
                } else {
                    permissionDenied("Байршил тогтоогч хаагдсан")
                }
            }
            REQUEST_CODE_BACKGROUND -> {
                if (isGranted) {
                    startService()
                } else {
                    // Хэрэглэгч Settings рүү ороод "Allow all the time" сонгоогүй бол
                    permissionDenied(
                            "Байршил арын төлөвт зөвшөөрнө үү. 'Allow all the time'-ийг сонгоно уу."
                    )
                }
            }
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
        Log.d(TAG, "Starting LocationService...")
        val intent = Intent(activity, LocationService::class.java)
        ContextCompat.startForegroundService(activity, intent)
    }
    
    private fun stopService() {
        Log.d(TAG, "Stopping LocationService...")
        val intent = Intent(activity, LocationService::class.java)
        activity.stopService(intent)
    }
    
    private fun permissionDenied(message: String) {
        Log.e(TAG, "Permission denied: $message")
        LocationService.setEventSink(null)
        stopService()
        eventSink?.error("permission_denied", message, null)
    }

    companion object {
        const val REQUEST_CODE_FOREGROUND = 9021
        const val REQUEST_CODE_BACKGROUND = 9022
        private const val TAG = "LocationStreamHandler"
    }
}
