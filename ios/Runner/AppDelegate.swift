import CoreLocation
import Flutter
import Foundation
import GoogleMaps
import UIKit
// ...existing code...
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  var locationHandler: LocationHandler?
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("AIzaSyA0hFR0VJcj140Z5aXu1pfrQpxbVfmL6DI")
    GeneratedPluginRegistrant.register(with: self)
    guard let controller = window?.rootViewController as? FlutterViewController else {
      return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    let eventChannel = FlutterEventChannel(
      name: "bg_location_stream",
      binaryMessenger: controller.binaryMessenger
    )

    locationHandler = LocationHandler()
    eventChannel.setStreamHandler(locationHandler)

    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
    }
    application.registerForRemoteNotifications()

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

class LocationHandler: NSObject, CLLocationManagerDelegate, FlutterStreamHandler {

  private var locationManager: CLLocationManager = CLLocationManager()
  private var eventSink: FlutterEventSink?
  private var lastSentTime: Date?
  private let minDistance: CLLocationDistance = 10.0
  private let minUpdateInterval: TimeInterval = 30
  private var lastLocation: CLLocation?

  override init() {
    super.init()
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    locationManager.distanceFilter = 10

    locationManager.allowsBackgroundLocationUpdates = true
    locationManager.pausesLocationUpdatesAutomatically = false
  }

  // Flutter EventChannel
  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink)
    -> FlutterError?
  {
    locationManager.requestAlwaysAuthorization()
    locationManager.requestLocation()
    locationManager.showsBackgroundLocationIndicator = true
    locationManager.startUpdatingLocation()
    self.eventSink = events
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    self.eventSink = nil
    locationManager.stopUpdatingLocation()
    return nil
  }

  // CLLocationManagerDelegate
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let newLocation = locations.last else { return }
    let now = Date()

    // 1. Нарийвчлал шалгах (20 метрээс дээш байвал хаяна)
    guard newLocation.horizontalAccuracy > 0 && newLocation.horizontalAccuracy <= 20 else {
      return
    }

    // 2. Эхний байршил эсвэл сүүлийн байршил байхгүй бол шууд дамжуулна
    guard let last = lastLocation else {
      lastLocation = newLocation
      lastSentTime = now
      sendLocationToFlutter(newLocation, time: now)
      return
    }

    // 3. Зайны шалгалт (Сүүлийн илгээсэн байршлаас хөдөлсөн зай)
    let distance = newLocation.distance(from: last)

    // A. 10 метрээс их хөдөлсөн бол: Шууд дамжуулна
    if distance >= minDistance {
      // Зай 10м ба түүнээс дээш бол шууд илгээнэ. Хугацааны хязгаарлалт үйлчлэхгүй.
      lastLocation = newLocation
      lastSentTime = now
      sendLocationToFlutter(newLocation, time: now)
      return
    }

    // B. 10 метрээс бага хөдөлсөн бол: Хугацааны шалгалт хийнэ
    // (distance < minDistance)
    if let lastTime = lastSentTime, now.timeIntervalSince(lastTime) >= minUpdateInterval {
      // 10м-ээс бага боловч, сүүлийн илгээлтээс 30 секунд өнгөрсөн бол илгээнэ.
      lastLocation = newLocation
      lastSentTime = now
      sendLocationToFlutter(newLocation, time: now)
      return
    }

    // Бусад тохиолдолд (10м-ээс бага хөдөлж, 30с өнгөрөөгүй бол) юу ч хийхгүй.
  }

  // Туслах функц (кодыг цэгцлэх үүднээс)
  private func sendLocationToFlutter(_ location: CLLocation, time: Date) {
    if let sink = eventSink {
      sink([
        "lat": location.coordinate.latitude,
        "lng": location.coordinate.longitude,
        "accuracy": location.horizontalAccuracy,
        "timestamp": time.timeIntervalSince1970,
      ])
    }
  }

  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print("Location error: \(error.localizedDescription)")
  }

}
