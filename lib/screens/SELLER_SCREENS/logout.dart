import 'package:flutter/material.dart';
import 'package:pharmo_app/screens/PA_SCREENS/pharma_home_page.dart';

class SellerSettingPage extends StatelessWidget {
  const SellerSettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
          onPressed: () {
            showLogoutDialog(context);
          },
          child: const Text('Logout')),
    );
  }
}

void showLogoutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return const LogoutDialog();
    },
  );
}
