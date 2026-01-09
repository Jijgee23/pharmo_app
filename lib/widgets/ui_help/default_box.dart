import 'package:flutter/material.dart';

class DefaultBox extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? action;
  const DefaultBox(
      {super.key, required this.title, required this.child, this.action});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          title,
          maxLines: 2,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        actions: [if (action != null) action!],
      ),
      body: child,
    );
  }
}
