//

import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pharmo_app/application/application.dart';

class LocationPermissionListener extends ChangeNotifier
    implements WidgetsBindingObserver {
  late LocationPermission permission;
  final logger = LogService();
  Future updateState() async {
    final value = await Geolocator.checkPermission();
    if (permission != null && permission == value) return;
    permission = value;
    print("Location permission changed to $permission");
    notifyListeners();
    // await logger.createLog(
    //   'Байршил тогтоогчийн зөвшөөрөлийн төлөв өөрчлөгдсөн ${permission.toString()} ',
    //   DateTime.now().toIso8601String(),
    // );
  }

  @override
  void didChangeAccessibilityFeatures() {}

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    await updateState();
  }

  @override
  void didChangeLocales(List<Locale>? locales) {}

  @override
  void didChangeMetrics() {}

  @override
  void didChangePlatformBrightness() {}

  @override
  void didChangeTextScaleFactor() {}

  @override
  void didChangeViewFocus(ViewFocusEvent event) {}

  @override
  void didHaveMemoryPressure() {}

  @override
  Future<bool> didPopRoute() {
    throw UnimplementedError();
  }

  @override
  Future<bool> didPushRoute(String route) {
    throw UnimplementedError();
  }

  @override
  Future<bool> didPushRouteInformation(RouteInformation routeInformation) {
    throw UnimplementedError();
  }

  @override
  Future<AppExitResponse> didRequestAppExit() {
    throw UnimplementedError();
  }

  @override
  void handleCancelBackGesture() {}

  @override
  void handleCommitBackGesture() {}

  @override
  bool handleStartBackGesture(PredictiveBackEvent backEvent) {
    throw UnimplementedError();
  }

  @override
  void handleUpdateBackGestureProgress(PredictiveBackEvent backEvent) {}
}
