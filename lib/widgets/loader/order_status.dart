import 'package:flutter/material.dart';
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
      decoration: BoxDecoration(),
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
