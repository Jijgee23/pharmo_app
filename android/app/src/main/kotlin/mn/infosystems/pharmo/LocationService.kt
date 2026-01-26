package mn.infosystems.pharmo

import android.annotation.SuppressLint
import android.app.*
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.location.Location
import android.location.LocationListener
import android.location.LocationManager
import android.os.Build
import android.os.IBinder
import android.os.PowerManager
import android.util.Log
import androidx.core.app.NotificationCompat
import io.flutter.plugin.common.EventChannel

class LocationService : Service(), LocationListener {

    private lateinit var locationManager: LocationManager
    private var isUpdating = false
    private var lastBroadcastLocation: Location? = null
    private var wakeLock: PowerManager.WakeLock? = null

    // ================= CONFIGURATION (synchronized with iOS) =================
    private val minTimeBetweenUpdates = 3000L          // 3 seconds
    private val minDistanceOsFilter = 10f              // Min distance for OS filter
    private val maxAllowedAccuracy = 30f               // 30 meters
    private val minDriftDistance = 20f                 // Min distance for drift check
    
    // Speed-based distance thresholds (km/h)
    private val highSpeedThreshold = 60f               // > 60 km/h
    private val mediumSpeedThreshold = 30f             // 30-60 km/h
    private val lowSpeedThreshold = 10f                // 10-30 km/h
    
    private val highSpeedDistance = 200f               // 200m at high speed
    private val mediumSpeedDistance = 100f             // 100m at medium speed
    private val normalSpeedDistance = 50f              // 50m at normal speed
    private val walkingSpeedDistance = 15f             // 15m at walking speed
    private val minSpeedThreshold = 0.5f               // 0.5 m/s
    
    companion object {
        private const val TAG = "LocationService"
        private const val CHANNEL_ID = "pharmo_bg_location"
        private const val NOTIFICATION_ID = 0x444
        
        @Volatile
        private var eventSink: EventChannel.EventSink? = null

        fun setEventSink(sink: EventChannel.EventSink?) {
            eventSink = sink
        }
    }

    // ================= SERVICE LIFECYCLE =================

    override fun onCreate() {
        super.onCreate()
        locationManager = getSystemService(Context.LOCATION_SERVICE) as LocationManager
        ensureNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.i(TAG, "Service started - will run in background even when app terminates")
        startForegroundServiceInternal()
        acquireWakeLock()
        startLocationUpdates()
        return START_STICKY
    }

    override fun onDestroy() {
        stopLocationUpdates()
        releaseWakeLock()
        setEventSink(null)
        Log.i(TAG, "Service destroyed")
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null

    // ================= LOCATION CALLBACK =================

    override fun onLocationChanged(location: Location) {
        if (eventSink == null) return

        // 1️⃣ Accuracy validation
        if (location.accuracy <= 0 || location.accuracy > maxAllowedAccuracy) {
            Log.d(TAG, "Location rejected - poor accuracy: ${location.accuracy}")
            return
        }

        val previous = lastBroadcastLocation

        // 2️⃣ First fix
        if (previous == null) {
            broadcastLocation(location)
            return
        }

        // 3️⃣ Time filter
        val timeDelta = location.time - previous.time
        if (timeDelta < minTimeBetweenUpdates) return

        // 4️⃣ Same coordinate guard
        if (location.latitude == previous.latitude && location.longitude == previous.longitude) {
            return
        }

        val distance = location.distanceTo(previous)

        // 5️⃣ Drift filter (when stationary)
        if (location.hasSpeed() && location.speed < minSpeedThreshold) {
            if (distance < minDriftDistance) return
        }

        // 6️⃣ Speed-based dynamic distance (synchronized with iOS)
        val speedKmH = location.speed * 3.6f
        val dynamicDistance = calculateDynamicDistance(speedKmH)

        if (distance >= dynamicDistance) {
            broadcastLocation(location)
        }
    }

    // ================= BROADCAST TO FLUTTER =================

    private fun broadcastLocation(location: Location) {
        lastBroadcastLocation = location

        eventSink?.success(
            mapOf(
                "lat" to location.latitude,
                "lng" to location.longitude,
                "acc" to location.accuracy,
                "spd" to location.speed,
                "time" to location.time
            )
        )
    }

    // ================= LOCATION CONTROL =================

    @SuppressLint("MissingPermission")
    private fun startLocationUpdates() {
        if (isUpdating) return
        isUpdating = true

        locationManager.requestLocationUpdates(
            LocationManager.GPS_PROVIDER,
            minTimeBetweenUpdates,
            minDistanceOsFilter,
            this
        )
        Log.i(TAG, "Location updates started")
    }

    private fun stopLocationUpdates() {
        if (!isUpdating) return
        locationManager.removeUpdates(this)
        isUpdating = false
        lastBroadcastLocation = null
        Log.i(TAG, "Location updates stopped")
    }

    override fun onProviderEnabled(provider: String) {
        Log.d(TAG, "Provider enabled: $provider")
    }

    override fun onProviderDisabled(provider: String) {
        Log.d(TAG, "Provider disabled: $provider")
    }

    // ================= FOREGROUND NOTIFICATION =================

    private fun ensureNotificationChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return

        val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        val channel = NotificationChannel(
            CHANNEL_ID,
            "Location Tracking",
            NotificationManager.IMPORTANCE_LOW
        )
        manager.createNotificationChannel(channel)
    }

    private fun startForegroundServiceInternal() {
        val notification = buildNotification()

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            startForeground(
                NOTIFICATION_ID,
                notification,
                ServiceInfo.FOREGROUND_SERVICE_TYPE_LOCATION
            )
        } else {
            startForeground(NOTIFICATION_ID, notification)
        }
    }

    private fun buildNotification(): Notification {
        val intent = Intent(this, MainActivity::class.java)
        val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        } else {
            PendingIntent.FLAG_UPDATE_CURRENT
        }
        val pendingIntent = PendingIntent.getActivity(this, 0, intent, flags)

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Pharmo Location Tracking")
            .setContentText("Monitoring location updates…")
            .setSmallIcon(android.R.drawable.ic_menu_mylocation)
            .setContentIntent(pendingIntent)
            .setOngoing(true)
            .setCategory(NotificationCompat.CATEGORY_SERVICE)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .build()
    }

    // ================= SPEED-BASED DISTANCE CALCULATOR =================

    private fun calculateDynamicDistance(speedKmH: Float): Float {
        return when {
            speedKmH > highSpeedThreshold -> highSpeedDistance
            speedKmH > mediumSpeedThreshold -> mediumSpeedDistance
            speedKmH > lowSpeedThreshold -> normalSpeedDistance
            else -> walkingSpeedDistance
        }
    }

    // ================= WAKE LOCK MANAGEMENT (background persistence) =================

    @SuppressLint("WakelockTimeout")
    private fun acquireWakeLock() {
        if (wakeLock?.isHeld == true) return
        
        val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
        wakeLock = powerManager.newWakeLock(
            PowerManager.PARTIAL_WAKE_LOCK,
            "LocationService::LocationTracking"
        ).apply {
            acquire()
            Log.d(TAG, "WakeLock acquired - app will continue tracking in background")
        }
    }

    private fun releaseWakeLock() {
        if (wakeLock?.isHeld == true) {
            wakeLock?.release()
            Log.d(TAG, "WakeLock released")
        }
    }
}
