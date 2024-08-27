import 'package:flutter/material.dart';
import 'package:pharmo_app/utilities/colors.dart';

final darkTheme = ThemeData(
  primaryColor: AppColors.primary,
  secondaryHeaderColor: AppColors.secondary,
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.cleanBlack,
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
    ),
  ),
);
  