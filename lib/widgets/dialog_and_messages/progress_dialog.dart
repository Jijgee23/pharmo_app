import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pharmo_app/application/utilities/colors.dart';
import 'package:pharmo_app/widgets/indicator/pharmo_indicator.dart';

/// Shows a centered loading dialog with a fixed 50px diameter indicator.
Future<T?> showPharmoProgressDialog<T>({
  bool barrierDismissible = false,
  Color barrierColor = const Color(0x33000000),
}) {
  return Get.dialog<T>(
    const PharmoProgressDialog(),
    barrierDismissible: barrierDismissible,
    barrierColor: barrierColor,
  );
}

/// Dismisses the progress dialog if it is currently visible.
void hidePharmoProgressDialog() {
  if (Get.isDialogOpen ?? false) {
    Get.back();
  }
}

class PharmoProgressDialog extends StatelessWidget {
  const PharmoProgressDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          decoration: const BoxDecoration(
            color: white,
            shape: BoxShape.circle,
          ),
          height: 65,
          width: 65,
          padding: const EdgeInsets.all(12.0),
          child: const PharmoIndicator(size: 34),
        ),
      ),
    );
  }
}
