import 'package:flutter/material.dart';
import 'package:pharmo_app/screens/SELLER_SCREENS/branch/branch.dart';
import 'package:pharmo_app/screens/SELLER_SCREENS/pharmacy_list.dart';
import 'package:pharmo_app/screens/SELLER_SCREENS/register_pharm/resgister_pharm.dart';
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
    const SellerCustomerPage(),
    const PharmacyList(),
    const RegisterPharm(),
    const ShoppingCart(),
    const CustomerBranchList(
      id: 52,
      name: 'S',
    ),
  ];

  @override
  void initState() {
    super.initState();
  }

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
            BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart), label: 'Захиалга'),
            BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart), label: 'Salbar'),
          ],
        ),
      ),
    );
  }
}
