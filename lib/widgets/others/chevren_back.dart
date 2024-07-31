import 'package:flutter/material.dart';

class ChevronBack extends StatelessWidget {
  const ChevronBack({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => Navigator.pop(context),
      child: const Icon(Icons.chevron_left),
    );
  }
}
