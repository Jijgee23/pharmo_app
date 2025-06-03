// import 'package:geolocator/geolocator.dart' show Geolocator;
// import 'package:pharmo_app/utilities/utils.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:workmanager/workmanager.dart';

// void callbackDispatcher() {
//   Workmanager().executeTask((taskName, inputData) async {
//     // Байршлыг дахин дамжуулах
//     final position = await Geolocator.getCurrentPosition();
//     final pref = await SharedPreferences.getInstance();
//     int? deliveryId = pref.getInt('deliveryId');
//     await apiRequest(
//       'PATCH',
//       endPoint: 'delivery/location/',
//       body: {
//         'delivery_id': deliveryId,
//         "lat": position.latitude,
//         "lng": position.longitude,
//       },
//     );
//     return Future.value(true);
//   });
// }

// class BackgroundTaskService {
//   static void initialize() {
//     Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
//   }

//   static void registerLocationSyncTask() {
//     Workmanager().registerPeriodicTask(
//       "locationTask",
//       "syncLocation",
//       frequency: Duration(minutes: 15),
//     );
//   }
// }
