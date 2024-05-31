import 'package:flutter/material.dart';
import 'package:pharmo_app/utilities/colors.dart';

void showFailedMessage({String? message, BuildContext? context}) {
  ScaffoldMessenger.of(context!).showSnackBar(
    SnackBar(
      showCloseIcon: true,
      backgroundColor: AppColors.failedColor,
      duration: const Duration(milliseconds: 800),
      content: Text(
        message!,
        style: const TextStyle(color: Colors.white),
        softWrap: true,
      ),
    ),
  );
}

void showSuccessMessage({String? message, BuildContext? context}) {
  ScaffoldMessenger.of(context!).showSnackBar(
    SnackBar(
      showCloseIcon: true,
      backgroundColor: AppColors.succesColor,
      duration: const Duration(milliseconds: 800),
      content: Text(
        message!,
        style: const TextStyle(color: Colors.white),
        softWrap: true,
      ),
    ),
  );
}
