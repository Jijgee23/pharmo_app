import CoreLocation
import Flutter
import Foundation
import GoogleMaps
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {

  var locationHandler: LocationHandler?
  private var timer: Timer?
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    GMSServices.provideAPIKey("AIzaSyA0hFR0VJcj140Z5aXu1pfrQpxbVfmL6DI")
    let registrar = self.registrar(forPlugin: "Runner")!
    let messenger = registrar.messenger()
    if launchOptions?[.location] != nil {
      if locationHandler == nil {
        locationHandler = LocationHandler()
      }
      locationHandler?.startMonitoringForBackground()
    }

    let batteryChannel = FlutterEventChannel(
      name: AppConstants.batteryChannalName,
      binaryMessenger: messenger
    )

    batteryChannel.setStreamHandler(BatteryHandler())

    let bgLocationChannel = FlutterEventChannel(
      name: AppConstants.bgLocationChannerName,
      binaryMessenger: messenger
    )

    let bg = FlutterMethodChannel(name: AppConstants.bgChannel, binaryMessenger: messenger, )

    bg.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in

      if call.method == "startTimer" {
        self.startPrinting()
        result("Timer Started")
      } else {
        result(FlutterMethodNotImplemented)
      }
    })

    locationHandler = LocationHandler()
    bgLocationChannel.setStreamHandler(locationHandler)

    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
    }

    application.registerForRemoteNotifications()

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  private func startPrinting() {
    timer?.invalidate()  // Өмнөх таймерыг цэвэрлэх
    timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
      print("Hello World")
    }
  }
}
