import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/basket_provider.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:provider/provider.dart';

class DMAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? leadingOnTap;
  final bool showIcon;
  final String title;
  final IconData? icon;

  const DMAppBar({
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

    return ChangeNotifierProvider(
      create: (context) => BasketProvider(),
      child: AppBar(
        iconTheme: const IconThemeData(color: AppColors.primary),
        centerTitle: true,
        title: Text(
          title,
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          // IconButton(
          //     icon: const Icon(
          //       Icons.notifications,
          //       color: Colors.blue,
          //     ),
          //     onPressed: () {}),
          // Container(
          //   margin: const EdgeInsets.only(right: 15),
          //   child: InkWell(
          //     onTap: () {
          //       Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ShoppingCart()));
          //     },
          //     child: badges.Badge(
          //       badgeContent: Text(
          //         "${basketProvider.count}",
          //         style: const TextStyle(color: Colors.white, fontSize: 11),
          //       ),
          //       badgeStyle: const badges.BadgeStyle(
          //         badgeColor: Colors.blue,
          //       ),
          //       child: const Icon(
          //         Icons.shopping_cart,
          //         color: Colors.red,
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
