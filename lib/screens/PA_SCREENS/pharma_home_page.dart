import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/auth_provider.dart';
import 'package:pharmo_app/screens/PA_SCREENS/my_orders.dart';
import 'package:pharmo_app/screens/PA_SCREENS/tabs/cart.dart';
import 'package:pharmo_app/screens/PA_SCREENS/tabs/home.dart';
import 'package:pharmo_app/screens/suppliers/supplier_page.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/widgets/appbar/custom_app_bar.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PharmaHomePage extends StatefulWidget {
  const PharmaHomePage({super.key});

  @override
  State<PharmaHomePage> createState() => _PharmaHomePageState();
}

class _PharmaHomePageState extends State<PharmaHomePage> {
  final List _pages = [
    const Home(),
    const ShoppingCartHome(),
  ];
  late SharedPreferences prefs;
  int _selectedIndex = 0;
  bool hidden = false;
  String email = '';
  String role = '';
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? useremail = prefs.getString('useremail');
    String? userRole = prefs.getString('userrole');
    setState(() {
      email = useremail.toString();
      role = userRole.toString();
    });
  }

  @override
  void initState() {
    getUserInfo();
    super.initState();
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            'Имейл хаяг: $email',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: size.height * 0.016),
                          ),
                          Text(
                            'Хэрэглэгчийн төрөл: $role',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: size.height * 0.016),
                          ),
                        ],
                      ),
                    ),
                  ),
                  _drawerItem(
                    title: 'Миний захиалгууд',
                    icon: Icons.shopping_cart,
                    onTap: () {
                      goto(const MyOrder(), context);
                    },
                  ),
                  _drawerItem(
                    title: 'Нийлүүлэгч',
                    icon: Icons.people,
                    onTap: () {
                      goto(const SupplierPage(), context);
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
            appBar: hidden
                ? null
                : const CustomAppBar(
                    title: 'Нүүр хуудас',
                  ),
            body: NotificationListener<ScrollNotification>(
              onNotification: (scrollNotification) {
                if (scrollNotification is ScrollUpdateNotification &&
                    scrollNotification.scrollDelta! > 0) {
                  setState(() {
                    hidden = true;
                  });
                } else if (scrollNotification is ScrollUpdateNotification &&
                    scrollNotification.scrollDelta! < 0) {
                  setState(() {
                    hidden = false;
                  });
                }
                return true;
              },
              child: _pages[_selectedIndex],
            ),
            bottomNavigationBar: hidden
                ? null
                : BottomNavigationBar(
                    currentIndex: _selectedIndex,
                    onTap: _onItemTapped,
                    items: const [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.home),
                        label: 'Нүүр',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.shopping_cart),
                        label: 'Миний сагс',
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

class LogoutDialog extends StatelessWidget {
  const LogoutDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);
    //  final size = MediaQuery.of(context).size;
    return ChangeNotifierProvider(
      create: (context) => AuthController(),
      child: AlertDialog(
        title: const Center(
          child: Text('Системээс гарах'),
        ),
        content: const Text('Та системээс гарахдаа итгэлтэй байна уу?'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Үгүй'),
          ),
          TextButton(
            onPressed: () {
              authController.logout(context);
              authController.toggleVisibile();
            },
            child: const Text('Тийм'),
          ),
        ],
      ),
    );
  }
}

void showLogoutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return const LogoutDialog();
    },
  );
}
