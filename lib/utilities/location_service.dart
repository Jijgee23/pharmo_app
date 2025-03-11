import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';

class LocationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  StreamSubscription<Position>? _positionStreamSubscription;

  void startTracking(int id) async {
    // 📌 Эхлээд locationWhenInUse зөвшөөрлийг хүснэ
    PermissionStatus loc = await Permission.location.request();

    if (loc.isGranted) {
      // 📌 Дараа нь locationAlways зөвшөөрлийг хүсэх боломжтой болно
      flutterLocalNotificationsPlugin.show(
        0,
        'Байршил дамжуулж байна',
        'Таны байршлыг арын төлөвт дамжуулж байна',
        platformChannelSpecifics,
      );

      LocationSettings locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      );

      _positionStreamSubscription =
          Geolocator.getPositionStream(locationSettings: locationSettings).listen(
        (Position position) async {
          print("📍 Байршил: Lat: ${position.latitude}, Long: ${position.longitude}");
          await _sendLocationToServer(position, id);
        },
      );
    } else {
      flutterLocalNotificationsPlugin.show(
        0,
        'Байршил хүлээгдэж байна',
        'Таны байршилыг дамжуулах эрхийг зөвшөөрөөгүй байна',
        platformChannelSpecifics,
      );
    }
  }

  void stopTracking() {
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
    message('Байршилыг дамжуулалт зогслоо!');
  }

  Future<void> _sendLocationToServer(Position position, int id) async {
    final res = await apiRequest('PATCH',
        endPoint: 'delivery/location/',
        body: {"delivery_id": id, "lat": position.latitude, "lng": position.longitude});
    if (res!.statusCode == 200) {
    } else {
      print("Амжилтгүй: ${res.statusCode}");
    }
  }
}

const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
  'location_channel',
  'Location Tracking',
  channelDescription: 'Байршлыг арын төлөвт дамжуулах',
  importance: Importance.max,
  priority: Priority.high,
  showWhen: false,
);

const NotificationDetails platformChannelSpecifics = NotificationDetails(
  android: androidPlatformChannelSpecifics,
);