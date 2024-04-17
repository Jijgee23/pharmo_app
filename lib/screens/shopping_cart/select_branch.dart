import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pharmo_app/controllers/auth_controller.dart';
import 'package:pharmo_app/models/sector.dart';
import 'package:pharmo_app/widgets/snack_message.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SelectBranchPage extends StatefulWidget {
  const SelectBranchPage({super.key});
  @override
  State<SelectBranchPage> createState() => _SelectBranchPageState();
}

class _SelectBranchPageState extends State<SelectBranchPage> {
  List<Sector> _branchList = <Sector>[];

  @override
  void initState() {
    getData();
    super.initState();
  }

  getData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("access_token");
      String bearerToken = "Bearer $token";
      final response = await http.get(Uri.parse('http://192.168.88.39:8000/api/v1/branch'), headers: <String, String>{
        'Content-Type': 'application/json; charset=utf-8',
        'Authorization': bearerToken,
      });
      if (response.statusCode == 200) {
        List<dynamic> res = jsonDecode(utf8.decode(response.bodyBytes));
        List<Sector> sectors = (res).map((data) => Sector.fromJson(data)).toList();
        _branchList = sectors;
        print(_branchList.length);
      } else {
        showFailedMessage(message: 'Түр хүлээгээд дахин оролдоно уу!', context: context);
      }
    } catch (e) {
      showFailedMessage(message: 'Өгөгдөл авчрах үед алдаа гарлаа. Админтай холбогдоно уу!', context: context);
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
              itemCount: _branchList.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    onTap: () async {
                      // SharedPreferences prefs = await SharedPreferences.getInstance();
                      // String? token = prefs.getString("access_token");
                      // String bearerToken = "Bearer $token";
                      // final response = await http.get(Uri.parse('http://192.168.88.39:8000/api/v1/branch/'), headers: <String, String>{
                      //   'Content-Type': 'application/json; charset=UTF-8',
                      //   'Authorization': bearerToken,
                      // });
                      // if (response.statusCode == 200) {
                      //   Map res = jsonDecode(response.body);
                      //   await prefs.setString('access_token', res['access_token']);
                      //   await prefs.setString('refresh_token', res['refresh_token']);
                      //   Navigator.push(
                      //       context,
                      //       MaterialPageRoute(
                      //           builder: (context) => SupplierDetail(
                      //                 supp: _branchList[index],
                      //               )));
                      // } else if (response.statusCode == 403) {
                      //   showFailedMessage(message: 'Энэ үйлдлийг хийхэд таны эрх хүрэхгүй байна.', context: context);
                      // } else {
                      //   showFailedMessage(message: 'Дахин оролдоно уу.', context: context);
                      // }
                    },
                    leading: const Icon(Icons.home),
                    title: Text(_branchList[index].name.toString()),
                    subtitle: Text(_branchList[index].id.toString()),
                  ),
                );
              }),
        ),
      ),
    );
  }
}
