import 'package:flutter/material.dart';
import 'package:pharmo_app/utilities/colors.dart';

class DialogBtn extends StatelessWidget {
  final String? title;
  final VoidCallback? onTap;
  const DialogBtn({super.key, this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100 ,
      padding:const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        onTap: onTap ?? () => Navigator.of(context).pop(),
        child: Center(
          child: Text(title != null ? title! : 'Хаах',
              style: const TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}
