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
    return Consumer2<HomeProvider, BasketProvider>(
      builder: (_, homeprovider, basketProvider, child) {
        bool isSupSelected =
            (homeprovider.supID != 0 || homeprovider.supID != null);
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
                leading: leading,
                actions: [
                  if (isSupSelected)
                    InkWell(
                      onTap: () => homeprovider
                          .changeIndex(homeprovider.userRole == 'PA' ? 1 : 2),
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
                                basketProvider.basket.totalCount.toString(),
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
            ),
          ),
        );
      },
    );
  }
}
