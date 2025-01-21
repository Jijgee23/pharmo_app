import 'package:flutter/material.dart';

class Constants {
  static const boxV10 = SizedBox(height: 10);
  static const boxV20 = SizedBox(height: 20);
  static const boxV30 = SizedBox(height: 30);
  static const boxV40 = SizedBox(height: 40);
  static const boxV50 = SizedBox(height: 50);
  static const boxH10 = SizedBox(width: 10);
  static const boxH20 = SizedBox(width: 20);
  static const boxH30 = SizedBox(width: 30);
  static const boxH40 = SizedBox(width: 40);
  static const boxH50 = SizedBox(width: 50);
  static const BoxDecoration boxDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(10)),
    border: Border(
      bottom: BorderSide(color: Colors.grey, width: 1),
    ),
  );
  static final defaultShadow = BoxShadow(
    color: Colors.grey.shade200,
    blurRadius: 3,
  );
  static var headerTextStyle = const TextStyle(
    overflow: TextOverflow.ellipsis,
    fontSize: 16,
    fontWeight: FontWeight.w400,
  );
}

String noImage =
    'https://st2.depositphotos.com/3904951/8925/v/450/depositphotos_89250312-stock-illustration-photo-picture-web-icon-in.jpg';

Duration duration = const Duration(milliseconds: 300);
