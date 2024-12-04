import 'package:flutter/material.dart';
import 'package:flutter_sliding_toast/flutter_sliding_toast.dart';

message({required String message, required BuildContext context}) {
  InteractiveToast.slide(
    context,
    title: Text(message,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Color.fromARGB(255, 255, 255, 255))),
    toastSetting: const SlidingToastSetting(
      toastAlignment: Alignment.topCenter,
      displayDuration: Duration(milliseconds: 1500),
      showProgressBar: false,
    ),
    toastStyle:
        const ToastStyle(backgroundColor: Color.fromARGB(255, 173, 69, 214)),
    leading: const Icon(
      Icons.info,
      color: Colors.white,
    ),
  );
}
