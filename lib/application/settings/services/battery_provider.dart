import 'package:pharmo_app/application/application.dart';

class BatteryProvider extends ChangeNotifier {
  BatteryProvider() {
    startListenBattery();
  }

  void startListenBattery() {
    NativeChannel.batteryChannel.receiveBroadcastStream().listen(
      (dynamic value) async {
        if (value == null) return;
        final bool hasTrack = await Authenticator.hasTrack();
        if (!hasTrack) return;
        final bool serviceRunning = await NativeChannel.isServiceRunning();
        if (!serviceRunning) return;
        final logType = Authenticator.security!.isSaler ? 'Борлуулалт' : 'Түгээлт';
        await LogService().createLog(
          logType,
          'Таны төхөөрөмжийн баттерей $value% байна.',
        );
        await FirebaseApi.local(
          'Баттерей сул байна',
          'Цэнэглэнэ үү, байршил дамжуулалт зогсох магадлалтай.',
        );
      },
    );
  }
}
