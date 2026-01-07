import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pharmo_app/application/utilities/colors.dart';

// Future message(
//   String message, {
//   bool success = false,
//   IconData icon = Icons.info,
//   Color color = black,
// }) async {
//   Get.showSnackbar(
//     GetSnackBar(
//       snackPosition: SnackPosition.TOP,
//       duration: const Duration(milliseconds: 2500),
//       margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//       borderRadius: 16,
//       backgroundColor: Colors.transparent,
//       snackStyle: SnackStyle.FLOATING,
//       forwardAnimationCurve: Curves.easeOutBack,
//       reverseAnimationCurve: Curves.easeInBack,
//       messageText: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [color.withAlpha(25 * 9), color.withAlpha(25 * 7)],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: [
//             BoxShadow(
//               color: color.withAlpha(100),
//               blurRadius: 10,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.start,
//           children: [
//             Icon(icon, color: Colors.white, size: 24),
//             const SizedBox(width: 10),
//             Expanded(
//               child: Text(
//                 message,
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 15,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     ),
//   );
// }

String? _lastMessage;

Future message(
  String aMessage, {
  int delay = 2500,
  bool isDismissible = true,
  VoidCallback? onTap,
  IconData? customIcon,
  List<Widget>? actions,
  bool enableHapticFeedback = true,
  Duration? animationDuration,
  Color? color,
}) async {
  if (_lastMessage == aMessage) return;
  _lastMessage = aMessage;
  Future.delayed(const Duration(milliseconds: 3000), () {
    _lastMessage = null;
  });

  // Color backgroundColor = Colors.black;
  IconData iconData = customIcon ?? Icons.check_circle;

  // switch (type) {
  //   case AlertType.error:
  //     backgroundColor = Colors.red.shade300;
  //     iconData = customIcon ?? Icons.error;
  //     if (enableHapticFeedback) {
  //       await HapticFeedback.heavyImpact();
  //     }
  //     break;
  //   case AlertType.warning:
  //     backgroundColor = Colors.deepOrange.shade900;
  //     iconData = customIcon ?? Icons.warning;
  //     if (enableHapticFeedback) {
  //       await HapticFeedback.mediumImpact();
  //     }
  //     break;
  //   case AlertType.complete:
  //     backgroundColor = Colors.green;
  //     iconData = customIcon ?? Icons.check;
  //     if (enableHapticFeedback) {
  //       await HapticFeedback.lightImpact();
  //     }
  //     break;
  //   default:
  //     backgroundColor = Colors.black;
  //     iconData = customIcon ?? Icons.check_circle;
  // }

  Get.showSnackbar(
    GetSnackBar(
      snackPosition: SnackPosition.TOP,
      duration: Duration(milliseconds: delay),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      borderRadius: 16,
      backgroundColor: color ?? black,
      snackStyle: SnackStyle.FLOATING,
      isDismissible: isDismissible,
      forwardAnimationCurve: Curves.easeOutBack,
      reverseAnimationCurve: Curves.easeInBack,
      animationDuration: animationDuration ?? const Duration(milliseconds: 300),
      onTap: onTap != null ? (_) => onTap() : null,
      mainButton: actions != null && actions.isNotEmpty
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: actions,
            )
          : null,
      messageText: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color ?? black.withAlpha(25 * 9),
              color ?? black.withAlpha(25 * 7)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color ?? black.withAlpha(100),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              iconData,
              color: Colors.white,
              size: 24,
              // semanticLabel: type?.toString() ?? 'message',
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                aMessage,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 4,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
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
