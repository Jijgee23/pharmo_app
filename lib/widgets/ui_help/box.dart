import 'package:flutter/material.dart';
import '../../utilities/constants.dart';

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
      padding: EdgeInsets.symmetric(vertical: size.height * 0.02, horizontal: size.width * 0.03),
      decoration: BoxDecoration(
        boxShadow: [Constants.defaultShadow],
        color: Colors.white,
        borderRadius: BorderRadius.circular(size.height * 0.02),
      ),
      child: child,
    );
  }
}
