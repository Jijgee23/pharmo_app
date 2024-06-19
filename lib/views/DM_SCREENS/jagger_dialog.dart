import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/auth_provider.dart';
import 'package:pharmo_app/views/DM_SCREENS/tabs/jagger_home.dart';
import 'package:pharmo_app/views/PA_SCREENS/tabs/cart.dart';
import 'package:pharmo_app/views/public_uses/suppliers/supplier_page.dart';
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
        return Scaffold(
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
                        style: TextStyle(
                            color: Colors.white, fontSize: size.height * 0.01),
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
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const SupplierPage()));
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
        );
      }),
    );
  }
}

void showLogoutDialog(BuildContext context) {
  Widget button(String text, VoidCallback onPressed) {
    return SizedBox(
      width: 100,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.grey, width: 2),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(color: Colors.black87),
        ),
      ),
    );
  }

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 100),
            child: Container(
              height: 250,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text(
                    'Системээс гарахдаа итгэлтэй байна уу?',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.primary,
                      decoration: TextDecoration.none,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Icon(Icons.logout_sharp,
                      color: AppColors.secondary, size: 50),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      button('Үгүй', () => Navigator.pop(context)),
                      button(
                        'Тийм',
                        () {
                          Provider.of<AuthController>(context, listen: false)
                              .logout(context);
                          Provider.of<AuthController>(context, listen: false)
                              .toggleVisibile();
                        },
                      ),
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      );
    },
  );
}
