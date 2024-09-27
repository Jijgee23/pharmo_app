import 'package:flutter/material.dart';

class MyIcon extends StatelessWidget {
  final String name;
  final double? size;
  final VoidCallback? onTap;
  const MyIcon({super.key, required this.name, this.size, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(0),
        margin: const EdgeInsets.all(0),
        child: Image.asset(
          'assets/icons_2/$name',
          scale: 1,
          width: size ?? 24,
        ),
      ),
    );
  }
}
