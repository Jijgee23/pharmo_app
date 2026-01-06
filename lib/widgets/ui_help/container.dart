import 'package:flutter/material.dart';
import 'package:pharmo_app/application/utilities/colors.dart';
import 'package:pharmo_app/application/utilities/constants.dart';
import 'package:pharmo_app/application/utilities/sizes.dart';

class Ctnr extends StatelessWidget {
  final Widget? child;
  final EdgeInsets? margin;
  const Ctnr({super.key, required this.child, this.margin});

  @override
  Widget build(BuildContext context) {
    final h = Sizes.height;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      padding: EdgeInsets.symmetric(horizontal: h * .015, vertical: h * .015),
      margin: margin ?? EdgeInsets.only(bottom: h * .008),
      decoration: BoxDecoration(
          // gradient: pinkGradinet,
          color: white,
          borderRadius: border10,
          border: Border.all(color: grey300)),
      child: child,
    );
  }
}
