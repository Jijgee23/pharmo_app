import 'package:flutter/material.dart';
import 'package:pharmo_app/utilities/utils.dart';

class Box extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  const Box({super.key, required this.child, this.margin});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      width: double.infinity,
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      padding: EdgeInsets.symmetric(vertical: size.height * 0.01, horizontal: size.width * 0.02),
      decoration: BoxDecoration(
        boxShadow: shadow(),
        color: Colors.white,
        borderRadius: BorderRadius.circular(size.height * 0.02),
      ),
      child: child,
    );
  }
}
