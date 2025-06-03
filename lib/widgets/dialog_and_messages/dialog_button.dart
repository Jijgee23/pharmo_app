import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:pharmo_app/utilities/colors.dart';

askDialog(BuildContext context, Function() onYes, String title,
    List<Widget>? children) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        child: Container(
          constraints: BoxConstraints(maxHeight: 600),
          decoration: BoxDecoration(
              color: white, borderRadius: BorderRadius.circular(15)),
          padding: const EdgeInsets.all(15),
          child: SingleChildScrollView(
            child: Column(
              spacing: 10,
              children: [
                if (title != '')
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ...children!,
                DialogButton(
                  title: 'Тийм',
                  bColor: Colors.blueAccent,
                  tColor: white,
                  onTap: onYes,
                ),
                DialogButton(
                  title: 'Үгүй',
                  bColor: grey400,
                  tColor: black,
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class DialogButton extends StatelessWidget {
  final String title;
  final Color? bColor;
  final Color? tColor;
  final Function()? onTap;
  const DialogButton({
    super.key,
    required this.title,
    this.bColor,
    this.tColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.maxFinite,
      child: ElevatedButton(
        onPressed: onTap ?? () => Navigator.pop(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: bColor ?? Colors.blueAccent,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(vertical: 12.5),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: tColor ?? Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

void myDialog({required List<Widget> children, String? title}) {
  Get.defaultDialog(
    title: title ?? '',
    titleStyle: TextStyle(
        fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
    middleTextStyle: TextStyle(fontSize: 16),
    backgroundColor: Colors.white,
    radius: 15,
    content: ConstrainedBox(
      constraints: BoxConstraints(maxHeight: 400),
      child: SingleChildScrollView(
        child: Column(
          spacing: 10,
          children: children,
        ),
      ),
    ),
    contentPadding: EdgeInsets.all(20),
  );
}
