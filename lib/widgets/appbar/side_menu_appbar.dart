import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/basket_provider.dart';
import 'package:pharmo_app/controllers/home_provider.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/widgets/others/chevren_back.dart';
import 'package:provider/provider.dart';

class SideAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? leadingOnTap;
  final IconData? icon;
  final Widget? leading;
  final String? text;
  final Widget? title;
  final bool hasBasket;
  final Widget? action;
  final Color? color;

  const SideAppBar({
    super.key,
    this.leadingOnTap,
    this.icon,
    this.leading,
    this.title,
    this.hasBasket = false,
    this.action,
    this.text,
    this.color,
  }) : preferredSize = const Size.fromHeight(kToolbarHeight);
  @override
  final Size preferredSize;

  @override
  Widget build(BuildContext context) {
    return Consumer2<HomeProvider, BasketProvider>(
      builder: (_, home, basket, child) {
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
                backgroundColor: color,
                surfaceTintColor: color,
                centerTitle: true,
                title: (text != null)
                    ? Text(
                        text!,
                        maxLines: 2,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          letterSpacing: 1,
                        ),
                      )
                    : title,
                leading: leading ?? const ChevronBack(),
                actions: [if (hasBasket) basketIcon(home, basket), action ?? const SizedBox()],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget basketIcon(HomeProvider home, BasketProvider basket) {
    return InkWell(
      onTap: () => home.changeIndex(home.userRole == 'PA' ? 1 : 2),
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(right: 10),
            child: const Center(
              child: Icon(Icons.shopping_cart, size: 24, color: Colors.white),
            ),
          ),
          Positioned(
            right: 2,
            top: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2.5),
              decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(15)),
              child: Text(
                basket.basket.totalCount.toString(),
                style: const TextStyle(color: white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
