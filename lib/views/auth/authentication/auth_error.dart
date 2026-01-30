import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/widget_extensions.dart';
import 'package:pharmo_app/views/profile/profile.dart';
import 'package:pharmo_app/widgets/inputs/custom_button.dart';

class AuthError extends StatelessWidget {
  const AuthError({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 30,
          children: [
            Text(
              'Хэрэглэгч олдсонгүй, нэвтэрнэ үү!',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Icon(
              Icons.logout_outlined,
              color: Colors.redAccent,
            ),
            CustomButton(
              text: 'Нэвтрэх',
              ontap: () => logout(context),
            )
          ],
        ).paddingAll(20),
      ),
    );
  }
}
