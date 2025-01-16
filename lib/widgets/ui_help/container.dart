import 'package:flutter/material.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/sizes.dart';

class Ctnr extends StatelessWidget {
  final Widget? child;
  final EdgeInsets? margin;
  const Ctnr({super.key, required this.child, this.margin});

  @override
  Widget build(BuildContext context) {
    // theme
    final h = Sizes.height;
    return AnimatedContainer(
      duration: const Duration(seconds: 1),
      padding: EdgeInsets.symmetric(horizontal: h * .015, vertical: h * .015),
      margin: margin ?? EdgeInsets.only(bottom: h * .008),
      decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(20),
          border:
              Border.all(color: theme.colorScheme.onPrimary.withOpacity(.5))),
      child: child,
    );
  }
}
