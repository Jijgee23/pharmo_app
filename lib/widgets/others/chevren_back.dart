import 'package:flutter/material.dart';

class ChevronBack extends StatelessWidget {
  final Color? color;
  final Color? backgroundColor;
  const ChevronBack({super.key, this.color, this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: BackButton(
        onPressed: () => Navigator.pop(context),
        style: ButtonStyle(
          iconColor: WidgetStatePropertyAll<Color>(color ?? Colors.white),
          backgroundColor: WidgetStatePropertyAll<Color>(
              backgroundColor ?? Colors.black.withOpacity(0.2)),
        ),
      ),
    );
  }
}
