// import CoreLocation
// import Flutter
// import Foundation
// import UserNotifications

// class PermissionHandler: NSObject {

//     private let locationManager: CLLocationManager = CLLocationManager()

//     // Байршлын зөвшөөрөл хүсэх
//     func requestLocationPermission(result: @escaping FlutterResult) {
//         let status: CLAuthorizationStatus = CLLocationManager.authorizationStatus()

//         switch status {
//         case .notDetermined:
//             locationManager.requestAlwaysAuthorization()
//             result("requesting")
//         case .restricted, .denied:
//             result("denied")
//         case .authorizedAlways, .authorizedWhenInUse:
//             result("granted")
//         @unknown default:
//             result("unknown")
//         }
//     }

//     // Мэдэгдлийн зөвшөөрөл хүсэх
//     func requestNotificationPermission(result: @escaping FlutterResult) {
//         let center = UNUserNotificationCenter.current()
//         center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
//             if let error = error {
//                 result(
//                     FlutterError(code: "ERROR", message: error.localizedDescription, details: nil))
//                 return
//             }
//             result(granted ? "granted" : "denied")
//         }
//     }

//     // Одоогийн төлөвүүдийг шалгах
//     func checkStatuses(result: @escaping FlutterResult) {
//         let locStatus = CLLocationManager.authorizationStatus()
//         let isLocationGranted =
//             (locStatus == .authorizedAlways || locStatus == .authorizedWhenInUse)

//         UNUserNotificationCenter.current().getNotificationSettings { settings in
//             let isNotifGranted = (settings.authorizationStatus == .authorized)

//             let statusMap: [String: Bool] = [
//                 "location": isLocationGranted,
//                 "notifications": isNotifGranted,
//             ]
//             result(statusMap)
//         }
//     }
// }
