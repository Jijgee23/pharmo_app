import 'package:flutter/material.dart';

class CustomIcon extends StatelessWidget {
  final String name;
  final double? size;

  const CustomIcon({super.key, required this.name, this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(0),
      margin: const EdgeInsets.all(0),
      child: Image.asset(
        'assets/icons/$name',
        scale: 1,
        width: size ?? 24,
      ),
    );
  }
}
