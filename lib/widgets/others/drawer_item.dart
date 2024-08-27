import 'package:flutter/material.dart';
import 'package:pharmo_app/utilities/colors.dart';

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
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12.5, horizontal: 20),
            child: Row(
              children: [
                Image.asset(
                  asset,
                  height: 24,
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  title,
                  style: const TextStyle(color: AppColors.cleanBlack),
                ),
              ],
            ),
          ),
          // Container(
          //     margin: const EdgeInsets.symmetric(horizontal: 20),
          //     child: const Divider())
        ],
      ),
    );
  }
}
