import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pharmo_app/controllers/auth_controller.dart';
import 'package:pharmo_app/models/supplier.dart';
import 'package:pharmo_app/screens/auth/branch/branch.dart';
import 'package:pharmo_app/widgets/snack_message.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomerBranchList extends StatefulWidget {
  const CustomerBranchList({super.key});
  @override
  State<CustomerBranchList> createState() => _CustomerBranchListState();
}

class _CustomerBranchListState extends State<CustomerBranchList> {
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
        floatingActionButton: FloatingActionButton(onPressed: () {}),
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
                      print(token);
                      String bearerToken = "Bearer $token";
                      final response = await http.post(
                          Uri.parse(
                              'http://192.168.88.39:8000/api/v1/seller/customer_branch/'),
                          headers: <String, String>{
                            'Content-Type': 'application/json; charset=UTF-8',
                            'Authorization': bearerToken,
                          },
                          body: jsonEncode({'customerId': _supList[index].id}));
                      print(response.statusCode);
                      if (response.statusCode == 200) {
                        print(response.statusCode);
                        print(response.body);
                        List<dynamic> data =
                            jsonDecode(utf8.decode(response.bodyBytes));
                        if (data.isNotEmpty) {
                          Map<String, dynamic> res = data[0];
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => CustomerBranchInfo(
                                        id: res['id'],
                                        name: res['name'],
                                      )));
                          // Handle the response
                          print(res['id']); // Example of accessing data
                          print(res['name']); // Example of accessing data
                          // You can then proceed with further processing of the response data
                        }
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
