import 'package:flutter/material.dart';

class T extends StatelessWidget {
  final String? v;
  final double? fs;
  final int? maxLine;
  final Color? color;
  final FontWeight? weight;
  const T(String this.v,
      {super.key, this.fs, this.maxLine, this.color, this.weight});

  @override
  Widget build(BuildContext context) {
    return Text(
      v!,
      maxLines: maxLine ?? 1,
      softWrap: true,
      textScaler: TextScaler.noScaling,
      style: TextStyle(
        fontSize: fs ?? 12,
        color: color ?? Colors.black,
        inherit: true,
        fontWeight: weight ?? FontWeight.normal,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
