import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pharmo_app/firebase_options.dart';

late AndroidNotificationChannel channel;
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

class FireProvider extends ChangeNotifier {
  static FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  bool isFlutterLocalNotificationsInitialized = false;
  String firebaseToken = 'noToken';
  setToken(String? n) {
    firebaseToken = n!;
    print('Setting token is $n');
    notifyListeners();
  }

  Future initFirebase() async {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    requestNotificationPermisions();
    setToken(await firebaseMessaging.getToken());
    print('TOKEN =======> $firebaseToken');
  }

  Future getDeviceToken() async {
    String? token;
    requestNotificationPermisions();
    token = await firebaseMessaging.getToken();
    setToken(token!);
  }

  void requestNotificationPermisions() async {
    if (Platform.isIOS) {
      await firebaseMessaging.requestPermission(
        alert: true,
        announcement: true,
        badge: true,
        carPlay: true,
        criticalAlert: true,
        provisional: true,
        sound: true,
      );
    }

    NotificationSettings notificationSettings =
        await firebaseMessaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );

    if (notificationSettings.authorizationStatus ==
        AuthorizationStatus.authorized) {
    } else if (notificationSettings.authorizationStatus ==
        AuthorizationStatus.provisional) {
    } else {
      print('User has denied permission');
    }
  }

  Future<void> showNotification(RemoteMessage message) async {
    AndroidNotificationChannel androidNotificationChannel =
        AndroidNotificationChannel(
      message.notification!.android!.channelId.toString(),
      message.notification!.android!.channelId.toString(),
      importance: Importance.max,
      showBadge: true,
      playSound: true,
    );

    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      androidNotificationChannel.id.toString(),
      androidNotificationChannel.name.toString(),
      channelDescription: 'Flutter Notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      ticker: 'ticker',
      sound: androidNotificationChannel.sound,
    );

    const DarwinNotificationDetails darwinNotificationDetails =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: darwinNotificationDetails,
    );

    Future.delayed(
      Duration.zero,
      () {
        flutterLocalNotificationsPlugin.show(
          0,
          message.notification!.title.toString(),
          message.notification!.body.toString(),
          notificationDetails,
        );
      },
    );
  }

  void firebaseInit(BuildContext context) {
    FirebaseMessaging.onMessage.listen((message) {
      RemoteNotification? notification = message.notification;
      // AndroidNotification? android = message.notification!.android;

      print("Notification title: ${notification!.title}");
      print("Notification title: ${notification.body}");
      print("Data: ${message.data.toString()}");

      // For IoS
      if (Platform.isIOS) {
        forgroundMessage();
      }

      if (Platform.isAndroid) {
        initLocalNotifications(context, message);
        showNotification(message);
      }
    });
  }

  Future forgroundMessage() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  void initLocalNotifications(
      BuildContext context, RemoteMessage message) async {
    var androidInitSettings =
        const AndroidInitializationSettings('@mipmap/launcher_icon');
    var iosInitSettings = const DarwinInitializationSettings();

    var initSettings = InitializationSettings(
        android: androidInitSettings, iOS: iosInitSettings);

    await flutterLocalNotificationsPlugin.initialize(initSettings,
        onDidReceiveNotificationResponse: (payload) {
      handleMesssage(context, message);
    });
  }

  void handleMesssage(BuildContext context, RemoteMessage message) {
    print('In handleMesssage function');
    print(message.data);
    if (message.data['type'] == 'text') {}
  }
}
