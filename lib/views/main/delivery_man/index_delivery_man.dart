import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/auth_provider.dart';
import 'package:pharmo_app/controllers/home_provider.dart';
import 'package:pharmo_app/views/main/delivery_man/delivery_home.dart';
import 'package:pharmo_app/views/main/delivery_man/delivery_orders.dart';
import 'package:pharmo_app/views/main/delivery_man/delivery_profile.dart';
import 'package:pharmo_app/widgets/appbar/dm_app_bar.dart';
import 'package:pharmo_app/widgets/bottom_bar/bottom_bar.dart';
import 'package:provider/provider.dart';

class IndexDeliveryMan extends StatefulWidget {
  const IndexDeliveryMan({super.key});

  @override
  State<IndexDeliveryMan> createState() => _IndexDeliveryManState();
}

class _IndexDeliveryManState extends State<IndexDeliveryMan> {
  @override
  void initState() {
    super.initState();
    Provider.of<HomeProvider>(context, listen: false).getUserInfo();
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
            create: (context) => AuthController())
      ],
      child: Consumer2<AuthController, HomeProvider>(
        builder: (context, authController, home, _) {
          return Scaffold(
            extendBody: true,
            appBar: DMAppBar(
                title: getTitle(home.currentIndex),),
            body: _pages[home.currentIndex],
            bottomNavigationBar: BottomBar(icons: icons),
          );
        },
      ),
    );
  }

  String getTitle(int n) {
    switch (n) {
      case 0:
        return 'Өнөөдрийн түгээлтүүд';
      case 1:
        return 'Бэлэн захиалгууд';
      case 2:
        return 'Миний профайл';
      default:
        return '';
    }
  }

  final List _pages = [
    const DeliveryHome(),
    const DeliveryOrders(),
    const DeliveryProfile()
  ];

  List<String> icons = ['truck-side', 'order-history', 'user'];
  List<String> labels = ['Түгээлт', 'Бэлэн захиалгууд', 'Профайл'];

  // final TextEditingController amount = TextEditingController();
  // final TextEditingController note = TextEditingController();
}
