import 'package:flutter/material.dart';
import 'package:pharmo_app/widgets/others/chevren_back.dart';

class SideMenuAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  const SideMenuAppbar({super.key, required this.title})
      : preferredSize = const Size.fromHeight(kToolbarHeight);

  @override
  final Size preferredSize;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 40,
      title: Text(title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)),
      centerTitle: true,
      leading: const ChevronBack(),
    );
  }
}
