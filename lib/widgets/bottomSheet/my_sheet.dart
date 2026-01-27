import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pharmo_app/application/context/color/colors.dart';

class SheetContainer extends StatelessWidget {
  final String? title;
  final List<Widget> children;
  final double spacing;
  const SheetContainer({
    super.key,
    this.title,
    required this.children,
    this.spacing = 20,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        width: double.maxFinite,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: const BoxDecoration(
          color: white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: SafeArea(
          child: Column(
            spacing: 20,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.center,
                child: Container(
                  height: 4,
                  width: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              if (title != null)
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    title!,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: spacing,
                children: children,
              )
            ],
          ),
        ),
      ),
    );
  }
}

Future mySheet({
  String? title,
  required List<Widget> children,
  bool isDismissible = false,
  double spacing = 20,
}) async {
  return await Get.bottomSheet(
    SheetContainer(
      title: title,
      spacing: spacing,
      children: children,
    ),
    isScrollControlled: true,
    isDismissible: isDismissible,
  );
}
