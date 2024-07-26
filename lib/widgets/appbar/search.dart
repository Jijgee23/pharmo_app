import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CustomSearchBar extends StatelessWidget {
  final String title;
  final TextEditingController searchController;
  void Function(String)? onChanged;
  final IconButton? suffix;
  final IconButton? prefix;
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
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 45,
      width: double.infinity,
      child: TextField(
        cursorColor: Colors.black,
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
          prefixIcon: Padding(
            padding: const EdgeInsets.all(12.5),
            child: Image.asset('assets/icons/search.png', width: 20,),
          ),
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: 5),
            child: suffix,
          ),
          prefix: prefix,
        ),
      ),
    );
  }
}
