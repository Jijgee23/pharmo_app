import 'package:flutter/material.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/sizes.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final String? hintText;
  final bool? obscureText;
  final bool? isPassword;
  final IconButton? suffixIcon;
  final Iterable<String>? autofillHints;
  final FocusNode? focusNode;
  final TextAlign? align;
  final Function(String?)? validator;
  final Function(String?)? onChanged;
  final Function(String?)? onSubmitted;
  final Function()? onComplete;
  final int? maxLine;

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
    this.align,
    this.maxLine,
  });

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final border = OutlineInputBorder(
        borderSide: BorderSide(color: grey400, width: .5),
        borderRadius: BorderRadius.circular(Sizes.mediumFontSize));
    TextStyle ts =
        TextStyle(color: grey600, fontSize: 14.0, fontWeight: FontWeight.w700);
    return SizedBox(
      child: TextFormField(
        textAlign: align ?? TextAlign.start,
        style: ts,
        onChanged: onChanged,
        onFieldSubmitted: onSubmitted,
        onEditingComplete: onComplete,
        autofillHints: autofillHints,
        key: key,
        controller: controller,
        keyboardType: keyboardType,
        cursorWidth: .8,
        cursorHeight: 14,
        cursorColor: Colors.black,
        maxLines: maxLine ?? 1,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: sw * 0.04),
          // labelText: hintText,
          labelStyle: ts,
          hintText: hintText,
          hintStyle: TextStyle(
              color: grey400, fontSize: 14.0, fontWeight: FontWeight.w700),
          border: border,
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red, width: .5),
            borderRadius: BorderRadius.circular(Sizes.mediumFontSize),
          ),
          enabledBorder: border,
          focusedBorder: border,
          suffixIcon: suffixIcon,
        ),
        obscureText: obscureText ?? false,
        autovalidateMode: AutovalidateMode.onUnfocus,
        validator: validator as String? Function(String?)?,
      ),
    );
  }
}
