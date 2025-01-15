import 'package:flutter/material.dart';
import 'package:pharmo_app/utilities/sizes.dart';

class Ibtn extends StatelessWidget {
  final Color? color;
  final IconData icon;
  final Function() onTap;
  const Ibtn({super.key, this.color, required this.onTap, required this.icon});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.all(Sizes.width * 0.02),
        padding: const EdgeInsets.all(10),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(icon, color: color ?? Colors.black, size: 18),
        ),
      ),
    );
  }
}
