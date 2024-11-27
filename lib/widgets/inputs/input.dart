import 'package:flutter/material.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/utils.dart';

class Input extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final Function(String?)? onChanged;
  final Function()? onComplete;
  const Input(
      {super.key,
      required this.controller,
      required this.hint,
      this.onChanged,
      this.onComplete});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          boxShadow: shadow(),
          color: AppColors.cleanWhite,
          border: Border.all(color: AppColors.primary.withOpacity(.5)),
          borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.symmetric(horizontal: 5),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              onChanged: onChanged,
              onEditingComplete: onComplete,
              controller: controller,
              cursorColor: Colors.black,
              cursorHeight: 14,
              cursorWidth: .8,
              keyboardType: null,
              style: const TextStyle(fontSize: 14),
              decoration: const InputDecoration(
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 20),
                hintText: 'Имейл хаяг',
                hintStyle: TextStyle(
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
