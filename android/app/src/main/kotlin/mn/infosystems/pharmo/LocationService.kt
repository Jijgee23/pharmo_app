package mn.infosystems.pharmo

import android.Manifest
import android.annotation.SuppressLint
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.content.pm.ServiceInfo
import android.location.Location
import android.location.LocationListener
import android.location.LocationManager
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat
import androidx.core.content.ContextCompat
import io.flutter.plugin.common.EventChannel

class LocationService : Service(), LocationListener {
  private lateinit var locationManager: LocationManager
  private var isUpdating = false
  private var lastBroadcastLocation: Location? = null

  override fun onCreate() {
    super.onCreate()
    locationManager = getSystemService(Context.LOCATION_SERVICE) as LocationManager
    ensureNotificationChannel()
  }

  override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
    val notification = buildNotification()
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
      startForeground(NOTIFICATION_ID, notification, ServiceInfo.FOREGROUND_SERVICE_TYPE_LOCATION)
    } else {
      startForeground(NOTIFICATION_ID, notification)
    }
    startLocationUpdates()
    return START_STICKY
  }

  override fun onDestroy() {
    super.onDestroy()
    stopLocationUpdates()
    setEventSink(null)
  }

  override fun onBind(intent: Intent?): IBinder? = null

  override fun onLocationChanged(location: Location) {
    val previousLocation = lastBroadcastLocation
    if (previousLocation != null && location.distanceTo(previousLocation) < LOCATION_MIN_DISTANCE_M) {
      return
    }
    lastBroadcastLocation = Location(location)
    eventSink?.success(mapOf("lat" to location.latitude, "lng" to location.longitude))
  }

  override fun onProviderEnabled(provider: String) {}

  override fun onProviderDisabled(provider: String) {}

  @SuppressLint("MissingPermission")
  private fun startLocationUpdates() {
    if (isUpdating) return
    if (!hasLocationPermission() || !hasBackgroundPermission()) {
      eventSink?.error("permission_denied", "Missing location permissions", null)
      stopSelf()
      return
    }
    isUpdating = true
    locationManager.requestLocationUpdates(
            LocationManager.GPS_PROVIDER,
            LOCATION_INTERVAL_MS,
            LOCATION_MIN_DISTANCE_M,
            this
    )
    locationManager.requestLocationUpdates(
            LocationManager.NETWORK_PROVIDER,
            LOCATION_INTERVAL_MS,
            LOCATION_MIN_DISTANCE_M,
            this
    )
  }

  private fun stopLocationUpdates() {
    if (!isUpdating) return
    locationManager.removeUpdates(this)
    isUpdating = false
    lastBroadcastLocation = null
  }

  private fun hasLocationPermission(): Boolean {
    val fineGranted =
            ContextCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) ==
                    PackageManager.PERMISSION_GRANTED
    val coarseGranted =
            ContextCompat.checkSelfPermission(this, Manifest.permission.ACCESS_COARSE_LOCATION) ==
                    PackageManager.PERMISSION_GRANTED
    return fineGranted || coarseGranted
  }

  private fun hasBackgroundPermission(): Boolean {
    return if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
      true
    } else {
      ContextCompat.checkSelfPermission(this, Manifest.permission.ACCESS_BACKGROUND_LOCATION) ==
              PackageManager.PERMISSION_GRANTED
    }
  }

  private fun ensureNotificationChannel() {
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
    val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
    val channel =
            NotificationChannel(CHANNEL_ID, "Location Tracking", NotificationManager.IMPORTANCE_LOW)
    manager.createNotificationChannel(channel)
  }

  private fun buildNotification(): Notification {
    val notificationIntent = Intent(this, MainActivity::class.java)
    val flags =
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
              PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            } else {
              PendingIntent.FLAG_UPDATE_CURRENT
            }
    val pendingIntent = PendingIntent.getActivity(this, 0, notificationIntent, flags)

    return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Pharmo байршлыг дамжуулж байна")
            .setContentText(
                    "Таны байршлыг хүргэлтийн явцыг шинэчлэх, ирэх цагийг тооцоолоход ашигладаг."
            )
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentIntent(pendingIntent)
            .setOngoing(true)
            .setCategory(NotificationCompat.CATEGORY_SERVICE)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .build()
  }

  companion object {
    private const val CHANNEL_ID = "pharmo_bg_location"
    private const val NOTIFICATION_ID = 0x444
    private const val LOCATION_INTERVAL_MS = 5_000L
    private const val LOCATION_MIN_DISTANCE_M = 10f

    @Volatile private var eventSink: EventChannel.EventSink? = null

    fun setEventSink(sink: EventChannel.EventSink?) {
      eventSink = sink
    }
  }
}
