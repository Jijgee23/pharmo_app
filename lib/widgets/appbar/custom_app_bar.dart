import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/auth_provider.dart';
import 'package:pharmo_app/controllers/basket_provider.dart';
import 'package:pharmo_app/controllers/home_provider.dart';
import 'package:pharmo_app/services/a_services.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/sizes.dart';
import 'package:provider/provider.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? leadingOnTap;
  final IconData? icon;
  final Widget? leading;
  final Widget? title;
  final bool? hasBasket;
  final List<Widget>? actions;

  const CustomAppBar({
    super.key,
    this.leadingOnTap,
    this.icon,
    this.leading,
    this.title,
    this.hasBasket,
    this.actions,
  }) : preferredSize = const Size.fromHeight(kToolbarHeight);
  @override
  final Size preferredSize;

  @override
  Widget build(BuildContext context) {
    return Consumer3<HomeProvider, BasketProvider, AuthController>(
      builder: (_, homeprovider, basketProvider, auth, child) {
        final security = LocalBase.security;
        bool isSupSelected = (security != null &&
            security.supplierId != null &&
            security.role == 'PA');
        return PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: AppBar(
            centerTitle: true,
            title: title,
            elevation: 0,
            leading: leading ?? lead(homeprovider, auth),
            actions: actions ??
                [
                  if (isSupSelected && hasBasket != false)
                    InkWell(
                      onTap: () => homeprovider
                          .changeIndex(getBasketIndex(security.role)),
                      child: Stack(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(right: 10),
                            child: const Center(
                              child: Icon(
                                Icons.shopping_cart,
                                size: 24,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Positioned(
                            right: 2,
                            top: 2,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 2.5),
                              decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(15)),
                              child: Text(
                                basketProvider.basket == null
                                    ? '0'
                                    : basketProvider.basket!.totalCount
                                        .toString(),
                                style: const TextStyle(
                                    color: white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
          ),
        );
      },
    );
  }

  InkWell lead(HomeProvider homeprovider, AuthController auth) {
    return InkWell(
      onTap: () =>
          homeprovider.changeIndex(getProfileIndex(LocalBase.security!.role)),
      child: Container(
        decoration: const BoxDecoration(color: white, shape: BoxShape.circle),
        margin: const EdgeInsets.only(left: 10),
        child: Center(
          child: Text(
            getLetter().substring(0, 1),
            style: TextStyle(
              color: theme.primaryColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  String getLetter() {
    // return 'A';
    return LocalBase.security != null ? LocalBase.security!.name : '';
  }

  getBasketIndex(String role) {
    if (role == 'PA') {
      return 1;
    } else {
      return 2;
    }
  }

  getProfileIndex(String role) {
    switch (role) {
      case 'PA':
        return 2;
      case 'S':
        return 3;
      case 'R':
        return 1;
      default:
        return 3;
    }
  }
}
