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
import androidx.core.app.NotificationCompat
import io.flutter.plugin.common.EventChannel

class LocationService : Service(), LocationListener {

    private lateinit var locationManager: LocationManager
    private var isUpdating = false
    private var lastBroadcastLocation: Location? = null

    // ================= CONFIG (iOS-той ижил) =================
    private val MIN_TIME_BW_UPDATES = 3000L          // 3 секунд
    private val MIN_DISTANCE_OS_FILTER = 10f         // OS-д хэлэх доод хязгаар
    private val MAX_ALLOWED_ACCURACY = 30f           // 30 метр
    private val MIN_SPEED_THRESHOLD = 0.5f           // 0.5 м/с

    // ================= SERVICE LIFECYCLE =================

    override fun onCreate() {
        super.onCreate()
        locationManager = getSystemService(Context.LOCATION_SERVICE) as LocationManager
        ensureNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        startForegroundServiceInternal()
        startLocationUpdates()
        return START_STICKY
    }

    override fun onDestroy() {
        stopLocationUpdates()
        setEventSink(null)
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null

    // ================= LOCATION CALLBACK =================

    override fun onLocationChanged(location: Location) {
        if (eventSink == null) return

        // 1️⃣ Accuracy filter
        if (location.accuracy <= 0 || location.accuracy > MAX_ALLOWED_ACCURACY) return

        val previous = lastBroadcastLocation

        // 2️⃣ First fix
        if (previous == null) {
            broadcastLocation(location)
            return
        }

        // 3️⃣ Time filter
        val timeDelta = location.time - previous.time
        if (timeDelta < MIN_TIME_BW_UPDATES) return

        // 4️⃣ Same coordinate guard
        if (
            location.latitude == previous.latitude &&
            location.longitude == previous.longitude
        ) return

        val distance = location.distanceTo(previous)

        // 5️⃣ Drift filter (зогссон үед)
        if (location.hasSpeed() && location.speed < MIN_SPEED_THRESHOLD) {
            if (distance < 20f) return
        }

        // 6️⃣ Speed-based dynamic distance (iOS-той 1:1)
        val speedKmH = location.speed * 3.6f
        val dynamicDistance = when {
            speedKmH > 60 -> 200f
            speedKmH > 30 -> 100f
            speedKmH > 10 -> 50f
            else -> 15f
        }

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
            MIN_TIME_BW_UPDATES,
            MIN_DISTANCE_OS_FILTER,
            this
        )
    }

    private fun stopLocationUpdates() {
        if (!isUpdating) return
        locationManager.removeUpdates(this)
        isUpdating = false
        lastBroadcastLocation = null
    }

    override fun onProviderEnabled(provider: String) {}
    override fun onProviderDisabled(provider: String) {}

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
        val flags =
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            } else {
                PendingIntent.FLAG_UPDATE_CURRENT
            }

        val pendingIntent = PendingIntent.getActivity(this, 0, intent, flags)

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Pharmo байршлыг дамжуулж байна")
            .setContentText("Байршлыг хянаж байна…")
            .setSmallIcon(android.R.drawable.ic_menu_mylocation)
            .setContentIntent(pendingIntent)
            .setOngoing(true)
            .setCategory(NotificationCompat.CATEGORY_SERVICE)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .build()
    }

    // ================= EVENT CHANNEL BRIDGE =================

    companion object {
        private const val CHANNEL_ID = "pharmo_bg_location"
        private const val NOTIFICATION_ID = 0x444

        @Volatile
        private var eventSink: EventChannel.EventSink? = null

        fun setEventSink(sink: EventChannel.EventSink?) {
            eventSink = sink
        }
    }
}
