import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pharmo_app/application/context/color/colors.dart';

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

Future<bool> confirmDialog({
  required BuildContext context,
  String title = 'Итгэлтэй байна уу?',
  String message = '',
  String? attentionText,
  Widget? content,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: white,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.question_mark, size: 60, color: Colors.green.shade700),
              const SizedBox(height: 15),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black54),
              ),
              if (attentionText != null) SizedBox(height: 15),
              if (attentionText != null)
                Text(
                  attentionText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              if (content != null) const SizedBox(height: 10),
              if (content != null) content,
              const SizedBox(height: 25),
              Row(
                spacing: 20,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey,
                        side: BorderSide(color: Colors.grey),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text('Үгүй'),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text('Тийм'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );

  return result ?? false;
}
