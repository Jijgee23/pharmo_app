import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/basket_provider.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/views/public_uses/shopping_cart/shopping_cart.dart';
import 'package:badges/badges.dart' as badges;
import 'package:provider/provider.dart';

class CartIcon extends StatelessWidget {
  const CartIcon({super.key});

  @override
  Widget build(BuildContext context) {
    final basketProvider = Provider.of<BasketProvider>(context);
    return ChangeNotifierProvider(
      create: (context) => BasketProvider(),
      child: Container(
        margin: const EdgeInsets.only(right: 15),
        child: InkWell(
          onTap: () {
            goto(const ShoppingCart(), context);
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
    );
  }
}
