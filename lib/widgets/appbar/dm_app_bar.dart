import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/basket_provider.dart';
import 'package:pharmo_app/utilities/constants.dart';
import 'package:provider/provider.dart';

class DMAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? leadingOnTap;
  final bool showIcon;
  final String title;
  final List<Widget>? actions;
  final IconData? icon;

  const DMAppBar({
    super.key,
    this.leadingOnTap,
    this.showIcon = false,
    this.title = "",
    this.icon,
    this.actions,
  }) : preferredSize = const Size.fromHeight(kToolbarHeight);

  @override
  final Size preferredSize;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => BasketProvider(),
      child: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AppBar(
          centerTitle: true,
          title: Text(
            title,
            style: Constants.headerTextStyle,
          ),
          actions: actions,
        ),
      ),
    );
  }
}
