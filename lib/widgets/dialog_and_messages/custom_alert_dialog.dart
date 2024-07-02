import 'package:flutter/material.dart';
import 'package:pharmo_app/utilities/colors.dart';

class CustomAlertDialog extends StatelessWidget {
  final String text;
  final Function submitFunction;
  final IconData icon;

  const CustomAlertDialog(
      {super.key,
      required this.text,
      required this.submitFunction,
      required this.icon});
  Widget button(String text, VoidCallback onPressed) {
    return SizedBox(
      width: 100,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.grey, width: 2),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(color: Colors.black87),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 100),
          child: Container(
            height: 250,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    decoration: TextDecoration.none,
                  ),
                  textAlign: TextAlign.center,
                ),
                Icon(icon, color: AppColors.secondary, size: 50),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    button('Үгүй', () {
                      Navigator.of(context).pop();
                    }),
                    button(
                      'Тийм',
                      () {
                        submitFunction();
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
        )
      ],
    );
  }
}
