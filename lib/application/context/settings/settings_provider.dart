import "package:flutter/services.dart";
import "package:permission_handler/permission_handler.dart";
import "package:pharmo_app/application/native_channels/native_channel.dart";
import "package:pharmo_app/controller/a_controlller.dart";

class SettingsProvider extends ChangeNotifier {
  int batteryLevel = 0;
  StreamSubscription? streamSubscription;

  Future requestPermission() async {
    await Permission.camera.request().then((val) => print(val));
  }



  Future<void> listenBattery() async {
    try {
      if (streamSubscription != null) return;
      streamSubscription =
          NativeChannel.batteryChannel.receiveBroadcastStream().listen(
        (value) {
          print(value.toString());
          if (value != null && value is num) {
            batteryLevel = value.toInt();
            notifyListeners();
          }
        },
      );
      if (streamSubscription != null) print('Listening battery');
      notifyListeners();
    } on PlatformException catch (e) {
      throw Exception(e);
    }
  }
}
