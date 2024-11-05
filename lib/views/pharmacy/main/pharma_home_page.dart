// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pharmo_app/controllers/auth_provider.dart';
import 'package:pharmo_app/controllers/basket_provider.dart';
import 'package:pharmo_app/controllers/home_provider.dart';
import 'package:pharmo_app/controllers/promotion_provider.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/views/pharmacy/drawer_menus/my_orders/my_orders.dart';
import 'package:pharmo_app/views/pharmacy/tabs/cart/cart.dart';
import 'package:pharmo_app/views/pharmacy/tabs/home/home.dart';
import 'package:pharmo_app/views/pharmacy/drawer_menus/promotion/promotion_screen.dart';
import 'package:pharmo_app/views/public_uses/filter/filter.dart';
import 'package:pharmo_app/widgets/appbar/custom_app_bar.dart';
import 'package:pharmo_app/widgets/drawer/drawer_item.dart';
import 'package:provider/provider.dart';

import '../../../widgets/bottom_bar/bottom_bar.dart';
import '../../../widgets/drawer/my_drawer.dart';

class PharmaHomePage extends StatefulWidget {
  const PharmaHomePage({super.key});

  @override
  State<PharmaHomePage> createState() => _PharmaHomePageState();
}

class _PharmaHomePageState extends State<PharmaHomePage> {
  final List _pages = [
    const Home(),
    const FilterPage(),
    const ShoppingCartHome(),
  ];
  bool hidden = false;
  late HomeProvider homeProvider;
  late PromotionProvider promotionProvider;

  @override
  void initState() {
    super.initState();
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
    promotionProvider = Provider.of<PromotionProvider>(context, listen: false);
    homeProvider.getUserInfo();
    homeProvider.getFilters();
    homeProvider.getSuppliers();
    homeProvider.getBranches(context);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthController>(
            create: (context) => AuthController()),
      ],
      child: Consumer3<AuthController, HomeProvider, BasketProvider>(
        builder: (context, authController, homeProvider, basketProvider, _) {
          return Scaffold(
            extendBody: true,
            drawer: MyDrawer(
              drawers: [
                DrawerItem(
                  title: 'Миний захиалгууд',
                  asset: 'assets/icons_2/time-past.png',
                  onTap: () => goto(const MyOrder()),
                ),
                DrawerItem(
                  title: 'Урамшуулал',
                  asset: 'assets/icons_2/gift-box-benefits.png',
                  onTap: () => goto(const PromotionWidget()),
                ),
              ],
            ),
            appBar: hidden
                ? null
                : CustomAppBar(
                    title: Text(
                      getAppBarText(homeProvider.currentIndex),
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
            body: NotificationListener<UserScrollNotification>(
              onNotification: (notification) {
                if (notification.direction == ScrollDirection.reverse &&
                    homeProvider.currentIndex == 0) {
                  setState(() => hidden = true);
                } else if (notification.direction == ScrollDirection.forward) {
                  setState(() => hidden = false);
                }
                return true;
              },
              child: _pages[homeProvider.currentIndex],
            ),
            bottomNavigationBar: BottomBar(
              homeProvider: homeProvider,
              listOfIcons: listOfIcons,
              labels: listOfStrings,
            ),
          );
        },
      ),
    );
  }

  List<String> listOfIcons = ['category', 'bars-sort', 'cart'];

  List<String> listOfStrings = ['Нүүр', 'Ангилал', 'Сагс'];

  getAppBarText(int index) {
    switch (index) {
      case 0:
        return 'Бараа';
      case 1:
        return 'Ангилал';
      case 2:
        return 'Сагс';
    }
  }
}

