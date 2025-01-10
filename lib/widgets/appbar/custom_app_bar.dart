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
    final theme = Theme.of(context);
    return Consumer<HomeProvider>(
      builder: (_, homeprovider, child) {
        return ChangeNotifierProvider(
          create: (context) => BasketProvider(),
          child: AppBar(
            iconTheme: IconThemeData(color: theme.primaryColor),
            centerTitle: true,
            title: title,
            leading: leading,
            actions: [
              // Ibtn(
              //   onTap: () {},
              //   icon: Icons.notifications,
              //   color: theme.primaryColor,
              // ),
              InkWell(
                onTap: () {
                  homeprovider
                      .changeIndex(homeprovider.userRole == 'PA' ? 1 : 2);
                },
                child: Stack(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                              blurRadius: 7,
                              color: Theme.of(context).shadowColor),
                        ],
                      ),
                      child: const Center(
                          child: Icon(Icons.shopping_cart, size: 18)),
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
        );
      },
    );
  }
}
