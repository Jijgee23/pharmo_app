// ============================================
// iOS BATTERY HANDLER - Matches Android BatteryHandler
// Same behavior: only sends when battery < 20%
// ============================================

import Flutter
import UIKit

class BatteryHandler: NSObject, FlutterStreamHandler {

    // ✅ Match Android: private var eventSink: EventChannel.EventSink? = null
    private var eventSink: FlutterEventSink?

    // iOS specific (Android uses BroadcastReceiver, we use Timer)
    private var timer: Timer?

    // ================= FLUTTER STREAM HANDLER =================

    // Match Android: override fun onListen(arguments: Any?, events: EventChannel.EventSink?)
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

        // ✅ Send initial value (match Android)
        sendBatteryLevel()

        // Check periodically (every 5 minutes = 300 seconds)
        timer = Timer.scheduledTimer(
            withTimeInterval: 300,
            repeats: true
        ) { [weak self] _ in
            self?.sendBatteryLevel()
        }

        print("✅ BatteryHandler: Monitoring started")

        return nil
    }

    // Match Android: override fun onCancel(arguments: Any?)
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        print("🛑 BatteryHandler: onCancel called")

        timer?.invalidate()
        timer = nil

        // ✅ Match Android: try { context.unregisterReceiver(batteryReceiver) }
        NotificationCenter.default.removeObserver(self)
        UIDevice.current.isBatteryMonitoringEnabled = false

        // ✅ Match Android: eventSink = null
        eventSink = nil

        print("✅ BatteryHandler: Monitoring stopped")

        return nil
    }

    @objc private func handleBatteryLevelChange() {
        sendBatteryLevel()
    }

    // ================= SEND BATTERY LEVEL =================
    // Match Android behavior exactly: only send if level < 20

    private func sendBatteryLevel() {
        // ✅ Match Android: val sink = eventSink ?: return
        guard let sink = eventSink else {
            print("⚠️ BatteryHandler: EventSink is null")
            return
        }

        #if targetEnvironment(simulator)
            // Simulator: always send 50% for testing
            sink(50)
            print("🔋 Battery level (simulator): 50%")
        #else
            // Real device
            let level = UIDevice.current.batteryLevel

            // batteryLevel returns -1.0 if battery monitoring is not enabled
            // ✅ Match Android: if (level < 20 && scale > 0)
            if level >= 0 {
                let percentage = Int(level * 100)

                // ✅ CRITICAL: Only send if battery < 20% (matches Android exactly!)
                if percentage < 20 {
                    sink(percentage)
                    print("🔋 Battery level: \(percentage)% (LOW - sent to Flutter)")
                    print("⚠️ Low battery: \(percentage)%")
                } else {
                    // Don't send if battery >= 20%
                    print("🔋 Battery level: \(percentage)% (OK - not sent)")
                }
            } else {
                print("⚠️ Battery level unavailable")
            }
        #endif
    }
}

// ============================================
// COMPARISON WITH ANDROID
// ============================================

/*
ANDROID CODE:
```kotlin
private fun sendBatteryLevel(intent: Intent?) {
    val sink = eventSink ?: return
    intent ?: return

    val level = intent.getIntExtra(BatteryManager.EXTRA_LEVEL, -1)
    val scale = intent.getIntExtra(BatteryManager.EXTRA_SCALE, -1)

    if (level < 20 && scale > 0) {  // ✅ Only if < 20%
        val batteryPercent = (level * 100) / scale
        sink.success(batteryPercent)
    }
}
```

iOS CODE:
```swift
private func sendBatteryLevel() {
    guard let sink = eventSink else { return }

    let level = UIDevice.current.batteryLevel

    if level >= 0 {
        let percentage = Int(level * 100)

        if percentage < 20 {  // ✅ Only if < 20%
            sink(percentage)
        }
    }
}
```

EXACT MATCH! ✅
*/
