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
        } else if (!isOnline && !isDialogOpen) {
          _showNetworkDialog();
        }
        bool isSharingLocation = await Authenticator.hasTrack();

        if (isSharingLocation) {
          // The saved track outlives the session: it is only cleared when
          // the delivery/route/visit ends, not on logout or when an expired
          // session is dropped. With nobody signed in there is nothing to
          // log or sync.
          final security = Authenticator.security;
          if (security == null) return;
          final logType = security.isRepresentative
              ? 'Уулзалт'
              : security.isSaler
                  ? 'Борлуулалт'
                  : 'Түгээлт';
          await logService.createLog(
            logType,
            'Байршил дамжуулах явцад холболт ${isOnline ? "сэргэсэн" : "салсан"}. (${DateTime.now().toIso8601String()})',
          );
          if (isOnline) {
            final context = GlobalKeys.navigatorKey.currentContext;
            if (context != null && context.mounted) {
              await context.read<JaggerProvider>().syncOffineTracks();
            }
          }
        }
      },
    );
  }

  bool isDialogOpen = false;

  void _showNetworkDialog() {
    // No navigator yet (the change came in during start-up): the next
    // change tries again.
    final context = GlobalKeys.navigatorKey.currentContext;
    if (context == null) return;
    isDialogOpen = true;
    showDialog(
      barrierDismissible: false,
      context: context,
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
    final context = GlobalKeys.navigatorKey.currentContext;
    if (!isDialogOpen || context == null) return;
    Navigator.of(context).pop();
    isDialogOpen = false;
  }
}
