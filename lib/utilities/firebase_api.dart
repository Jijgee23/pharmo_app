// ignore_for_file: unused_local_variable

import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await setupFlutterNotifications();
  showFlutterNotification(message);
}

late AndroidNotificationChannel channel;
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

bool isFlutterLocalNotificationsInitialized = false;

Future<void> setupFlutterNotifications() async {
  if (isFlutterLocalNotificationsInitialized) {
    return;
  }
  channel = const AndroidNotificationChannel(
    'high_importance_channel', 
    'High Importance Notifications',
    description:
        'This channel is used for important notifications.', 
    importance: Importance.high,
  );

  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  isFlutterLocalNotificationsInitialized = true;
}

void showFlutterNotification(RemoteMessage message) {
  RemoteNotification? notification = message.notification;
  AndroidNotification? android = message.notification?.android;
  if (notification != null && android != null && !kIsWeb) {
    flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          icon: 'launch_background',
        ),
      ),
    );
  }
}

class FirebaseApi {
  static final _firebaseMessaging = FirebaseMessaging.instance;
  static Future<void> initNotification() async {
    try {
      await _firebaseMessaging.requestPermission();
      if (Platform.isAndroid) {
        String deviceToken = await _firebaseMessaging.getToken() ?? '';
      } else {
        String deviceToken = await _firebaseMessaging.getAPNSToken() ?? '';
      }

      // print(deviceToken);
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      if (!kIsWeb) {
        await setupFlutterNotifications();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
