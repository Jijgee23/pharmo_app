import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

bool hasInternet(ConnectivityResult r) =>
    r == ConnectivityResult.mobile ||
    r == ConnectivityResult.wifi ||
    r == ConnectivityResult.vpn ||
    r == ConnectivityResult.ethernet;

Future<bool> isOnline() async {
  final results = await Connectivity().checkConnectivity();
  return results.any(hasInternet);
}

class ConnectivityService {
  static final Connectivity _connectivity = Connectivity();
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
}
