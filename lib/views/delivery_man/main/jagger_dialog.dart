import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/auth_provider.dart';
import 'package:pharmo_app/controllers/home_provider.dart';
import 'package:pharmo_app/views/delivery_man/tabs/home/jagger_home.dart';
import 'package:pharmo_app/views/pharmacy/tabs/cart/cart.dart';
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
            title: Text('Нүүр хуудас'),
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
      child: InkWell(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade700),
              borderRadius: BorderRadius.circular(15)),
          child: Center(
            child: Text(
              text,
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ),
      ),
    );
  }

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: AppColors.cleanWhite,
        child: Container(

          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const Text(
                  "Системээс гарахдаа итгэлтэй байна уу?",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    decoration: TextDecoration.none,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Icon(Icons.login, color: AppColors.secondary, size: 50),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    button('Үгүй', () {
                      Navigator.of(context).pop();
                    }),
                    button(
                      'Тийм',
                      () {
                        Provider.of<AuthController>(context, listen: false)
                            .logout(context);
                        Provider.of<AuthController>(context, listen: false)
                            .toggleVisibile();
                        Provider.of<HomeProvider>(context, listen: false)
                            .changeIndex(0);
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      );
    },
  );
}
