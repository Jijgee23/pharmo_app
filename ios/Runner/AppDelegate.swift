import CoreLocation
import Firebase
import Flutter
import Foundation
import GoogleMaps
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {

    let flutterEngine = FlutterEngine(name: "main engine")

    // Owned here rather than by SceneDelegate: the CLLocationManager inside
    // LocationHandler must keep running across scene disconnect/reconnect
    // (backgrounding, being swiped away in the app switcher, memory
    // pressure) — otherwise UIBackgroundModes "location" in Info.plist is
    // undermined the moment the scene tears down its (previously scene-
    // owned) LocationHandler instance.
    private var locationHandler: LocationHandler?
    private var batteryHandler: BatteryHandler?

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        FirebaseApp.configure()
        GMSServices.provideAPIKey("AIzaSyA0hFR0VJcj140Z5aXu1pfrQpxbVfmL6DI")

        // Start the single Flutter engine and register all plugins with it.
        // Do NOT call super — that would create a second engine + window,
        // causing the scene's displayed window to show black.
        flutterEngine.run()
        GeneratedPluginRegistrant.register(with: flutterEngine)

        setupLocationAndBatteryChannels()

        if launchOptions?[.location] != nil {
            print("📍 App launched from location event")
            locationHandler?.startMonitoringForBackground()
        }

        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
        }
        application.registerForRemoteNotifications()

        return true
    }

    // Bound to flutterEngine.binaryMessenger — the engine, not any scene's
    // FlutterViewController — so these channels (and the LocationHandler/
    // BatteryHandler behind them) live for the process lifetime instead of
    // being torn down and recreated whenever the scene disconnects.
    private func setupLocationAndBatteryChannels() {
        let messenger = flutterEngine.binaryMessenger

        locationHandler = LocationHandler()
        batteryHandler = BatteryHandler()

        let bgLocationChannel = FlutterEventChannel(
            name: AppConstants.LOCATION_EVENT_CHANNEL,
            binaryMessenger: messenger
        )
        bgLocationChannel.setStreamHandler(locationHandler)

        let batteryChannel = FlutterEventChannel(
            name: AppConstants.BATTERY_EVENT_CHANNEL,
            binaryMessenger: messenger
        )
        batteryChannel.setStreamHandler(batteryHandler)

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
            case "start": result(self.startLocationService())
            case "stop": result(self.stopLocationService())
            case "isRunning": result(self.isLocationServiceRunning())
            default: result(FlutterMethodNotImplemented)
            }
        }

        print("✅ EventChannels and MethodChannel configured")
    }

    private func startLocationService() -> Bool {
        guard locationHandler != nil else {
            print("❌ LocationHandler is nil")
            return false
        }
        print("✅ LocationHandler ready")
        return true
    }

    private func stopLocationService() -> Bool {
        LocationHandler.clearEventSink()
        print("✅ EventSink cleared")
        return true
    }

    private func isLocationServiceRunning() -> Bool {
        let running = LocationHandler.isRunning()
        print("📊 isLocationServiceRunning: \(running)")
        return running
    }

    override func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    override func application(
        _ application: UIApplication,
        didDiscardSceneSessions sceneSessions: Set<UISceneSession>
    ) {}

    override func applicationWillTerminate(_ application: UIApplication) {
        print("🛑 App terminating")
        LocationHandler.clearEventSink()
    }
}

// ============================================
// APP CONSTANTS
// ============================================

struct AppConstants {
    static let LOCATION_CONTROL_CHANNEL = "location_control"
    static let LOCATION_EVENT_CHANNEL = "bg_location_stream"
    static let BATTERY_EVENT_CHANNEL = "batteryStream"

    static let batteryChannelName = BATTERY_EVENT_CHANNEL
    static let bgLocationChannelName = LOCATION_EVENT_CHANNEL
}
