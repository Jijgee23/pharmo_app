import CoreLocation
import Flutter
import Foundation
import os.log

class LocationHandler: NSObject, CLLocationManagerDelegate, FlutterStreamHandler {

    private var locationManager: CLLocationManager = CLLocationManager()
    private var eventSink: FlutterEventSink?
    private var lastSentTime: Date?
    private let minDistance: CLLocationDistance = 5.0
    private let minUpdateInterval: TimeInterval = 30
    private var lastLocation: CLLocation?
    private let logger: OSLog = OSLog(
        subsystem: "com.pharmo.location",
        category: "LocationTracking"
    )

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 5
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
    }

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink)
        -> FlutterError?
    {
        self.eventSink = events
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.showsBackgroundLocationIndicator = true
        locationManager.startUpdatingLocation()

        if let lastLoc = lastLocation {
            let locationData: [String: Any] = [
                "lat": lastLoc.coordinate.latitude,
                "lng": lastLoc.coordinate.longitude,
                "acc": lastLoc.horizontalAccuracy,
                "timestamp": lastLoc.timestamp.timeIntervalSince1970,
                "onSubscriptionStart": true,
            ]
            eventSink?(locationData)

            os_log(
                "Location sent on subscription start: lat=%{public}f, lng=%{public}f",
                log: logger, type: .debug,
                lastLoc.coordinate.latitude,
                lastLoc.coordinate.longitude)
        }

        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        if let lastLoc = lastLocation, let sink = eventSink {
            let locationData: [String: Any] = [
                "lat": lastLoc.coordinate.latitude,
                "lng": lastLoc.coordinate.longitude,
                "acc": lastLoc.horizontalAccuracy,
                "timestamp": lastLoc.timestamp.timeIntervalSince1970,
                "onSubscriptionEnd": true,
            ]
            sink(locationData)

            os_log(
                "📍 Location update | lat=%{public}f lng=%{public}f acc=%{public}f",
                log: logger,
                type: .debug,
                lastLoc.coordinate.latitude,
                lastLoc.coordinate.longitude,
                lastLoc.horizontalAccuracy
            )
        }

        locationManager.stopUpdatingLocation()
        locationManager.delegate = nil
        self.eventSink = nil
        self.lastLocation = nil
        self.lastSentTime = nil

        print("iOS: Location tracking fully stopped.")
        return nil
    }

    // CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let sink = eventSink else {
            locationManager.stopUpdatingLocation()
            return
        }

        guard let newLocation = locations.last else { return }
        let now = Date()

        // ...existing code...
        guard newLocation.horizontalAccuracy > 0 && newLocation.horizontalAccuracy <= 50 else {
            return
        }

        guard let last: CLLocation = lastLocation, let lastTime: Date = lastSentTime else {
            updateAndBroadcast(location: newLocation, time: now)
            return
        }

        let distance: CLLocationDistance = newLocation.distance(from: last)
        let timeInterval: TimeInterval = now.timeIntervalSince(lastTime)

        let movedEnough: Bool = distance >= 5.0

        if movedEnough {
            updateAndBroadcast(location: newLocation, time: now)
        }
    }

    // Туслах функц (кодыг цэгцлэх үүднээс)
    private func updateAndBroadcast(location: CLLocation, time: Date) {
        lastLocation = location
        lastSentTime = time
        let locationData: [String: Any] = [
            "lat": location.coordinate.latitude,
            "lng": location.coordinate.longitude,
            "acc": location.horizontalAccuracy,
            "timestamp": time.timeIntervalSince1970,
        ]

        eventSink?(locationData)
        os_log(
            "Location broadcast: lat=%{public}@, lng=%{public}@",
            log: logger, type: .debug,
            String(location.coordinate.latitude),
            String(location.coordinate.longitude))
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        os_log("Location error: %{public}@", log: logger, type: .error, error.localizedDescription)
    }
}
