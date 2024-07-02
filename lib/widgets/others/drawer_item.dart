import 'package:flutter/material.dart';

class DrawerItem extends StatelessWidget {
  final String title;
  final String asset;
  final VoidCallback onTap;

  const DrawerItem(
      {super.key,
      required this.title,
      required this.onTap,
      required this.asset});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Divider(
            thickness: 1,
            color: Colors.grey[300],
          ),
        ),
        ListTile(
          leading: Image.asset(
            asset,
            height: 24,
          ),
          title: Text(title),
          onTap: onTap,
        ),
      ],
    );
  }
}
