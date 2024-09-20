import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/basket_provider.dart';
import 'package:pharmo_app/controllers/home_provider.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:provider/provider.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? leadingOnTap;
  final IconData? icon;
  final Widget? leading;
  final Widget? title;

  const CustomAppBar({
    super.key,
    this.leadingOnTap,
    this.icon,
    this.leading,
    this.title,
  }) : preferredSize = const Size.fromHeight(kToolbarHeight);

  @override
  final Size preferredSize;

  @override
  Widget build(BuildContext context) {
    final basketProvider = Provider.of<BasketProvider>(context);
    return Consumer<HomeProvider>(builder: (_, homeprovider, child) {
      return ChangeNotifierProvider(
        create: (context) => BasketProvider(),
        child: AppBar(
          iconTheme: const IconThemeData(color: AppColors.primary),
          centerTitle: true,
          title: title,
          leading: leading,
          backgroundColor: Colors.white,
          foregroundColor: Colors.white,
          shadowColor: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 0,
          actions: [
            IconButton(
                icon: Image.asset(
                  'assets/icons/notification.png',
                  height: 24,
                ),
                onPressed: () {}),
            Container(
              margin: const EdgeInsets.only(right: 15),
              child: InkWell(
                onTap: () {
                  homeprovider
                      .changeIndex(homeprovider.userRole == 'PA' ? 2 : 3);
                },
                child: badges.Badge(
                  badgeContent: Text(
                    "${basketProvider.count}",
                    style: const TextStyle(color: Colors.white, fontSize: 11),
                  ),
                  badgeStyle: const badges.BadgeStyle(
                    badgeColor: Colors.blue,
                  ),
                  child: Image.asset(
                    'assets/icons/shop-tab.png',
                    height: 24,
                    width: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
