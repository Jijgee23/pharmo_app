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
import 'package:pharmo_app/views/public_uses/Notification/notification.dart';
import 'package:pharmo_app/views/public_uses/filter.dart';
import 'package:pharmo_app/widgets/others/drawer_item.dart';
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
                  backgroundColor: Colors.white,
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
                    IconButton(
                      icon: Image.asset(
                        'assets/icons/notification.png',
                        height: 24,
                      ),
                      onPressed: () => goto(const NotificationPage(), context),
                    ),
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
                          child: Image.asset(
                            'assets/icons/shop-tab.png',
                            height: 24,
                            width: 24,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
          drawer: Drawer(
            backgroundColor: AppColors.cleanWhite,
            shape: const RoundedRectangleBorder(),
            width: size.width > 480 ? size.width * 0.5 : size.width * 0.7,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomDrawerHeader(size: size),
                DrawerItem(
                    title: 'Эмийг сан бүртгэх',
                    onTap: () => goto(const RegisterPharmPage(), context),
                    asset: 'assets/icons/drugstore.png'),
                DrawerItem(
                    title: 'Орлогын жагсаалт',
                    onTap: () => goto(const IncomeList(), context),
                    asset: 'assets/icons/icnome.png'),
                DrawerItem(
                    title: 'Захиалгууд',
                    onTap: () => goto(const SellerOrders(), context),
                    asset: 'assets/icons/order.png'),
                DrawerItem(
                    title: 'Харилцагчийн захиалгын түүх',
                    onTap: () =>
                        goto(const SellerCustomerOrderHisrtory(), context),
                    asset: 'assets/icons/clock.png'),
                homeProvider.userRole == 'D'
                    ? DrawerItem(
                        title: 'Түгээгчрүү шилжих',
                        onTap: () {
                          gotoRemoveUntil(const JaggerHomePage(), context);
                        },
                        asset: 'assets/icons/swap.png',
                      )
                    : const SizedBox(),
                DrawerItem(
                    title: 'Гарах',
                    onTap: () => showLogoutDialog(context),
                    asset: 'assets/icons/check-out.png'),
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
                  useLegacyColorScheme: true,
                  currentIndex: homeProvider.currentIndex,
                  onTap: homeProvider.changeIndex,
                  selectedItemColor: AppColors.primary,
                  unselectedItemColor: AppColors.primary,
                  showSelectedLabels: true,
                  showUnselectedLabels: false,
                  iconSize: 20,
                  type: BottomNavigationBarType.fixed,
                  items: [
                    BottomNavigationBarItem(
                      icon: Image.asset(
                        'assets/icons/user.png',
                        height: 20,
                      ),
                      label: 'Захиалагч',
                    ),
                    BottomNavigationBarItem(
                      icon: Image.asset(
                        'assets/icons/house.png',
                        height: 20,
                      ),
                      label: 'Бараа',
                    ),
                    BottomNavigationBarItem(
                      icon: Image.asset(
                        'assets/icons/options.png',
                        height: 20,
                      ),
                      label: 'Ангилал',
                    ),
                    BottomNavigationBarItem(
                      icon: Image.asset(
                        'assets/icons/shop-tab.png',
                        height: 20,
                      ),
                      label: 'Сагс',
                    ),
                  ],
                ),
        );
      },
    );
  }
}
