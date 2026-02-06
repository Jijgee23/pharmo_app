import 'package:flutter/material.dart';
import 'package:pharmo_app/application/context/theme/size/sizes.dart';

class Button extends StatelessWidget {
  final String text;
  final Function()? onTap;
  final Color? color;
  final double? width;
  const Button(
      {super.key, required this.text, this.onTap, this.color, this.width});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      width: width ?? size.width * 0.4,
      padding:
          EdgeInsets.symmetric(vertical: size.width * 0.03, horizontal: 10),
      decoration: BoxDecoration(
        color: color ?? theme.primaryColor,
        borderRadius: BorderRadius.circular(size.width * 0.05),
      ),
      child: InkWell(
        onTap: onTap ?? () => Navigator.pop(context),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
