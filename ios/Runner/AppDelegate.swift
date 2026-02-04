
import CoreLocation
import Flutter
import Foundation
import GoogleMaps
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {

    var locationHandler: LocationHandler?
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        // Google Maps API
        GMSServices.provideAPIKey("AIzaSyA0hFR0VJcj140Z5aXu1pfrQpxbVfmL6DI")
        
        // Get messenger
        let controller = window?.rootViewController as! FlutterViewController
        let messenger = controller.binaryMessenger
        
        // ✅ Handle app launch from location event (background)
        if launchOptions?[.location] != nil {
            print("📍 App launched from location event")
            
            if locationHandler == nil {
                locationHandler = LocationHandler()
            }
            locationHandler?.startMonitoringForBackground()
        }
        
        // ✅ Setup Battery Channel
        let batteryChannel = FlutterEventChannel(
            name: AppConstants.batteryChannelName,
            binaryMessenger: messenger
        )
        batteryChannel.setStreamHandler(BatteryHandler())
        
        // ✅ Setup Location Channel
        let bgLocationChannel = FlutterEventChannel(
            name: AppConstants.bgLocationChannelName,
            binaryMessenger: messenger
        )
        
        // ✅ IMPORTANT: Initialize LocationHandler only once
        if locationHandler == nil {
            locationHandler = LocationHandler()
        }
        
        bgLocationChannel.setStreamHandler(locationHandler)
        
        print("✅ EventChannels configured")
        
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
    
    // ✅ Handle app entering background
    override func applicationDidEnterBackground(_ application: UIApplication) {
        print("📱 App entered background")
        
        // Location updates will continue in background
        // No need to stop them
    }
    
    // ✅ Handle app entering foreground
    override func applicationWillEnterForeground(_ application: UIApplication) {
        print("📱 App entering foreground")
    }
    
    // ✅ Handle app termination
    override func applicationWillTerminate(_ application: UIApplication) {
        print("🛑 App terminating")
        
        // Clean up
        locationHandler = nil
    }
}