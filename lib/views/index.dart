import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/home_provider.dart';
import 'package:pharmo_app/views/main/delivery_man/jagger_home.dart';
import 'package:pharmo_app/views/main/cart/cart.dart';
import 'package:pharmo_app/views/main/home.dart';
import 'package:pharmo_app/views/product/product_searcher.dart';
import 'package:pharmo_app/views/main/profile.dart';
import 'package:pharmo_app/views/main/seller/customers.dart';
import 'package:pharmo_app/views/main/seller/add_customer.dart';
import 'package:pharmo_app/views/main/seller/customer_searcher.dart';
import 'package:pharmo_app/widgets/appbar/custom_app_bar.dart';
import 'package:pharmo_app/widgets/bottom_bar/bottom_bar.dart';
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
        String role = homeProvider.userRole ?? '';
        return Scaffold(
          extendBody: true,
          appBar: CustomAppBar(title: getAppbar(role)),
          body: getPages(role)[homeProvider.currentIndex],
          bottomNavigationBar: BottomBar(icons: getIcons(role)),
        );
      },
    );
  }

  Widget getAppbar(String role) {
    if (role == 'PA') {
      switch (homeProvider.currentIndex) {
        case 0:
          return const ProductSearcher();
        case 2:
          return appBarSingleText('Миний профайл');
        default:
          return appBarSingleText('Сагс');
      }
    } else if (role == 'S') {
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
        case 3:
          return appBarSingleText('Миний профайл');

        default:
          return selectedCustomer(homeProvider);
      }
    } else {
      switch (homeProvider.currentIndex) {
        case 0:
          return appBarSingleText('Өнөөдрийн түгээлтүүд');
        case 1:
          return const Row(
            children: [
              Expanded(flex: 8, child: CustomerSearcher()),
              SizedBox(width: 10),
              Expanded(child: AddCustomer()),
            ],
          );
        case 2:
          return const ProductSearcher();
        case 4:
          return appBarSingleText('Миний профайл');
        default:
          return selectedCustomer(homeProvider);
      }
    }
  }

  appBarSingleText(String v) {
    return Text(v, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18));
  }

  List<String> getIcons(String role) {
    if (role == 'PA') {
      return ['category', 'cart', 'user'];
    } else if (role == 'S') {
      return ['users', 'category', 'cart', 'user'];
    } else {
      return ['truck-side', 'users', 'category', 'cart', 'user'];
    }
  }

  List<Widget> getPages(String role) {
    if (role == 'PA') {
      return [const Home(), const Cart(), const Profile()];
    } else if (role == "S") {
      return [const CustomerList(), const Home(), const Cart(), const Profile()];
    } else {
      return [
        const HomeJagger(),
        const CustomerList(),
        const Home(),
        const Cart(),
        const Profile()
      ];
    }
  }
}
