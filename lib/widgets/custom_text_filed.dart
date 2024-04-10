import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final TextInputType keyboardType;
  final String hintText;
  final bool? obscureText;
  final IconData? suffixIcon;

  final Function(String?)? validator;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    required this.validator,
    required this.keyboardType,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SizedBox(
      width: size.width * 0.75,
      child: TextFormField(
        key: key,
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: hintText,
          border: const OutlineInputBorder(),
            suffixIcon: suffixIcon != null ? Icon(suffixIcon) : null
        ),
        obscureText: obscureText ??
            false, 
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: validator as String? Function(String?)?,
      ),
    );
  }
}
