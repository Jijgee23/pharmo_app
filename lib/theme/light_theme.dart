import 'package:flutter/material.dart';
import 'package:pharmo_app/utilities/colors.dart';

final lightTheme = ThemeData(
  primaryColor: primary,
  hintColor: secondary,
  brightness: Brightness.light,
  scaffoldBackgroundColor: lightBackground,
  splashColor: Colors.transparent,
  highlightColor: Colors.transparent,
  appBarTheme: const AppBarTheme(
    backgroundColor: lightBackground,
    surfaceTintColor: lightBackground,
    iconTheme: IconThemeData(
      color: primary,
      applyTextScaling: true,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    hintStyle: const TextStyle(
      color: primary,
    ),
    focusedBorder: const OutlineInputBorder(
      borderSide: BorderSide(
        color: primary,
        width: 1,
      ),
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    labelStyle: const TextStyle(
      color: primary,
    ),
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
    backgroundColor: primary,
    selectedItemColor: white,
    unselectedIconTheme: IconThemeData(
      color: white.withOpacity(.5),
    ),
  ),
);
