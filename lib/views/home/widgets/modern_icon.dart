import 'package:flutter/material.dart';

class ModernIcon extends StatelessWidget {
  final void Function()? onPressed;
  final IconData iconData;
  final Color? color;

  const ModernIcon({
    super.key,
    this.onPressed,
    required this.iconData,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Icon(
          iconData,
          color: color ?? Colors.grey.shade700,
          size: 20,
        ),
      ),
    );
  }
}
