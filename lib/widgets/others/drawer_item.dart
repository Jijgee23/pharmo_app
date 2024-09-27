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
            padding: const EdgeInsets.only(top: 15, bottom: 15, left: 20),
            child: Row(
              children: [
                Image.asset(
                  asset,
                  height: 24,
                  color: AppColors.primary,
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  title,
                  style: const TextStyle(
                      color: AppColors.cleanBlack,
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Container(
              decoration:const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.primary, width: 1)
                )
              ),
            ),
          )
          // Container(
          //     margin: const EdgeInsets.symmetric(horizontal: 20),
          //     child: const Divider())
        ],
      ),
    );
  }
}
