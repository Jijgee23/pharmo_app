import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pharmo_app/application/services/firebase_sevice.dart';

class DeviceManager {
  static final DeviceManager _instance = DeviceManager._internal();
  DeviceManager._internal();
  factory DeviceManager() {
    return _instance;
  }

  Future<String> loadVersionAppversion() async {
    final info = await PackageInfo.fromPlatform();
    appVersion = info.version;
    return info.version;
  }

  String appVersion = '';

  Future<Device> deviceInfo() async {
    DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    final token = await FirebaseApi.getToken();
    await loadVersionAppversion();
    if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfoPlugin.iosInfo;
      return Device(
        brand: 'Apple',
        name: iosInfo.name,
        model: iosInfo.model,
        modelVersion: iosInfo.utsname.machine,
        os: iosInfo.systemName,
        osVersion: iosInfo.systemVersion,
        id: iosInfo.identifierForVendor ?? '',
        firebaseToken: token,
        type: "IOS",
      );
    }
    AndroidDeviceInfo android = await deviceInfoPlugin.androidInfo;
    return Device(
      brand: android.brand,
      name: android.name,
      model: android.model,
      modelVersion: android.device,
      os: Platform.operatingSystem,
      osVersion: Platform.operatingSystemVersion,
      id: android.id,
      firebaseToken: token,
      type: "ANDROID",
    );
  }
}


class Device {
  final String brand;
  final String name;
  final String model;
  final String modelVersion;
  final String os;
  final String osVersion;
  final String id;
  final String firebaseToken;
  final String type;
  Device({
    required this.brand,
    required this.name,
    required this.model,
    required this.modelVersion,
    required this.os,
    required this.osVersion,
    required this.id,
    required this.firebaseToken,
    required this.type,
  });
}
