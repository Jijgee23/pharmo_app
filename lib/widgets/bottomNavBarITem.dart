import 'package:flutter/material.dart';
import 'package:pharmo_app/utilities/colors.dart';

class NavBarIcon extends StatelessWidget {
  final String url;
  const NavBarIcon({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/icons_2/$url.png',
      height: 20,
      color: AppColors.primary,
    );
  }
}
