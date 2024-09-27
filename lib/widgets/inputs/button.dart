import 'package:flutter/material.dart';
import 'package:pharmo_app/utilities/colors.dart';

class Button extends StatelessWidget {
  final String text;
  final Function()? onTap;
  final Color? color;
  final double? width;
  const Button(
      {super.key, required this.text, this.onTap, this.color, this.width});

  @override
  Widget build(BuildContext context) {
    final meqiaQuery = MediaQuery.of(context).size.width;
    return Container(
      width: width ?? meqiaQuery * 0.4,
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      decoration: BoxDecoration(
          color: color ?? AppColors.main,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.white)),
      child: InkWell(
        onTap: onTap ?? () => Navigator.pop(context) ,
        splashColor: Colors.white,
        child: Center(
          child: Text(text, style: const TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}
