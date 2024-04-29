import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/auth_provider.dart';
import 'package:pharmo_app/controllers/basket_provider.dart';
import 'package:pharmo_app/screens/DM_SCREENS/tabs/jagger_home.dart';
import 'package:pharmo_app/screens/PA_SCREENS/tabs/cart.dart';
import 'package:pharmo_app/screens/suppliers/supplier_page.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/widgets/appbar/custom_app_bar.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class JaggerDialog extends StatefulWidget {
  const JaggerDialog({super.key});

  @override
  State<JaggerDialog> createState() => _JaggerDialogState();
}

class _JaggerDialogState extends State<JaggerDialog> {
  final List _pages = [
    const HomeJagger(),
    const ShoppingCartHome(),
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
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final cartProvider = Provider.of<BasketProvider>(context, listen: true);
    final authProvider = Provider.of<AuthController>(context, listen: false);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthController>(create: (context) => AuthController()),
      ],
      child: Consumer<AuthController>(builder: (context, authController, _) {
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
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
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
                          'И-мэйл хаяг: ${authProvider.userInfo['email']}',
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
                    onTap: () {},
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
            appBar: const CustomAppBar(
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
                  label: 'Миний сагс',
                ),
                // BottomNavigationBarItem(
                //   icon: Icon(Icons.medical_information),
                //   label: 'Эмийн сан',
                // ),
                // BottomNavigationBarItem(
                //   icon: Icon(Icons.person_sharp),
                //   label: 'Бүртгэл',
                // ),
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
      return const LogoutDialog();
    },
  );
}
