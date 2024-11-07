import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pharmo_app/controllers/basket_provider.dart';
import 'package:pharmo_app/controllers/home_provider.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/views/delivery_man/main/jagger_home_page.dart';
import 'package:pharmo_app/views/seller/drawer_menus/income/income_list.dart';
import 'package:pharmo_app/views/seller/tabs/home/seller_home_tab.dart';
import 'package:pharmo_app/views/seller/tabs/pharms/pharmacy_list.dart';
import 'package:pharmo_app/views/seller/drawer_menus/register_pharm/register_pharm.dart';
import 'package:pharmo_app/views/seller/tabs/seller_shopping_cart/seller_shopping_cart.dart';
import 'package:pharmo_app/views/public_uses/notification/notification.dart';
import 'package:pharmo_app/views/public_uses/filter/filter.dart';
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

  @override
  void initState() {
    super.initState();
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
    homeProvider.getUserInfo();
    homeProvider.getBasketId();
    homeProvider.getFilters();
  }

  final List _pages = [
    const PharmacyList(),
    const SellerHomeTab(),
    const FilterPage(),
    const SellerShoppingCart(),
  ];

  @override
  Widget build(BuildContext context) {
    final basketProvider = Provider.of<BasketProvider>(context);
    return Consumer<HomeProvider>(
      builder: (_, homeProvider, child) {
        var textStyle =
            TextStyle(color: Colors.blueGrey.shade800, fontSize: 13.0);
        return Scaffold(
          extendBody: true,
          resizeToAvoidBottomInset: false,
          appBar: homeProvider.invisible
              ? null
              : AppBar(
                  backgroundColor: Colors.white,
                  centerTitle: true,
                  title: homeProvider.selectedCustomerId == 0
                      ? Text('Захиалагч сонгоно уу', style: textStyle)
                      : TextButton(
                          onPressed: () {
                            setState(() {
                              homeProvider.currentIndex = 0;
                            });
                          },
                          child: RichText(
                            text: TextSpan(
                              text: 'Сонгосон захиалагч: ',
                              style: textStyle,
                              children: [
                                TextSpan(
                                    text: homeProvider.selectedCustomerName,
                                    style: const TextStyle(
                                        color: AppColors.secondary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13.0)),
                              ],
                            ),
                          ),
                        ),
                  actions: [
                    IconButton(
                      icon: Image.asset('assets/icons_2/bell.png', height: 24),
                      onPressed: () => goto(const NotificationPage()),
                    ),
                    Container(
                      margin: const EdgeInsets.only(right: 15),
                      child: InkWell(
                        onTap: () => homeProvider.changeIndex(3),
                        child: badges.Badge(
                          badgeContent: Text(
                            "${basketProvider.count}",
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
                  title: 'Орлогын жагсаалт',
                  onTap: () => goto(const IncomeList()),
                  asset: 'assets/icons_2/wallet-income.png'),
              // DrawerItem(
              //     title: 'Захиалгууд',
              //     onTap: () => goto(
              //           const SellerOrders(),
              //         ),
              //     asset: 'assets/icons_2/time-past.png'),
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

  List<String> icons = ['user', 'category', 'bars-sort', 'cart'];
  List<String> labels = ['Захиалагч', 'Бараа', 'Ангилал', 'Сагс'];
}
