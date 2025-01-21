import 'package:flutter/material.dart';
import 'package:pharmo_app/widgets/appbar/side_menu_appbar.dart';

class DefaultBox extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? action;
  const DefaultBox(
      {super.key, required this.title, required this.child, this.action});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: SideAppBar(
        title: Text(
          title,
          maxLines: 2,
          style: const TextStyle(
              color: Colors.white, fontSize: 15, letterSpacing: 1),
        ),
        action: action,
      ),
      body: child,
    );
  }
}
