import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pharmo_app/utilities/colors.dart';

void message(String message, {bool isSuccess = false}) {
  Get.showSnackbar(
    GetSnackBar(
      message: message,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(milliseconds: 2000),
      margin: const EdgeInsets.symmetric(horizontal: 30),
      snackStyle: SnackStyle.FLOATING,
      borderRadius: 15,
      backgroundColor:
          isSuccess ? succesColor : const Color.fromARGB(255, 255, 252, 63),
      forwardAnimationCurve: Curves.linear,
      reverseAnimationCurve: Curves.linearToEaseOut,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      messageText: Center(
        child: Text(
          textAlign: TextAlign.center,
          message,
          style:
              const TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
      ),
    ),
  );
}

// void message(String message, {bool isSuccess = false}) {
//   Get.showSnackbar(
//     GetSnackBar(
//       message: message,
//       snackPosition: SnackPosition.TOP,
//       duration: const Duration(milliseconds: 2000),
//       margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//       padding: const EdgeInsets.all(16),
//       snackStyle: SnackStyle.FLOATING,
//       borderRadius: 12,
//       backgroundColor: isSuccess ? Colors.green.shade600 : Colors.red.shade600,
//       forwardAnimationCurve: Curves.easeOutExpo,
//       reverseAnimationCurve: Curves.easeInOutCubic,
//       boxShadows: [
//         BoxShadow(
//           color: Colors.black.withOpacity(0.3),
//           blurRadius: 8,
//           offset: const Offset(0, 4),
//         ),
//       ],
//       icon: Icon(
//         isSuccess ? Icons.check_circle : Icons.error,
//         color: Colors.white,
//         size: 28,
//       ),
//       messageText: Center(
//         child: Text(
//           message,
//           textAlign: TextAlign.center,
//           style: const TextStyle(
//             color: Colors.white,
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ),
//     ),
//   );
// }

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
