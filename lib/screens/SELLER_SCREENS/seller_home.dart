
import 'package:flutter/material.dart';
import 'package:pharmo_app/screens/PA_SCREENS/tabs/home.dart';
import 'package:pharmo_app/screens/SELLER_SCREENS/location_picker.dart';
import 'package:pharmo_app/screens/shopping_cart/shopping_cart.dart';
import 'package:pharmo_app/utilities/colors.dart';

class SellerHomePage extends StatefulWidget {
  const SellerHomePage({super.key});

  @override
  State<SellerHomePage> createState() => _SellerHomePageState();
}

class _SellerHomePageState extends State<SellerHomePage> {
  int _selectedIndex = 0;
  List<String> orders = [];
  void onTap(index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  final List _pages = [
    const Home(),
    const ShoppingCart(),
    const LocationPicker(),
  ];
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
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
            BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Бүртгэл'),
          ],
        ),
      ),
    );
  }
}
