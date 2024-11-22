import 'package:flutter/material.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/constants.dart';

class DrawerItem extends StatelessWidget {
  final String title;
  final String asset;
  final VoidCallback onTap;
  final Color? mainColor;

  const DrawerItem(
      {super.key,
      required this.title,
      required this.onTap,
      required this.asset,
      this.mainColor});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 15, bottom: 15, left: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Image.asset(
                      asset,
                      height: 24,
                      color: mainColor ?? AppColors.primary,
                    ),
                    Constants.boxH20,
                    Text(
                      title,
                      style: TextStyle(
                        color: mainColor ?? AppColors.cleanBlack,
                        overflow: TextOverflow.ellipsis,
                        fontSize: height * .0124
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Icon(
                    Icons.chevron_right,
                    color: mainColor ?? Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
