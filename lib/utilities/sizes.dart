import 'package:flutter/material.dart';
import 'package:pharmo_app/global_key.dart';

class Sizes {
  static double get width {
    return MediaQuery.of(GlobalKeys.navigatorKey.currentContext!).size.width;
  }

  static double get height {
    return MediaQuery.of(GlobalKeys.navigatorKey.currentContext!).size.height;
  }

  static final smallFontSize = height * 0.012;
  static final mediulFontSize = height * 0.016;
  static final bigFontSize = height * 0.02;
}

final theme = Theme.of(GlobalKeys.navigatorKey.currentState!.context);

final defaultDecoration = BoxDecoration(
  border: Border.all(color: theme.primaryColor),
  borderRadius: BorderRadius.circular(
    Sizes.smallFontSize,
  ),
);
