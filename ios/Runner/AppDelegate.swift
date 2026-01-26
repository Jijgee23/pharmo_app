import CoreLocation
import Flutter
import Foundation
import GoogleMaps
import UIKit
import UserNotifications

public var batteryChannalName: String = "batteryStream"
public var bgLocationChannerName: String = "bg_location_stream"
public var permissionChannelName: String = "permissionChannel"

@main
@objc class AppDelegate: FlutterAppDelegate {
  // variables
  var locationHandler: LocationHandler?
  var batteryEventSink: BatteryHandler?
  var permissionHandler: PermissionHandler?
  //
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("AIzaSyA0hFR0VJcj140Z5aXu1pfrQpxbVfmL6DI")

    guard let controller = window?.rootViewController as? FlutterViewController else {
      return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    let batteryChannel = FlutterEventChannel(
      name: batteryChannalName,
      binaryMessenger: controller.binaryMessenger
    )

    batteryEventSink = BatteryHandler()
    batteryChannel.setStreamHandler(batteryEventSink)

    let eventChannel = FlutterEventChannel(
      name: bgLocationChannerName,
      binaryMessenger: controller.binaryMessenger
    )

    locationHandler = LocationHandler()
    eventChannel.setStreamHandler(locationHandler)

    let permissionChannel = FlutterMethodChannel(
      name: permissionChannelName,
      binaryMessenger: controller.binaryMessenger
    )

    self.permissionHandler = PermissionHandler()

    permissionChannel.setMethodCallHandler({
      [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      guard let handler = self?.permissionHandler else {
        result(FlutterError(code: "UNINITIALIZED", message: "Handler is nil", details: nil))
        return
      }

      switch call.method {
      case "requestLocation":
        handler.requestLocationPermission(result: result)
      case "requestNotification":
        handler.requestNotificationPermission(result: result)
      case "checkAllStatuses":
        handler.checkStatuses(result: result)
      default:
        result(FlutterMethodNotImplemented)
      }
    })

    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
    }

    application.registerForRemoteNotifications()

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
