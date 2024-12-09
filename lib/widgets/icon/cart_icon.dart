import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/basket_provider.dart';
import 'package:pharmo_app/controllers/home_provider.dart';
import 'package:badges/badges.dart' as badges;
import 'package:provider/provider.dart';

class CartIcon extends StatefulWidget {
  final Color? color;
  const CartIcon({super.key, this.color});

  @override
  State<CartIcon> createState() => _CartIconState();
}

class _CartIconState extends State<CartIcon> {
  late HomeProvider home;
  @override
  void initState() {
    super.initState();
    home = Provider.of<HomeProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    final basketProvider = Provider.of<BasketProvider>(context);
    final theme = Theme.of(context);
    return ChangeNotifierProvider(
      create: (context) => BasketProvider(),
      child: Container(
        margin: const EdgeInsets.only(right: 15),
        child: InkWell(
          onTap: () {
            home.changeIndex(home.userRole == 'PA' ? 2 : 3);
            Navigator.pop(context);
          },
          child: badges.Badge(
            badgeContent: Text(
              "${basketProvider.count}",
              style: const TextStyle(color: Colors.white, fontSize: 11),
            ),
            badgeStyle: badges.BadgeStyle(
              badgeColor: theme.hintColor,
            ),
            child: Image.asset(
              'assets/icons_2/cart.png',
              height: 24,
              width: 24,
              color: widget.color ?? theme.primaryColor,
            ),
          ),
        ),
      ),
    );
  }
}
