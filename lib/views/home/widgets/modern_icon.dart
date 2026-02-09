import 'package:flutter/material.dart';

class ModernIcon extends StatelessWidget {
  final void Function()? onPressed;
  final IconData iconData;
  const ModernIcon({
    super.key,
    this.onPressed,
    required this.iconData,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey.shade100,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 0,
        padding: EdgeInsets.all(14),
      ),
      icon: Icon(
        iconData,
        color: Colors.black,
        size: 20,
      ),
    );
  }
}
