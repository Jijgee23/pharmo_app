import 'package:flutter/material.dart';

class TwoitemsRow extends StatelessWidget {
  final String title;
  final String text;
  final Color? color;
  final Function()? onTapText;
  final double? fontSize;
  final bool? isLong;

  const TwoitemsRow(
      {super.key,
      required this.title,
      required this.text,
      this.color,
      this.onTapText,
      this.fontSize,
      this.isLong});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.blueGrey.shade800,
              fontSize: fontSize ?? 14.0,
              fontWeight: FontWeight.bold,
              overflow: TextOverflow.ellipsis,
            ),
            maxLines: 1,
            softWrap: true,
          ),
          SizedBox(
            width: isLong ?? true ? null : MediaQuery.of(context).size.width * 0.7,
            child: InkWell(
              onTap: onTapText,
              child: Text(
                text,
                style: TextStyle(
                  color: color ?? Colors.red.shade800,
                  fontSize: fontSize ?? 14.0,
                  fontWeight: FontWeight.bold,
                  overflow: TextOverflow.ellipsis,
                ),
                maxLines: 2,
                softWrap: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
