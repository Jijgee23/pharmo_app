import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CustomSearchBar extends StatelessWidget {
  final String title;
  final TextEditingController searchController;
  void Function(String)? onChanged;
  final IconButton? iconButton;
  CustomSearchBar({
    super.key,
    this.onChanged,
    required this.searchController,
    required this.title,
    this.iconButton,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 18),
      child: TextField(
        controller: searchController,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: title,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: iconButton,
        ),
      ),
    );
  }
}
