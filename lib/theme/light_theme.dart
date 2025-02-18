import 'package:flutter/material.dart';
import 'package:pharmo_app/utilities/colors.dart';

final lightTheme = ThemeData(
  primaryColor: primary,
  hintColor: secondary,
  shadowColor: Colors.grey.shade300,
  // brightness: Brightness.light,
  scaffoldBackgroundColor: white,
  splashColor: transperant,
  highlightColor: transperant,
  colorScheme: const ColorScheme(
    brightness: Brightness.light,
    primary: primary,
    onPrimary: darkPrimary,
    secondary: secondary,
    onSecondary: black,
    error: failedColor,
    onError: failedColor,
    surface: darkPrimary,
    onSurface: white,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: primary,
    surfaceTintColor: primary,
    iconTheme: IconThemeData(
      color: white,
      applyTextScaling: true,
    ),
  ),
  inputDecorationTheme: const InputDecorationTheme(
    hintStyle: TextStyle(
      color: primary,
    ),
    focusedBorder: InputBorder.none,
    border: InputBorder.none,
    labelStyle: TextStyle(color: primary),
  ),
  checkboxTheme: CheckboxThemeData(
    checkColor: WidgetStateProperty.all(primary),
    overlayColor: WidgetStateProperty.all(primary),
    side: const BorderSide(color: primary, width: 1),
    fillColor: const WidgetStatePropertyAll(Colors.transparent),
  ),
  fontFamily: 'Inter',
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
      color: white.withOpacity(.5),
    ),
  ),
);
