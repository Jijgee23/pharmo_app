import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:pharmo_app/controllers/a_controlller.dart';
import 'package:pharmo_app/database/log_model.dart';
import 'package:pharmo_app/services/firebase_sevice.dart';
import 'package:pharmo_app/services/local_base.dart';
import 'package:pharmo_app/services/log_service.dart';

bool hasInternet(ConnectivityResult r) =>
    r == ConnectivityResult.mobile || r == ConnectivityResult.wifi;

Future<bool> isOnline() async {
  final results = await Connectivity().checkConnectivity();
  return results.any(hasInternet);
}

class ConnectivityService {
  static final Connectivity _connectivity = Connectivity();
  static StreamSubscription<List<ConnectivityResult>>? _subscription;
  static bool? _lastConnectionStatus;
  final StreamController<bool> _controller = StreamController.broadcast();

  ConnectivityService() {
    _connectivity.onConnectivityChanged.listen((results) {
      _controller.add(results.isNotEmpty &&
          results.any((r) => r != ConnectivityResult.none));
    });
  }

  Stream<bool> get connectivityStream => _controller.stream;
  void dispose() => _controller.close();

  static Future<bool> netWorkConnected() async {
    List<ConnectivityResult> result = await _connectivity.checkConnectivity();
    if (result.contains(ConnectivityResult.mobile) ||
        result.contains(ConnectivityResult.wifi)) {
      return true;
    }
    return false;
  }

  static Future<void> startListennetwork() async {
    debugPrint('listenting network');
    if (_subscription != null) return;
    try {
      final initialResults = await _connectivity.checkConnectivity();
      _lastConnectionStatus = initialResults.any(hasInternet);
    } catch (_) {
      _lastConnectionStatus = null;
    }

    _subscription = _connectivity.onConnectivityChanged.listen(
      (results) async {
        bool connected = (results.contains(ConnectivityResult.mobile) ||
            results.contains(ConnectivityResult.wifi));

        debugPrint("connect: $connected");
        if (!connected && await LocalBase.hasDelmanTrack() ||
            await LocalBase.hasSellerTrack()) {
          await FirebaseApi.local(
            'Интернет тасарсан',
            'Интернет холболт тасарлаа. Холболтоо шалгана уу.',
          );
          await LogService.saveModel(
            LogModel(logType: 'disconnected', desc: LogService.disconnected),
          );
        }
        if (connected && await LocalBase.hasDelmanTrack() ||
            await LocalBase.hasSellerTrack()) {
          await LogService.createLog('connection', LogService.connected);
        }
        final isConnected = results.any(hasInternet);
        if (_lastConnectionStatus != null &&
            _lastConnectionStatus == isConnected) {
          return;
        }
        _lastConnectionStatus = isConnected;
      },
      onError: (_) => _lastConnectionStatus = null,
    );
  }
}
