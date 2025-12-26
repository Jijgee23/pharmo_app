import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pharmo_app/utilities/colors.dart';
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
                    message('⚠️ Тохиргоо нээгдэхэд алдаа гарлаа');
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
    if (!serviceEnabled) {
      return false;
    }
    LocationPermission permission = await Geolocator.checkPermission();

    print(permission);
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.always) {
      return true;
    } else {
      getMessage();
      return false;
    }
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

bool isPositionChanged(Position oldPos, Position newPos,
    [double threshold = 0.0001]) {
  return (oldPos.latitude - newPos.latitude).abs() > threshold ||
      (oldPos.longitude - newPos.longitude).abs() > threshold;
}
