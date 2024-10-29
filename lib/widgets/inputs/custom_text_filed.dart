import 'package:flutter/material.dart';
import 'package:pharmo_app/utilities/colors.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final String? hintText;
  final bool? obscureText;
  final bool? isPassword;
  final IconButton? suffixIcon;
  final Iterable<String>? autofillHints;

  final Function(String?)? validator;
  final Function(String?)? onChanged;
  final Function(String?)? onSubmitted;

  const CustomTextField({
    super.key,
    required this.controller,
    this.hintText,
    this.obscureText,
    this.validator,
    this.keyboardType,
    this.suffixIcon,
    this.onChanged,
    this.onSubmitted,
    this.isPassword,
    this.autofillHints,
  });

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    return SizedBox(
      // height: sh * 0.055,
      child: TextFormField(
        onChanged: onChanged,
        onFieldSubmitted: onSubmitted,
        autofillHints: autofillHints,
        key: key,
        controller: controller,
        keyboardType: keyboardType,
        cursorWidth: .8,
        cursorColor: Colors.black,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(
            horizontal: sw * 0.04,
          ),
          labelText: hintText,
          labelStyle: TextStyle(color: Colors.grey.shade700, fontSize: 14.0),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(15),
            ),
          ),
          errorBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.secondary)),
          errorStyle: const TextStyle(
            color: Colors.redAccent,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(
              color: AppColors.primary,
            ),
          ),
          suffixIcon: suffixIcon,
        ),
        obscureText: obscureText ?? false,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: validator as String? Function(String?)?,
      ),
    );
  }
}
