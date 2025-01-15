import 'package:flutter/material.dart';
import 'package:pharmo_app/utilities/sizes.dart';

class Ctnr extends StatelessWidget {
  final Widget? child;
  final EdgeInsets? margin;
  const Ctnr({super.key, required this.child, this.margin});

  @override
  Widget build(BuildContext context) {
    // theme
    final h = Sizes.height;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: h * .015, vertical: h * .015),
      margin: margin ?? EdgeInsets.only(bottom: h * .008),
      decoration: BoxDecoration(
        color: const Color(0XFFdee2ff),
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }
}
