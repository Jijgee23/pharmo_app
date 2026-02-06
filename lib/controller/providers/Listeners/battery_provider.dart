import 'package:pharmo_app/application/application.dart';

class BatteryProvider extends ChangeNotifier {
  BatteryProvider() {
    startListenBattery();
  }
  void startListenBattery() async {
    print('LISTENING BATTERY');
    NativeChannel.batteryChannel.receiveBroadcastStream().listen(
      (dynamic value) async {
        if (value == null) return;
        bool isSharingLocation = await Authenticator.hasTrack();
        if (isSharingLocation) {
          final logType =
              Authenticator.security!.isSaler ? 'Борлуулалт' : 'Түгээлт';
          await LogService().createLog(
            logType,
            'Таны төхөөрөмжийн баттерей $value% байна.',
          );
          await FirebaseApi.local(
            'Баттерей сул байна',
            'Цэнэглэнэ үү, байршил дамжуулалт зогсох магадлалтай.',
          );
        }
      },
    );
  }
}
