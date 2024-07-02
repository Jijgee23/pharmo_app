import 'package:flutter/material.dart';

void goto(Widget widget, BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => widget),
  );
}

void gotoRemoveUntil(Widget widget, BuildContext context) {
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => widget),
    (route) => false,
  );
}

chevronBack(BuildContext context) {
  return IconButton(
    onPressed: () {
      Navigator.pop(context);
    },
    icon: const Icon(Icons.chevron_left),
  );
}
