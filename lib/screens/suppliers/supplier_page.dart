import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pharmo_app/controllers/auth_controller.dart';
import 'package:pharmo_app/models/supplier.dart';
import 'package:pharmo_app/screens/suppliers/supplier_detail_page.dart';
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

  @override
  void initState() {
    getData();
    super.initState();
  }

  getData() async {
    try {
      final response = await http.get(Uri.parse('http://192.168.88.39:8000/api/v1/suppliers'), headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      });
      if (response.statusCode == 200) {
        Map res = json.decode(response.body);
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return ChangeNotifierProvider(
      create: (context) => AuthController(),
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: size.height * 0.13,
          centerTitle: true,
          backgroundColor: const Color(0xFF1B2E3C),
          title: Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
            child: Column(
              children: [
                Text(
                  'Pharmo',
                  style: TextStyle(fontSize: size.height * 0.04, fontStyle: FontStyle.italic, color: Colors.white),
                ),
                Text(
                  'Эмийн бөөний худалдаа,\n захиалгын систем',
                  style: TextStyle(fontSize: size.height * 0.02, fontStyle: FontStyle.italic, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
        body: Container(
          child: ListView.builder(
              itemCount: _supList.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SupplierDetail(
                                    supp: _supList[index],
                                  )));
                    },
                    leading: const Icon(Icons.home),
                    title: Text(_supList[index].name),
                    subtitle: Text(_supList[index].id),
                  ),
                );
              }),
        ),
      ),
    );
  }
}

class TokenManager {
  static const String _tokenKey = 'token';

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }
}
