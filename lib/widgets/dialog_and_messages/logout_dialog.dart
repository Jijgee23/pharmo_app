import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/auth_provider.dart';
import 'package:provider/provider.dart';

class LogoutDialog extends StatelessWidget {
  const LogoutDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);
    return ChangeNotifierProvider(
      create: (context) => AuthController(),
      child: AlertDialog(
        title: const Center(
          child: Text('Системээс гарах'),
        ),
        content: const Text('Та системээс гарахдаа итгэлтэй байна уу?'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Үгүй'),
          ),
          TextButton(
            onPressed: () {
              authController.logout();
              authController.toggleVisibile();
            },
            child: const Text('Тийм'),
          ),
        ],
      ),
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
