// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:pharmo_app/controllers/a_controlller.dart';
// import 'package:pharmo_app/database/log_model.dart';
// import 'package:pharmo_app/services/firebase_sevice.dart';
// import 'package:pharmo_app/services/local_base.dart';
// import 'package:pharmo_app/services/log_service.dart';

import 'package:connectivity_plus/connectivity_plus.dart';

bool hasInternet(ConnectivityResult r) =>
    r == ConnectivityResult.mobile ||
    r == ConnectivityResult.wifi ||
    r == ConnectivityResult.ethernet;

Future<bool> isOnline() async {
  final results = await Connectivity().checkConnectivity();
  return results.any(hasInternet);
}

// class ConnectivityService {
//   static final Connectivity _connectivity = Connectivity();
//   static StreamSubscription<List<ConnectivityResult>>? _subscription;
//   static bool? _lastConnectionStatus;
//   final StreamController<bool> _controller = StreamController.broadcast();

//   ConnectivityService() {
//     _connectivity.onConnectivityChanged.listen((results) {
//       _controller.add(results.isNotEmpty &&
//           results.any((r) => r != ConnectivityResult.none));
//     });
//   }

//   Stream<bool> get connectivityStream => _controller.stream;
//   void dispose() => _controller.close();

//   static Future<bool> netWorkConnected() async {
//     List<ConnectivityResult> result = await _connectivity.checkConnectivity();
//     if (result.contains(ConnectivityResult.mobile) ||
//         result.contains(ConnectivityResult.wifi)) {
//       return true;
//     }
//     return false;
//   }

//   static Future<void> startListennetwork() async {
//     debugPrint('listenting network');
//     if (_subscription != null) return;
//     try {
//       final initialResults = await _connectivity.checkConnectivity();
//       _lastConnectionStatus = initialResults.any(hasInternet);
//     } catch (_) {
//       _lastConnectionStatus = null;
//     }

//     _subscription = _connectivity.onConnectivityChanged.listen(
//       (results) async {
//         for (var r in results) {
//           print("result: $r");
//         }
//         final hasMobileData = results.contains(ConnectivityResult.mobile);
//         final hasWifi = results.contains(ConnectivityResult.wifi);
//         final hasEthernet = results.contains(ConnectivityResult.ethernet);
//         bool connected = (hasMobileData || hasWifi || hasEthernet);
//         final logService = LogService();
//         final hasDelmanTrack = await LocalBase.hasDelmanTrack();
//         final hasSellerTrack = await LocalBase.hasSellerTrack();
//         debugPrint("connect: $connected");
//         if (!connected && (hasDelmanTrack || hasSellerTrack)) {
//           await FirebaseApi.local(
//             'Интернет тасарсан',
//             'Интернет холболт тасарлаа. Холболтоо шалгана уу.',
//           );
//           await logService.saveModel(
//             LogModel(logType: 'disconnected', desc: LogService.disconnected),
//           );
//         }
//         if (connected && (hasDelmanTrack || hasSellerTrack)) {
//           await logService.createLog('connection', LogService.connected);
//           final user = LocalBase.security;
//           if (user == null) return;
//           if (user.role == "D") {
//             final deliveryId = await LocalBase.getDelmanTrackId();
//             if (deliveryId != 0) {
//               // JaggerProvider().getTrackBox();
//             }
//           }
//         }
//         final isConnected = results.any(hasInternet);
//         if (_lastConnectionStatus != null &&
//             _lastConnectionStatus == isConnected) {
//           return;
//         }
//         _lastConnectionStatus = isConnected;
//       },
//       onError: (_) => _lastConnectionStatus = null,
//     );
//   }
// }
