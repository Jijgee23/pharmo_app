import 'package:flutter/material.dart';
import 'package:pharmo_app/application/core/theme/color/colors.dart';

class Col extends StatelessWidget {
  final String t1;
  final String t2;
  final double? fontSize1;
  final double? fontSize2;
  final CrossAxisAlignment? cxs;
  const Col(
      {super.key, required this.t1, required this.t2, this.fontSize1, this.fontSize2, this.cxs});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: cxs ?? CrossAxisAlignment.start,
      children: [
        Text(
          t1,
          softWrap: true,
          maxLines: 2,
          style: TextStyle(
            fontSize: fontSize1 ?? 12,
            fontWeight: FontWeight.bold,
            color: black.withOpacity(.5),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          t2,
          maxLines: 1,
          softWrap: true,
          style: TextStyle(
            fontSize: fontSize2 ?? 14,
            fontWeight: FontWeight.bold,
            overflow: TextOverflow.ellipsis,
            color: black,
          ),
        ),
      ],
    );
  }
}
