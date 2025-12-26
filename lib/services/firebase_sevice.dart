import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pharmo_app/services/firebase_options.dart';

typedef RemoteMessageHandler = Future<void> Function(RemoteMessage message);

/// Centralises Firebase setup, permission handling, and notification plumbing.
class FirebaseApi {
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static bool _isLocalNotificationsInitialized = false;

  static RemoteMessageHandler? _foregroundMessageHandler;
  static RemoteMessageHandler? _openedAppMessageHandler;
  static RemoteMessageHandler? _backgroundMessageHandler;
  static RemoteMessageHandler? _initialMessageHandler;

  static const AndroidNotificationChannel _androidChannel =
      AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'Channel used for important notifications.',
    importance: Importance.high,
    playSound: true,
    showBadge: true,
  );

  static final NotificationDetails _notificationDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      _androidChannel.id,
      _androidChannel.name,
      channelDescription: _androidChannel.description,
      icon: '@drawable/ic_notification_white',
      priority: Priority.high,
      playSound: true,
    ),
    iOS: const DarwinNotificationDetails(),
  );

  /// Call during app start to ensure Firebase + messaging are fully ready.
  static Future<void> initFirebase() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } on FirebaseException catch (e) {
      if (e.code == 'duplicate-app') {
        debugPrint('⚠️ Firebase already initialized, using existing app.');
      } else {
        rethrow;
      }
    }
    try {
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      await _initializeLocalNotifications();
      await _initializeMessaging();

      FirebaseMessaging.onMessage.listen((message) async {
        await showFlutterNotification(message);
        await _dispatchMessage(message, _foregroundMessageHandler);
      });

      FirebaseMessaging.onMessageOpenedApp.listen(
        (message) async => _dispatchMessage(
          message,
          _openedAppMessageHandler ?? _initialMessageHandler,
        ),
      );
    } catch (error, stackTrace) {
      debugPrint('Firebase init failed: $error\n$stackTrace');
    }
  }

  @pragma('vm:entry-point')
  static Future<void> firebaseMessagingBackgroundHandler(
    RemoteMessage message,
  ) async {
    await showFlutterNotification(message);
    await _dispatchMessage(message, _backgroundMessageHandler);
  }

  static Future<void> showFlutterNotification(RemoteMessage message) async {
    final RemoteNotification? notification = message.notification;

    // Avoid duplicate banners on iOS where APNS already shows alerts.
    if (Platform.isIOS && notification != null) {
      return;
    }

    await _initializeLocalNotifications();

    final String? title = notification?.title ??
        (message.data['title'] != null ? '${message.data['title']}' : null);
    final String? body = notification?.body ??
        (message.data['body'] != null ? '${message.data['body']}' : null);

    if (title == null && body == null) {
      return;
    }

    await _localNotifications.show(
      notification?.hashCode ?? message.hashCode,
      title,
      body,
      _notificationDetails,
      payload: message.data.isEmpty ? null : message.data.toString(),
    );
  }

  static Future<void> local(String title, String text) async {
    await _initializeLocalNotifications();
    await _localNotifications.cancel(_singleNotificationId);
    await _localNotifications.show(
      _singleNotificationId,
      title,
      text,
      _notificationDetails,
    );
  }

  static const int _singleNotificationId = 1001;

  static void registerHandlers({
    RemoteMessageHandler? onForegroundMessage,
    RemoteMessageHandler? onOpenedAppMessage,
    RemoteMessageHandler? onBackgroundMessage,
    RemoteMessageHandler? onInitialMessage,
  }) {
    _foregroundMessageHandler = onForegroundMessage;
    _openedAppMessageHandler = onOpenedAppMessage;
    _backgroundMessageHandler = onBackgroundMessage;
    _initialMessageHandler = onInitialMessage;
  }

  /// Call after navigation is ready to process a notification that launched the app.
  static Future<void> handleInitialMessage() async {
    final RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage == null) return;
    await _dispatchMessage(
      initialMessage,
      _initialMessageHandler ?? _openedAppMessageHandler,
    );
  }

  static Future<void> _initializeMessaging() async {
    final FirebaseMessaging messaging = FirebaseMessaging.instance;

    await messaging.setAutoInitEnabled(true);
    await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (Platform.isIOS || Platform.isMacOS) {
      await messaging.getAPNSToken();
    }

    await messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  static Future<void> _initializeLocalNotifications() async {
    if (_isLocalNotificationsInitialized) return;

    const androidSettings =
        AndroidInitializationSettings('@drawable/ic_notification_white');
    const iosSettings = DarwinInitializationSettings(
      requestBadgePermission: true,
      requestSoundPermission: true,
      requestAlertPermission: true,
      defaultPresentSound: true,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(initSettings);
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_androidChannel);

    _isLocalNotificationsInitialized = true;
  }

  static Future<void> _dispatchMessage(
    RemoteMessage message,
    RemoteMessageHandler? handler,
  ) async {
    if (handler == null) return;
    await handler(message);
  }

  static Future<String> getToken() async {
    String result = '';
    try {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        if (iosInfo.isPhysicalDevice) {
          await FirebaseMessaging.instance.getAPNSToken();
          await Future.delayed(const Duration(seconds: 2));
          final token = await FirebaseMessaging.instance.getToken();
          if (token != null) {
            result = token;
          }
        }
      } else {
        result = await FirebaseMessaging.instance.getToken() ?? '';
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return result;
  }
}
