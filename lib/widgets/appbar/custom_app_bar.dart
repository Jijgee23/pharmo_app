import 'package:flutter/material.dart';
import 'package:pharmo_app/controller/providers/auth_provider.dart';
import 'package:pharmo_app/controller/providers/basket_provider.dart';
import 'package:pharmo_app/controller/providers/home_provider.dart';
import 'package:pharmo_app/application/services/a_services.dart';
import 'package:pharmo_app/application/utilities/colors.dart';
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
        if (security == null) {
          return PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: AppBar(),
          );
        }
        return PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: AppBar(
            centerTitle: false,
            title: title,
            leading: null,
            actions: actions ??
                [
                  if (hasBasket != false)
                    InkWell(
                      onTap: () => homeprovider
                          .changeIndex(getBasketIndex(security.role)),
                      child: Stack(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(right: 10),
                            child: const Center(
                              child: Icon(Icons.shopping_cart),
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
                                  fontWeight: FontWeight.bold,
                                ),
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
