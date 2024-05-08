import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/auth_provider.dart';
import 'package:pharmo_app/screens/DM_SCREENS/jagger_dialog.dart';
import 'package:pharmo_app/screens/DM_SCREENS/jagger_order_page.dart';
import 'package:pharmo_app/screens/DM_SCREENS/tabs/jagger_home.dart';
import 'package:pharmo_app/screens/SELLER_SCREENS/seller_home/seller_home.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/widgets/appbar/dm_app_bar.dart';
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
  int _selectedIndex = 0;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final authProvider = Provider.of<AuthController>(context, listen: false);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthController>(
            create: (context) => AuthController()),
      ],
      child: Consumer<AuthController>(builder: (context, authController, _) {
        return SafeArea(
          child: Scaffold(
            drawer: Drawer(
              shape: const RoundedRectangleBorder(),
              width: size.width * 0.7,
              child: ListView(
                children: [
                  SizedBox(
                    width: size.width,
                    child: DrawerHeader(
                      curve: Curves.easeInOut,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: size.width * 0.1,
                            height: size.width * 0.1,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            child: Icon(
                              Icons.person,
                              color: AppColors.secondary,
                              size: size.width * 0.1,
                            ),
                          ),
                          Text(
                            authProvider.userInfo['email'],
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: size.height * 0.02),
                          ),
                        ],
                      ),
                    ),
                  ),
                  _drawerItem(
                    title: 'Захиалга',
                    icon: Icons.shopping_cart,
                    onTap: () {
                      goto(const JaggerOrderPage(), context);
                    },
                  ),
                  _drawerItem(
                    title: 'Борлуулагчруу шилжих',
                    icon: Icons.swap_vert,
                    onTap: () {
                      goto(const SellerHomePage(), context);
                    },
                  ),
                  _drawerItem(
                    title: 'Гарах',
                    icon: Icons.logout,
                    onTap: () {
                      showLogoutDialog(context);
                    },
                  ),
                ],
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
                  icon: Icon(Icons.home),
                  label: 'Түгээлт',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.shopping_cart),
                  label: 'Захиалгууд',
                ),
              ],
              selectedItemColor: AppColors.secondary,
              unselectedItemColor: AppColors.primary,
            ),
          ),
        );
      }),
    );
  }
  Widget _drawerItem(
      {required String title, required IconData icon, Function()? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.lightBlue),
      title: Text(title),
      onTap: onTap,
    );
  }
}
