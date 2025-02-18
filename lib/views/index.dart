import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/home_provider.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/views/delivery_man/index_delivery_man.dart';
import 'package:pharmo_app/views/pharmacy/drawer_menus/my_orders/my_orders.dart';
import 'package:pharmo_app/views/cart/cart.dart';
import 'package:pharmo_app/views/home.dart';
import 'package:pharmo_app/views/pharmacy/drawer_menus/promotion/promotion_screen.dart';
import 'package:pharmo_app/views/product/product_searcher.dart';
import 'package:pharmo_app/views/seller/customer/customers.dart';
import 'package:pharmo_app/views/seller/order/seller_orders.dart';
import 'package:pharmo_app/views/seller/seller_report/add_customer.dart';
import 'package:pharmo_app/views/seller/seller_report/customer_searcher.dart';
import 'package:pharmo_app/views/seller/seller_report/seller_report.dart';
import 'package:pharmo_app/widgets/appbar/custom_app_bar.dart';
import 'package:pharmo_app/widgets/bottom_bar/bottom_bar.dart';
import 'package:pharmo_app/widgets/drawer/drawer_item.dart';
import 'package:pharmo_app/widgets/drawer/my_drawer.dart';
import 'package:provider/provider.dart';

class IndexPharma extends StatefulWidget {
  const IndexPharma({super.key});

  @override
  State<IndexPharma> createState() => _IndexPharmaState();
}

class _IndexPharmaState extends State<IndexPharma> {
  late HomeProvider homeProvider;

  @override
  void initState() {
    super.initState();
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, homeProvider, _) {
        bool isPharma = homeProvider.userRole == 'PA';
        return Scaffold(
          extendBody: true,
          drawer: MyDrawer(drawers: isPharma ? pharmaDrawerItems() : sellerDrawerItems()),
          appBar: CustomAppBar(title: isPharma ? pharmAppBarTitle() : sellerAppBarTitle()),
          body: isPharma
              ? _pharmacyPages[homeProvider.currentIndex]
              : _sellerPages[homeProvider.currentIndex],
          bottomNavigationBar: BottomBar(
            labels: isPharma ? pharmaLabels : sellerLabels,
            icons: isPharma ? pharmaIcons : sellericons,
          ),
        );
      },
    );
  }

  pharmAppBarTitle() {
    switch (homeProvider.currentIndex) {
      case 0:
        return const ProductSearcher();
      default:
        return const Text(
          'Сагс',
          style: TextStyle(color: white, fontWeight: FontWeight.bold, fontSize: 13.0),
        );
    }
  }

  Widget sellerAppBarTitle() {
    switch (homeProvider.currentIndex) {
      case 0:
        return const Row(
          children: [
            Expanded(flex: 8, child: CustomerSearcher()),
            SizedBox(width: 10),
            Expanded(child: AddCustomer()),
          ],
        );
      case 1:
        return const ProductSearcher();
      default:
        return selectedCustomer(homeProvider);
    }
  }

  // FOR PARMACY
  List<String> pharmaIcons = ['category', 'cart'];
  List<String> pharmaLabels = ['Бараа', 'Сагс'];
  List<String> sellericons = ['user', 'category', 'cart'];
  List<String> sellerLabels = ['Харилцагч', 'Бараа', 'Сагс'];

  pharmaDrawerItems() {
    return [
      DrawerItem(
          title: 'Захиалгууд',
          asset: 'assets/icons_2/time-past.png',
          onTap: () => goto(const MyOrder())),
      DrawerItem(
          title: 'Урамшуулал',
          asset: 'assets/icons_2/gift-box-benefits.png',
          onTap: () => goto(const PromotionWidget())),
    ];
  }

  sellerDrawerItems() {
    return [
      DrawerItem(
          title: 'Захиалгууд',
          onTap: () => goto(const SellerOrders()),
          asset: 'assets/icons_2/time-past.png'),
      DrawerItem(
          title: 'Тайлан',
          onTap: () => goto(const SellerReportPage()),
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

  final List _pharmacyPages = [
    const Home(),
    const Cart(),
  ];

  final List _sellerPages = [
    const CustomerList(),
    const Home(),
    const Cart(),
  ];
}
