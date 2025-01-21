import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SheetContainer extends StatelessWidget {
  final String? title;
  final List<Widget> children;

  const SheetContainer({super.key, this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
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
        child: Wrap(
          runSpacing: 20,
          crossAxisAlignment: WrapCrossAlignment.center,
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
            if (title != null)
              Align(
                alignment: Alignment.center,
                child: Text(
                  title!,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            Wrap(
              runSpacing: 20,
              children: children,
            ),
          ],
        ),
      ),
    );
  }
}

void mySheet({String? title, required List<Widget> children}) {
  Get.bottomSheet(
    SheetContainer(title: title, children: children),
    isScrollControlled: true,
  );
}
