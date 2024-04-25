import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pharmo_app/models/order.dart';
import 'package:pharmo_app/models/seller_order.dart';
import 'package:pharmo_app/screens/SELLER_SCREENS/branch/branch.dart';
import 'package:pharmo_app/screens/SELLER_SCREENS/pharmacy_list.dart';
import 'package:pharmo_app/screens/SELLER_SCREENS/register_pharm/resgister_pharm.dart';
import 'package:pharmo_app/screens/SELLER_SCREENS/seller_customer/seller_customer.dart';
import 'package:pharmo_app/screens/shopping_cart/shopping_cart.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/widgets/snack_message.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class SellerHomePage extends StatefulWidget {
  const SellerHomePage({super.key});

  @override
  State<SellerHomePage> createState() => _SellerHomePageState();
}

class _SellerHomePageState extends State<SellerHomePage> {
  int _selectedIndex = 0;
  List<String> orders = [];

  getOrders() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');
      final response = await http.get(
        Uri.parse('http://192.168.88.39:8000/api/v1/order/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token'
        },
      );
      Map res = jsonDecode(utf8.decode(response.bodyBytes));
      //  orders.clear();
      print(res['results'][0]['user']['name']);
      for (int i = 0; i < res['results'].length; i++) {
        // orders.add(SellerOrder.fromJson(res['results'][i]));
        orders.add(res['results'][i]['user']['name']);
        //    print(res['results'][i]['user']['name']);
      }
      print(response.statusCode);
    } catch (e) {
      showFailedMessage(message: 'Data not found.', context: context);
    }
  }

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
        floatingActionButton: FloatingActionButton(onPressed: () {
          getOrders();
        }),
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
