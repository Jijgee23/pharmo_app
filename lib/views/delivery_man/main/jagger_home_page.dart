import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/auth_provider.dart';
import 'package:pharmo_app/controllers/home_provider.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/views/public_uses/privacy_policy/privacy_policy.dart';
import 'package:pharmo_app/views/public_uses/user_information/user_information.dart';
import 'package:pharmo_app/views/seller/main/seller_home.dart';
import 'package:pharmo_app/views/delivery_man/main/logout_dialog.dart';
import 'package:pharmo_app/views/delivery_man/drawer_menus/expend/shipment_expense.dart';
import 'package:pharmo_app/views/delivery_man/tabs/home/jagger_home.dart';
import 'package:pharmo_app/views/delivery_man/drawer_menus/shipment_history/shipment_history.dart';
import 'package:pharmo_app/views/pharmacy/main/pharma_home_page.dart';
import 'package:pharmo_app/widgets/appbar/dm_app_bar.dart';
import 'package:pharmo_app/widgets/bottomNavBarITem.dart';
import 'package:pharmo_app/widgets/others/drawer_item.dart';
import 'package:provider/provider.dart';

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
    homeProvider.getUserInfo();
    homeProvider.getPosition();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final orientation = MediaQuery.of(context).orientation;
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthController>(
            create: (context) => AuthController())
      ],
      child: Consumer<AuthController>(builder: (context, authController, _) {
        return Scaffold(
          extendBody: true,
          drawer: MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: Drawer(
              backgroundColor: Colors.white,
              elevation: 0,
              width: size.width > 480 ? size.width * 0.5 : size.width * 0.7,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const CustomDrawerHeader(),
                    DrawerItem(
                      title: 'Түгээлтийн түүх',
                      asset: 'assets/icons_2/time-past.png',
                      onTap: () => goto(const ShipmentHistory(), context),
                    ),
                    DrawerItem(
                      title: 'Борлуулагчруу шилжих',
                      asset: 'assets/icons_2/swap.png',
                      onTap: () =>
                          gotoRemoveUntil(const SellerHomePage(), context),
                    ),
                    DrawerItem(
                      title: 'Миний бүртгэл',
                      asset: 'assets/icons_2/user.png',
                      onTap: () => goto(const UserInformation(), context),
                    ),
                    DrawerItem(
                      title: 'Нууцлалын бодлого',
                      asset: 'assets/icons_2/privacy.png',
                      onTap: () => goto(const PrivacyPolicy(), context),
                    ),
                    DrawerItem(
                      title: 'Гарах',
                      asset: 'assets/icons_2/signout.png',
                      onTap: () {
                        showLogoutDialog(context);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          appBar: DMAppBar(
            title: (_selectedIndex == 0) ? 'Өнөөдрийн түгээлтүүд' : 'Зарлагууд',
          ),
          body: _pages[_selectedIndex],
          bottomNavigationBar: Container(
            margin: EdgeInsets.symmetric(
                vertical: 10,
                horizontal: (orientation == Orientation.portrait)
                    ? size.width * 0.33
                    : size.width * 0.4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BottomNavigationBar(
                showSelectedLabels: false,
                backgroundColor: AppColors.primary,
                showUnselectedLabels: false,
                type: BottomNavigationBarType.fixed,
                currentIndex: _selectedIndex,
                onTap: _onItemTapped,
                items: const [
                  BottomNavigationBarItem(
                    icon: NavBarIcon(url: 'truck-side'),
                    label: 'Түгээлт',
                  ),
                  BottomNavigationBarItem(
                    icon: NavBarIcon(url: 'expense'),
                    label: 'Зарлагууд',
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
