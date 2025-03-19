import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/dialog_button.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';

class LocationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  StreamSubscription<Position>? _positionStreamSubscription;

  void startTracking(int id) async {
    final s = await Geolocator.checkPermission();
    await Geolocator.requestPermission();
    bool location = await Geolocator.isLocationServiceEnabled();
    if (!location) {
      await Geolocator.requestPermission();
      if (s == LocationPermission.deniedForever) {
        getMessage();
      }
    } else {
      if (s == LocationPermission.always) {
        handleTracking(id);
      } else {
        getMessage();
      }
    }
    print(s);
  }

  getMessage() {
    Get.dialog(
      Dialog(
        backgroundColor: white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20), color: white),
          child: Column(
            spacing: 20,
            mainAxisSize: MainAxisSize.min,
            children: [
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold, color: black),
                  children: [
                    TextSpan(text: 'Байршилийн зөвшөөрлийг '),
                    TextSpan(
                        text: Platform.isAndroid ? 'All them time' : 'Always',
                        style: TextStyle(color: Colors.redAccent)),
                    TextSpan(text: ' болгон тохируулна уу!')
                  ],
                ),
              ),
              DialogButton(
                  title: 'Хаах',
                  bColor: atnessGrey,
                  tColor: neonBlue,
                  onTap: () => Get.back()),
              DialogButton(
                  title: 'Тохируулах',
                  bColor: neonBlue,
                  tColor: black,
                  onTap: () => openAppSettings().then((e) => Get.back())),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
      transitionCurve: Curves.easeInOut,
      transitionDuration: Duration(milliseconds: 500),
    );
  }

  void handleTracking(int id) async {
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
        print(
            "📍 Байршил: Lat: ${position.latitude}, Long: ${position.longitude}");
        await _sendLocationToServer(position, id);
      },
    );
  }

  void stopTracking() {
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
    message('Байршилыг дамжуулалт зогслоо!');
  }

  Future<void> _sendLocationToServer(Position position, int id) async {
    final res = await apiRequest('PATCH',
        endPoint: 'delivery/location/',
        body: {
          "delivery_id": id,
          "lat": position.latitude,
          "lng": position.longitude
        });

    if (res!.statusCode == 200) {
      flutterLocalNotificationsPlugin.show(
        0,
        'Байршил дамжуулж байна',
        'Таны байршлыг арын төлөвт дамжуулж байна. өргөрөг: ${position.latitude} уртраг: ${position.longitude}',
        platformChannelSpecifics,
      );
    } else {
      print("Амжилтгүй: ${res.statusCode}");
    }
  }
}

const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
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
