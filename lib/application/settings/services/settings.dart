import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pharmo_app/application/theme/color/colors.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/dialog_button.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';

class Settings {
  static Position? currentPosition;
  static Future updatePosition() async {
    currentPosition = await Geolocator.getCurrentPosition();
  }

  static Future<void> getMessage() async {
    Future<void> handler() async {
      final success = await openAppSettings();
      if (success) {
        Get.back(canPop: true);
      } else {
        messageWarning('⚠️ Тохиргоо нээгдэхэд алдаа гарлаа');
      }
    }

    void back() => Get.back();

    return Get.dialog(
      Dialog(
        backgroundColor: white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: white,
          ),
          child: Column(
            spacing: 20,
            mainAxisSize: MainAxisSize.min,
            children: [
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: black),
                  children: [
                    TextSpan(text: 'Байршилийн зөвшөөрлийг '),
                    TextSpan(
                      text: Platform.isAndroid ? 'All the time' : 'Always',
                      style: TextStyle(color: Colors.redAccent),
                    ),
                    TextSpan(text: ' болгон тохируулна уу!')
                  ],
                ),
              ),
              DialogButton(
                title: 'Хаах',
                bColor: atnessGrey,
                tColor: neonBlue,
                onTap: back,
              ),
              DialogButton(title: 'Тохируулах', bColor: neonBlue, tColor: black, onTap: handler)
            ],
          ),
        ),
      ),
      barrierDismissible: false,
      transitionCurve: Curves.easeInOut,
      transitionDuration: Duration(milliseconds: 500),
    );
  }

  /// True when location may be taken always and precisely, as tracking a
  /// delivery or route needs. Otherwise says what to change, offers the
  /// settings, and returns false.
  static Future<bool> checkAlwaysLocationPermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      messageWarning('Байршил тогтоогчоо асаана уу!');
      await Geolocator.openLocationSettings();
      return false;
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await _requestLocationPermission();
    }
    if (permission != LocationPermission.always) {
      await getMessage();
      return false;
    }
    if (await Geolocator.getLocationAccuracy() != LocationAccuracyStatus.precise) {
      messageWarning('Байршлын тохиргооноос "Нарийвчлалтай" (Precise) сонголтыг асаана уу!');
      await openAppSettings();
      return false;
    }
    return true;
  }

  // On Android, Geolocator.requestPermission() never completes when the
  // request comes back cancelled (an empty result: asked while the settings
  // were in front, or foreground and background together on Android 11+),
  // which left the start button spinning for good. Give up after a while
  // and go by what is granted.
  static Future<LocationPermission> _requestLocationPermission() async {
    try {
      return await Geolocator.requestPermission().timeout(const Duration(seconds: 30));
    } on TimeoutException {
      return Geolocator.checkPermission();
    } on Exception {
      return Geolocator.checkPermission();
    }
  }

  static Future<bool> checkWhenUseLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      getMessage();
      return false;
    }

    if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
      return true;
    } else {
      getMessage();
      return false;
    }
  }
}
