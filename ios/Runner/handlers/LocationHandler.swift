
import CoreLocation
import Flutter
import Foundation
import os.log

class LocationHandler: NSObject, CLLocationManagerDelegate, FlutterStreamHandler {

    private var locationManager: CLLocationManager = CLLocationManager()
    private var eventSink: FlutterEventSink?

    // Filtering components
    private var kalmanFilter = KalmanLocationFilter()
    private var lastAcceptedLocation: FilteredLocation?
    private var lastBroadcastTime: Date?

    // Statistics
    private var totalReceived = 0
    private var totalAccepted = 0
    private var totalRejected = 0

    // ✅ Match Android: @Volatile private var isRunningFlag = false
    private static var isRunningFlagLock = NSLock()
    private static var _isRunningFlag = false
    
    // ✅ Match Android: @Volatile private var eventSink: EventChannel.EventSink? = null
    private static var sharedEventSinkLock = NSLock()
    private static var _sharedEventSink: FlutterEventSink?

    // Configuration - EXACTLY synchronized with Android
    private let maxAccuracyMeters: CLLocationAccuracy = 30.0
    private let minDistanceMeters: CLLocationDistance = 10.0
    private let minTimeBetweenUpdatesSeconds: TimeInterval = 3.0
    private let gpsDriftThreshold: CLLocationDistance = 12.0

    // Speed thresholds (m/s) - EXACT match with Android
    private let highSpeedThreshold: CLLocationSpeed = 16.7  // 60 km/h
    private let mediumSpeedThreshold: CLLocationSpeed = 8.3  // 30 km/h
    private let lowSpeedThreshold: CLLocationSpeed = 2.8  // 10 km/h
    private let minSpeedThreshold: CLLocationSpeed = 0.5  // 1.8 km/h

    // Distance thresholds - EXACT match with Android
    private let highSpeedDistance: CLLocationDistance = 200.0
    private let mediumSpeedDistance: CLLocationDistance = 100.0
    private let normalSpeedDistance: CLLocationDistance = 50.0
    private let walkingSpeedDistance: CLLocationDistance = 15.0

    // GPS jump detection - EXACT match with Android
    private let maxSpeedMs: CLLocationSpeed = 50.0  // 180 km/h
    private let maxAccuracyForValidation: CLLocationAccuracy = 20.0 // Match Android: MAX_ACCURACY = 20f

    private let logger = OSLog(subsystem: "mn.infosystems.pharmo", category: "LocationTracking")

    override init() {
        super.init()
        setupLocationManager()
    }

    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.activityType = .automotiveNavigation

        if #available(iOS 11.0, *) {
            locationManager.showsBackgroundLocationIndicator = true
        }

        os_log("✅ LocationManager configured", log: logger, type: .info)
    }

    // ================= STATIC METHODS - EXACT MATCH WITH Android companion object =================

    // Match Android: fun isRunning(): Boolean = isRunningFlag
    static func isRunning() -> Bool {
        isRunningFlagLock.lock()
        defer { isRunningFlagLock.unlock() }
        return _isRunningFlag
    }
    
    private static func setRunning(_ value: Bool) {
        isRunningFlagLock.lock()
        defer { isRunningFlagLock.unlock() }
        _isRunningFlag = value
    }

    // Match Android: @Synchronized fun setEventSink(sink: EventChannel.EventSink?)
    @objc static func setEventSink(_ sink: FlutterEventSink?) {
        sharedEventSinkLock.lock()
        defer { sharedEventSinkLock.unlock() }
        _sharedEventSink = sink
        print(sink != nil ? "✅ EventSink SET (not null)" : "⚠️ EventSink CLEARED (null)")
    }
    
    private static func getEventSink() -> FlutterEventSink? {
        sharedEventSinkLock.lock()
        defer { sharedEventSinkLock.unlock() }
        return _sharedEventSink
    }

    // Match Android: fun hasEventSink(): Boolean = eventSink != null
    static func hasEventSink() -> Bool {
        return getEventSink() != nil
    }

    // Match Android: LocationService.setEventSink(null)
    @objc static func clearEventSink() {
        setEventSink(nil)
    }

    // ================= FLUTTER STREAM HANDLER - MATCH Android onListen/onCancel =================

    func onListen(
        withArguments arguments: Any?,
        eventSink events: @escaping FlutterEventSink
    ) -> FlutterError? {
        os_log("📡 onListen called - Setting EventSink", log: logger, type: .info)

        // ✅ Match Android: eventSink = events
        self.eventSink = events
        LocationHandler.setEventSink(events)

        // ✅ Match Android: isRunningFlag = true
        LocationHandler.setRunning(true)
        os_log("✅ isRunningFlag = true", log: logger, type: .info)

        // ✅ Match Android: Wait a bit for EventSink confirmation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            if !LocationHandler.hasEventSink() {
                os_log("⚠️ EventSink still null after 200ms", log: self.logger, type: .error)
                os_log("Make sure EventChannel.listen() is called BEFORE starting service", log: self.logger, type: .error)
            } else {
                os_log("✅ EventSink confirmed ready", log: self.logger, type: .info)
            }
        }

        // Reset filters (match Android onCreate behavior)
        kalmanFilter.reset()
        lastAcceptedLocation = nil
        lastBroadcastTime = nil
        totalReceived = 0
        totalAccepted = 0
        totalRejected = 0

        // Request authorization
        locationManager.requestAlwaysAuthorization()

        // Start location updates (match Android startLocationUpdates)
        locationManager.startMonitoringSignificantLocationChanges()
        locationManager.startUpdatingLocation()

        os_log("✅ iOS Location tracking started", log: logger, type: .info)

        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        os_log("🛑 onCancel called", log: logger, type: .info)

        // ✅ Match Android: isRunningFlag = false
        LocationHandler.setRunning(false)
        os_log("✅ isRunningFlag = false", log: logger, type: .info)

        // Stop location updates (match Android stopLocationUpdates)
        locationManager.stopUpdatingLocation()
        locationManager.stopMonitoringSignificantLocationChanges()

        // Log final statistics (match Android onDestroy)
        logStatistics()

        // ✅ Match Android: setEventSink(null)
        LocationHandler.setEventSink(nil)
        self.eventSink = nil
        self.lastAcceptedLocation = nil
        self.lastBroadcastTime = nil

        os_log("✅ iOS Location tracking stopped", log: logger, type: .info)

        return nil
    }

    // ================= BACKGROUND MONITORING =================

    func startMonitoringForBackground() {
        os_log("📱 Starting background location monitoring", log: logger, type: .info)
        locationManager.startMonitoringSignificantLocationChanges()
    }

    // ================= LOCATION DELEGATE - EXACT MATCH WITH Android onLocationChanged =================

    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        totalReceived += 1

        // ✅ Match Android: val sink = eventSink; if (sink == null)
        let sink = self.eventSink ?? LocationHandler.getEventSink()
        
        if sink == nil {
            // Match Android: Only log every 10th attempt to avoid spam
            if totalReceived % 10 == 1 {
                os_log(
                    """
                    ⚠️ EventSink is NULL (attempt %d)
                    - Service running: %{public}@
                    - Total received: %d
                    - Total ignored: %d
                    ⚠️ Call EventChannel.listen() BEFORE starting service!
                    """,
                    log: logger,
                    type: .error,
                    totalReceived,
                    LocationHandler.isRunning() ? "YES" : "NO",
                    totalReceived,
                    totalReceived
                )
            }
            return
        }

        guard let rawLocation = locations.last else { return }

        // ✅ Match Android: Process location through filtering pipeline
        let result = processLocation(rawLocation)

        // ✅ Match Android: when (result) { is FilterResult.Accepted/Rejected }
        switch result {
        case .accepted(let filtered, let reason):
            totalAccepted += 1
            broadcastLocation(filtered, to: sink!)
            logAcceptance(filtered, reason: reason)

        case .rejected(let reason):
            totalRejected += 1
            logRejection(reason)
        }

        // Match Android: Log stats every 50 locations
        if totalReceived % 50 == 0 {
            logStatistics()
        }
    }

    // ================= FILTERING PIPELINE - EXACT MATCH WITH Android processLocation =================

    private func processLocation(_ rawLocation: CLLocation) -> FilterResult {
        // STEP 1: Accuracy validation (match Android)
        if !isAccuracyValid(rawLocation) {
            return .rejected(
                "Poor accuracy: \(Int(rawLocation.horizontalAccuracy))m > \(Int(maxAccuracyMeters))m"
            )
        }

        // STEP 2: Apply Kalman filter for smoothing (match Android)
        let smoothedLocation = kalmanFilter.filter(rawLocation)

        // STEP 3: First location - MATCH Android behavior (reject with WARM UP)
        guard let previous = lastAcceptedLocation else {
            let filtered = FilteredLocation(location: smoothedLocation)
            lastAcceptedLocation = filtered
            lastBroadcastTime = Date()
            // ✅ Match Android: return FilterResult.Rejected("WARM UP: First location")
            return .rejected("WARM UP: First location")
        }

        // STEP 4: Time-based throttling (match Android)
        let now = Date()
        if let lastTime = lastBroadcastTime {
            let timeDeltaMs = now.timeIntervalSince(lastTime) * 1000.0
            if timeDeltaMs < minTimeBetweenUpdatesSeconds * 1000.0 {
                return .rejected(
                    "Too frequent: \(Int(timeDeltaMs))ms < \(Int(minTimeBetweenUpdatesSeconds * 1000))ms"
                )
            }
        }

        // STEP 5: Distance validation (match Android)
        let distance = smoothedLocation.distance(from: previous.location)

        // GPS drift detection (stationary) - EXACT match with Android
        if smoothedLocation.speed >= 0 && smoothedLocation.speed < minSpeedThreshold {
            if distance < gpsDriftThreshold {
                return .rejected(
                    "GPS drift: \(Int(distance))m < \(Int(gpsDriftThreshold))m (stationary)"
                )
            }
        }

        // STEP 6: Speed-based distance threshold (match Android)
        let requiredDistance = calculateDynamicDistance(for: smoothedLocation.speed)
        if distance < requiredDistance {
            return .rejected(
                "Insufficient distance: \(Int(distance))m < \(Int(requiredDistance))m"
            )
        }

        // STEP 7: Speed validation (GPS jump detection) - EXACT match with Android
        if let lastTime = lastBroadcastTime {
            let timeDeltaMs = now.timeIntervalSince(lastTime) * 1000.0
            if timeDeltaMs > 0 {
                let speedResult = validateSpeed(
                    previous: previous.location,
                    current: smoothedLocation,
                    timeDeltaMs: timeDeltaMs
                )
                
                if !speedResult.isValid {
                    return .rejected(speedResult.reason ?? "Invalid speed")
                }
            }
        }

        // STEP 8: All checks passed! (match Android)
        let filtered = FilteredLocation(location: smoothedLocation)
        lastAcceptedLocation = filtered
        lastBroadcastTime = now

        let speedKmh = Int(smoothedLocation.speed * 3.6)
        return .accepted(
            filtered,
            "Valid: \(Int(distance))m, \(speedKmh) km/h"
        )
    }

    // ================= VALIDATION HELPERS - MATCH Android LocationFilterValidator =================

    private func isAccuracyValid(_ location: CLLocation) -> Bool {
        // Match Android: return location.accuracy > 0 && location.accuracy <= MAX_ACCURACY
        return location.horizontalAccuracy > 0 && location.horizontalAccuracy <= maxAccuracyForValidation
    }

    private func validateSpeed(
        previous: CLLocation,
        current: CLLocation,
        timeDeltaMs: Double
    ) -> ValidationResult {
        // Match Android: validateSpeed implementation
        if timeDeltaMs <= 0 {
            return ValidationResult(isValid: false, reason: "Invalid time delta")
        }

        let distance = current.distance(from: previous)
        let timeDeltaSec = timeDeltaMs / 1000.0
        let calculatedSpeed = distance / timeDeltaSec

        // Check for GPS jump (unrealistic speed)
        if calculatedSpeed > maxSpeedMs {
            let speedKmh = Int(calculatedSpeed * 3.6)
            let maxSpeedKmh = Int(maxSpeedMs * 3.6)
            return ValidationResult(
                isValid: false,
                reason: "GPS jump: \(speedKmh)km/h (max: \(maxSpeedKmh)km/h)"
            )
        }

        return ValidationResult(isValid: true, reason: nil)
    }

    private func calculateDynamicDistance(for speedMs: CLLocationSpeed) -> CLLocationDistance {
        // EXACT match with Android calculateDynamicDistance
        if speedMs >= highSpeedThreshold {
            return highSpeedDistance
        } else if speedMs >= mediumSpeedThreshold {
            return mediumSpeedDistance
        } else if speedMs >= lowSpeedThreshold {
            return normalSpeedDistance
        } else {
            return walkingSpeedDistance
        }
    }

    // ================= BROADCAST TO FLUTTER - EXACT MATCH WITH Android =================

    private func broadcastLocation(_ filtered: FilteredLocation, to sink: FlutterEventSink) {
        let location = filtered.location

        // ✅ Match Android map structure EXACTLY
        let locationData: [String: Any] = [
            "lat": location.coordinate.latitude,
            "lng": location.coordinate.longitude,
            "accuracy": location.horizontalAccuracy,
            "speed": location.speed,
            "time": Int64(location.timestamp.timeIntervalSince1970 * 1000),
            "heading": location.course >= 0 ? location.course : 0,
            // Debug info
            "filtered": true,
            "accept_rate": totalReceived > 0 ? Float(totalAccepted) / Float(totalReceived) : 0,
        ]

        sink(locationData)

        // Match Android: Commented out detailed log
        // os_log("✅ Location broadcast: (%f, %f)", log: logger, type: .debug, ...)
    }

    // ================= LOGGING & STATISTICS - EXACT MATCH WITH Android =================

    private func logAcceptance(_ location: FilteredLocation, reason: String) {
        let speedKmh = Int(location.location.speed * 3.6)
        let accuracy = Int(location.location.horizontalAccuracy)

        // Match Android: Commented out (can uncomment for debugging)
        // os_log("✅ ACCEPTED: %{public}@ | Speed: %dkm/h | Acc: %dm", ...)
    }

    private func logRejection(_ reason: String) {
        // Match Android: Commented out (can uncomment for debugging)
        // os_log("❌ REJECTED: %{public}@", ...)
    }

    private func logStatistics() {
        // ✅ EXACT match with Android logStatistics format
        let acceptRate =
            totalReceived > 0
            ? Int(Float(totalAccepted) / Float(totalReceived) * 100)
            : 0

        os_log(
            """
            📊 STATISTICS:
            ═══════════════════════════════
            Total received: %d
            Accepted: %d
            Rejected: %d
            Accept rate: %d%%
            EventSink: %{public}@
            Service running: %{public}@
            ═══════════════════════════════
            """,
            log: logger,
            type: .info,
            totalReceived,
            totalAccepted,
            totalRejected,
            acceptRate,
            LocationHandler.hasEventSink() ? "✅ SET" : "❌ NULL",
            LocationHandler.isRunning() ? "✅ YES" : "❌ NO"
        )
    }

    // ================= LOCATION MANAGER DELEGATE =================

    func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        os_log(
            "❌ Location error: %{public}@",
            log: logger,
            type: .error,
            error.localizedDescription
        )
    }

    func locationManager(
        _ manager: CLLocationManager,
        didChangeAuthorization status: CLAuthorizationStatus
    ) {
        let statusString: String
        switch status {
        case .notDetermined:
            statusString = "Not Determined"
        case .restricted:
            statusString = "Restricted"
        case .denied:
            statusString = "Denied"
        case .authorizedAlways:
            statusString = "Always Authorized ✅"
        case .authorizedWhenInUse:
            statusString = "When In Use"
        @unknown default:
            statusString = "Unknown"
        }

        os_log(
            "📍 Authorization changed: %{public}@",
            log: logger,
            type: .info,
            statusString
        )
    }
}

// ============================================
// KALMAN FILTER - EXACT MATCH WITH Android
// ============================================

class KalmanLocationFilter {
    private var lat: Double = 0.0
    private var lng: Double = 0.0
    private var variance: Double = -1.0
    
    // Match Android: private const val PROCESS_NOISE = 0.1
    private let processNoise: Double = 0.1

    func filter(_ measurement: CLLocation) -> CLLocation {
        if variance < 0 {
            // First measurement
            lat = measurement.coordinate.latitude
            lng = measurement.coordinate.longitude
            variance = Double(measurement.horizontalAccuracy * measurement.horizontalAccuracy)
        } else {
            // Predict
            let predictionVariance = variance + processNoise

            // Update
            let measurementVariance = Double(
                measurement.horizontalAccuracy * measurement.horizontalAccuracy
            )
            let kalmanGain = predictionVariance / (predictionVariance + measurementVariance)

            lat += kalmanGain * (measurement.coordinate.latitude - lat)
            lng += kalmanGain * (measurement.coordinate.longitude - lng)
            variance = (1 - kalmanGain) * predictionVariance
        }

        // Create filtered location
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        let filteredLocation = CLLocation(
            coordinate: coordinate,
            altitude: measurement.altitude,
            horizontalAccuracy: sqrt(variance),
            verticalAccuracy: measurement.verticalAccuracy,
            course: measurement.course,
            speed: measurement.speed,
            timestamp: measurement.timestamp
        )

        return filteredLocation
    }

    func reset() {
        variance = -1.0
    }
}

// ============================================
// DATA STRUCTURES - EXACT MATCH WITH Android
// ============================================

struct FilteredLocation {
    let location: CLLocation
    let timestamp: Date

    init(location: CLLocation) {
        self.location = location
        self.timestamp = Date()
    }
}

enum FilterResult {
    case accepted(FilteredLocation, String)
    case rejected(String)
}

// Match Android: data class ValidationResult
struct ValidationResult {
    let isValid: Bool
    let reason: String?
}