import CoreLocation
import Flutter
import Foundation
import GoogleMaps
// ...existing code...
import UIKit

// import FirebaseCore

@main
@objc class AppDelegate: FlutterAppDelegate {
  var locationHandler: LocationHandler?
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // FirebaseApp.configure()
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

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

class LocationHandler: NSObject, CLLocationManagerDelegate, FlutterStreamHandler {

  private var locationManager: CLLocationManager = CLLocationManager()
  private var eventSink: FlutterEventSink?

  override init() {
    super.init()
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.distanceFilter = 10  // 10 meters
    locationManager.requestAlwaysAuthorization()
    locationManager.allowsBackgroundLocationUpdates = true
    locationManager.pausesLocationUpdatesAutomatically = false
    locationManager.startUpdatingLocation()
  }

  // Flutter EventChannel
  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink)
    -> FlutterError?
  {
    self.eventSink = events
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    self.eventSink = nil
    return nil
  }

  // CLLocationManagerDelegate
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let loc = locations.last else { return }
    if let sink = eventSink {
      sink([
        "lat": loc.coordinate.latitude,
        "lng": loc.coordinate.longitude,
      ])
    }
  }

  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print("Location error: \(error.localizedDescription)")
  }
}
