import 'package:flutter/material.dart';

class DrawerItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const DrawerItem(
      {super.key,
      required this.title,
      required this.icon,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.lightBlue),
      title: Text(title),
      onTap: onTap,
    );
  }
}
