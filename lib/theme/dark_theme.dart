import 'package:flutter/material.dart';
import 'package:pharmo_app/utilities/colors.dart';

final darkTheme = ThemeData(
  primaryColor: darkPrimary,
  hintColor: secondary,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: darkBackground,
  appBarTheme: const AppBarTheme(
    backgroundColor: darkBackground,
    surfaceTintColor: darkBackground,
    iconTheme: IconThemeData(
      color: darkPrimary,
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
    bodyLarge: TextStyle(color: Colors.black),
    bodyMedium: TextStyle(color: Colors.black),
    bodySmall: TextStyle(color: Colors.black),
    displayMedium: TextStyle(color: Colors.white, fontSize: 14),
  ),
  cardColor: Colors.grey.shade200,
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: AppColors.cleanWhite,
    selectedItemColor: darkPrimary,
    unselectedIconTheme: IconThemeData(
      color: darkPrimary.withOpacity(.5),
    ),
  ),
);
