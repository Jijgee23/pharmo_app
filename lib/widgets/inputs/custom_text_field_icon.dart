import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pharmo_app/utilities/colors.dart';

class CustomTextFieldIcon extends StatelessWidget {
  final TextEditingController? controller;
  final Widget? prefixIconData;
  final Widget? suffixIconData;
  final String? hintText;
  final String? labelText;
  final int? maxLine;
  final bool obscureText;
  final Color? fillColor;
  final String? validatorText;
  final Function? onChanged;
  final Function? validator;
  final String? errorText;
  final bool? expands;
  final String? type;
  final String? suffix;
  final String? suffixText;
  final bool enabled;
  final TextStyle? hintTextStyle;
  final bool isNumber;
  const CustomTextFieldIcon(
      {super.key,
      this.controller,
      this.hintText,
      this.maxLine,
      this.prefixIconData,
      this.validatorText,
      this.obscureText = false,
      this.fillColor,
      this.labelText,
      this.onChanged,
      this.validator,
      this.errorText,
      this.suffixIconData,
      this.expands,
      this.type,
      this.suffix,
      this.suffixText,
      this.enabled = true,
      required this.isNumber,
      this.hintTextStyle});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      enabled: enabled,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return validatorText;
        }
        return null;
      },
      maxLines: maxLine ?? 1,
      controller: controller,
      obscureText: obscureText,
      onChanged: (value) {
        if (onChanged != null) onChanged!(value);
      },
      style: const TextStyle(color: AppColors.primary, fontSize: 15),
      cursorColor: AppColors.primary,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      inputFormatters: isNumber ? <TextInputFormatter>[FilteringTextInputFormatter.allow(RegExp(r'[0-9]')), FilteringTextInputFormatter.digitsOnly] : <TextInputFormatter>[],
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: labelText,
        hintText: hintText,
        hintStyle: hintTextStyle ?? TextStyle(fontSize: 13, color: Colors.grey.shade400, fontWeight: FontWeight.w500),
        errorText: errorText,
        errorStyle: const TextStyle(color: Colors.red),
        prefixIcon: type == "none" ? null : prefixIconData,
        suffixIcon: suffixIconData,
        suffixText: suffixText,
        suffixStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
        filled: true,
        fillColor: fillColor,
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primary)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primary)),
      ),
    );
  }
}
