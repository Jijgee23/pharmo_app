
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/home_provider.dart';
import '../../utilities/colors.dart';

class CustomDrawerHeader extends StatelessWidget {
  const CustomDrawerHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var style = const TextStyle(color: AppColors.cleanWhite, fontSize: 14);
    return Consumer<HomeProvider>(builder: (context, homeProvider, child) {
      return Container(
        decoration: const BoxDecoration(
          color: AppColors.primary,
          border: Border(
            bottom: BorderSide(color: Colors.grey),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.center,
              child: ClipOval(
                child: Image.asset(
                  'assets/icons/boy.png',
                  height: 50,
                ),
              ),
            ),
            const SizedBox(height: 10),
            homeProvider.userEmail != null
                ? Text(
              homeProvider.userEmail!,
              style: style,
            )
                : const SizedBox()
          ],
        ),
      );
    });
  }
}