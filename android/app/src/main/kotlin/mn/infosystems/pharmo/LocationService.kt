// ============================================
// FINAL FIXED LOCATION SERVICE
// isRunningFlag added + EventSink synchronization
// ============================================

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
import kotlin.math.sqrt

class LocationService : Service(), LocationListener {

    private lateinit var locationManager: LocationManager
    private var isUpdating = false
    private var wakeLock: PowerManager.WakeLock? = null

    // Filtering components
    private val kalmanFilter = KalmanLocationFilter()
    private val locationFilter = LocationFilterValidator()
    private var lastAcceptedLocation: FilteredLocation? = null
    private var lastBroadcastTime = 0L
    private var consecutiveTurnCount = 0

    // Statistics
    private var totalReceived = 0
    private var totalAccepted = 0
    private var totalRejected = 0

    // ================= CONFIGURATION =================
    companion object {
        private const val TAG = "LocationService"
        private const val CHANNEL_ID = "pharmo_bg_location"
        private const val NOTIFICATION_ID = 0x444

        // Filter settings
        private const val MAX_ACCURACY_METERS = 25f
        private const val MIN_DISTANCE_METERS = 6f
        private const val MIN_TIME_BETWEEN_UPDATES_MS = 2000L
        private const val MIN_TIME_DURING_TURN_MS = 1000L
        private const val GPS_DRIFT_THRESHOLD = 8f
        private const val TURN_BEARING_THRESHOLD = 22f  // degrees — significant direction change

        // Speed thresholds (m/s) — tuned for Ulaanbaatar city traffic
        private const val HIGH_SPEED_THRESHOLD = 13.9f   // 50 km/h  (ring road / Peace Ave)
        private const val MEDIUM_SPEED_THRESHOLD = 5.6f  // 20 km/h  (normal city flow)
        private const val LOW_SPEED_THRESHOLD = 1.4f     // 5 km/h   (heavy traffic / seller walking)
        private const val MIN_SPEED_THRESHOLD = 0.4f     // ~1.5 km/h (near-stationary)

        // Distance thresholds (m) — UB: most time spent at 5–20 km/h
        // Driver (car): normalSpeed range covers most UB traffic
        // Seller (foot or car): walkingSpeed covers on-foot delivery
        private const val HIGH_SPEED_DISTANCE = 60f      // 50+ km/h  → ~4 s interval
        private const val MEDIUM_SPEED_DISTANCE = 30f    // 20–50 km/h → ~4 s interval
        private const val NORMAL_SPEED_DISTANCE = 12f    // 5–20 km/h  → ~4 s in traffic
        private const val WALKING_SPEED_DISTANCE = 6f    // <5 km/h    → seller on foot

        @Volatile 
        private var eventSink: EventChannel.EventSink? = null

        @Volatile
        private var isRunningFlag = false

        @Synchronized
        fun setEventSink(sink: EventChannel.EventSink?) {
            eventSink = sink
            Log.d(TAG, if (sink != null) {
                "✅ EventSink SET (not null)"
            } else {
                "⚠️ EventSink CLEARED (null)"
            })
        }
        
        fun isRunning(): Boolean = isRunningFlag
        
        fun hasEventSink(): Boolean = eventSink != null
    }

    // ================= SERVICE LIFECYCLE =================
  
    override fun onCreate() {
        super.onCreate()
        locationManager = getSystemService(Context.LOCATION_SERVICE) as LocationManager
        ensureNotificationChannel()
        Log.i(TAG, "LocationService created")
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.i(TAG, "LocationService starting...")
        
        // ✅ CRITICAL: Set running flag
        isRunningFlag = true
        Log.i(TAG, "✅ isRunningFlag = true")
        
        // Wait a bit for EventSink to be set
        android.os.Handler(android.os.Looper.getMainLooper()).postDelayed({
            if (eventSink == null) {
                Log.w(TAG, "⚠️ EventSink still null after 200ms")
                Log.w(TAG, "Make sure EventChannel.listen() is called BEFORE starting service")
            } else {
                Log.i(TAG, "✅ EventSink confirmed ready")
            }
        }, 200)
        
        startForegroundServiceInternal()
        acquireWakeLock()
        startLocationUpdates()
        
        Log.i(TAG, "LocationService fully started")
        return START_STICKY
    }

    override fun onDestroy() {
        Log.i(TAG, "LocationService destroying...")
        
        // ✅ CRITICAL: Clear running flag
        isRunningFlag = false
        Log.i(TAG, "✅ isRunningFlag = false")
        
        stopLocationUpdates()
        releaseWakeLock()
        setEventSink(null)
        logStatistics()
        
        Log.i(TAG, "LocationService destroyed")
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null

    // ================= MAIN LOCATION CALLBACK =================

    override fun onLocationChanged(location: Location) {
        totalReceived++

        // ✅ Better EventSink check with detailed logging
        val sink = eventSink
        if (sink == null) {
            // Only log every 10th attempt to avoid spam
            if (totalReceived % 10 == 1) {
                Log.w(TAG, """
                    ⚠️ EventSink is NULL (attempt $totalReceived)
                    - Service running: $isRunningFlag
                    - Total received: $totalReceived
                    - Total ignored: $totalReceived
                    ⚠️ Call EventChannel.listen() BEFORE starting service!
                """.trimIndent())
            }
            return
        }

        // Process location through filtering pipeline
        val result = processLocation(location)

        when (result) {
            is FilterResult.Accepted -> {
                totalAccepted++
                broadcastLocation(result.location, sink)
                logAcceptance(result.location, result.reason)
            }
            is FilterResult.Rejected -> {
                totalRejected++
                logRejection(result.reason)
            }
        }

        // Log stats every 50 locations
        if (totalReceived % 50 == 0) {
            logStatistics()
        }
    }

    // ================= FILTERING PIPELINE =================

    private fun processLocation(rawLocation: Location): FilterResult {
        // STEP 1: Accuracy validation
        if (!locationFilter.isAccuracyValid(rawLocation)) {
            return FilterResult.Rejected(
                "Poor accuracy: ${rawLocation.accuracy.toInt()}m > ${MAX_ACCURACY_METERS.toInt()}m"
            )
        }

        // STEP 2: Apply Kalman filter for smoothing
        val smoothedLocation = kalmanFilter.filter(rawLocation)

        // STEP 3: First location - always accept
        val previous = lastAcceptedLocation
        if (previous == null) {
            val filtered = FilteredLocation(smoothedLocation)
            lastAcceptedLocation = filtered
            lastBroadcastTime = System.currentTimeMillis()
            return FilterResult.Rejected("WARM UP: First location")
            // return FilterResult.Accepted(filtered, "First location accepted")
        }

        // STEP 4: Turn / roundabout detection
        val turning = isTurnDetected(previous.location, smoothedLocation)
        if (turning) consecutiveTurnCount++ else consecutiveTurnCount = 0
        val onCircularPath = consecutiveTurnCount >= 3   // likely roundabout

        // STEP 5: Time-based throttling
        val now = System.currentTimeMillis()
        val timeDelta = now - lastBroadcastTime
        val minTime = if (turning || onCircularPath) MIN_TIME_DURING_TURN_MS else MIN_TIME_BETWEEN_UPDATES_MS
        if (timeDelta < minTime) {
            return FilterResult.Rejected(
                "Too frequent: ${timeDelta}ms < ${minTime}ms"
            )
        }

        // STEP 6: Distance validation
        val distance = smoothedLocation.distanceTo(previous.location)

        // GPS drift check only when stationary and not turning
        if (!turning && smoothedLocation.hasSpeed() && smoothedLocation.speed < MIN_SPEED_THRESHOLD) {
            if (distance < GPS_DRIFT_THRESHOLD) {
                return FilterResult.Rejected(
                    "GPS drift: ${distance.toInt()}m (stationary)"
                )
            }
        }

        // Distance threshold — skipped entirely during turns/roundabouts.
        // On a curve the chord is shorter than the arc, so distance-based
        // filtering drops valid points and makes paths look angular.
        if (!turning && !onCircularPath) {
            val requiredDistance = calculateDynamicDistance(smoothedLocation.speed)
            if (distance < requiredDistance) {
                return FilterResult.Rejected(
                    "Insufficient distance: ${distance.toInt()}m < ${requiredDistance.toInt()}m"
                )
            }
        }

        // STEP 7: Speed validation (GPS jump detection)
        val speedResult = locationFilter.validateSpeed(previous.location, smoothedLocation, timeDelta)
        if (!speedResult.isValid) {
            return FilterResult.Rejected(speedResult.reason ?: "Invalid speed")
        }

        // STEP 8: All checks passed!
        val filtered = FilteredLocation(smoothedLocation)
        lastAcceptedLocation = filtered
        lastBroadcastTime = now

        val mode = when {
            onCircularPath -> "roundabout"
            turning -> "turn"
            else -> "straight"
        }
        return FilterResult.Accepted(
            filtered,
            "$mode: ${distance.toInt()}m, ${(smoothedLocation.speed * 3.6f).toInt()} km/h"
        )
    }

    // ================= TURN DETECTION =================

    private fun isTurnDetected(previous: Location, current: Location): Boolean {
        // Require minimum distance to reliably compute a bearing from coordinates
        val dist = current.distanceTo(previous)
        if (dist < 3f) return false

        // Direction computed from actual coordinates — reliable regardless of GPS bearing
        val coordBearing = previous.bearingTo(current)

        // Compare against the GPS-reported bearing at the last accepted point (direction we arrived)
        if (previous.hasBearing()) {
            if (bearingDiff(previous.bearing, coordBearing) >= TURN_BEARING_THRESHOLD) return true
        }
        // Fallback: compare two GPS-reported bearings if both available
        if (previous.hasBearing() && current.hasBearing()) {
            if (bearingDiff(previous.bearing, current.bearing) >= TURN_BEARING_THRESHOLD) return true
        }
        return false
    }

    private fun bearingDiff(a: Float, b: Float): Float {
        val diff = Math.abs(a - b)
        return if (diff > 180f) 360f - diff else diff
    }

    // ================= DYNAMIC DISTANCE CALCULATOR =================

    private fun calculateDynamicDistance(speedMs: Float): Float {
        return when {
            speedMs >= HIGH_SPEED_THRESHOLD -> HIGH_SPEED_DISTANCE
            speedMs >= MEDIUM_SPEED_THRESHOLD -> MEDIUM_SPEED_DISTANCE
            speedMs >= LOW_SPEED_THRESHOLD -> NORMAL_SPEED_DISTANCE
            else -> WALKING_SPEED_DISTANCE
        }
    }

    // ================= BROADCAST TO FLUTTER =================

    private fun broadcastLocation(filtered: FilteredLocation, sink: EventChannel.EventSink) {
        val loc = filtered.location

        try {
            sink.success(
                mapOf(
                    "lat" to loc.latitude,
                    "lng" to loc.longitude,
                    "accuracy" to loc.accuracy,
                    "speed" to loc.speed,
                    "time" to loc.time,
                    "heading" to if (loc.hasBearing()) loc.bearing else 0f,
                    // Debug info
                    "filtered" to true,
                    "accept_rate" to (totalAccepted.toFloat() / totalReceived)
                )
            )

            // Log.d(TAG, "✅ Location broadcast: (${loc.latitude}, ${loc.longitude})")
            
        } catch (e: Exception) {
            Log.e(TAG, "❌ Failed to broadcast location", e)
        }
    }

    // ================= LOCATION CONTROL =================

    @SuppressLint("MissingPermission")
    private fun startLocationUpdates() {
        if (isUpdating) {
            Log.w(TAG, "Location updates already running")
            return
        }
        
        isUpdating = true

        // Request updates from GPS provider
        locationManager.requestLocationUpdates(
            LocationManager.GPS_PROVIDER,
            1000L, // OS filter: 1 second (we filter in app)
            0f, // No OS distance filter (we filter in app)
            this
        )

        Log.i(TAG, "✅ Location updates started with Kalman filtering")
    }

    private fun stopLocationUpdates() {
        if (!isUpdating) return
        
        locationManager.removeUpdates(this)
        isUpdating = false
        lastAcceptedLocation = null
        consecutiveTurnCount = 0
        kalmanFilter.reset()
        
        Log.i(TAG, "✅ Location updates stopped")
    }

    // ================= LOGGING & STATISTICS =================

    private fun logAcceptance(location: FilteredLocation, reason: String) {
        val speedKmh = (location.location.speed * 3.6f).toInt()
        // Log.d(
        //     TAG,
        //     "✅ ACCEPTED: $reason | Speed: ${speedKmh}km/h | Acc: ${location.location.accuracy.toInt()}m"
        // )
    }

    private fun logRejection(reason: String) {
        // Log.d(TAG, "❌ REJECTED: $reason")
    }

    private fun logStatistics() {
        val acceptRate = if (totalReceived > 0) {
            (totalAccepted.toFloat() / totalReceived * 100).toInt()
        } else {
            0
        }

        Log.i(
            TAG,
            """
            📊 STATISTICS:
            ═══════════════════════════════
            Total received: $totalReceived
            Accepted: $totalAccepted
            Rejected: $totalRejected
            Accept rate: $acceptRate%
            EventSink: ${if (eventSink != null) "✅ SET" else "❌ NULL"}
            Service running: ${if (isRunningFlag) "✅ YES" else "❌ NO"}
            ═══════════════════════════════
        """.trimIndent()
        )
    }

    // ================= NOTIFICATION =================

    private fun ensureNotificationChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return

        val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        val channel = NotificationChannel(
            CHANNEL_ID,
            "Байршил дамжуулалт",
            NotificationManager.IMPORTANCE_LOW
        ).apply {
            description = "Хүргэлтийн байршил дамжуулж байна"
            setShowBadge(false)
        }
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
        
        Log.i(TAG, "✅ Foreground service started")
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
            .setContentTitle("Pharmo хүргэлт")
            .setContentText("Байршил дамжуулж байна...")
            .setSmallIcon(android.R.drawable.ic_menu_mylocation)
            .setContentIntent(pendingIntent)
            .setOngoing(true)
            .setSilent(true)
            .setCategory(NotificationCompat.CATEGORY_SERVICE)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .build()
    }

    // ================= WAKE LOCK =================

    @SuppressLint("WakelockTimeout")
    private fun acquireWakeLock() {
        if (wakeLock?.isHeld == true) {
            Log.w(TAG, "WakeLock already held")
            return
        }

        val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
        wakeLock = powerManager.newWakeLock(
            PowerManager.PARTIAL_WAKE_LOCK,
            "$TAG::LocationTracking"
        ).apply {
            acquire()
            Log.d(TAG, "✅ WakeLock acquired")
        }
    }

    private fun releaseWakeLock() {
        wakeLock?.takeIf { it.isHeld }?.release()
        wakeLock = null
        Log.d(TAG, "✅ WakeLock released")
    }

    // ================= LOCATION PROVIDER CALLBACKS =================

    override fun onProviderEnabled(provider: String) {
        Log.i(TAG, "✅ Provider enabled: $provider")
    }

    override fun onProviderDisabled(provider: String) {
        Log.w(TAG, "⚠️ Provider disabled: $provider")
    }
}


class KalmanLocationFilter {
    private var lat = 0.0
    private var lng = 0.0
    private var variance = -1.0

    private var speed = 0.0
    private var speedVariance = -1.0

    companion object {
        private const val PROCESS_NOISE = 10.0        // ~26% gain — tracks curves without cutting corners
        private const val SPEED_PROCESS_NOISE = 3.0
        private const val DEFAULT_SPEED_ACCURACY = 2.0
    }

    fun filter(measurement: Location): Location {
        val rawSpeed = if (measurement.hasSpeed() && measurement.speed >= 0) {
            measurement.speed.toDouble()
        } else {
            0.0
        }
        val speedAccuracy = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O &&
            measurement.hasSpeedAccuracy() && measurement.speedAccuracyMetersPerSecond > 0
        ) {
            measurement.speedAccuracyMetersPerSecond.toDouble()
        } else {
            DEFAULT_SPEED_ACCURACY
        }
        val speedMeasurementVariance = speedAccuracy * speedAccuracy

        if (variance < 0) {
            lat = measurement.latitude
            lng = measurement.longitude
            variance = (measurement.accuracy * measurement.accuracy).toDouble()
            speed = rawSpeed
            speedVariance = speedMeasurementVariance
        } else {
            // Position
            val predictionVariance = variance + PROCESS_NOISE
            val measurementVariance = (measurement.accuracy * measurement.accuracy).toDouble()
            val kalmanGain = predictionVariance / (predictionVariance + measurementVariance)
            lat += kalmanGain * (measurement.latitude - lat)
            lng += kalmanGain * (measurement.longitude - lng)
            variance = (1 - kalmanGain) * predictionVariance

            // Speed
            val speedPredictionVariance = speedVariance + SPEED_PROCESS_NOISE
            val speedGain = speedPredictionVariance / (speedPredictionVariance + speedMeasurementVariance)
            speed += speedGain * (rawSpeed - speed)
            speedVariance = (1 - speedGain) * speedPredictionVariance
        }

        val smoothedSpeed = speed
        return Location(measurement).apply {
            latitude = lat
            longitude = lng
            accuracy = sqrt(variance).toFloat()
            this.speed = maxOf(0.0, smoothedSpeed).toFloat()
        }
    }

    fun reset() {
        variance = -1.0
        speedVariance = -1.0
    }
}

// ============================================
// LOCATION FILTER VALIDATOR
// ============================================

class LocationFilterValidator {
    companion object {
        private const val MAX_ACCURACY = 25f
        private const val MAX_SPEED_MS = 33.3f // 120 km/h — UB max road speed is 80 km/h
    }

    fun isAccuracyValid(location: Location): Boolean {
        return location.accuracy > 0 && location.accuracy <= MAX_ACCURACY
    }

    fun validateSpeed(
        previous: Location,
        current: Location,
        timeDeltaMs: Long
    ): ValidationResult {
        if (timeDeltaMs <= 0) {
            return ValidationResult(false, "Invalid time delta")
        }

        val distance = current.distanceTo(previous)
        val timeDeltaSec = timeDeltaMs / 1000f
        val calculatedSpeed = distance / timeDeltaSec

        // Check for GPS jump (unrealistic speed)
        if (calculatedSpeed > MAX_SPEED_MS) {
            val speedKmh = (calculatedSpeed * 3.6f).toInt()
            return ValidationResult(
                false,
                "GPS jump: ${speedKmh}km/h (max: ${(MAX_SPEED_MS * 3.6f).toInt()}km/h)"
            )
        }

        return ValidationResult(true, null)
    }
}

data class ValidationResult(val isValid: Boolean, val reason: String?)

// ============================================
// DATA CLASSES
// ============================================

data class FilteredLocation(
    val location: Location,
    val timestamp: Long = System.currentTimeMillis()
)

sealed class FilterResult {
    data class Accepted(
        val location: FilteredLocation,
        val reason: String
    ) : FilterResult()

    data class Rejected(
        val reason: String
    ) : FilterResult()
}

