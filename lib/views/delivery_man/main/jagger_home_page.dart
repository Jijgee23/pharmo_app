import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/auth_provider.dart';
import 'package:pharmo_app/controllers/home_provider.dart';
import 'package:pharmo_app/controllers/jagger_provider.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/views/seller/main/seller_home.dart';
import 'package:pharmo_app/views/delivery_man/tabs/home/jagger_home.dart';
import 'package:pharmo_app/views/delivery_man/drawer_menus/shipment_history/shipment_history.dart';
import 'package:pharmo_app/widgets/appbar/dm_app_bar.dart';
import 'package:pharmo_app/widgets/drawer/drawer_item.dart';
import 'package:provider/provider.dart';

import '../../../widgets/bottom_bar/bottom_bar.dart';
import '../../../widgets/drawer/my_drawer.dart';
import '../tabs/expend/shipment_expense.dart';

class JaggerHomePage extends StatefulWidget {
  const JaggerHomePage({super.key});

  @override
  State<JaggerHomePage> createState() => _JaggerHomePageState();
}

class _JaggerHomePageState extends State<JaggerHomePage> {
  final List _pages = [
    const HomeJagger(),
    const ShipmentExpensePage(),
  ];
  late HomeProvider homeProvider;
  late JaggerProvider jaggerProvider;

  @override
  void initState() {
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
    jaggerProvider = Provider.of<JaggerProvider>(context, listen: false);
    homeProvider.getUserInfo();
    jaggerProvider.fetchJaggers();
    homeProvider.getPosition();
    super.initState();
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
          drawer: MyDrawer(
            drawers: [
              DrawerItem(
                title: 'Түгээлтийн түүх',
                asset: 'assets/icons_2/time-past.png',
                onTap: () => goto(const ShipmentHistory()),
              ),
              DrawerItem(
                title: 'Борлуулагчруу шилжих',
                asset: 'assets/icons_2/swap.png',
                onTap: () {
                  homeProvider.changeIndex(0);
                  gotoRemoveUntil(const SellerHomePage(),context);
                },
              ),
            ],
          ),
          appBar: DMAppBar(
            title: (homeProvider.currentIndex == 0)
                ? 'Өнөөдрийн түгээлтүүд'
                : 'Зарлагууд',
          ),
          body: _pages[home.currentIndex],
          bottomNavigationBar: BottomBar(
            homeProvider: homeProvider,
            listOfIcons: icons,
            labels: labels,
          ),
        );
      }),
    );
  }

  List<String> icons = ['truck-side', 'expense'];
  List<String> labels = ['Түгээлт', 'Зарлагууд'];
}
