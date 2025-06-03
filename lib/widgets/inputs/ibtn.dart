import 'package:flutter/material.dart';
import 'package:pharmo_app/utilities/sizes.dart';

class Ibtn extends StatelessWidget {
  final Color? color;
  final Color? bColor;
  final IconData icon;
  final Function() onTap;
  const Ibtn(
      {super.key,
      this.color,
      required this.onTap,
      required this.icon,
      this.bColor});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.all(Sizes.width * 0.02),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: bColor ?? Colors.white,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(icon, color: color ?? Colors.black, size: 18),
        ),
      ),
    );
  }
}
