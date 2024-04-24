import 'package:flutter/material.dart';

class CustomAlertDialog extends StatelessWidget {
  final String text;
  final Function submitFunction;
  final Function? cancelFunction;

  const CustomAlertDialog({super.key, this.text = "Устгахдаа итгэлтэй байна уу? ", required this.submitFunction, this.cancelFunction});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Устгах'),
      content: Text(
        text,
        style: const TextStyle(fontSize: 16),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            cancelFunction!();
          },
          child: const Text("Үгүй"),
        ),
        TextButton(
          onPressed: () {
            submitFunction();
          },
          child: const Text(
            "Тийм",
          ),
        ),
      ],
    );
  }
}
