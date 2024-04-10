import 'package:flutter/material.dart';
import 'package:pharmo_app/controllers/auth_controller.dart';
import 'package:pharmo_app/screens/suppliers/supplier_page.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:provider/provider.dart';

import 'tabs/cart.dart';
import 'tabs/search.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List _pages = [
    const HomeTab(),
    const SearchScreen(),
    const ShoppingCart(),
    const Center(
      child: Text("Contact"),
    ),
  ];
  int _selectedIndex = 0;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);

    return ChangeNotifierProvider(
      create: (context) => AuthController(),
      child: SafeArea(
        child: Scaffold(
          drawer: Drawer(
            child: ListView(
              children: [
                const DrawerHeader(
                  curve: Curves.bounceIn,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        Text('Profile'),
                        Column(
                          children: [],
                        )
                      ],
                    ),
                  ),
                ),
                ListTile(
                  title: const Text('Item 1'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text('Нийлүүлэгч'),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const SupplierPage()));
                  },
                ),
                ListTile(
                  title: const Text('logout'),
                  onTap: () {
                    authController.logout(context);
                    authController.toggleVisibile();
                  },
                ),
              ],
            ),
          ),
          appBar: AppBar(
            iconTheme: const IconThemeData(color: AppColors.primary),
            centerTitle: true,
            title: const Text(
              'Хэрэглэгчийн байршил',
              style: TextStyle(fontSize: 16),
            ),
            actions: [
              IconButton(
                  icon: const Icon(
                    Icons.notifications,
                    color: AppColors.primary,
                  ),
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: ((context) {
                          return AlertDialog(
                            title: const Text('Захиалгууд'),
                            content: const ShoppingCart(),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('Хаах'),
                              ),
                            ],
                          );
                        }));
                  }),
            ],
          ),
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
      ),
    );
  }
}

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        children: [
          const Text('Home Tab'),
          ElevatedButton(
            onPressed: () {},
            child: const Text('BTn'),
          ),
        ],
      ),
    );
  }
}
