import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/auth_provider.dart';
import 'package:pharmo_app/controllers/basket_provider.dart';
import 'package:pharmo_app/controllers/home_provider.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/sizes.dart';
import 'package:provider/provider.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? leadingOnTap;
  final IconData? icon;
  final Widget? leading;
  final Widget? title;
  final bool? hasBasket;

  const CustomAppBar({
    super.key,
    this.leadingOnTap,
    this.icon,
    this.leading,
    this.title,
    this.hasBasket,
  }) : preferredSize = const Size.fromHeight(kToolbarHeight);
  @override
  final Size preferredSize;

  @override
  Widget build(BuildContext context) {
    return Consumer3<HomeProvider, BasketProvider, AuthController>(
      builder: (_, homeprovider, basketProvider, auth, child) {
        bool isSupSelected = (homeprovider.supID != 0 || homeprovider.supID != null);
        return ChangeNotifierProvider(
          create: (context) => BasketProvider(),
          child: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              child: AppBar(
                centerTitle: true,
                title: title,
                leading: lead(homeprovider, auth),
                actions: [
                  if (isSupSelected)
                    InkWell(
                      onTap: () => homeprovider.changeIndex(getBasketIndex(homeprovider.userRole!)),
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
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2.5),
                              decoration: BoxDecoration(
                                  color: Colors.red, borderRadius: BorderRadius.circular(15)),
                              child: Text(
                                basketProvider.basket.totalCount.toString(),
                                style: const TextStyle(
                                    color: white, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  InkWell lead(HomeProvider homeprovider, AuthController auth) {
    return InkWell(
      onTap: () => homeprovider.changeIndex(getProfileIndex(homeprovider.userRole!)),
      child: Container(
        decoration: const BoxDecoration(color: white, shape: BoxShape.circle),
        margin: const EdgeInsets.only(left: 10),
        child: Center(
          child: Text(getLetter(auth).substring(0, 1),
              style:
                  TextStyle(color: theme.primaryColor, fontSize: 18, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  String getLetter(AuthController auth) {
    final account = auth.account;
    if (account.companyName != null) {
      return account.companyName!;
    } else if (account.name != null) {
      return account.name!;
    } else {
      return account.email;
    }
  }

  getBasketIndex(String role) {
    if (role == 'PA') {
      return 1;
    } else if (role == 'S') {
      return 2;
    } else {
      return 3;
    }
  }

  getProfileIndex(String role) {
    if (role == 'PA') {
      return 2;
    } else if (role == 'S') {
      return 3;
    } else {
      return 4;
    }
  }
}
