// import 'package:flutter/material.dart';
// import 'package:get/get_utils/src/extensions/export.dart';
// import 'package:pharmo_app/application/context/theme/size/sizes.dart';

// class XBox extends StatelessWidget {
//   final Widget child;
//   final EdgeInsetsGeometry? margin;
//   final List<BoxShadow>? shadow;
//   const XBox({super.key, required this.child, this.margin, this.shadow});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       margin: margin ?? const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
//       padding: EdgeInsets.symmetric(
//           vertical: context.height * 0.015, horizontal: context.width * 0.0025),
//       decoration: BoxDecoration(
//         color: theme.cardColor,
//         borderRadius: BorderRadius.circular(context.height * 0.005),
//         boxShadow: shadow,
//       ),
//       child: child,
//     );
//   }
// }
