import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/auth_controller.dart';
import 'package:pharmo_app/widgets/custom_text_button.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);
    return ChangeNotifierProvider(
      create: (context) => AuthController(),
      child: Scaffold(
        appBar: AppBar(
          actions: [
            CustomTextButton(
                text: 'Гарах',
                onTap: () {
                  authController.logout(context);
                }),
          ],
        ),
        body: Container(
          padding: const EdgeInsets.all(20),
          child: const Center(
            child: Column(
              children: [Text('email'), Text('userID')],
            ),
          ),
        ),
      ),
    );
  }
}
