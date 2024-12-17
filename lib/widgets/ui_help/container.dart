import 'package:flutter/material.dart';
import 'package:pharmo_app/utilities/screen_size.dart';

class Ctnr extends StatelessWidget {
  final Widget? child;
  final EdgeInsets? margin;
  const Ctnr({super.key, required this.child, this.margin});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final h = ScreenSize.height;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: h * .015, vertical: h * .015),
      margin: margin ?? EdgeInsets.only(bottom: h * .008),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(5),
      ),
      child: child,
    );
  }
}
