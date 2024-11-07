import 'package:flutter/material.dart';

class MyRadio extends StatelessWidget {
  final String value;
  final String groupValue;
  final Function(String?)? onChanged;
  final String title;
  const MyRadio(
      {super.key,
      required this.value,
      required this.groupValue,
      this.onChanged,
      required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Radio(
          value: value,
          groupValue: groupValue,
          onChanged: onChanged,
        ),
        Text(
          title,
          style: const TextStyle(fontSize: 14.0),
        )
      ],
    );
  }
}
