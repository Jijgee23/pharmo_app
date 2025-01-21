import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pharmo_app/utilities/sizes.dart';

class SheetContainer extends StatelessWidget {
  final String? title;
  final List<Widget> children;
  const SheetContainer({super.key, this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    const space = SizedBox(height: Sizes.mediumFontSize);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.center,
            child: Container(
              height: 4,
              width: 50,
              decoration: BoxDecoration(
                  color: Colors.grey, borderRadius: BorderRadius.circular(3)),
            ),
          ),
          space,
          if (title != null)
            Align(
              alignment: Alignment.center,
              child: Text(
                title!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          space,
          Expanded(
            child: SingleChildScrollView(
              child: Wrap(
                runSpacing: 20,
                children: children,
              ),
            ),
          )
        ],
      ),
    );
  }
}

mySheet({String? title, required List<Widget> children}) {
  Get.bottomSheet(
    SheetContainer(
      title: title,
      children: children,
    ),
  );
}
