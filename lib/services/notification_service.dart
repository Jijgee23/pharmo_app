import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class Notify {
  static AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'location_channel',
    'Location Tracking',
    channelDescription: 'Байршлыг арын төлөвт дамжуулах',
    importance: Importance.max,
    priority: Priority.high,
    showWhen: false,
  );

  static NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
  );
  static local(String title, String text) {
    flutterLocalNotificationsPlugin.show(
      0,
      title,
      text,
      platformChannelSpecifics,
    );
  }

  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static initializeNotifications() {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsDarwin);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }
}
