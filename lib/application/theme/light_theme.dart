import 'package:flutter/material.dart';
import 'package:pharmo_app/application/color/colors.dart';

final lightTheme = ThemeData(
  primaryColor: primary,
  hintColor: secondary,
  shadowColor: Colors.grey.shade300,
  // brightness: Brightness.light,
  scaffoldBackgroundColor: white,
  splashColor: Colors.grey.withAlpha(50),
  highlightColor: Colors.grey.withAlpha(50),
  colorScheme: const ColorScheme(
    brightness: Brightness.light,
    primary: primary,
    onPrimary: white,
    secondary: secondary,
    onSecondary: black,
    error: Colors.red,
    onError: Colors.red,
    surface: white,
    onSurface: black,
  ),
  cardTheme: CardThemeData(
    color: white,
    elevation: 0,
    shadowColor: Colors.grey.shade300,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
      side: BorderSide(color: Colors.grey.shade300),
    ),
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: white,
    surfaceTintColor: white,
    // scrolledUnderElevation: 1,
    shadowColor: grey100,

    iconTheme: IconThemeData(
      color: black,
      applyTextScaling: true,
    ),
    elevation: 1,
    foregroundColor: black,
    actionsIconTheme: IconThemeData(
      color: black,
    ),
  ),

  inputDecorationTheme: const InputDecorationTheme(
    hintStyle: TextStyle(
      color: black,
    ),
    focusedBorder: InputBorder.none,
    border: InputBorder.none,
    // labelStyle: TextStyle(color: primary),
  ),
  checkboxTheme: CheckboxThemeData(
    checkColor: WidgetStateProperty.all(primary),
    overlayColor: WidgetStateProperty.all(primary),
    side: const BorderSide(color: primary, width: 1),
    fillColor: const WidgetStatePropertyAll(Colors.transparent),
  ),
  fontFamily: 'Sf-Pro-Text',
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.black),
    bodyMedium: TextStyle(color: Colors.black),
    bodySmall: TextStyle(color: Colors.black),
  ),
  cardColor: Colors.white,
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: white,
    selectedItemColor: white,
    unselectedIconTheme: IconThemeData(
      color: white..withAlpha(125),
    ),
  ),
);
