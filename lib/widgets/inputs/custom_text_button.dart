import 'package:flutter/material.dart';
import 'package:pharmo_app/utilities/sizes.dart';

class CustomTextButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const CustomTextButton({super.key, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 0),
        child: Text(
          text,
          style: TextStyle(
            color: theme.primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 14
          ),
        ),
      ),
    );
  }
}
