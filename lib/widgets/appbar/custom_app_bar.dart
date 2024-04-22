import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/basket_provider.dart';
import 'package:pharmo_app/screens/shopping_cart/shopping_cart.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:provider/provider.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? leadingOnTap;
  final bool showIcon;
  final String title;
  final IconData? icon;

  const CustomAppBar({
    super.key,
    this.leadingOnTap,
    this.showIcon = false,
    this.title = "",
    this.icon,
  }) : preferredSize = const Size.fromHeight(kToolbarHeight);

  @override
  final Size preferredSize;

  @override
  Widget build(BuildContext context) {
    final basketProvider = Provider.of<BasketProvider>(context);
    final shoppingCartCC = context.watch<BasketProvider>().count;

    return ChangeNotifierProvider(
      create: (context) => BasketProvider(),
      child: AppBar(
        iconTheme: const IconThemeData(color: AppColors.primary),
        centerTitle: true,
        title: Text(
          '${basketProvider.count} $shoppingCartCC',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          IconButton(
              icon: const Icon(
                Icons.notifications,
                color: AppColors.primary,
              ),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: ((context) {
                      return AlertDialog(
                        title: const Text('Захиалгууд'),
                        content: const ShoppingCart(),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Хаах'),
                          ),
                        ],
                      );
                    }));
              }),
          Container(
            margin: const EdgeInsets.only(right: 15),
            child: badges.Badge(
              badgeContent: Text(
                "${basketProvider.count} ${shoppingCartCC}",
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
              badgeStyle: const badges.BadgeStyle(
                badgeColor: Colors.blue,
              ),
              child: const Icon(
                Icons.shopping_basket,
                color: Colors.red,
              ),
            ),
          )
        ],
      ),
    );
  }
}
