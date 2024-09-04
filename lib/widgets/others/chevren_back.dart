import 'package:flutter/material.dart';

class ChevronBack extends StatelessWidget {
  const ChevronBack({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      splashColor: Colors.black.withOpacity(0.3),
      onTap: () => Navigator.pop(context),
      child: Container(
          margin: const EdgeInsets.all(3),
          child: const Icon(Icons.chevron_left)),
    );
  }
}
