import 'package:flutter/material.dart';
import 'package:pharmo_app/utilities/colors.dart';

void showFailedMessage({String? message, BuildContext? context}) {
  ScaffoldMessenger.of(context!).showSnackBar(
    SnackBar(
      duration: const Duration(milliseconds: 2000),
      content: SizedBox(
        width: double.infinity,
        child: Row(children: [
          const Icon(
            Icons.close,
            color: Colors.white,
            size: 25,
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: Text(
              message!,
              style: const TextStyle(color: Colors.white),
              softWrap: true,
            ),
          ),
        ]),
      ),
      backgroundColor: AppColors.failedColor,
    ),
  );
}

void showSuccessMessage({String? message, BuildContext? context}) {
  ScaffoldMessenger.of(context!).showSnackBar(
    SnackBar(
      duration: const Duration(milliseconds: 2000),
      content: SizedBox(
        width: double.infinity,
        child: Row(children: [
          const Icon(
            Icons.check,
            color: Colors.white,
            size: 25,
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: Text(
              message!,
              style: const TextStyle(color: Colors.white),
              softWrap: true,
            ),
          ),
        ]),
      ),
      backgroundColor: AppColors.succesColor,
    ),
  );
}
