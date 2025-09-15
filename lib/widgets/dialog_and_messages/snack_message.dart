import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pharmo_app/utilities/colors.dart';

Future message(
  String message, {
  bool success = false,
  IconData icon = Icons.info,
  Color color = black,
}) async {
  Get.showSnackbar(
    GetSnackBar(
      snackPosition: SnackPosition.TOP,
      duration: const Duration(milliseconds: 2500),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      borderRadius: 16,
      backgroundColor: Colors.transparent,
      snackStyle: SnackStyle.FLOATING,
      forwardAnimationCurve: Curves.easeOutBack,
      reverseAnimationCurve: Curves.easeInBack,
      messageText: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withAlpha(25 * 9), color.withAlpha(25 * 7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withAlpha(100),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
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
