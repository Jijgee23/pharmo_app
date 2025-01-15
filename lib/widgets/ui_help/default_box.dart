import 'package:flutter/material.dart';
import 'package:pharmo_app/widgets/others/chevren_back.dart';

class DefaultBox extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? action;
  const DefaultBox(
      {super.key, required this.title, required this.child, this.action});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: const ChevronBack(),
        title: Text(
          title,
          style: const TextStyle(
              color: Colors.white, fontSize: 15, letterSpacing: 2),
        ),
        actions: [
          action ?? SizedBox(width: size.width * 0.08),
        ],
      ),
      body: child,
    );
  }
}
