import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/basket_provider.dart';
import 'package:pharmo_app/controllers/home_provider.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/views/DM_SCREENS/jagger_dialog.dart';
import 'package:pharmo_app/views/DM_SCREENS/jagger_home_page.dart';
import 'package:pharmo_app/views/PA_SCREENS/pharma_home_page.dart';
import 'package:pharmo_app/views/SELLER_SCREENS/income_record/income_list.dart';
import 'package:pharmo_app/views/SELLER_SCREENS/order/history.dart';
import 'package:pharmo_app/views/SELLER_SCREENS/order/seller_orders.dart';
import 'package:pharmo_app/views/SELLER_SCREENS/tabs/home/seller_home_tab.dart';
import 'package:pharmo_app/views/SELLER_SCREENS/tabs/pharms/pharmacy_list.dart';
import 'package:pharmo_app/views/SELLER_SCREENS/tabs/pharms/register_pharm.dart';
import 'package:pharmo_app/views/SELLER_SCREENS/tabs/seller_shopping_cart/seller_shopping_cart.dart';
import 'package:pharmo_app/views/public_uses/filter.dart';
import 'package:pharmo_app/widgets/drawer_item.dart';
import 'package:provider/provider.dart';

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
    homeProvider.getDeviceInfo();
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
    Size size = MediaQuery.of(context).size;
    final basketProvider = Provider.of<BasketProvider>(context);
    final homePrvdr = Provider.of<HomeProvider>(context);
    return Consumer<HomeProvider>(
      builder: (_, homeProvider, child) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: homeProvider.invisible
              ? null
              : AppBar(
                  centerTitle: true,
                  title: homePrvdr.selectedCustomerId == 0
                      ? const Text('Захиалагч сонгоно уу')
                      : TextButton(
                          onPressed: () {
                            setState(() {
                              homeProvider.currentIndex = 0;
                            });
                          },
                          child: RichText(
                            text: TextSpan(
                              text: 'Сонгосон захиалагч: ',
                              style: TextStyle(
                                  color: Colors.blueGrey.shade800,
                                  fontSize: 13.0),
                              children: [
                                TextSpan(
                                    text: homeProvider.selectedCustomerName,
                                    style: const TextStyle(
                                        color: AppColors.succesColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13.0)),
                              ],
                            ),
                          ),
                        ),
                  actions: [
                    Container(
                      margin: const EdgeInsets.only(right: 15),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            homeProvider.currentIndex = 3;
                          });
                        },
                        child: badges.Badge(
                          badgeContent: Text(
                            "${basketProvider.count}",
                            style: const TextStyle(
                                color: Colors.white, fontSize: 11),
                          ),
                          badgeStyle: const badges.BadgeStyle(
                            badgeColor: Colors.blue,
                          ),
                          child: const Icon(
                            Icons.shopping_cart,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
          drawer: Drawer(
            shape: const RoundedRectangleBorder(),
            width: size.width > 480 ? size.width * 0.5 : size.width * 0.7,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomDrawerHeader(size: size),
                DrawerItem(
                  title: 'Эмийг сан бүртгэх',
                  icon: Icons.medical_services,
                  onTap: () {
                    goto(const RegisterPharmPage(), context);
                  },
                ),
                DrawerItem(
                  title: 'Орлогын жагсаалт',
                  icon: Icons.money,
                  onTap: () {
                    goto(const IncomeList(), context);
                  },
                ),
                DrawerItem(
                  title: 'Захиалгууд',
                  icon: Icons.article_outlined,
                  onTap: () {
                    goto(const SellerOrders(), context);
                  },
                ),
                DrawerItem(
                  title: 'Харилцагчийн захиалгын түүх',
                  icon: Icons.clear_all,
                  onTap: () {
                    goto(const SellerCustomerOrderHisrtory(), context);
                  },
                ),
                homeProvider.userRole == 'D'
                    ? DrawerItem(
                        title: 'Түгээгчрүү шилжих',
                        icon: Icons.swap_vert,
                        onTap: () {
                          gotoRemoveUntil(const JaggerHomePage(), context);
                        },
                      )
                    : const SizedBox(),
                DrawerItem(
                  title: 'Гарах',
                  icon: Icons.logout,
                  onTap: () {
                    showLogoutDialog(context);
                  },
                ),
              ],
            ),
          ),
          body: NotificationListener<ScrollNotification>(
            onNotification: (scrollNotification) {
              if (scrollNotification.metrics.atEdge == true) {
                setState(() {
                  homeProvider.invisible = false;
                });
              }
              if (scrollNotification is ScrollUpdateNotification &&
                  scrollNotification.scrollDelta! < 0) {
                setState(() {
                  homeProvider.invisible = false;
                });
              }
              if (scrollNotification is ScrollUpdateNotification &&
                  scrollNotification.scrollDelta! > 0) {
                setState(() {
                  homeProvider.invisible = true;
                });
              }
              return true;
            },
            child: _pages[homeProvider.currentIndex],
          ),
          bottomNavigationBar: homeProvider.invisible
              ? null
              : BottomNavigationBar(
                  currentIndex: homeProvider.currentIndex,
                  onTap: homeProvider.changeIndex,
                  selectedItemColor: AppColors.primary,
                  unselectedItemColor: AppColors.primary,
                  items: const [
                    BottomNavigationBarItem(
                        icon: Icon(Icons.person_outlined),
                        label: 'Захиалагч',
                        activeIcon: Icon(Icons.person)),
                    BottomNavigationBarItem(
                        icon: Icon(Icons.home_outlined),
                        label: 'Бараа',
                        activeIcon: Icon(Icons.home)),
                    BottomNavigationBarItem(
                        icon: Icon(Icons.category_outlined),
                        label: 'Ангилал',
                        activeIcon: Icon(Icons.category)),
                    BottomNavigationBarItem(
                        icon: Icon(Icons.shopping_cart_outlined),
                        label: 'Сагс',
                        activeIcon: Icon(Icons.shopping_cart)),
                  ],
                ),
        );
      },
    );
  }
}
