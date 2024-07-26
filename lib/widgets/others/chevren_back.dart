import 'package:flutter/material.dart';

class ChevronBack extends StatelessWidget {
  const ChevronBack({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => Navigator.pop(context),
      icon: const Icon(Icons.chevron_left),
    );
  }
}
