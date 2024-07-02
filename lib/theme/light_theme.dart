import 'package:flutter/material.dart';
import 'package:pharmo_app/utilities/colors.dart';

final lightTheme = ThemeData(
  primaryColor: AppColors.primary,
  scaffoldBackgroundColor: AppColors.cleanWhite,
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.cleanWhite,
  ),
  inputDecorationTheme: InputDecorationTheme(
    hintStyle: const TextStyle(
      color: AppColors.primary,
    ),
    focusedBorder:const OutlineInputBorder(
      borderSide:  BorderSide(
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
);
