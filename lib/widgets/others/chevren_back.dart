import 'package:flutter/material.dart';

class ChevronBack extends StatelessWidget {
  final Color? color;
  final Color? backgroundColor;
  const ChevronBack({super.key, this.color, this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => Navigator.pop(context),
      // style: IconButton.styleFrom(
      //   backgroundColor: Colors.black.withAlpha(50),
      // ),

      // ButtonStyle.(
      //   iconColor: WidgetStatePropertyAll<Color>(color ?? Colors.white),
      //   backgroundColor: WidgetStatePropertyAll<Color>(
      //     backgroundColor ?? Colors.black.withOpacity(0.2),
      //   ),
      // ),
      icon: Icon(Icons.chevron_left_rounded),
    );
  }
}
