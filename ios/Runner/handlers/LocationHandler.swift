// ============================================
// iOS LOCATION HANDLER - Matches Android LocationService
// Added static methods: isRunning(), clearEventSink()
// ============================================

import CoreLocation
import Flutter
import Foundation
import os.log

class LocationHandler: NSObject, CLLocationManagerDelegate, FlutterStreamHandler {

    private var locationManager: CLLocationManager = CLLocationManager()

    // ✅ Match Android: private var eventSink: EventChannel.EventSink? = null
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
    private static var isRunningFlag = false

    // ✅ Match Android: @Volatile private var eventSink: EventChannel.EventSink? = null
    private static var sharedEventSink: FlutterEventSink?

    // Configuration - synchronized with Android
    private let maxAccuracyMeters: CLLocationAccuracy = 30.0
    private let minDistanceMeters: CLLocationDistance = 10.0
    private let minTimeBetweenUpdatesSeconds: TimeInterval = 3.0
    private let gpsDriftThreshold: CLLocationDistance = 8.0

    // Speed thresholds (m/s)
    private let highSpeedThreshold: CLLocationSpeed = 16.7  // 60 km/h
    private let mediumSpeedThreshold: CLLocationSpeed = 8.3  // 30 km/h
    private let lowSpeedThreshold: CLLocationSpeed = 2.8  // 10 km/h
    private let minSpeedThreshold: CLLocationSpeed = 0.5  // 1.8 km/h

    // Distance thresholds
    private let highSpeedDistance: CLLocationDistance = 200.0
    private let mediumSpeedDistance: CLLocationDistance = 100.0
    private let normalSpeedDistance: CLLocationDistance = 50.0
    private let walkingSpeedDistance: CLLocationDistance = 15.0

    // GPS jump detection
    private let maxSpeedMs: CLLocationSpeed = 50.0  // 180 km/h

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

    // ================= STATIC METHODS (Match Android companion object) =================

    // Match Android: fun isRunning(): Boolean = isRunningFlag
    static func isRunning() -> Bool {
        return isRunningFlag
    }

    // Match Android: fun setEventSink(sink: EventChannel.EventSink?)
    @objc static func setEventSink(_ sink: FlutterEventSink?) {
        sharedEventSink = sink
        print(sink != nil ? "✅ EventSink SET (not null)" : "⚠️ EventSink CLEARED (null)")
    }

    // Match Android: LocationService.setEventSink(null)
    @objc static func clearEventSink() {
        sharedEventSink = nil
        print("⚠️ EventSink CLEARED (null)")
    }

    // ================= FLUTTER STREAM HANDLER =================

    func onListen(
        withArguments arguments: Any?,
        eventSink events: @escaping FlutterEventSink
    ) -> FlutterError? {
        os_log("📡 onListen called - Setting EventSink", log: logger, type: .info)

        // ✅ Match Android: self.eventSink = events
        self.eventSink = events
        LocationHandler.sharedEventSink = events

        // ✅ Match Android: LocationHandler.isRunning = true (but we use isRunningFlag)
        LocationHandler.isRunningFlag = true
        os_log("✅ isRunningFlag = true", log: logger, type: .info)

        // Reset filters (match Android)
        kalmanFilter.reset()
        lastAcceptedLocation = nil
        lastBroadcastTime = nil
        totalReceived = 0
        totalAccepted = 0
        totalRejected = 0

        // Request authorization
        locationManager.requestAlwaysAuthorization()

        // Start location updates
        locationManager.startMonitoringSignificantLocationChanges()
        locationManager.startUpdatingLocation()

        os_log("✅ iOS Location tracking started", log: logger, type: .info)

        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        os_log("🛑 onCancel called", log: logger, type: .info)

        // ✅ Match Android: LocationHandler.isRunning = false
        LocationHandler.isRunningFlag = false
        os_log("✅ isRunningFlag = false", log: logger, type: .info)

        locationManager.stopUpdatingLocation()
        locationManager.stopMonitoringSignificantLocationChanges()

        // Log final statistics
        logStatistics()

        // ✅ Match Android: self.eventSink = null
        self.eventSink = nil
        LocationHandler.sharedEventSink = nil
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

    // ================= LOCATION DELEGATE =================

    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        totalReceived += 1

        // ✅ Match Android: guard let sink = eventSink
        guard let sink = eventSink ?? LocationHandler.sharedEventSink else {
            if totalReceived % 10 == 1 {
                os_log(
                    """
                    ⚠️ EventSink is NULL (attempt %d)
                    - Service running: %{public}@
                    - Total received: %d
                    ⚠️ Call EventChannel.listen() BEFORE starting service!
                    """,
                    log: logger,
                    type: .error,
                    totalReceived,
                    LocationHandler.isRunningFlag ? "YES" : "NO",
                    totalReceived
                )
            }
            return
        }

        guard let rawLocation = locations.last else { return }

        // Process through filtering pipeline
        let result = processLocation(rawLocation)

        switch result {
        case .accepted(let filtered, let reason):
            totalAccepted += 1
            broadcastLocation(filtered, to: sink)
            logAcceptance(filtered, reason: reason)

        case .rejected(let reason):
            totalRejected += 1
            logRejection(reason)
        }

        // Log stats every 50 locations
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

        // STEP 2: Apply Kalman filter
        let smoothedLocation = kalmanFilter.filter(rawLocation)

        // STEP 3: First location - always accept
        guard let previous = lastAcceptedLocation else {
            let filtered = FilteredLocation(location: smoothedLocation)
            lastAcceptedLocation = filtered
            lastBroadcastTime = Date()
            return .accepted(filtered, "First location")
        }

        // STEP 4: Time throttling
        let now = Date()
        if let lastTime = lastBroadcastTime {
            let timeDelta = now.timeIntervalSince(lastTime)
            if timeDelta < minTimeBetweenUpdatesSeconds {
                return .rejected(
                    "Too frequent: \(String(format: "%.1f", timeDelta))s < \(minTimeBetweenUpdatesSeconds)s"
                )
            }
        }

        // STEP 5: Distance validation
        let distance = smoothedLocation.distance(from: previous.location)

        // GPS drift detection (stationary)
        if smoothedLocation.speed >= 0 && smoothedLocation.speed < minSpeedThreshold {
            if distance < gpsDriftThreshold {
                return .rejected(
                    "GPS drift: \(Int(distance))m < \(Int(gpsDriftThreshold))m (stationary)"
                )
            }
        }

        // STEP 6: Speed-based distance threshold
        let requiredDistance = calculateDynamicDistance(for: smoothedLocation.speed)
        if distance < requiredDistance {
            return .rejected(
                "Insufficient distance: \(Int(distance))m < \(Int(requiredDistance))m"
            )
        }

        // STEP 7: GPS jump detection
        if let lastTime = lastBroadcastTime {
            let timeDeltaSeconds = now.timeIntervalSince(lastTime)
            if timeDeltaSeconds > 0 {
                let calculatedSpeed = distance / timeDeltaSeconds

                if calculatedSpeed > maxSpeedMs {
                    let speedKmh = Int(calculatedSpeed * 3.6)
                    return .rejected(
                        "GPS jump: \(speedKmh)km/h (max: \(Int(maxSpeedMs * 3.6))km/h)"
                    )
                }
            }
        }

        // STEP 8: All checks passed!
        let filtered = FilteredLocation(location: smoothedLocation)
        lastAcceptedLocation = filtered
        lastBroadcastTime = now

        let speedKmh = Int(smoothedLocation.speed * 3.6)
        return .accepted(
            filtered,
            "Valid: \(Int(distance))m, \(speedKmh) km/h"
        )
    }

    // ================= HELPERS =================

    private func isAccuracyValid(_ location: CLLocation) -> Bool {
        return location.horizontalAccuracy > 0 && location.horizontalAccuracy <= maxAccuracyMeters
    }

    private func calculateDynamicDistance(for speedMs: CLLocationSpeed) -> CLLocationDistance {
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

        os_log(
            "✅ Location broadcast: (%f, %f)",
            log: logger,
            type: .debug,
            location.coordinate.latitude,
            location.coordinate.longitude
        )
    }

    // ================= LOGGING =================

    private func logAcceptance(_ location: FilteredLocation, reason: String) {
        let speedKmh = Int(location.location.speed * 3.6)
        let accuracy = Int(location.location.horizontalAccuracy)

        os_log(
            "✅ ACCEPTED: %{public}@ | Speed: %dkm/h | Acc: %dm",
            log: logger,
            type: .debug,
            reason,
            speedKmh,
            accuracy
        )
    }

    private func logRejection(_ reason: String) {
        os_log(
            "❌ REJECTED: %{public}@",
            log: logger,
            type: .debug,
            reason
        )
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
            Running: %{public}@
            ═══════════════════════════════
            """,
            log: logger,
            type: .info,
            totalReceived,
            totalAccepted,
            totalRejected,
            acceptRate,
            (eventSink != nil || LocationHandler.sharedEventSink != nil) ? "✅ SET" : "❌ NULL",
            LocationHandler.isRunningFlag ? "✅ YES" : "❌ NO"
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
// KALMAN FILTER (Same as Android)
// ============================================

class KalmanLocationFilter {
    private var lat: Double = 0.0
    private var lng: Double = 0.0
    private var variance: Double = -1.0

    private let processNoise: Double = 0.5

    func filter(_ measurement: CLLocation) -> CLLocation {
        if variance < 0 {
            lat = measurement.coordinate.latitude
            lng = measurement.coordinate.longitude
            variance = Double(measurement.horizontalAccuracy * measurement.horizontalAccuracy)
        } else {
            let predictionVariance = variance + processNoise
            let measurementVariance = Double(
                measurement.horizontalAccuracy * measurement.horizontalAccuracy
            )
            let kalmanGain = predictionVariance / (predictionVariance + measurementVariance)

            lat += kalmanGain * (measurement.coordinate.latitude - lat)
            lng += kalmanGain * (measurement.coordinate.longitude - lng)
            variance = (1 - kalmanGain) * predictionVariance
        }

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
// DATA STRUCTURES (Same as Android)
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