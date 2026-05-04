
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
    private var consecutiveTurnCount = 0

    // Statistics
    private var totalReceived = 0
    private var totalAccepted = 0
    private var totalRejected = 0

    private static var isRunningFlagLock = NSLock()
    private static var _isRunningFlag = false

    private static var sharedEventSinkLock = NSLock()
    private static var _sharedEventSink: FlutterEventSink?

    // Configuration — synchronized with Android
    private let maxAccuracyMeters: CLLocationAccuracy = 25.0
    private let minDistanceMeters: CLLocationDistance = 6.0
    private let minTimeBetweenUpdatesMs: Double = 2000.0
    private let minTimeDuringTurnMs: Double = 1000.0
    private let gpsDriftThreshold: CLLocationDistance = 8.0
    private let turnBearingThreshold: Double = 22.0   // degrees

    // Speed thresholds (m/s) — tuned for Ulaanbaatar city traffic
    private let highSpeedThreshold: CLLocationSpeed = 13.9
    private let mediumSpeedThreshold: CLLocationSpeed = 5.6
    private let lowSpeedThreshold: CLLocationSpeed = 1.4
    private let minSpeedThreshold: CLLocationSpeed = 0.4

    // Distance thresholds (m)
    private let highSpeedDistance: CLLocationDistance = 60.0
    private let mediumSpeedDistance: CLLocationDistance = 30.0
    private let normalSpeedDistance: CLLocationDistance = 12.0
    private let walkingSpeedDistance: CLLocationDistance = 6.0

    private let maxSpeedMs: CLLocationSpeed = 33.3
    private let maxAccuracyForValidation: CLLocationAccuracy = 25.0

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

    // ================= STATIC METHODS =================

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

    static func hasEventSink() -> Bool {
        return getEventSink() != nil
    }

    @objc static func clearEventSink() {
        setEventSink(nil)
    }

    // ================= FLUTTER STREAM HANDLER =================

    func onListen(
        withArguments arguments: Any?,
        eventSink events: @escaping FlutterEventSink
    ) -> FlutterError? {
        os_log("📡 onListen called - Setting EventSink", log: logger, type: .info)

        self.eventSink = events
        LocationHandler.setEventSink(events)
        LocationHandler.setRunning(true)
        os_log("✅ isRunningFlag = true", log: logger, type: .info)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            if !LocationHandler.hasEventSink() {
                os_log("⚠️ EventSink still null after 200ms", log: self.logger, type: .error)
            } else {
                os_log("✅ EventSink confirmed ready", log: self.logger, type: .info)
            }
        }

        kalmanFilter.reset()
        lastAcceptedLocation = nil
        lastBroadcastTime = nil
        consecutiveTurnCount = 0
        totalReceived = 0
        totalAccepted = 0
        totalRejected = 0

        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()

        os_log("✅ iOS Location tracking started", log: logger, type: .info)
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        os_log("🛑 onCancel called", log: logger, type: .info)

        LocationHandler.setRunning(false)
        os_log("✅ isRunningFlag = false", log: logger, type: .info)

        locationManager.stopUpdatingLocation()
        logStatistics()

        LocationHandler.setEventSink(nil)
        self.eventSink = nil
        self.lastAcceptedLocation = nil
        self.lastBroadcastTime = nil
        self.consecutiveTurnCount = 0

        os_log("✅ iOS Location tracking stopped", log: logger, type: .info)
        return nil
    }

    // ================= BACKGROUND MONITORING =================

    func startMonitoringForBackground() {
        locationManager.startMonitoringSignificantLocationChanges()
    }

    // ================= LOCATION DELEGATE =================

    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        totalReceived += 1

        let sink = self.eventSink ?? LocationHandler.getEventSink()

        if sink == nil {
            if totalReceived % 10 == 1 {
                os_log(
                    "⚠️ EventSink is NULL (attempt %d) - Total received: %d",
                    log: logger, type: .error,
                    totalReceived, totalReceived
                )
            }
            return
        }

        guard let rawLocation = locations.last else { return }

        let result = processLocation(rawLocation)

        switch result {
        case .accepted(let filtered, let reason):
            totalAccepted += 1
            broadcastLocation(filtered, to: sink!)
            logAcceptance(filtered, reason: reason)
        case .rejected(let reason):
            totalRejected += 1
            logRejection(reason)
        }

        if totalReceived % 50 == 0 {
            logStatistics()
        }
    }

    // ================= FILTERING PIPELINE =================

    private func processLocation(_ rawLocation: CLLocation) -> FilterResult {
        // STEP 1: Accuracy validation
        if !isAccuracyValid(rawLocation) {
            return .rejected(
                "Poor accuracy: \(Int(rawLocation.horizontalAccuracy))m > \(Int(maxAccuracyMeters))m"
            )
        }

        // STEP 2: Kalman filter
        let smoothedLocation = kalmanFilter.filter(rawLocation)

        // STEP 3: First location
        guard let previous = lastAcceptedLocation else {
            lastAcceptedLocation = FilteredLocation(location: smoothedLocation)
            lastBroadcastTime = Date()
            return .rejected("WARM UP: First location")
        }

        // STEP 4: Turn / roundabout detection
        let turning = isTurnDetected(previous: previous.location, current: smoothedLocation)
        if turning { consecutiveTurnCount += 1 } else { consecutiveTurnCount = 0 }
        let onCircularPath = consecutiveTurnCount >= 3

        // STEP 5: Time-based throttling
        let now = Date()
        if let lastTime = lastBroadcastTime {
            let timeDeltaMs = now.timeIntervalSince(lastTime) * 1000.0
            let minTime = (turning || onCircularPath) ? minTimeDuringTurnMs : minTimeBetweenUpdatesMs
            if timeDeltaMs < minTime {
                return .rejected("Too frequent: \(Int(timeDeltaMs))ms < \(Int(minTime))ms")
            }
        }

        // STEP 6: Distance validation
        let distance = smoothedLocation.distance(from: previous.location)

        // GPS drift check only when stationary and not turning
        if !turning && smoothedLocation.speed >= 0 && smoothedLocation.speed < minSpeedThreshold {
            if distance < gpsDriftThreshold {
                return .rejected("GPS drift: \(Int(distance))m (stationary)")
            }
        }

        // Distance threshold — skipped during turns/roundabouts.
        // On a curve the chord is shorter than the arc, so distance-based
        // filtering drops valid points and makes paths look angular.
        if !turning && !onCircularPath {
            let requiredDistance = calculateDynamicDistance(for: smoothedLocation.speed)
            if distance < requiredDistance {
                return .rejected(
                    "Insufficient distance: \(Int(distance))m < \(Int(requiredDistance))m"
                )
            }
        }

        // STEP 7: Speed validation (GPS jump detection)
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

        // STEP 8: All checks passed!
        lastAcceptedLocation = FilteredLocation(location: smoothedLocation)
        lastBroadcastTime = now

        let mode = onCircularPath ? "roundabout" : turning ? "turn" : "straight"
        let speedKmh = Int(smoothedLocation.speed * 3.6)
        return .accepted(
            lastAcceptedLocation!,
            "\(mode): \(Int(distance))m, \(speedKmh) km/h"
        )
    }

    // ================= TURN DETECTION =================

    private func isTurnDetected(previous: CLLocation, current: CLLocation) -> Bool {
        let dist = current.distance(from: previous)
        if dist < 3.0 { return false }

        // Bearing computed from actual coordinates — reliable regardless of GPS course
        let coordBearing = coordinateBearing(from: previous, to: current)

        // Compare against GPS course at last accepted point
        if previous.course >= 0 {
            if bearingDiff(previous.course, coordBearing) >= turnBearingThreshold { return true }
        }
        // Fallback: compare two GPS courses if both available
        if previous.course >= 0 && current.course >= 0 {
            if bearingDiff(previous.course, current.course) >= turnBearingThreshold { return true }
        }
        return false
    }

    private func bearingDiff(_ a: Double, _ b: Double) -> Double {
        let diff = abs(a - b)
        return diff > 180.0 ? 360.0 - diff : diff
    }

    // Equivalent to Android's Location.bearingTo()
    private func coordinateBearing(from: CLLocation, to: CLLocation) -> Double {
        let lat1 = from.coordinate.latitude * .pi / 180.0
        let lat2 = to.coordinate.latitude * .pi / 180.0
        let dLng = (to.coordinate.longitude - from.coordinate.longitude) * .pi / 180.0

        let y = sin(dLng) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLng)
        let bearing = atan2(y, x) * 180.0 / .pi
        return (bearing + 360.0).truncatingRemainder(dividingBy: 360.0)
    }

    // ================= DYNAMIC DISTANCE CALCULATOR =================

    private func calculateDynamicDistance(for speedMs: CLLocationSpeed) -> CLLocationDistance {
        if speedMs >= highSpeedThreshold { return highSpeedDistance }
        if speedMs >= mediumSpeedThreshold { return mediumSpeedDistance }
        if speedMs >= lowSpeedThreshold { return normalSpeedDistance }
        return walkingSpeedDistance
    }

    // ================= VALIDATION HELPERS =================

    private func isAccuracyValid(_ location: CLLocation) -> Bool {
        return location.horizontalAccuracy > 0 && location.horizontalAccuracy <= maxAccuracyForValidation
    }

    private func validateSpeed(
        previous: CLLocation,
        current: CLLocation,
        timeDeltaMs: Double
    ) -> ValidationResult {
        if timeDeltaMs <= 0 {
            return ValidationResult(isValid: false, reason: "Invalid time delta")
        }
        let distance = current.distance(from: previous)
        let timeDeltaSec = timeDeltaMs / 1000.0
        let calculatedSpeed = distance / timeDeltaSec

        if calculatedSpeed > maxSpeedMs {
            let speedKmh = Int(calculatedSpeed * 3.6)
            let maxKmh = Int(maxSpeedMs * 3.6)
            return ValidationResult(
                isValid: false,
                reason: "GPS jump: \(speedKmh)km/h (max: \(maxKmh)km/h)"
            )
        }
        return ValidationResult(isValid: true, reason: nil)
    }

    // ================= BROADCAST TO FLUTTER =================

    private func broadcastLocation(_ filtered: FilteredLocation, to sink: FlutterEventSink) {
        let location = filtered.location

        let locationData: [String: Any] = [
            "lat": location.coordinate.latitude,
            "lng": location.coordinate.longitude,
            "accuracy": location.horizontalAccuracy,
            "speed": location.speed,
            "time": Int64(location.timestamp.timeIntervalSince1970 * 1000),
            "heading": location.course >= 0 ? location.course : 0,
            "filtered": true,
            "accept_rate": totalReceived > 0 ? Float(totalAccepted) / Float(totalReceived) : 0,
        ]

        sink(locationData)
    }

    // ================= LOGGING & STATISTICS =================

    private func logAcceptance(_ location: FilteredLocation, reason: String) {
        // os_log("✅ ACCEPTED: %{public}@", log: logger, type: .debug, reason)
    }

    private func logRejection(_ reason: String) {
        // os_log("❌ REJECTED: %{public}@", log: logger, type: .debug, reason)
    }

    private func logStatistics() {
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
            log: logger, type: .info,
            totalReceived, totalAccepted, totalRejected, acceptRate,
            LocationHandler.hasEventSink() ? "✅ SET" : "❌ NULL",
            LocationHandler.isRunning() ? "✅ YES" : "❌ NO"
        )
    }

    // ================= LOCATION MANAGER DELEGATE =================

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        os_log("❌ Location error: %{public}@", log: logger, type: .error, error.localizedDescription)
    }

    func locationManager(
        _ manager: CLLocationManager,
        didChangeAuthorization status: CLAuthorizationStatus
    ) {
        let statusString: String
        switch status {
        case .notDetermined: statusString = "Not Determined"
        case .restricted: statusString = "Restricted"
        case .denied: statusString = "Denied"
        case .authorizedAlways: statusString = "Always Authorized ✅"
        case .authorizedWhenInUse: statusString = "When In Use"
        @unknown default: statusString = "Unknown"
        }
        os_log("📍 Authorization changed: %{public}@", log: logger, type: .info, statusString)
    }
}

// ============================================
// KALMAN FILTER
// ============================================

class KalmanLocationFilter {
    private var lat: Double = 0.0
    private var lng: Double = 0.0
    private var variance: Double = -1.0

    private var speed: Double = 0.0
    private var speedVariance: Double = -1.0

    private let processNoise: Double = 10.0    // ~26% gain — tracks curves without cutting corners
    private let speedProcessNoise: Double = 3.0

    func filter(_ measurement: CLLocation) -> CLLocation {
        let rawSpeed = measurement.speed >= 0 ? measurement.speed : 0.0
        let speedAccuracy = measurement.speedAccuracy > 0 ? measurement.speedAccuracy : 2.0
        let speedMeasurementVariance = speedAccuracy * speedAccuracy

        if variance < 0 {
            lat = measurement.coordinate.latitude
            lng = measurement.coordinate.longitude
            variance = measurement.horizontalAccuracy * measurement.horizontalAccuracy
            speed = rawSpeed
            speedVariance = speedMeasurementVariance
        } else {
            // Position
            let predictionVariance = variance + processNoise
            let measurementVariance = measurement.horizontalAccuracy * measurement.horizontalAccuracy
            let kalmanGain = predictionVariance / (predictionVariance + measurementVariance)
            lat += kalmanGain * (measurement.coordinate.latitude - lat)
            lng += kalmanGain * (measurement.coordinate.longitude - lng)
            variance = (1 - kalmanGain) * predictionVariance

            // Speed
            let speedPredictionVariance = speedVariance + speedProcessNoise
            let speedGain = speedPredictionVariance / (speedPredictionVariance + speedMeasurementVariance)
            speed += speedGain * (rawSpeed - speed)
            speedVariance = (1 - speedGain) * speedPredictionVariance
        }

        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        return CLLocation(
            coordinate: coordinate,
            altitude: measurement.altitude,
            horizontalAccuracy: sqrt(variance),
            verticalAccuracy: measurement.verticalAccuracy,
            course: measurement.course,
            speed: max(0, speed),
            timestamp: measurement.timestamp
        )
    }

    func reset() {
        variance = -1.0
        speedVariance = -1.0
    }
}

// ============================================
// DATA STRUCTURES
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

struct ValidationResult {
    let isValid: Bool
    let reason: String?
}
