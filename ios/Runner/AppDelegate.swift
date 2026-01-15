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
    self.eventSink = events

    // Delegate-ийг заавал энд дахин тохируулна
    locationManager.delegate = self

    locationManager.requestAlwaysAuthorization()
    locationManager.showsBackgroundLocationIndicator = true
    locationManager.startUpdatingLocation()

    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    locationManager.stopUpdatingLocation()

    // 2. Delegate-ийг салгах (Чухал: Ингэснээр дахин байршил ирэхгүй)
    locationManager.delegate = nil

    // 3. Өгөгдөл дамжуулах сувгийг хаах
    self.eventSink = nil

    // 4. Түр хадгалсан байршлуудыг цэвэрлэх
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

    // 2. Нарийвчлалын шүүлтүүр (Kotlin дээр 50 байгаа тул ижилсүүлэв)
    // iOS-д accuracy > 50 бол ихэвчлэн маш тодорхойгүй байдаг
    guard newLocation.horizontalAccuracy > 0 && newLocation.horizontalAccuracy <= 50 else {
      return
    }

    // 3. Өмнөх байршил байгаа эсэхийг шалгах (Kotlin: val isFirstLocation = previous == null)
    guard let last = lastLocation, let lastTime = lastSentTime else {
      // Эхний байршил бол шууд илгээнэ
      updateAndBroadcast(location: newLocation, time: now)
      return
    }

    // 4. Шалгуурууд (Kotlin-той ижил логик)
    let distance = newLocation.distance(from: last)
    let timeInterval = now.timeIntervalSince(lastTime)

    let movedEnough = distance >= 10.0  // 10 метр хөдөлсөн үү
    let timeEnough = timeInterval >= 30.0  // 30 секунд өнгөрсөн үү

    // Аль нэг нөхцөл биелсэн бол Flutter-лүү дамжуулна
    if movedEnough || timeEnough {
      updateAndBroadcast(location: newLocation, time: now)
    }

    // Бусад тохиолдолд (10м-ээс бага хөдөлж, 30с өнгөрөөгүй бол) юу ч хийхгүй.
  }

  // Туслах функц (кодыг цэгцлэх үүднээс)
  private func updateAndBroadcast(location: CLLocation, time: Date) {
    lastLocation = location
    lastSentTime = time
    let locationData: [String: Any] = [
      "lat": location.coordinate.latitude,
      "lng": location.coordinate.longitude,
      "acc": location.horizontalAccuracy,  // "accuracy" байсныг Kotlin-той ижил "acc" болгов
      "timestamp": time.timeIntervalSince1970,
    ]

    eventSink?(locationData)
  }

  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print("Location error: \(error.localizedDescription)")
  }

}
