import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:pharmo_app/controllers/auth_provider.dart';
import 'package:pharmo_app/models/supplier.dart';
import 'package:pharmo_app/screens/PA_SCREENS/tabs/home.dart';
import 'package:pharmo_app/screens/PA_SCREENS/tabs/search.dart';
import 'package:pharmo_app/screens/PA_SCREENS/shopping_cart/shopping_cart.dart';
import 'package:pharmo_app/screens/suppliers/supplier_detail_page.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/widgets/snack_message.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SupplierPage extends StatefulWidget {
  const SupplierPage({super.key});
  @override
  State<SupplierPage> createState() => _SupplierPageState();
}

class _SupplierPageState extends State<SupplierPage> {
  final List<Supplier> _supList = <Supplier>[];
  final List pages = [
    const Home(),
    const SearchScreen(),
    const ShoppingCart(),
    const Home(),
  ];
  int _selectedIndex = 0;

  @override
  void initState() {
    getData();
    super.initState();
  }

  getData() async {
    try {
      final response = await http.get(
          Uri.parse('${dotenv.env['SERVER_URL']}suppliers'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=utf-8',
          });
      if (response.statusCode == 200) {
        // Map res = json.decode(response.body);
        Map res = jsonDecode(utf8.decode(response.bodyBytes));
        print(res);
        setState(() {
          res.forEach((key, value) {
            var model = Supplier(key, value);
            _supList.add(model);
          });
        });
      } else {
        showFailedMessage(
            message: 'Түр хүлээгээд дахин оролдоно уу!', context: context);
      }
    } catch (e) {
      showFailedMessage(
          message: 'Өгөгдөл авчрах үед алдаа гарлаа. Админтай холбогдоно уу!',
          context: context);
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthController(),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            'Нийлүүлэгч',
            style: TextStyle(fontSize: 18),
          ),
          actions: [
            IconButton(
                icon: const Icon(
                  Icons.notifications,
                  color: Colors.blue,
                ),
                onPressed: () {}),
            IconButton(
                icon: const Icon(
                  Icons.shopping_basket,
                  color: Colors.red,
                ),
                onPressed: () {}),
          ],
        ),
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          child: ListView.builder(
              itemCount: _supList.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    onTap: () async {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      String? token = prefs.getString("access_token");
                      String bearerToken = "Bearer $token";
                      final response = await http.post(
                          Uri.parse('${dotenv.env['SERVER_URL']}pick/'),
                          headers: <String, String>{
                            'Content-Type': 'application/json; charset=UTF-8',
                            'Authorization': bearerToken,
                          },
                          body: jsonEncode({'pId': _supList[index].id}));
                      if (response.statusCode == 200) {
                        Map<String, dynamic> res = jsonDecode(response.body);
                        await prefs.setString(
                            'access_token', res['access_token']);
                        await prefs.setString(
                            'refresh_token', res['refresh_token']);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SupplierDetail(
                                      supp: _supList[index],
                                    )));
                      } else if (response.statusCode == 403) {
                        showFailedMessage(
                            message:
                                'Энэ үйлдлийг хийхэд таны эрх хүрэхгүй байна.',
                            context: context);
                      } else {
                        showFailedMessage(
                            message: 'Дахин оролдоно уу.', context: context);
                      }
                    },
                    leading: const Icon(Icons.home),
                    title: Text(_supList[index].name),
                    subtitle: Text(_supList[index].id),
                  ),
                );
              }),
        ),
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
  }
}
