import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pharmo_app/controllers/basket_provider.dart';
import 'package:pharmo_app/controllers/home_provider.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/views/delivery_man/main/jagger_home_page.dart';
import 'package:pharmo_app/views/seller/drawer_menus/income/income_list.dart';
import 'package:pharmo_app/views/seller/drawer_menus/order/seller_orders.dart';
import 'package:pharmo_app/views/seller/tabs/home/seller_home_tab.dart';
import 'package:pharmo_app/views/seller/tabs/pharms/pharmacy_list.dart';
import 'package:pharmo_app/views/seller/tabs/seller_shopping_cart/seller_shopping_cart.dart';
import 'package:pharmo_app/widgets/drawer/drawer_item.dart';
import 'package:provider/provider.dart';

import '../../../widgets/bottom_bar/bottom_bar.dart';
import '../../../widgets/drawer/my_drawer.dart';

class SellerHomePage extends StatefulWidget {
  const SellerHomePage({
    super.key,
  });

  @override
  State<SellerHomePage> createState() => _SellerHomePageState();
}

class _SellerHomePageState extends State<SellerHomePage> {
  late HomeProvider homeProvider;
  late BasketProvider basket;

  @override
  void initState() {
    super.initState();
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
    basket = Provider.of<BasketProvider>(context, listen: false);
    init();
  }

  void init() async {
    await basket.getBasket();
    await homeProvider.getUserInfo();
    await homeProvider.getBasketId();
    await homeProvider.getFilters();
  }

  final List _pages = [
    const PharmacyList(),
    const SellerHomeTab(),
    // const FilterPage(),
    const SellerShoppingCart(),
  ];

  @override
  Widget build(BuildContext context) {
    final basketProvider = Provider.of<BasketProvider>(context);
    return Consumer<HomeProvider>(
      builder: (_, homeProvider, child) {
        final textStyle = TextStyle(
          color: Colors.blueGrey.shade800,
          fontSize: 12.0,
          letterSpacing: 0.3,
          fontWeight: FontWeight.bold,
        );
        return Scaffold(
          extendBody: true,
          resizeToAvoidBottomInset: false,
          appBar: homeProvider.invisible
              ? null
              : AppBar(
                  centerTitle: true,
                  title: homeProvider.selectedCustomerId == 0
                      ? Text('Харилцагч сонгоно уу !', style: textStyle)
                      : TextButton(
                          onPressed: () {
                            setState(() {
                              homeProvider.currentIndex = 0;
                            });
                          },
                          child: RichText(
                            text: TextSpan(
                              text: 'Сонгосон харилцагч: ',
                              style: textStyle,
                              children: [
                                TextSpan(
                                  text: homeProvider.selectedCustomerName,
                                  style: const TextStyle(
                                    color: AppColors.succesColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                  actions: [
                    InkWell(
                      child: Image.asset(
                        'assets/icons_2/bell.png',
                        height: 24,
                        color: AppColors.primary,
                      ),
                      // onTap: () => goto(const NotificationPage()),
                    ),
                    Container(
                      margin: const EdgeInsets.only(right: 15, left: 10),
                      child: InkWell(
                        onTap: () => homeProvider.changeIndex(2),
                        child: badges.Badge(
                          badgeContent: Text(
                            basketProvider.basket.totalCount.toString(),
                            style: const TextStyle(
                                color: Colors.white, fontSize: 11),
                          ),
                          badgeStyle: const badges.BadgeStyle(
                            badgeColor: AppColors.secondary,
                          ),
                          child: Image.asset(
                            'assets/icons_2/cart.png',
                            height: 24,
                            width: 24,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
          drawer: MyDrawer(
            drawers: [
              // DrawerItem(
              //     title: 'Эмийг сан бүртгэх',
              //     onTap: () => goto(const RegisterPharmPage()),
              //     asset: 'assets/icons_2/doctor.png'),

              DrawerItem(
                  title: 'Захиалгууд',
                  onTap: () => goto(
                        const SellerOrders(),
                      ),
                  asset: 'assets/icons_2/time-past.png'),
              DrawerItem(
                  title: 'Орлогын жагсаалт',
                  onTap: () => goto(const IncomeList()),
                  asset: 'assets/icons_2/wallet-income.png'),
              homeProvider.userRole == 'D'
                  ? DrawerItem(
                      title: 'Түгээгчрүү шилжих',
                      onTap: () {
                        homeProvider.changeIndex(0);
                        gotoRemoveUntil(const JaggerHomePage(), context);
                      },
                      asset: 'assets/icons_2/swap.png',
                    )
                  : const SizedBox(),
            ],
          ),
          body: NotificationListener<UserScrollNotification>(
            onNotification: (notification) {
              if (notification.direction == ScrollDirection.reverse &&
                  homeProvider.currentIndex == 1) {
                setState(() => homeProvider.invisible = true);
              } else if (notification.direction == ScrollDirection.forward) {
                setState(() => homeProvider.invisible = false);
              }
              return true;
            },
            child: _pages[homeProvider.currentIndex],
          ),
          bottomNavigationBar: homeProvider.invisible
              ? null
              : BottomBar(
                  homeProvider: homeProvider,
                  listOfIcons: icons,
                  labels: labels,
                ),
        );
      },
    );
  }

  List<String> icons = ['user', 'category', 'cart'];
  List<String> labels = ['Харилцагч', 'Бараа', 'Сагс'];
}
