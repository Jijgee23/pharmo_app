import 'package:flutter/material.dart';
import 'package:pharmo_app/utilities/colors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback ontap;
  const CustomButton({super.key, required this.text, required this.ontap});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: const WidgetStatePropertyAll(
          AppColors.primary,
        ),
        padding: WidgetStatePropertyAll(
          EdgeInsets.symmetric(
            vertical: size.height * 0.015,
          ),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              25,
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
