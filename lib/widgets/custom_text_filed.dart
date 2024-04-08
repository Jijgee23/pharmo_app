import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final TextInputType keyboardType;
  final String hintText;
  final bool? obscureText; // Made obscureText optional

  final Function(String?)? validator;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    required this.validator,
    required this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SizedBox(
      height: size.height * 0.08,
      width: size.width * 0.75,
      child: TextFormField(
        key: key,
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: hintText,
          border: const OutlineInputBorder(),
        ),
        obscureText: obscureText ??
            false, 
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: validator as String? Function(String?)?,
      ),
    );
  }
}
