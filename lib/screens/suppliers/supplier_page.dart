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
      final response = await http.get(
          Uri.parse('http://192.168.88.39:8000/api/v1/suppliers'),
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
                          Uri.parse('http://192.168.88.39:8000/api/v1/pick/'),
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
                        
                      } else if (response.statusCode == 403) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SupplierDetail(
                                      supp: _supList[index],
                                    )));
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
      ),
    );
  }
}
