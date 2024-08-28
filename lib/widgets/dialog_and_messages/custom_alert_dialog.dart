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
      child: InkWell(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade700),
              borderRadius: BorderRadius.circular(15)),
          child: Center(
            child: Text(
              text,
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      height: MediaQuery.of(context).size.height > 600 ?  MediaQuery.of(context).size.height / 3 : 300,
      width: MediaQuery.of(context).size.width > 600 ?  MediaQuery.of(context).size.width / 2 : null,
      child: Dialog(
        backgroundColor: AppColors.cleanWhite,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.3,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
      ),
    );
  }
}
