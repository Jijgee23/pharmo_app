import 'package:flutter/material.dart';
import 'package:pharmo_app/utilities/colors.dart';

class Constants {
  static var headerTextStyle = const TextStyle(
    overflow: TextOverflow.ellipsis,
    color: AppColors.primary,
    fontSize: 16,
    fontWeight: FontWeight.w400,
  );
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
}
