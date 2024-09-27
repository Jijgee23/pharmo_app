import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/auth_provider.dart';
import 'package:pharmo_app/controllers/home_provider.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:provider/provider.dart';


void showLogoutDialog(BuildContext context) {
  Widget button(String text, VoidCallback onPressed) {
    return SizedBox(
      width: 100,
      child: InkWell(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          decoration: BoxDecoration(
            color: AppColors.primary,
              border: Border.all(color: Colors.grey.shade700),
              borderRadius: BorderRadius.circular(15)),
          child: Center(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: AppColors.cleanWhite,
        child: Container(

          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const Text(
                  "Системээс гарахдаа итгэлтэй байна уу?",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    decoration: TextDecoration.none,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    button('Үгүй', () {
                      Navigator.of(context).pop();
                    }),
                    button(
                      'Тийм',
                      () {
                        Provider.of<AuthController>(context, listen: false)
                            .logout(context);
                        Provider.of<AuthController>(context, listen: false)
                            .toggleVisibile();
                        Provider.of<HomeProvider>(context, listen: false)
                            .changeIndex(0);
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      );
    },
  );
}
