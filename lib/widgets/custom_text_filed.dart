import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final String? hintText;
  final bool? obscureText;
  final bool? isPassword;
  final IconButton? suffixIcon;

  final Function(String?)? validator;
  final Function(String?)? onChanged;

  const CustomTextField({
    super.key,
    required this.controller,
    this.hintText,
    this.obscureText,
    this.validator,
    this.keyboardType,
    this.suffixIcon,
    this.onChanged,
    this.isPassword,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SizedBox(
      width: size.width * 0.9,
      child: TextFormField(
        onChanged: onChanged,
        key: key,
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: hintText,
          border: const OutlineInputBorder(),
          suffixIcon: suffixIcon,
        ),
        obscureText: obscureText ?? false,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: validator as String? Function(String?)?,
      ),
    );
  }
}
