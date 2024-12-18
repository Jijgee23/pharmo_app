import 'package:flutter/material.dart';
import 'package:pharmo_app/utilities/screen_size.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback ontap;
  final Color? color;
  final Color? borderColor;
  final EdgeInsets? padding;
  final Widget? child;
  const CustomButton(
      {super.key,
      required this.text,
      required this.ontap,
      this.color,
      this.borderColor,
      this.padding,
      this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(
          color ?? theme.primaryColor,
        ),
        padding: WidgetStatePropertyAll(
          padding ?? EdgeInsets.symmetric(vertical: ScreenSize.height * 0.015),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            side: BorderSide(
              color:
                  borderColor != null ? Colors.transparent : theme.primaryColor,
            ),
            borderRadius: BorderRadius.circular(
              10,
            ),
          ),
        ),
      ),
      onPressed: ontap,
      child: Center(
        child: child ??
            Text(
              text,
              style: TextStyle(
                  color: Colors.white, fontSize: ScreenSize.height * 0.014),
            ),
      ),
    );
  }
}
