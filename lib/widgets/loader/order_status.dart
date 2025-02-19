import 'package:flutter/material.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/constants.dart';
import 'package:pharmo_app/utilities/utils.dart';

class OrderStatusAnimation extends StatelessWidget {
  final String process;
  final String status;
  final EdgeInsets? margin;
  const OrderStatusAnimation({
    super.key,
    required this.process,
    required this.status,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration:
          BoxDecoration(color: white, borderRadius: border10, border: Border.all(color: grey300)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          widget(process, getProcessGif(process)),
          widget(status, getStatusGif(status)),
        ],
      ),
    );
  }

  widget(String title, String url) {
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          maxLines: 2,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Image.asset(url, height: 50)
      ],
    );
  }
}
