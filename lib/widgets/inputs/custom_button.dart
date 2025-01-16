import 'package:flutter/material.dart';
import 'package:pharmo_app/utilities/sizes.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback ontap;
  final Color? color;
  final Color? borderColor;
  final EdgeInsets? padding;
  final double? borderRadius;
  final Widget? child;
  const CustomButton(
      {super.key,
      required this.text,
      required this.ontap,
      this.color,
      this.borderColor,
      this.padding,
      this.child,
      this.borderRadius});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(
          color ?? theme.primaryColor,
        ),
        padding: WidgetStatePropertyAll(
          padding ?? EdgeInsets.symmetric(vertical: Sizes.height * 0.015),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            side: BorderSide(
              color:
                  borderColor != null ? Colors.transparent : theme.primaryColor,
            ),
            borderRadius: BorderRadius.circular(borderRadius ?? 50),
          ),
        ),
      ),
      onPressed: ontap,
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
}
