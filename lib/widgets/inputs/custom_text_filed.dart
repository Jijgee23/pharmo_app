import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final String? hintText;
  final bool? obscureText;
  final bool? isPassword;
  final IconButton? suffixIcon;
  final Iterable<String>? autofillHints;
  final FocusNode? focusNode;

  final Function(String?)? validator;
  final Function(String?)? onChanged;
  final Function(String?)? onSubmitted;
  final Function()? onComplete;

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
    this.focusNode,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);
    final border = OutlineInputBorder(
      borderSide:
          BorderSide(color: theme.primaryColor.withOpacity(0.7), width: .7),
    );
    return SizedBox(
      child: TextFormField(
        onChanged: onChanged,
        onFieldSubmitted: onSubmitted,
        onEditingComplete: onComplete,
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
          border: border,
          errorBorder: border,
          enabledBorder: border,
          focusedBorder: border,
          suffixIcon: suffixIcon,
        ),
        obscureText: obscureText ?? false,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: validator as String? Function(String?)?,
      ),
    );
  }
}
