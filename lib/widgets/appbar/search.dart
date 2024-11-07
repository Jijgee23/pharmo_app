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
      height: 40,
      width: double.infinity,
      child: TextField(
        keyboardType: keyboardType,
        controller: searchController,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        decoration: InputDecoration(
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            // borderSide: const BorderSide(
            // ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          hintText: title,
          hintStyle: const TextStyle(fontSize: 14),
          prefixIcon: prefix ?? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
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
