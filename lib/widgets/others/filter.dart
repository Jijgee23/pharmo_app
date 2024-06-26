import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CustomFitler extends StatelessWidget {
  final String text;
  bool selected = false;
  final ValueChanged<bool> onSelected;
  CustomFitler({
    super.key,
    required this.selected,
    required this.text,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(text),
      selected: selected,
      onSelected: onSelected,
    );
  }
}
