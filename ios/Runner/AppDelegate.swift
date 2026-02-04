import CoreLocation
import Flutter
import Foundation
import GoogleMaps
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {

    private var locationHandler: LocationHandler?
    private var batteryHandler: BatteryHandler?

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        // Google Maps API
        GMSServices.provideAPIKey("AIzaSyA0hFR0VJcj140Z5aXu1pfrQpxbVfmL6DI")

        // Get messenger (same as Android: flutterEngine.dartExecutor.binaryMessenger)
        guard let controller = window?.rootViewController as? FlutterViewController else {
            return super.application(application, didFinishLaunchingWithOptions: launchOptions)
        }
        let messenger = controller.binaryMessenger

        // ✅ Initialize handlers (matches Android: locationStreamHandler = LocationStreamHandler(this))
        locationHandler = LocationHandler()
        batteryHandler = BatteryHandler()

        // ✅ Setup Location Event Channel
        let bgLocationChannel = FlutterEventChannel(
            name: AppConstants.LOCATION_EVENT_CHANNEL,
            binaryMessenger: messenger
        )
        bgLocationChannel.setStreamHandler(locationHandler)

        // ✅ Setup Battery Event Channel
        let batteryChannel = FlutterEventChannel(
            name: AppConstants.BATTERY_EVENT_CHANNEL,
            binaryMessenger: messenger
        )
        batteryChannel.setStreamHandler(batteryHandler)

        // ✅ Setup Location Control Method Channel (matches Android MethodChannel)
        let locationControlChannel = FlutterMethodChannel(
            name: AppConstants.LOCATION_CONTROL_CHANNEL,
            binaryMessenger: messenger
        )

        locationControlChannel.setMethodCallHandler { [weak self] (call, result) in
            guard let self = self else {
                result(FlutterMethodNotImplemented)
                return
            }

            switch call.method {
            case "start":
                let started = self.startLocationService()
                result(started)

            case "stop":
                let stopped = self.stopLocationService()
                result(stopped)

            case "isRunning":
                let isRunning = self.isLocationServiceRunning()
                result(isRunning)

            default:
                result(FlutterMethodNotImplemented)
            }
        }

        print("✅ EventChannels and MethodChannel configured")

        // ✅ Handle app launch from location event (background)
        if launchOptions?[.location] != nil {
            print("📍 App launched from location event")
            locationHandler?.startMonitoringForBackground()
        }

        // Notification setup
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
        }

        application.registerForRemoteNotifications()

        GeneratedPluginRegistrant.register(with: self)

        return super.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
    }

    // ================= METHOD CHANNEL HANDLERS =================
    // (Matches Android: startLocationService, stopLocationService, isLocationServiceRunning)

    private func startLocationService() -> Bool {
        // In iOS, we don't have separate Service like Android
        // Location updates are controlled by LocationHandler.onListen()
        // This is just for API compatibility
        print("✅ startLocationService called (iOS uses onListen)")
        return true
    }

    private func stopLocationService() -> Bool {
        // In iOS, stopping is handled by LocationHandler.onCancel()
        // This is just for API compatibility
        print("✅ stopLocationService called (iOS uses onCancel)")

        // Clear EventSink (matches Android: LocationService.setEventSink(null))
        LocationHandler.clearEventSink()
        return true
    }

    private func isLocationServiceRunning() -> Bool {
        let isRunning = LocationHandler.isRunning()
        print("📊 isLocationServiceRunning: \(isRunning)")
        return isRunning
    }

    // ================= APP LIFECYCLE =================

    override func applicationDidEnterBackground(_ application: UIApplication) {
        print("📱 App entered background")
    }

    override func applicationWillEnterForeground(_ application: UIApplication) {
        print("📱 App entering foreground")
    }

    override func applicationWillTerminate(_ application: UIApplication) {
        print("🛑 App terminating")
        locationHandler = nil
        batteryHandler = nil
    }
}

// ============================================
// APP CONSTANTS
// (Matches Android companion object in MainActivity)
// ============================================

struct AppConstants {
    static let LOCATION_CONTROL_CHANNEL = "location_control"
    static let LOCATION_EVENT_CHANNEL = "bg_location_stream"
    static let BATTERY_EVENT_CHANNEL = "batteryStream"

    // Legacy names for compatibility (can remove later)
    static let batteryChannelName = BATTERY_EVENT_CHANNEL
    static let bgLocationChannelName = LOCATION_EVENT_CHANNEL
}
