import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:pharmo_app/application/application.dart';

class ConnectionProvider extends ChangeNotifier {
  ConnectionProvider() {
    startStream();
  }

  StreamSubscription? stream;
  final connectivity = Connectivity();
  final LogService logService = LogService();

  Future startStream() async {
    print('LISTENING CONNECTION');
    stream = connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> status) async {
        bool isOnline = await NetworkChecker.hasInternet();
        notifyListeners();

        if (isOnline && isDialogOpen) {
          _hideNetworkDialog();
          return;
        }
        if (!isOnline && !isDialogOpen) {
          _showNetworkDialog();
        }
        bool isSharingLocation = await Authenticator.hasTrack();

        if (isSharingLocation) {
          final logType =
              Authenticator.security!.isSaler ? 'Борлуулалт' : 'Түгээлт';
          await logService.createLog(
            logType,
            'Байршил дамжуулах явцад холболт ${isOnline ? "сэргэсэн" : "салсан"}. (${DateTime.now().toIso8601String()})',
          );
        }
      },
    );
  }

  bool isDialogOpen = false;

  void _showNetworkDialog() {
    isDialogOpen = true;
    showDialog(
      barrierDismissible: false,
      context: GlobalKeys.navigatorKey.currentContext!,
      builder: (context) {
        return PopScope(
          canPop: false,
          child: Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: EdgeInsets.all(30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.wifi_off, color: Colors.red, size: 50),
                  SizedBox(height: 20),
                  Text(
                    'Интернет холболт салсан',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _hideNetworkDialog() {
    if (isDialogOpen) {
      Navigator.of(GlobalKeys.navigatorKey.currentContext!).pop();
      isDialogOpen = false;
    }
  }
}
