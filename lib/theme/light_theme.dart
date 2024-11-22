import 'package:flutter/material.dart';
import 'package:pharmo_app/utilities/colors.dart';

final lightTheme = ThemeData(
  primaryColor: AppColors.primary,
  scaffoldBackgroundColor: AppColors.background,
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.background,
    surfaceTintColor: AppColors.background,
  ),
  inputDecorationTheme: InputDecorationTheme(
    hintStyle: const TextStyle(
      color: AppColors.primary,
    ),
    focusedBorder: const OutlineInputBorder(
      borderSide: BorderSide(
        color: AppColors.primary,
        width: 1,
      ),
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    labelStyle: const TextStyle(
      color: AppColors.primary,
    ),
  ),
  checkboxTheme: CheckboxThemeData(
    checkColor: WidgetStateProperty.all(AppColors.primary),
    overlayColor: WidgetStateProperty.all(AppColors.primary),
    side: const BorderSide(color: AppColors.primary, width: 1),
    fillColor: const WidgetStatePropertyAll(Colors.transparent),
  ),
  fontFamily: 'Inter',
  splashColor: Colors.transparent,
  highlightColor: Colors.transparent,
);
