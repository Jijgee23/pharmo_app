import CoreLocation
import Flutter
import Foundation
import os.log

class LocationHandler: NSObject, CLLocationManagerDelegate, FlutterStreamHandler {

    private var locationManager: CLLocationManager = CLLocationManager()
    private var eventSink: FlutterEventSink?
    private var lastBroadcastLocation: CLLocation?

    // Kotlin талтай ижил тохиргооны утгууд
    private let minDistanceChange: CLLocationDistance = 10.0  // 10 метр
    private let minUpdateInterval: TimeInterval = 3.0  // 3 секунд
    private let maxAllowedAccuracy: CLLocationAccuracy = 25.0  // 25 метр

    // Speed-based distance thresholds (km/h)
    private let highSpeedThreshold: CLLocationSpeed = 60.0  // > 60 km/h
    private let mediumSpeedThreshold: CLLocationSpeed = 30.0  // 30-60 km/h
    private let lowSpeedThreshold: CLLocationSpeed = 10.0  // 10-30 km/h

    private let highSpeedDistance: CLLocationDistance = 200.0  // 200m at high speed
    private let mediumSpeedDistance: CLLocationDistance = 100.0  // 100m at medium speed
    private let normalSpeedDistance: CLLocationDistance = 50.0  // 50m at normal speed
    private let walkingSpeedDistance: CLLocationDistance = 15.0  // 15m at walking speed

    private let minTimeDeltaBetweenUpdates: TimeInterval = 5.0  // 5 seconds

    private let logger = OSLog(subsystem: "mn.infosystems.pharmo", category: "LocationTracking")

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = minDistanceChange
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.activityType = CLActivityType.automotiveNavigation
        if #available(iOS 11.0, *) {
            locationManager.showsBackgroundLocationIndicator = true
        }
    }

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink)
        -> FlutterError?
    {
        self.eventSink = events
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.startMonitoringSignificantLocationChanges()
        locationManager.startUpdatingLocation()
        os_log("iOS: Location tracking started", log: logger, type: .info)
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        locationManager.stopUpdatingLocation()
        locationManager.stopMonitoringSignificantLocationChanges()
        locationManager.delegate = nil
        self.eventSink = nil
        self.lastBroadcastLocation = nil
        os_log("iOS: Location tracking stopped", log: logger, type: .info)
        return nil
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let sink = eventSink, let newLocation = locations.last else { return }

        // 1. Accuracy validation
        if newLocation.horizontalAccuracy < 0 || newLocation.horizontalAccuracy > maxAllowedAccuracy
        {
            os_log(
                "iOS: Location rejected - poor accuracy: %f", log: logger, type: .debug,
                newLocation.horizontalAccuracy)
            return
        }

        guard let lastPoint = lastBroadcastLocation else {
            broadcastLocation(newLocation)
            return
        }

        let speedKmH = newLocation.speed * 3.6  // Convert m/s to km/h
        let distance = newLocation.distance(from: lastPoint)
        let timeDelta = newLocation.timestamp.timeIntervalSince(lastPoint.timestamp)

        // 2. Dynamic distance threshold based on speed
        let dynamicDistance = calculateDynamicDistance(for: speedKmH)

        // 3. Broadcast if distance threshold met and minimum time elapsed
        if distance >= dynamicDistance && timeDelta >= minTimeDeltaBetweenUpdates {
            broadcastLocation(newLocation)
        }
    }

    func startMonitoringForBackground() {
        locationManager.delegate = self
        locationManager.startMonitoringSignificantLocationChanges()
        os_log("iOS: Background location monitoring started", log: logger, type: .info)
    }

    private func calculateDynamicDistance(for speedKmH: CLLocationSpeed) -> CLLocationDistance {
        if speedKmH > highSpeedThreshold {
            return highSpeedDistance
        } else if speedKmH > mediumSpeedThreshold {
            return mediumSpeedDistance
        } else if speedKmH > lowSpeedThreshold {
            return normalSpeedDistance
        } else {
            return walkingSpeedDistance
        }
    }

    private func broadcastLocation(_ location: CLLocation) {
        lastBroadcastLocation = location

        let locationData: [String: Any] = [
            "lat": location.coordinate.latitude,
            "lng": location.coordinate.longitude,
            "acc": location.horizontalAccuracy,
            "spd": location.speed,
            "time": Int64(location.timestamp.timeIntervalSince1970 * 1000),  // Kotlin-той ижил Milliseconds
        ]

        eventSink?(locationData)

        os_log(
            "iOS: Location broadcast - lat: %f, lng: %f", log: logger, type: .debug,
            location.coordinate.latitude,
            location.coordinate.longitude
        )
    }
}
