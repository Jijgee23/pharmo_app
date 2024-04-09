import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pharmo_app/models/supplier.dart';
import 'package:pharmo_app/screens/login_page.dart';
import 'package:pharmo_app/widgets/snack_message.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SupplierDetail extends StatefulWidget {
  final Supplier supp;

  const SupplierDetail({Key? key, required this.supp}) : super(key: key);

  @override
  State<SupplierDetail> createState() => _SupplierDetailState();
}

class _SupplierDetailState extends State<SupplierDetail> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDataById();
  }

  getDataById() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // var token = prefs.getString("accessToken");
      String? token = await TokenManager.getToken();
      String ss = 'Bearer $token';
      print(ss);
      final response = await http.post(Uri.parse('http://192.168.88.39:8000/api/v1/pick/'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': ss,
          },
          body: jsonEncode({'pId': widget.supp.id}));
      print(response.body);
    } catch (e) {
      showFailedMessage(message: 'Өгөгдөл авчрах үед алдаа гарлаа. Админтай холбогдоно уу!', context: context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
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
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Full Details",
                style: TextStyle(fontWeight: FontWeight.w600, color: Colors.blueGrey, fontSize: 20),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  const Text('Name', style: TextStyle(color: Colors.teal, fontSize: 16, fontWeight: FontWeight.w600)),
                  Padding(
                    padding: const EdgeInsets.only(left: 30),
                    child: Text(widget.supp.name, style: const TextStyle(fontSize: 16)),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  const Text('Contact', style: TextStyle(color: Colors.teal, fontSize: 16, fontWeight: FontWeight.w600)),
                  Padding(
                    padding: const EdgeInsets.only(left: 25),
                    child: Text(widget.supp.id, style: const TextStyle(fontSize: 16)),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Description', style: TextStyle(color: Colors.teal, fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(widget.supp.name, style: const TextStyle(fontSize: 16)),
                ],
              )
            ],
          ),
        ));
  }
}
