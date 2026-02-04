// ============================================
// IMPROVED iOS LOCATION HANDLER
// Kalman filter + GPS jump detection + Statistics
// ============================================

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
    
    // Running state
    private static var isRunning = false
    
    // Configuration - synchronized with Android
    private let maxAccuracyMeters: CLLocationAccuracy = 30.0
    private let minDistanceMeters: CLLocationDistance = 10.0
    private let minTimeBetweenUpdatesSeconds: TimeInterval = 3.0
    private let gpsDriftThreshold: CLLocationDistance = 8.0
    
    // Speed thresholds (m/s)
    private let highSpeedThreshold: CLLocationSpeed = 16.7  // 60 km/h
    private let mediumSpeedThreshold: CLLocationSpeed = 8.3  // 30 km/h
    private let lowSpeedThreshold: CLLocationSpeed = 2.8   // 10 km/h
    private let minSpeedThreshold: CLLocationSpeed = 0.5   // 1.8 km/h
    
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
        locationManager.distanceFilter = kCLDistanceFilterNone  // We filter in app
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.activityType = .automotiveNavigation
        
        if #available(iOS 11.0, *) {
            locationManager.showsBackgroundLocationIndicator = true
        }
        
        os_log("✅ LocationManager configured", log: logger, type: .info)
    }

    // ================= FLUTTER STREAM HANDLER =================
    
    func onListen(
        withArguments arguments: Any?,
        eventSink events: @escaping FlutterEventSink
    ) -> FlutterError? {
        os_log("📡 onListen called - Setting EventSink", log: logger, type: .info)
        
        self.eventSink = events
        LocationHandler.isRunning = true
        
        // Reset filters
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
        
        LocationHandler.isRunning = false
        
        locationManager.stopUpdatingLocation()
        locationManager.stopMonitoringSignificantLocationChanges()
        
        // Log final statistics
        logStatistics()
        
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
    
    // ================= LOCATION DELEGATE =================

    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        totalReceived += 1
        
        guard let sink = eventSink else {
            // Only log every 10th attempt to avoid spam
            if totalReceived % 10 == 1 {
                os_log(
                    "⚠️ EventSink is NULL (attempt %d)",
                    log: logger,
                    type: .error,
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
        return location.horizontalAccuracy > 0 &&
               location.horizontalAccuracy <= maxAccuracyMeters
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
            // Debug info
            "filtered": true,
            "accept_rate": totalReceived > 0 ? Float(totalAccepted) / Float(totalReceived) : 0
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
        let acceptRate = totalReceived > 0 
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
            eventSink != nil ? "✅ SET" : "❌ NULL",
            LocationHandler.isRunning ? "✅ YES" : "❌ NO"
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
// KALMAN FILTER
// ============================================

class KalmanLocationFilter {
    private var lat: Double = 0.0
    private var lng: Double = 0.0
    private var variance: Double = -1.0
    
    private let processNoise: Double = 0.5
    
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