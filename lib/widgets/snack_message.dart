import 'package:flutter/material.dart';

void showFailedMessage({String? message, BuildContext? context}) {
  ScaffoldMessenger.of(context!).showSnackBar(SnackBar(
    duration:const Duration(milliseconds: 2000),
    content: Text(
      message!,
      style:const TextStyle(color: Colors.white),
    ),
    backgroundColor: const Color.fromARGB(255, 241, 124, 14),
  ),
  );
}
void showSuccessMessage({String? message, BuildContext? context}) {
  ScaffoldMessenger.of(context!).showSnackBar(
    SnackBar(
      duration: const Duration(milliseconds: 2000),
      content: Text(
        message!,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor:const Color.fromARGB(255, 6, 211, 74),
    ),
  );
}