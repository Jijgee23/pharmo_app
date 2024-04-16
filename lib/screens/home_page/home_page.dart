import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/auth_controller.dart';
import 'package:pharmo_app/controllers/basket_provider.dart';
import 'package:pharmo_app/screens/branch/branch.dart';
import 'package:pharmo_app/screens/home_page/tabs/home.dart';
import 'package:pharmo_app/screens/partners/partner_page.dart';
import 'package:pharmo_app/screens/suppliers/supplier_page.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/widgets/appbar/custom_app_bar.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'tabs/cart.dart';
import 'tabs/search.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List _pages = [
    const Home(),
    const SearchScreen(),
    const ShoppingCart(),
    const Home(),
  ];
  late SharedPreferences prefs;
  int _selectedIndex = 0;
  String _basketCount = '';

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  getData() async {
    try {
      prefs = await SharedPreferences.getInstance();
      setState(() => _basketCount = prefs.getString('basket_count').toString());
      final basketProvider = Provider.of<BasketProvider>(context, listen: false);
      print('--------------> ${basketProvider.count}');
    } catch (e) {
      print(e);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final shoppingCartProvider = Provider.of<BasketProvider>(context, listen: false);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthController>(create: (context) => AuthController()),
        ChangeNotifierProvider<BasketProvider>(create: (context) => BasketProvider()),
      ],
      child: Consumer2<AuthController, BasketProvider>(builder: (context, authController, basketProvider, child) {
        return SafeArea(
          child: Scaffold(
            drawer: Drawer(
              width: size.width * 0.7,
              child: ListView(
                children: [
                  DrawerHeader(
                    padding: EdgeInsets.all(size.width * 0.05),
                    curve: Curves.easeInOut,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Бүртгэл',
                          style: TextStyle(color: Colors.white),
                        ),
                        Container(
                          width: size.width * 0.15,
                          height: size.width * 0.15,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: Icon(
                            Icons.person,
                            color: AppColors.secondary,
                            size: size.width * 0.15,
                          ),
                        ),
                        Text(
                          'Имейл хаяг: supplier@gmail.com',
                          style: TextStyle(color: Colors.white, fontSize: size.height * 0.01),
                        ),
                      ],
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.shopping_cart),
                    title: const Text('Захиалга'),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.widgets),
                    title: const Text('Бараа бүтээгдэхүүн'),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text('Харилцагч'),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const PartnerPage()));
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.people),
                    title: const Text('Нийлүүлэгч'),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const SupplierPage()));
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.settings),
                    title: const Text('Тохиргоо'),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text('Гарах'),
                    onTap: () {
                      showLogoutDialog(context);
                    },
                  ),
                ],
              ),
            ),
            // appBar: AppBar(
            //   iconTheme: const IconThemeData(color: AppColors.primary),
            //   centerTitle: true,
            //   title: const Text(
            //     'Хэрэглэгчийн байршил',
            //     style: TextStyle(fontSize: 16),
            //   ),
            //   actions: [
            //     IconButton(
            //         icon: const Icon(
            //           Icons.notifications,
            //           color: AppColors.primary,
            //         ),
            //         onPressed: () {
            //           showDialog(
            //               context: context,
            //               builder: ((context) {
            //                 return AlertDialog(
            //                   title: const Text('Захиалгууд'),
            //                   content: const ShoppingCart(),
            //                   actions: [
            //                     TextButton(
            //                       onPressed: () {
            //                         Navigator.pop(context);
            //                       },
            //                       child: const Text('Хаах'),
            //                     ),
            //                   ],
            //                 );
            //               }));
            //         }),
            //     Container(
            //       margin: const EdgeInsets.only(right: 15),
            //       child: badges.Badge(
            //         badgeContent: Text(
            //           "$_basketCount ${shoppingCartProvider.count}",
            //           style: const TextStyle(color: Colors.white, fontSize: 10),
            //         ),
            //         badgeStyle: const badges.BadgeStyle(
            //           badgeColor: Colors.blue,
            //         ),
            //         child: const Icon(
            //           Icons.shopping_basket,
            //           color: Colors.red,
            //         ),
            //       ),
            //     )
            //   ],
            // ),
            appBar: CustomAppBar(),
            body: _pages[_selectedIndex],
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Нүүр',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.search),
                  label: 'Хайх',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.shop_2),
                  label: 'Захиалга',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_sharp),
                  label: 'Бүртгэл',
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
      return LogoutDialog();
    },
  );
}
