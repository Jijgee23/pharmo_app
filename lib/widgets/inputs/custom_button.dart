import 'package:flutter/material.dart';
import 'package:pharmo_app/utilities/colors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback ontap;
  final Color? color;
  final Color? borderColor;
  const CustomButton(
      {super.key,
      required this.text,
      required this.ontap,
      this.color,
      this.borderColor});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(
          color ?? AppColors.primary,
        ),
        padding: WidgetStatePropertyAll(
          EdgeInsets.symmetric(
            vertical: size.height * 0.015,
          ),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            side: BorderSide(
              color:
                  borderColor != null ? Colors.transparent : AppColors.primary,
            ),
            borderRadius: BorderRadius.circular(
              10,
            ),
          ),
        ),
      ),
      onPressed: ontap,
      child: Center(
        child: Text(
          text,
          style: TextStyle(color: Colors.white, fontSize: size.height * 0.013),
        ),
      ),
    );
  }
}
