import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/basket_provider.dart';
import 'package:pharmo_app/controllers/home_provider.dart';
import 'package:pharmo_app/controllers/promotion_provider.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/views/delivery_man/index_delivery_man.dart';
import 'package:pharmo_app/views/pharmacy/drawer_menus/my_orders/my_orders.dart';
import 'package:pharmo_app/views/public_uses/cart/cart.dart';
import 'package:pharmo_app/views/pharmacy/home.dart';
import 'package:pharmo_app/views/pharmacy/drawer_menus/promotion/promotion_screen.dart';
import 'package:pharmo_app/views/public_uses/filter/filter.dart';
import 'package:pharmo_app/views/seller/customers.dart';
import 'package:pharmo_app/views/seller/drawer_menus/income/income_list.dart';
import 'package:pharmo_app/views/seller/drawer_menus/order/seller_orders.dart';
import 'package:pharmo_app/widgets/appbar/custom_app_bar.dart';
import 'package:pharmo_app/widgets/drawer/drawer_item.dart';
import 'package:provider/provider.dart';

import '../../widgets/bottom_bar/bottom_bar.dart';
import '../../widgets/drawer/my_drawer.dart';

class IndexPharma extends StatefulWidget {
  const IndexPharma({super.key});

  @override
  State<IndexPharma> createState() => _IndexPharmaState();
}

class _IndexPharmaState extends State<IndexPharma> {
  late HomeProvider homeProvider;
  late PromotionProvider promotionProvider;
  late BasketProvider basketProvider;

  @override
  void initState() {
    super.initState();
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
    promotionProvider = Provider.of<PromotionProvider>(context, listen: false);
    basketProvider = Provider.of<BasketProvider>(context, listen: false);
    basketProvider.getBasket();
    homeProvider.getUserInfo();
    homeProvider.getBasketId();
    homeProvider.getFilters();
    if (homeProvider.userRole == 'PA') {
      initPharma();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void initPharma() async {
    await homeProvider.getSuppliers();
    await homeProvider.getBranches(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer2<HomeProvider, BasketProvider>(
      builder: (context, homeProvider, basketProvider, _) {
        bool isPharma = homeProvider.userRole == 'PA';
        return Scaffold(
          extendBody: true,
          drawer: MyDrawer(
            drawers: isPharma ? pharmaDrawerItems() : sellerDrawerItems(),
          ),
          appBar: CustomAppBar(
              title: isPharma
                  ? Text(
                      getAppBarText(homeProvider.currentIndex),
                      style: TextStyle(
                        color: theme.primaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  : getSellerAppBarTitle()),
          body: Container(
            padding: const EdgeInsets.only(right: 10, left: 10),
            child: isPharma
                ? _pharmacyPages[homeProvider.currentIndex]
                : _sellerPages[homeProvider.currentIndex],
          ),
          bottomNavigationBar: BottomBar(
            homeProvider: homeProvider,
            listOfIcons: isPharma ? pharmaIcons : sellericons,
            labels: isPharma ? pharmaLabels : sellerLabels,
          ),
        );
      },
    );
  }

  // FOR PARMACY
  List<String> pharmaIcons = ['category', 'bars-sort', 'cart'];
  List<String> pharmaLabels = ['Бараа', 'Ангилал', 'Сагс'];
  pharmaDrawerItems() {
    return [
      DrawerItem(
        title: 'Захиалгууд',
        asset: 'assets/icons_2/time-past.png',
        onTap: () => goto(const MyOrder()),
      ),
      DrawerItem(
        title: 'Урамшуулал',
        asset: 'assets/icons_2/gift-box-benefits.png',
        onTap: () => goto(const PromotionWidget()),
      ),
    ];
  }

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

  final List _pharmacyPages = [
    const Home(),
    const FilterPage(),
    const Cart(),
  ];

  // FOR SELLER
  List<String> sellericons = ['user', 'category', 'cart'];
  List<String> sellerLabels = ['Харилцагч', 'Бараа', 'Сагс'];
  sellerDrawerItems() {
    return [
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
                gotoRemoveUntil(const IndexDeliveryMan());
              },
              asset: 'assets/icons_2/swap.png',
            )
          : const SizedBox(),
    ];
  }

  getSellerAppBarTitle() {
    final textStyle = TextStyle(
      color: Theme.of(context).primaryColor,
      fontSize: 12.0,
      letterSpacing: 0.3,
      fontWeight: FontWeight.bold,
    );
    return homeProvider.selectedCustomerId == 0
        ? Text('Харилцагч сонгоно уу!', style: textStyle)
        : TextButton(
            onPressed: () => homeProvider.changeIndex(0),
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
          );
  }

  final List _sellerPages = [
    const CustomerList(),
    const Home(),
    const Cart(),
  ];
}
