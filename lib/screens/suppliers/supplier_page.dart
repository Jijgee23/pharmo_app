import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pharmo_app/controllers/auth_provider.dart';
import 'package:pharmo_app/controllers/basket_provider.dart';
import 'package:pharmo_app/models/supplier.dart';
import 'package:pharmo_app/screens/PA_SCREENS/tabs/home.dart';
import 'package:pharmo_app/screens/PA_SCREENS/tabs/search.dart';
import 'package:pharmo_app/screens/suppliers/supplier_detail_page.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/widgets/appbar/custom_app_bar.dart';
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
  ];
  int _selectedIndex = 0;

  @override
  void initState() {
    getData();
    super.initState();
  }

  getData() async {
    try {
      final response = await http.get(Uri.parse('http://192.168.88.39:8000/api/v1/suppliers'), headers: <String, String>{
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
        showFailedMessage(message: 'Түр хүлээгээд дахин оролдоно уу!', context: context);
      }
    } catch (e) {
      showFailedMessage(message: 'Өгөгдөл авчрах үед алдаа гарлаа. Админтай холбогдоно уу!', context: context);
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final basketProvider = Provider.of<BasketProvider>(context, listen: true);
    return Scaffold(
      // appBar: AppBar(
      //   iconTheme: const IconThemeData(color: AppColors.primary),
      //   centerTitle: true,
      //   title: const Text(
      //     'Нийлүүлэгч',
      //     style: TextStyle(fontSize: 16),
      //   ),
      //   actions: [
      //     Container(
      //       margin: const EdgeInsets.only(right: 15),
      //       child: InkWell(
      //         onTap: () {
      //           Navigator.push(context, MaterialPageRoute(builder: (_) => const ShoppingCart()));
      //         },
      //         child: badges.Badge(
      //           badgeContent: Text(
      //             "${basketProvider.count}",
      //             style: const TextStyle(color: Colors.white, fontSize: 11),
      //           ),
      //           badgeStyle: const badges.BadgeStyle(
      //             badgeColor: Colors.blue,
      //           ),
      //           child: const Icon(
      //             Icons.shopping_basket,
      //             color: Colors.red,
      //           ),
      //         ),
      //       ),
      //     ),
      //   ],
      // ),
      appBar: const CustomAppBar(
        title: 'Нийлүүлэгч',
      ),
      body: ChangeNotifierProvider(
        create: (context) => AuthController(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          child: ListView.builder(
              itemCount: _supList.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    onTap: () async {
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      String? token = prefs.getString("access_token");
                      String bearerToken = "Bearer $token";
                      final response = await http.post(Uri.parse('http://192.168.88.39:8000/api/v1/pick/'),
                          headers: <String, String>{
                            'Content-Type': 'application/json; charset=UTF-8',
                            'Authorization': bearerToken,
                          },
                          body: jsonEncode({'pId': _supList[index].id}));
                      if (response.statusCode == 200) {
                        Map<String, dynamic> res = jsonDecode(response.body);
                        await prefs.setString('access_token', res['access_token']);
                        await prefs.setString('refresh_token', res['refresh_token']);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SupplierDetail(
                                      supp: _supList[index],
                                    )));
                      } else if (response.statusCode == 403) {
                        showFailedMessage(message: 'Энэ үйлдлийг хийхэд таны эрх хүрэхгүй байна.', context: context);
                      } else {
                        showFailedMessage(message: 'Дахин оролдоно уу.', context: context);
                      }
                    },
                    leading: const Icon(Icons.home),
                    title: Text(_supList[index].name),
                    subtitle: Text(_supList[index].id),
                  ),
                );
              }),
        ),
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
            label: 'Миний сагс',
          ),
        ],
        selectedItemColor: AppColors.secondary,
        unselectedItemColor: AppColors.primary,
      ),
    );
  }
}
