import 'package:flutter/material.dart';
import 'package:pharmo_app/utilities/colors.dart';

final darkTheme = ThemeData(
  primaryColor: darkPrimary,
  hintColor: secondary,
  shadowColor: black,
  colorScheme: const ColorScheme(
    brightness: Brightness.dark,
    primary: darkPrimary,
    onPrimary: primary,
    secondary: secondary,
    onSecondary: white,
    error: failedColor,
    onError: failedColor,
    surface: darkPrimary,
    onSurface: darkPrimary,
  ),
  // brightness: Brightness.dark,
  scaffoldBackgroundColor: black,
  appBarTheme: const AppBarTheme(
    backgroundColor: darkPrimary,
    surfaceTintColor: darkPrimary,
    iconTheme: IconThemeData(
      color: white,
      applyTextScaling: true,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    hintStyle: const TextStyle(
      color: darkPrimary,
    ),
    focusedBorder: const OutlineInputBorder(
      borderSide: BorderSide(
        color: darkPrimary,
        width: 1,
      ),
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    labelStyle: const TextStyle(
      color: darkPrimary,
    ),
  ),
  checkboxTheme: CheckboxThemeData(
    checkColor: WidgetStateProperty.all(darkPrimary),
    overlayColor: WidgetStateProperty.all(darkPrimary),
    side: const BorderSide(color: darkPrimary, width: 1),
    fillColor: const WidgetStatePropertyAll(Colors.transparent),
  ),
  fontFamily: 'Inter',
  splashColor: Colors.transparent,
  highlightColor: Colors.transparent,
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.black, fontSize: 18),
    bodyMedium: TextStyle(color: Colors.black, fontSize: 14),
    bodySmall: TextStyle(color: Colors.black, fontSize: 10),
    displayMedium: TextStyle(color: Colors.white, fontSize: 14),
  ),
  cardColor: Colors.grey.shade200,
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: Colors.grey.shade400,
    selectedItemColor: darkPrimary,
    unselectedIconTheme: IconThemeData(
      color: darkPrimary.withOpacity(.5),
    ),
  ),
);
