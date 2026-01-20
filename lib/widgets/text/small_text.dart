import 'package:flutter/material.dart';
import 'package:pharmo_app/application/color/colors.dart';
import 'package:pharmo_app/application/size/sizes.dart';

class SmallText extends StatelessWidget {
  final String text;
  final bool? isbold;
  final Color? color;
  const SmallText(this.text, {super.key, this.isbold, this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      softWrap: true,
      style: TextStyle(
        color: color ?? black,
        fontSize: Sizes.smallFontSize + 2,
        fontWeight: (isbold == true) ? FontWeight.bold : FontWeight.w400,
      ),
    );
  }
}
