import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CustomSearchBar extends StatelessWidget {
  final String title;
  final TextEditingController searchController;
  void Function(String)? onChanged;
  final Widget? suffix;
  final Widget? prefix;
  final Function()? onTapSuffux;
  final TextInputType? keyboardType;
  final Function(String)? onSubmitted;
  CustomSearchBar({
    super.key,
    this.onChanged,
    required this.searchController,
    required this.title,
    this.suffix,
    this.prefix,
    this.keyboardType,
    this.onSubmitted,
    this.onTapSuffux,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 35,
      width: double.infinity,
      child: TextField(
        keyboardType: keyboardType,
        controller: searchController,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        decoration: InputDecoration(
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: const BorderSide(
              color: Colors.black,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          hintText: title,
          hintStyle: const TextStyle(height: 1),
          prefixIcon: prefix ?? Padding(
            padding: const EdgeInsets.all(8),
            child: Image.asset(
              'assets/icons/search.png',
              width: 20,
            ),
          ),
          suffixIcon: InkWell(
            onTap: onTapSuffux,
            child: suffix,
          ),
          prefix: prefix,
        ),
      ),
    );
  }
}
