import 'package:flutter/material.dart';
import 'package:pharmo_app/screens/PA_SCREENS/tabs/home.dart';
import 'package:pharmo_app/screens/SELLER_SCREENS/logout.dart';
import 'package:pharmo_app/screens/SELLER_SCREENS/pharmacy_list.dart';
import 'package:pharmo_app/screens/SELLER_SCREENS/seller_customer/seller_customer.dart';
import 'package:pharmo_app/screens/shopping_cart/shopping_cart.dart';
import 'package:pharmo_app/utilities/colors.dart';

class SellerHomePage extends StatefulWidget {
  const SellerHomePage({super.key});

  @override
  State<SellerHomePage> createState() => _SellerHomePageState();
}

class _SellerHomePageState extends State<SellerHomePage> {
  int _selectedIndex = 0;
  void onTap(index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List _pages = [
    const Home(),
    const PharmacyList(),
    const SellerCustomerPage(),
    const ShoppingCart(),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Pharmo',
            style: TextStyle(color: AppColors.primary),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(
                Icons.notifications,
                color: AppColors.primary,
              ),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(
                Icons.logout,
                color: AppColors.primary,
              ),
              onPressed: () {
                showLogoutDialog(context);
              },
            ),
          ],
        ),
        body: _pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          selectedItemColor: AppColors.secondary,
          unselectedItemColor: AppColors.primary,
          onTap: onTap,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Нүүр'),
            BottomNavigationBarItem(
                icon: Icon(Icons.medical_information), label: 'Эмийн сангууд'),
            BottomNavigationBarItem(
                icon: Icon(Icons.person), label: 'Харилцагчид'),
            BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart), label: 'Захиалга'),
          ],
        ),
      ),
    );
  }
}
