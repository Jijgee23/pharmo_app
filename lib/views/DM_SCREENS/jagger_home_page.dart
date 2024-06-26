import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/auth_provider.dart';
import 'package:pharmo_app/controllers/home_provider.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/views/DM_SCREENS/jagger_dialog.dart';
import 'package:pharmo_app/views/DM_SCREENS/jagger_order_page.dart';
import 'package:pharmo_app/views/DM_SCREENS/tabs/jagger_home.dart';
import 'package:pharmo_app/views/PA_SCREENS/pharma_home_page.dart';
import 'package:pharmo_app/views/SELLER_SCREENS/seller_home.dart';
import 'package:pharmo_app/widgets/appbar/dm_app_bar.dart';
import 'package:pharmo_app/widgets/drawer_item.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class JaggerHomePage extends StatefulWidget {
  const JaggerHomePage({super.key});

  @override
  State<JaggerHomePage> createState() => _JaggerHomePageState();
}

class _JaggerHomePageState extends State<JaggerHomePage> {
  final List _pages = [
    const HomeJagger(),
    const JaggerOrderPage(),
  ];
  late SharedPreferences prefs;
  late HomeProvider homeProvider;
  int _selectedIndex = 0;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
    homeProvider.getDeviceInfo();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthController>(
            create: (context) => AuthController()),
      ],
      child: Consumer<AuthController>(builder: (context, authController, _) {
        return Scaffold(
          drawer: MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: Drawer(
              shape: const RoundedRectangleBorder(),
              width: size.width > 480 ? size.width * 0.5 : size.width * 0.7,
              child: ListView(
                children: [
                  CustomDrawerHeader(size: size),
                  DrawerItem(
                    title: 'Захиалга',
                    icon: Icons.shopping_cart,
                    onTap: () => goto(const JaggerOrderPage(), context),
                  ),
                  DrawerItem(
                    title: 'Борлуулагчруу шилжих',
                    icon: Icons.swap_vert,
                    onTap: () =>
                        gotoRemoveUntil(const SellerHomePage(), context),
                  ),
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
          ),
          appBar: const DMAppBar(
            title: 'Нүүр хуудас',
          ),
          body: _pages[_selectedIndex],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Түгээлт',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart_outlined),
                activeIcon: Icon(Icons.shopping_cart),
                label: 'Захиалгууд',
              ),
            ],
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.primary,
          ),
        );
      }),
    );
  }
}
