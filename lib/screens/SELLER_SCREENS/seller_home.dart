import 'package:flutter/material.dart';
import 'package:pharmo_app/screens/SELLER_SCREENS/pharmacy_list.dart';
import 'package:pharmo_app/screens/SELLER_SCREENS/seller_customer/logout.dart';
import 'package:pharmo_app/screens/SELLER_SCREENS/seller_customer/seller_customer.dart';
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
    const PharmacyList(),
    const SellerCustomerPage(),
    const SellerSettingPage(),
    const SellerSettingPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.secondary,
        unselectedItemColor: AppColors.primary,
        onTap: onTap,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.medical_information), label: 'Эмийн сангууд'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person), label: 'Харилцагчид'),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart), label: 'Захиалга'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        ],
      ),
    );
  }
}
