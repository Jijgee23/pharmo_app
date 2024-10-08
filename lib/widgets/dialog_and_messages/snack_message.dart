import 'package:flutter/material.dart';
import 'package:pharmo_app/utilities/colors.dart';

void showFailedMessage(
    {required String message, required BuildContext context}) {
  final snackBar = SnackBar(
    showCloseIcon: true,
    closeIconColor: AppColors.cleanWhite,
    elevation: 100,
    behavior: SnackBarBehavior.floating,
    backgroundColor: AppColors.main,
    duration: const Duration(milliseconds: 2000),
    content: Center(
      child: Text(
        message,
        style: const TextStyle(color: AppColors.cleanWhite),
        softWrap: true,
      ),
    ),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar,
      snackBarAnimationStyle: AnimationStyle(curve: Curves.easeIn));
}

void showSuccessMessage(
    {required String message, required BuildContext context}) {
  final snackBar = SnackBar(
    showCloseIcon: true,
    closeIconColor: AppColors.cleanBlack,
    elevation: 100,
    behavior: SnackBarBehavior.floating,
    backgroundColor:  AppColors.succesColor,
    duration: const Duration(milliseconds: 1500),
    content: Center(
      child: Text(
        message,
        style: const TextStyle(color: AppColors.cleanBlack),
        softWrap: true,
      ),
    ),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar,
      snackBarAnimationStyle: AnimationStyle(curve: Curves.easeIn));
}
