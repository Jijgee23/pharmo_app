import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pharmo_app/utilities/colors.dart';

void message(String message) {
  print(message);
  Get.showSnackbar(
    GetSnackBar(
      message: message,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(milliseconds: 1500),
      margin: const EdgeInsets.symmetric(horizontal: 30),
      snackStyle: SnackStyle.FLOATING,
      borderRadius: 10,
      backgroundColor: black,
      forwardAnimationCurve: Curves.easeOutQuad,
      messageText: Center(
        child: Text(
          textAlign: TextAlign.center,
          message,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    ),
  );
}

// message({required String message, required BuildContext context}) {
//   InteractiveToast.slide(
//     context,
//     title: Text(message,
//         textAlign: TextAlign.center,
//         style: const TextStyle(color: Color.fromARGB(255, 255, 255, 255))),
//     toastSetting: const SlidingToastSetting(
//       toastAlignment: Alignment.topCenter,
//       displayDuration: Duration(milliseconds: 1500),
//       showProgressBar: false,
//     ),
//     toastStyle:
//         const ToastStyle(backgroundColor: Color.fromARGB(255, 173, 69, 214)),
//     leading: const Icon(
//       Icons.info,
//       color: Colors.white,
//     ),
//   );
// }
