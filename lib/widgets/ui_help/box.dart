import 'package:flutter/material.dart';
import 'package:pharmo_app/application/utilities/sizes.dart';

class Box extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final List<BoxShadow>? shadow;
  const Box({super.key, required this.child, this.margin, this.shadow});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      padding: EdgeInsets.symmetric(
          vertical: Sizes.height * 0.015, horizontal: Sizes.width * 0.0025),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(Sizes.height * 0.005),
        boxShadow: shadow,
      ),
      child: child,
    );
  }
}
