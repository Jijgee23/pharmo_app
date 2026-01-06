import 'package:flutter/material.dart';
import 'package:pharmo_app/application/utilities/colors.dart';
import 'package:pharmo_app/application/utilities/sizes.dart';
import 'package:pharmo_app/views/pharmacy/promotion/marked_promo_dialog.dart';

class DialogBtn extends StatelessWidget {
  final String? title;
  final VoidCallback? onTap;
  const DialogBtn({super.key, this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Sizes.width * .3,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: onTap ?? () => Navigator.of(context).pop(),
        child: Center(
          child: text(title != null ? title! : 'Хаах', color: white),
        ),
      ),
    );
  }
}
