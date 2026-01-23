//
//  BatteryHandler.swift
//  Runner
//
//  Created by admin on 2026/1/22.
//

import Flutter

class BatteryHandler: NSObject, FlutterStreamHandler {
    private var eventSink: FlutterEventSink?

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink)
        -> FlutterError?
    {
        self.eventSink = events

        // Батерейны мониторингийг асаах
        UIDevice.current.isBatteryMonitoringEnabled = true

        // Батерейны түвшин өөрчлөгдөх мэдэгдлийг бүртгэх
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleBatteryLevelChange),
            name: UIDevice.batteryLevelDidChangeNotification,
            object: nil
        )

        // Цэнэглэж буй төлөв өөрчлөгдөх мэдэгдлийг бүртгэх (заавал биш)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleBatteryLevelChange),
            name: UIDevice.batteryStateDidChangeNotification,
            object: nil
        )

        // Анхны утгыг шууд илгээх
        sendBatteryLevel()

        return nil
    }

    // Stream зогсоход дуудагдана
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        NotificationCenter.default.removeObserver(self)
        eventSink = nil
        return nil
    }

    @objc private func handleBatteryLevelChange() {
        sendBatteryLevel()
    }

    private func sendBatteryLevel() {
        guard let sink = eventSink else { return }

        #if targetEnvironment(simulator)
            return
                sink(99)
        #else
            let level = UIDevice.current.batteryLevel

            if level < 0 && level < 20 {
                sink(Int(level * 100))
            }
        #endif
    }
}
