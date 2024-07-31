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

const ts1 = TextStyle(color: Colors.blueGrey, fontSize: 12.0);
const ts2 = TextStyle(color: Colors.blueGrey, fontSize: 16.0);
const ts3 = TextStyle(color: Colors.blueGrey, fontSize: 20.0);

extension AppContext on BuildContext {
  Size get size => MediaQuery.sizeOf(this);
  double get height => MediaQuery.of(this).size.height;
  double get width => MediaQuery.of(this).size.width;
  Future push(Widget widget) async {
    await Navigator.push(
      this,
      MaterialPageRoute(builder: (context) => widget),
    );
  }

  void pop() async {
    return Navigator.pop(this);
  }
}
