import CoreLocation
import Flutter
import Foundation
import GoogleMaps
// ...existing code...
import UserNotifications
import UIKit
import Firebase
import FirebaseMessaging
import FirebaseCore

@main
@objc class AppDelegate: FlutterAppDelegate {
  var locationHandler: LocationHandler?
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    FirebaseApp.configure()
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
    guard newLocation.horizontalAccuracy > 0 && newLocation.horizontalAccuracy <= 20 else {
      return
    }
    if let last = lastLocation {
      let distance = newLocation.distance(from: last)
      if distance < minDistance {
        return // 10м-ээс бага бол шинэчлэлт хийхгүй
      }
    }

    let now = Date()
    if let lastTime = lastSentTime, now.timeIntervalSince(lastTime) < minUpdateInterval {
      return // хэт ойрхон update-уудыг хязгаарлана
    }

    lastLocation = newLocation
    lastSentTime = now

    if let sink = eventSink {
      sink([
        "lat": newLocation.coordinate.latitude,
        "lng": newLocation.coordinate.longitude,
        "accuracy": newLocation.horizontalAccuracy,
        "timestamp": now.timeIntervalSince1970
      ])
    }
  }

  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print("Location error: \(error.localizedDescription)")
  }
}
