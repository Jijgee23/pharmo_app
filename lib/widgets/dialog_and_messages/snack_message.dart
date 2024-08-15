import 'package:flutter/material.dart';
import 'package:pharmo_app/utilities/colors.dart';

void showFailedMessage(
    {required String message, required BuildContext context}) {
  final snackBar = SnackBar(
    showCloseIcon: true,
    closeIconColor: AppColors.primary,
    elevation: 100,
    behavior: SnackBarBehavior.floating,
    backgroundColor: AppColors.failedColor,
    duration: const Duration(milliseconds: 1500),
    content: Center(
      child: Text(
        message,
        style: const TextStyle(color: AppColors.primary),
        softWrap: true,
      ),
    ),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

void showSuccessMessage(
    {required String message, required BuildContext context}) {
  final snackBar = SnackBar(
    showCloseIcon: true,
    closeIconColor: AppColors.primary,
    elevation: 100,
    behavior: SnackBarBehavior.floating,
    backgroundColor: AppColors.succesColor,
    duration: const Duration(milliseconds: 1500),
    content: Center(
      child: Text(
        message,
        style: const TextStyle(color: AppColors.primary),
        softWrap: true,
      ),
    ),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
