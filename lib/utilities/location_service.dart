import 'dart:async';
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';

class LocationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  StreamSubscription<Position>? _positionStreamSubscription;

  void startTracking(int id) async {
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

    flutterLocalNotificationsPlugin.show(
      0,
      'Байршил дамжуулж байна',
      'Таны байршлыг арын төлөвт дамжуулж байна',
      platformChannelSpecifics,
    );

    LocationSettings locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 3,
    );

    _positionStreamSubscription = Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) async {
      print("Байршил: Lat: ${position.latitude}, Long: ${position.longitude}");
      await _sendLocationToServer(position, id);
    });
  }

  void stopTracking() {
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
    print("Tracking stopped");
  }

  Future<void> _sendLocationToServer(Position position, int id) async {
    http.Response res = await apiPatch(
      'delivery/location/',
      jsonEncode({"delivery_id": id, "lat": position.latitude, "lng": position.longitude}),
    );
    if (res.statusCode == 200) {
      message('Амжилттай дамжууллаа!');
    } else {
      print("Амжилтгүй: ${res.statusCode}");
    }
  }
}
