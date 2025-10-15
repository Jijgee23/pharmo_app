import 'package:flutter/material.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/sizes.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback ontap;
  final Color? color;
  final Color? borderColor;
  final EdgeInsets? padding;
  final double? borderRadius;
  final Widget? child;
  final bool enabled; // 🆕

  const CustomButton({
    super.key,
    required this.text,
    required this.ontap,
    this.color,
    this.borderColor,
    this.padding,
    this.child,
    this.borderRadius,
    this.enabled = true, // 🆕 default true
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(getColor()),
        padding: WidgetStatePropertyAll(
          padding ?? EdgeInsets.symmetric(vertical: Sizes.height * 0.015),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            side: BorderSide(
              color: borderColor ?? theme.primaryColor,
            ),
            borderRadius: BorderRadius.circular(borderRadius ?? 15),
          ),
        ),
        foregroundColor: WidgetStatePropertyAll(
          enabled ? Colors.white : Colors.white.withAlpha(150),
        ),
      ),
      onPressed: enabled ? ontap : null,
      child: Center(
        child: child ??
            Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontSize: Sizes.mediumFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
      ),
    );
  }

  getColor() {
    if (color != null && enabled) {
      return color;
    } else if (color == null && enabled) {
      return theme.primaryColor;
    } else if (color != null && !enabled) {
      return grey400;
    } else if (color == null && !enabled) {
      return grey400;
    }
  }
}
