import 'package:flutter/material.dart';
import 'package:pharmo_app/utilities/colors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback ontap;
  const CustomButton({super.key, required this.text, required this.ontap});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Card(
      color: AppColors.primary,
      child: InkWell(
      onTap: ontap,
      child: Container(
          decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
        width: size.width * 0.75,
        height: size.height * 0.08,
        child: Center(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white),
          ),
        ),
        ),
      ),
    );
  }
}
