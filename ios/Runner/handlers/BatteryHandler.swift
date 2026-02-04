//
//  BatteryHandler.swift
//  Runner
//
//  Created by admin on 2026/1/22.
//

import Flutter

class BatteryHandler: NSObject, FlutterStreamHandler {
    private var eventSink: FlutterEventSink?
    private var timer: Timer?
    
    func onListen(
        withArguments arguments: Any?,
        eventSink events: @escaping FlutterEventSink
    ) -> FlutterError? {
        print("🔋 BatteryHandler: onListen called")
        
        self.eventSink = events
        
        // Enable battery monitoring
        UIDevice.current.isBatteryMonitoringEnabled = true
        
        // Register for battery level changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleBatteryLevelChange),
            name: UIDevice.batteryLevelDidChangeNotification,
            object: nil
        )
        
        // Register for battery state changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleBatteryLevelChange),
            name: UIDevice.batteryStateDidChangeNotification,
            object: nil
        )
        
        // Send initial value
        sendBatteryLevel()
        
        // ✅ Also check periodically (every 5 minutes)
        timer = Timer.scheduledTimer(
            withTimeInterval: 300,
            repeats: true
        ) { [weak self] _ in
            self?.sendBatteryLevel()
        }
        
        print("✅ BatteryHandler: Monitoring started")
        
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        print("🛑 BatteryHandler: onCancel called")
        
        timer?.invalidate()
        timer = nil
        
        NotificationCenter.default.removeObserver(self)
        UIDevice.current.isBatteryMonitoringEnabled = false
        
        eventSink = nil
        
        print("✅ BatteryHandler: Monitoring stopped")
        
        return nil
    }
    
    @objc private func handleBatteryLevelChange() {
        sendBatteryLevel()
    }
    
    private func sendBatteryLevel() {
        guard let sink = eventSink else {
            print("⚠️ BatteryHandler: EventSink is null")
            return
        }
        
        #if targetEnvironment(simulator)
            // Simulator: send test value
            sink(50)
            print("🔋 Battery level (simulator): 50%")
        #else
            // Real device
            let level = UIDevice.current.batteryLevel
            
            // batteryLevel returns -1.0 if battery monitoring is not enabled
            if level >= 0 {
                let percentage = Int(level * 100)
                sink(percentage)
                
                print("🔋 Battery level: \(percentage)%")
                
                // ✅ Warn if battery is low
                if percentage < 20 {
                    print("⚠️ Low battery: \(percentage)%")
                }
            } else {
                print("⚠️ Battery level unavailable")
            }
        #endif
    }
}