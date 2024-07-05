import 'package:flutter/material.dart';
import 'package:pharmo_app/utilities/colors.dart';

void showFailedMessage({String? message, BuildContext? context}) {
  final size = MediaQuery.of(context!).size;
  final snackBar = SnackBar(
    showCloseIcon: true,
    closeIconColor: AppColors.primary,
    elevation: 100,
    behavior: SnackBarBehavior.floating,
    backgroundColor: AppColors.failedColor,
    duration: const Duration(milliseconds: 1500),
    margin: EdgeInsets.only(bottom: size.height - 130, left: 15, right: 15),
    content: Center(
      child: Text(
        message!,
        style: const TextStyle(color: AppColors.primary),
        softWrap: true,
      ),
    ),
    animation: CurvedAnimation(
      parent: AnimationController(
        duration: const Duration(milliseconds: 1500),
        vsync: Scaffold.of(context),
      ),
      curve: Curves.fastOutSlowIn,
    ),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
void showSuccessMessage({String? message, BuildContext? context}) {
  final size = MediaQuery.of(context!).size;
  final snackBar = SnackBar(
    showCloseIcon: true,
    closeIconColor:  AppColors.primary,
    elevation: 100,
    behavior: SnackBarBehavior.floating,
    backgroundColor: AppColors.succesColor,
    margin: EdgeInsets.only(bottom: size.height - 130, left: 15, right: 15),
    duration: const Duration(milliseconds: 1500),
    content: Center(
      child: Text(
        message!,
        style: const TextStyle(color: AppColors.primary),
        softWrap: true,
      ),
    ),
    animation: CurvedAnimation(
      parent: AnimationController(
        duration: const Duration(milliseconds: 1500),
        vsync: Scaffold.of(context),
      ),
      curve: Curves.easeInOut,
    ),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}