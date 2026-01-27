import 'package:flutter/material.dart';

class ModernField extends StatelessWidget {
  final TextEditingController? controller;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmited;
  final String hint;
  final IconButton? suffixIcon;
  const ModernField({
    super.key,
    this.controller,
    this.onChanged,
    this.onSubmited,
    this.hint = 'Хайх',
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TextFormField(
        style: TextStyle(
          color: Colors.grey.shade800,
          fontSize: 14,
        ),
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          isDense: true,
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
          ),
          suffixIcon: suffixIcon,
          prefixIcon: Icon(
            Icons.search_rounded,
          ),
        ),
      ),
    );
  }
}
