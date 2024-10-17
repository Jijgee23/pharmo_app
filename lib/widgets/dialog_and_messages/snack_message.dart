import 'package:flutter/material.dart';
import 'package:flutter_sliding_toast/flutter_sliding_toast.dart';
import 'package:pharmo_app/utilities/colors.dart';

message({required String message, required BuildContext context}) {
  InteractiveToast.slide(
    context,
    title: Text(message,
        textAlign: TextAlign.center,
        style: const TextStyle(color: AppColors.cleanWhite)),
    toastSetting: const SlidingToastSetting(
      toastAlignment: Alignment.topCenter,
      displayDuration: Duration(milliseconds: 1500),
      showProgressBar: false,
    ),
    toastStyle: const ToastStyle(backgroundColor: AppColors.primary),
  );
}
