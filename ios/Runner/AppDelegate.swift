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

        // ✅ Match Android: Get messenger (flutterEngine.dartExecutor.binaryMessenger)
        guard let controller = window?.rootViewController as? FlutterViewController else {
            return super.application(application, didFinishLaunchingWithOptions: launchOptions)
        }
        let messenger = controller.binaryMessenger

        // ✅ Match Android: Initialize handlers
        // Android: locationStreamHandler = LocationStreamHandler(this)
        // Android: batteryHandler = BatteryHandler(this)
        locationHandler = LocationHandler()
        batteryHandler = BatteryHandler()

        // ✅ Match Android: Setup Location Event Channel
        // Android: EventChannel(flutterEngine.dartExecutor.binaryMessenger, LOCATION_EVENT_CHANNEL)
        //         .setStreamHandler(locationStreamHandler)
        let bgLocationChannel = FlutterEventChannel(
            name: AppConstants.LOCATION_EVENT_CHANNEL,
            binaryMessenger: messenger
        )
        bgLocationChannel.setStreamHandler(locationHandler)

        // ✅ Match Android: Setup Battery Event Channel
        // Android: EventChannel(flutterEngine.dartExecutor.binaryMessenger, BATTERY_EVENT_CHANNEL)
        //         .setStreamHandler(batteryHandler)
        let batteryChannel = FlutterEventChannel(
            name: AppConstants.BATTERY_EVENT_CHANNEL,
            binaryMessenger: messenger
        )
        batteryChannel.setStreamHandler(batteryHandler)

        // ✅ Match Android: Setup Location Control Method Channel
        // Android: MethodChannel(flutterEngine.dartExecutor.binaryMessenger, LOCATION_CONTROL_CHANNEL)
        //         .setMethodCallHandler { call, result -> ... }
        let locationControlChannel = FlutterMethodChannel(
            name: AppConstants.LOCATION_CONTROL_CHANNEL,
            binaryMessenger: messenger
        )

        locationControlChannel.setMethodCallHandler { [weak self] (call, result) in
            guard let self = self else {
                result(FlutterMethodNotImplemented)
                return
            }

            // ✅ Match Android: when (call.method) { "start" -> ..., "stop" -> ..., "isRunning" -> ... }
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

    // ================= METHOD CHANNEL HANDLERS - EXACT MATCH WITH Android =================

    // Match Android: private fun startLocationService(): Boolean
    private func startLocationService() -> Bool {
        // ✅ Match Android behavior:
        // Android starts actual Service with: ContextCompat.startForegroundService(this, intent)
        // iOS doesn't have Services, but we can verify handler is ready
        
        print("✅ startLocationService called")
        
        // In iOS, location is actually started by LocationHandler.onListen()
        // This method is just for API compatibility with Android
        
        if locationHandler == nil {
            print("❌ LocationHandler is nil")
            return false
        }
        
        print("✅ LocationHandler is ready (actual start happens via onListen)")
        return true
    }

    // Match Android: private fun stopLocationService(): Boolean
    private func stopLocationService() -> Bool {
        print("✅ stopLocationService called")
        
        // ✅ Match Android: LocationService.setEventSink(null)
        LocationHandler.clearEventSink()
        
        // In iOS, location is actually stopped by LocationHandler.onCancel()
        // This method is just for API compatibility with Android
        
        print("✅ EventSink cleared (actual stop happens via onCancel)")
        return true
    }

    // Match Android: private fun isLocationServiceRunning(): Boolean
    private func isLocationServiceRunning() -> Bool {
        // ✅ Match Android: return LocationService.isRunning()
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
        
        // Clean up (match Android onDestroy behavior)
        LocationHandler.clearEventSink()
        locationHandler = nil
        batteryHandler = nil
    }
}

// ============================================
// APP CONSTANTS - EXACT MATCH WITH Android companion object
// ============================================

struct AppConstants {
    // ✅ Match Android MainActivity companion object EXACTLY:
    // companion object {
    //     private val LOCATION_CONTROL_CHANNEL = "location_control"
    //     private val LOCATION_EVENT_CHANNEL = "bg_location_stream"
    //     private val BATTERY_EVENT_CHANNEL = "batteryStream"
    // }
    
    static let LOCATION_CONTROL_CHANNEL = "location_control"
    static let LOCATION_EVENT_CHANNEL = "bg_location_stream"
    static let BATTERY_EVENT_CHANNEL = "batteryStream"

    // Legacy names for backward compatibility (can be removed)
    static let batteryChannelName = BATTERY_EVENT_CHANNEL
    static let bgLocationChannelName = LOCATION_EVENT_CHANNEL
}