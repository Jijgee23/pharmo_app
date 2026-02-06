import 'package:flutter/material.dart';
import 'package:pharmo_app/controller/providers/auth_provider.dart';
import 'package:pharmo_app/controller/providers/basket_provider.dart';
import 'package:pharmo_app/controller/providers/home_provider.dart';
import 'package:pharmo_app/application/services/a_services.dart';
import 'package:provider/provider.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? leadingOnTap;
  final IconData? icon;
  final Widget? leading;
  final Widget? title;
  final List<Widget>? actions;

  const CustomAppBar({
    super.key,
    this.leadingOnTap,
    this.icon,
    this.leading,
    this.title,
    this.actions,
  }) : preferredSize = const Size.fromHeight(kToolbarHeight);
  @override
  final Size preferredSize;

  @override
  Widget build(BuildContext context) {
    return Consumer3<HomeProvider, CartProvider, AuthController>(
      builder: (_, homeprovider, cart, auth, child) {
        final security = Authenticator.security;
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
            actions: actions,
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
