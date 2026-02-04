import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pharmo_app/application/context/color/colors.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/dialog_button.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';

class Settings {
  static Position? currentPosition;
  static Future updatePosition() async {
    currentPosition = await Geolocator.getCurrentPosition();
  }

  static Future<void> getMessage() async {
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
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold, color: black),
                  children: [
                    TextSpan(text: 'Байршилийн зөвшөөрлийг '),
                    TextSpan(
                        text: Platform.isAndroid ? 'All the time' : 'Always',
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
                onTap: () async {
                  final success = await openAppSettings();
                  if (success) {
                    Get.back(canPop: true);
                  } else {
                    messageWarning('⚠️ Тохиргоо нээгдэхэд алдаа гарлаа');
                  }
                },
              )
            ],
          ),
        ),
      ),
      barrierDismissible: false,
      transitionCurve: Curves.easeInOut,
      transitionDuration: Duration(milliseconds: 500),
    );
  }

  static Future<bool> checkAlwaysLocationPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    print("service enabled: $serviceEnabled");
    if (!serviceEnabled) {
      await openAppSettings();
    }
    LocationPermission permission = await Geolocator.checkPermission();
    print(permission);

    if (permission == LocationPermission.denied) {
      try {
        permission = await Geolocator.requestPermission();
      } catch (e) {
        if (e is PlatformException) {
          await openAppSettings();
        }
      }
    }
    if (permission == LocationPermission.deniedForever) {
      await openAppSettings();
    }
    if (permission == LocationPermission.whileInUse) {
      await openAppSettings();
    }
    if (permission == LocationPermission.always) {
      final accuricy = await Geolocator.getLocationAccuracy();
      if (permission == LocationPermission.always &&
          accuricy == LocationAccuracyStatus.precise) {
        return true;
      }
      if (accuricy != LocationAccuracyStatus.precise) {
        await openAppSettings();
      }
    }
    await Geolocator.requestPermission();
    return false;
  }

  static Future<bool> checkWhenUseLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      getMessage();
      return false;
    }

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      return true;
    } else {
      getMessage();
      return false;
    }
  }
}
