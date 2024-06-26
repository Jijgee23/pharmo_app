// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:pharmo_app/models/supplier.dart';
import 'package:pharmo_app/widgets/snack_message.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SuplierList extends StatefulWidget {
  const SuplierList({super.key});
  @override
  State<SuplierList> createState() => _SuplierListState();
}

class _SuplierListState extends State<SuplierList> {
  final List<Supplier> _supList = <Supplier>[];

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
    return Scaffold(
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
                    await prefs.remove('suplierId');
                    String? token = prefs.getString("access_token");
                    await prefs.setString('suplierId', _supList[index].id.toString());
                    String bearerToken = "Bearer $token";
                    final response = await http.post(
                        Uri.parse(
                            '${dotenv.env['SERVER_URL']}seller/customer_branch/'),
                        headers: <String, String>{
                          'Content-Type': 'application/json; charset=UTF-8',
                          'Authorization': bearerToken,
                        },
                        body: jsonEncode({'customerId': _supList[index].id}));
                    if (response.statusCode == 200) {
                      List<dynamic> data =
                          jsonDecode(utf8.decode(response.bodyBytes));
                      if (data.isNotEmpty) {
                      }
                    } else {
                      showFailedMessage(
                          message: 'Дахин оролдоно уу.', context: context);
                    }
                  },
                  leading: const Icon(Icons.home),
                  title: Text(_supList[index].name),
                  subtitle: Text(_supList[index].id.toString()),
                ),
              );
            }),
      ),
    );
  }
}
