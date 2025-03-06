import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/auth_provider.dart';
import 'package:pharmo_app/controllers/home_provider.dart';
import 'package:pharmo_app/controllers/jagger_provider.dart';
import 'package:pharmo_app/views/main/delivery_man/delivery_home.dart';
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
  late HomeProvider homeProvider;
  late JaggerProvider jaggerProvider;

  @override
  void initState() {
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
    jaggerProvider = Provider.of<JaggerProvider>(context, listen: false);
    homeProvider.getUserInfo();

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider<AuthController>(create: (context) => AuthController())],
      child: Consumer2<AuthController, HomeProvider>(
        builder: (context, authController, home, _) {
          return Scaffold(
            extendBody: true,
            appBar: DMAppBar(
                title: (homeProvider.currentIndex == 0) ? 'Өнөөдрийн түгээлтүүд' : 'Миний профайл'),
            body: _pages[home.currentIndex],
            bottomNavigationBar: BottomBar(icons: icons),
          );
        },
      ),
    );
  }

  final List _pages = [const DeliveryHome(), const DeliveryProfile()];

  List<String> icons = ['truck-side', 'user'];
  List<String> labels = ['Түгээлт', 'Профайл'];

  final TextEditingController amount = TextEditingController();
  final TextEditingController note = TextEditingController();
}
