// import 'package:flutter/material.dart';
// import 'package:pharmo_app/application/function/utilities/a_utils.dart';

// class Ibtn extends StatelessWidget {
//   final Color? color;
//   final Color? bColor;
//   final IconData icon;
//   final Function() onTap;
//   const Ibtn(
//       {super.key,
//       this.color,
//       required this.onTap,
//       required this.icon,
//       this.bColor});

//   @override
//   Widget build(BuildContext context) {
//     return IconButton(
//       onPressed: onTap,
//       style: ElevatedButton.styleFrom(
//         shape: CircleBorder(),
//         backgroundColor: bColor ?? Colors.white,
//         overlayColor: primary.withAlpha(100),
//         padding: EdgeInsets.all(2),
//       ),
//       icon: Icon(icon, color: color ?? Colors.black),
//     );
//   }
// }
