import CoreLocation
import Flutter
import Foundation
import os.log

class LocationHandler: NSObject, CLLocationManagerDelegate, FlutterStreamHandler {

    private var locationManager: CLLocationManager = CLLocationManager()
    private var eventSink: FlutterEventSink?
    private var lastBroadcastLocation: CLLocation?

    // Kotlin талтай ижил тохиргооны утгууд
    private let minDistanceChange: CLLocationDistance = 5.0  // 10 метр
    private let minUpdateInterval: TimeInterval = 3.0  // 3 секунд
    private let maxAllowedAccuracy: CLLocationAccuracy = 30.0  // 30 метр
    private let minSpeedThreshold: CLLocationSpeed = 0.5  // 0.5 м/с

    private let logger = OSLog(subsystem: "mn.infosystems.pharmo", category: "LocationTracking")

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation

        // Kotlin-ий startLocationUpdates дээрх тохиргоотой ижилсүүлэв
        locationManager.distanceFilter = minDistanceChange
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.activityType = CLActivityType.automotiveNavigation

        // iOS 11+ бол Foreground индикатор харуулах
        if #available(iOS 11.0, *) {
            locationManager.showsBackgroundLocationIndicator = true
        }
    }

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink)
        -> FlutterError?
    {
        self.eventSink = events
        locationManager.delegate = self

        // Зогсож байх үед дата ирэхийг багасгахын тулд:
        // locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10.0  // 10 метр тутамд нэг update өгөх

        locationManager.requestAlwaysAuthorization()
        //  locationManager.startMonitoringSignificantLocationChanges()
        locationManager.startUpdatingLocation()
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

    // func stopListenChanges(withArguments arguments: Any?) -> FlutterError? {
    //     locationManager.stopUpdatingLocation()
    //     locationManager.delegate = nil
    //     self.eventSink = nil
    //     self.lastBroadcastLocation = nil
    //     os_log("iOS: Location tracking stopped", log: logger, type: .info)
    //     return nil
    // }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let sink = eventSink, let newLocation = locations.last else { return }

        // 1. Нарийвчлал шалгах
        if newLocation.horizontalAccuracy < 0 || newLocation.horizontalAccuracy > 25.0 {
            return
        }

        guard let lastPoint = lastBroadcastLocation else {
            broadcastLocation(newLocation)
            return
        }

        let speedKmH = newLocation.speed * 3.6  // m/s-ийг км/ц рүү шилжүүлэх
        let distance = newLocation.distance(from: lastPoint)
        let timeDelta = newLocation.timestamp.timeIntervalSince(lastPoint.timestamp)

        // 2. Хурднаас хамаарч зайны босгыг тогтоох
        var dynamicDistance: CLLocationDistance = 15.0  // Анхны утга: 15 метр

        if speedKmH > 60 {
            dynamicDistance = 200.0  // 60 км/ц-аас дээш бол 200 метр тутамд
        } else if speedKmH > 30 {
            dynamicDistance = 100.0  // 30-60 км/ц-ийн хооронд бол 100 метр тутамд
        } else if speedKmH > 10 {
            dynamicDistance = 50.0  // 10-30 км/ц-ийн хооронд бол 50 метр тутамд
        } else {
            dynamicDistance = 15.0  // Алхах эсвэл маш удаан үед 15 метр
        }

        // 3. Шүүлтүүр: Зайны босго давсан БӨГӨӨД дор хаяж 5 секунд өнгөрсөн байх
        if distance >= dynamicDistance && timeDelta >= 5.0 {
            broadcastLocation(newLocation)
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
