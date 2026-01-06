import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pharmo_app/application/utilities/colors.dart';

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
