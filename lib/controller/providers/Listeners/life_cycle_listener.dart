import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:pharmo_app/application/application.dart';

class LifeCycleListener extends ChangeNotifier
    implements WidgetsBindingObserver {
  final LogService logService = LogService();

  LifeCycleListener() {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAccessibilityFeatures() {}

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    final context = GlobalKeys.navigatorKey.currentContext;
    if (context != null) {
      final jagger = context.read<JaggerProvider>();
      await jagger.loadPermission();
    }
    if (state == AppLifecycleState.paused) {
      bool isSharingLocation = await hasTrack();
      if (isSharingLocation) {
        final logType =
            Authenticator.security!.isSaler ? 'Борлуулалт' : 'Түгээлт';
        await logService.createLog(
          logType,
          'Байршил дамжуулах явцад бусад апп руу шилжсэн.  (${DateTime.now().toIso8601String()})',
        );
      }
    }
    if (state == AppLifecycleState.resumed) {
      resumeWhenHasTrack(state);
    }
  }

  void resumeWhenHasTrack(AppLifecycleState state) async {
    Security? security = Authenticator.security;
    if (security == null || (security != null && security.role == 'PA')) {
      return;
    }
    Future.microtask(
      () async {
        await GlobalKeys.navigatorKey.currentContext!
            .read<JaggerProvider>()
            .tracking();
      },
    );
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
