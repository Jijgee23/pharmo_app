import 'package:flutter/material.dart';
import 'package:pharmo_app/utilities/colors.dart';

class Button extends StatelessWidget {
  final String text;
  final Function() onTap;
  final Color? color;
  const Button(
      {super.key, required this.text, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    final meqiaQuery = MediaQuery.of(context).size.width;
    return Container(
      width: meqiaQuery * 0.35,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
          color: color ?? AppColors.main,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white)),
      child: InkWell(
        onTap: onTap,
        child: Center(
          child: Text(text, style: const TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}
