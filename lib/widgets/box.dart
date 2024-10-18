import 'package:flutter/material.dart';
import '../utilities/constants.dart';

class Box extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  const Box({super.key, required this.child, this.margin});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        boxShadow: [Constants.defaultShadow],
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }
}
