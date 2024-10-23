import 'package:flutter/material.dart';

class ChevronBack extends StatelessWidget {
  final Color? color;
  const ChevronBack({super.key, this.color});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      splashColor: Colors.black.withOpacity(0.3),
      onTap: () => Navigator.pop(context),
      child: Padding(
        padding:const EdgeInsets.only(left: 10),
        child: Icon(
          Icons.chevron_left,
          color: color ?? Colors.black,
        ),
      ),
    );
  }
}
