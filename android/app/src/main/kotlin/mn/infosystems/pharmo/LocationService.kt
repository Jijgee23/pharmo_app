package mn.infosystems.pharmo

import android.annotation.SuppressLint
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
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

    // Тохиргооны тогтмолууд
    private val MIN_TIME_BW_UPDATES = 3000L // 3 секундээс хурдан шинэчлэхгүй
    private val MIN_DISTANCE_CHANGE_FOR_UPDATES = 10f // OS-д өгөх доод хязгаар (10 метр)
    private val MAX_ALLOWED_ACCURACY = 30f // 30 метрээс их алдаатайг тоохгүй
    private val MIN_SPEED_THRESHOLD = 0.5f // 0.5 м/с (1.8 км/ц)-аас бага бол зогссон гэж үзнэ

    override fun onCreate() {
        super.onCreate()
        locationManager = getSystemService(Context.LOCATION_SERVICE) as LocationManager
        ensureNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        updateForegroundNotification()
        startLocationUpdates()
        return START_STICKY
    }

    // ... (Notification хэсэг хэвээрээ) ...
    private fun ensureNotificationChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        val channel =
                NotificationChannel(
                        CHANNEL_ID,
                        "Location Tracking",
                        NotificationManager.IMPORTANCE_LOW
                )
        manager.createNotificationChannel(channel)
    }

    private fun updateForegroundNotification() {
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
                .setContentText("Байршлыг хянаж байна...")
                .setSmallIcon(R.drawable.ic_notification) // Та өөрийн icon-оо тааруулаарай
                .setContentIntent(pendingIntent)
                .setOngoing(true)
                .setCategory(NotificationCompat.CATEGORY_SERVICE)
                .setPriority(NotificationCompat.PRIORITY_LOW)
                .build()
    }

    override fun onDestroy() {
        super.onDestroy()
        stopLocationUpdates()
        setEventSink(null)
    }

    override fun onBind(intent: Intent?): IBinder? = null

    // ---------------------------------------------------------
    // ГОЛ ӨӨРЧЛӨЛТҮҮД ЭНД БАЙНА
    // ---------------------------------------------------------

    override fun onLocationChanged(location: Location) {
        if (eventSink == null) return

        // 1. Нарийвчлал шалгах (Accuracy Check)
        // Хэрэв байршлын алдаа нь 30 метрээс их бол шууд хаяна.
        if (location.accuracy > MAX_ALLOWED_ACCURACY) {
            return
        }

        val previous = lastBroadcastLocation

        // 2. Анхны байршил бол шууд авна
        if (previous == null) {
            broadcastLocation(location)
            return
        }

        // 3. Цаг хугацааны шалгуур (Time Check)
        // Өмнөх мэдээллээс хойш хэт богино хугацаа өнгөрсөн бол авахгүй (OS заримдаа дараалж өгдөг)
        val timeDelta = location.time - previous.time
        if (timeDelta < 2000) { // 2 секунд
            return
        }

        val latitudeNotChanged = location.latitude == previous.latitude
        val longitudeNotChanged = location.longitude == previous.longitude

        if (latitudeNotChanged && longitudeNotChanged ) {
            return
        }
        
        // 4. Зайн болон Хурдны шалгуур (Distance & Speed Smart Check)
        val distance = location.distanceTo(previous)

        // Хэрэв төхөөрөмж хурдны мэдээлэл өгсөн бөгөөд тэр нь маш бага бол (зогсож байна)
        // ГЭВЧ зай нь 5-10 метр зөрөөтэй байвал энэ нь GPS Drift юм. Шинэчлэхгүй.
        if (location.hasSpeed() && location.speed < MIN_SPEED_THRESHOLD) {
            // Гэхдээ хэрэв зай нь үнэхээр хол (жишээ нь 20м) үсэрсэн бол
            // магадгүй машин зогсоод хөдөлсөн байж болно.
            if (distance < 20f) {
                return // Зогсож байгаа үеийн хэлбэлзэл гэж үзнэ
            }
        }

        // Хэрэв зай нь дор хаяж 10 метр өөрчлөгдсөн бол шинэчилнэ
        if (distance >= MIN_DISTANCE_CHANGE_FOR_UPDATES) {
            broadcastLocation(location)
        }
    }

    private fun broadcastLocation(location: Location) {
        lastBroadcastLocation = location
        // Flutter тал руу явуулах
        eventSink?.success(
                mapOf(
                        "lat" to location.latitude,
                        "lng" to location.longitude,
                        "acc" to location.accuracy,
                        "spd" to location.speed, // Хурдыг бас явуулах нь зүгээр
                        "time" to location.time
                )
        )
    }

    @SuppressLint("MissingPermission")
    private fun startLocationUpdates() {
        if (isUpdating) return
        isUpdating = true

        // ӨӨРЧЛӨЛТ: 0, 0 гэхийн оронд тодорхой хязгаар тавьж өгөх
        // Энэ нь OS-д "Битгий зайгүй бүх мэдээг өг, бага зэрэг шүүж өг" гэж хэлж байна.
        locationManager.requestLocationUpdates(
                LocationManager.GPS_PROVIDER,
                MIN_TIME_BW_UPDATES, // Доод тал нь 3 секунд
                MIN_DISTANCE_CHANGE_FOR_UPDATES, // Доод тал нь 10 метр
                this
        )
    }

    // ... (Бусад функцууд хэвээрээ) ...

    override fun onProviderEnabled(provider: String) {}
    override fun onProviderDisabled(provider: String) {}

    private fun stopLocationUpdates() {
        if (!isUpdating) return
        locationManager.removeUpdates(this)
        isUpdating = false
        lastBroadcastLocation = null
    }

    // ... (Companion object хэвээрээ) ...
    companion object {
        private const val CHANNEL_ID = "pharmo_bg_location"
        private const val NOTIFICATION_ID = 0x444
        @Volatile private var eventSink: EventChannel.EventSink? = null
        fun setEventSink(sink: EventChannel.EventSink?) {
            eventSink = sink
        }
    }
}
