import 'package:flutter/material.dart';
import 'package:pharmo_app/utilities/global_key.dart';

class Sizes {
  static double get width {
    return MediaQuery.of(GlobalKeys.navigatorKey.currentContext!).size.width;
  }

  static double get height {
    return MediaQuery.of(GlobalKeys.navigatorKey.currentContext!).size.height;
  }

  static const smallFontSize = 10.0;
  static const mediumFontSize = 14.0;
  static const bigFontSize = 18.0;

  static bool isTablet() {
    final mediaQuery = MediaQuery.of(GlobalKeys.navigatorKey.currentContext!);
    return mediaQuery.size.shortestSide >= 600;
  }
}

final theme = Theme.of(GlobalKeys.navigatorKey.currentState!.context);

final defaultDecoration = BoxDecoration(
  border: Border.all(color: theme.primaryColor),
  borderRadius: BorderRadius.circular(
    Sizes.smallFontSize,
  ),
);

final ctx = GlobalKeys.navigatorKey.currentState!.context;
final screenH = Sizes.height;
final screenW = Sizes.width;
String wait = 'Түр хүлээгээд дахин оролдоно уу!';
