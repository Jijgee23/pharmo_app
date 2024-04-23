import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pharmo_app/models/branch.dart';
import 'package:pharmo_app/screens/SELLER_SCREENS/branch/brainch_detail.dart';
import 'package:pharmo_app/widgets/snack_message.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class CustomerBranchList extends StatefulWidget {
  final int id;
  final String name;
  const CustomerBranchList({
    super.key,
    required this.id,
    required this.name,
  });

  @override
  State<CustomerBranchList> createState() => _CustomerBranchListState();
}

class _CustomerBranchListState extends State<CustomerBranchList> {
  final List<Branch> _branchList = <Branch>[];
  @override
  @override
  void initState() {
    getSupId();
    super.initState();
  }

  String? suplierId = '';
  getSupId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? supId = prefs.getString('suplierId');
    suplierId = supId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        child: ListView.builder(
          itemCount: 1,
          itemBuilder: (context, index) {
            return Card(
              child: ListTile(
                onTap: () async {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  String? token = prefs.getString("access_token");
                  final response = await http.post(
                      Uri.parse(
                          'http://192.168.88.39:8000/api/v1/seller/customer_branch/'),
                      headers: <String, String>{
                        'Content-Type': 'application/json; charset=UTF-8',
                        'Authorization': 'Bearer $token',
                      },
                      body: jsonEncode(
                          {'customerId': suplierId, 'branchId': widget.id}));
                  prefs.setString('suplierId', suplierId.toString());
                  prefs.setString('branchId', widget.id.toString());
                  if (response.statusCode == 200) {
                    Map<dynamic, dynamic> res =
                        jsonDecode(utf8.decode(response.bodyBytes));
                    _branchList.clear();
                    Map<String, dynamic> manager = res['manager'];

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BranchDetails(
                          id: res['id'],
                          name: res['name'],
                          phone: res['phone'],
                          address: res['address'],
                          managerName: manager['name'],
                          managerEmail: manager['email'],
                          managerPhone: manager['phone'],
                        ),
                      ),
                    );
                  } else {
                    showFailedMessage(
                        context: context,
                        message: 'Салбарын мэдээлэл татаж чадсангүй');
                  }
                },
                title: Text('Салбарийн дугаар: ${widget.id}'),
                subtitle: Text('Салбарийн нэр: ${widget.name}'),
              ),
            );
          },
        ),
      ),
    );
  }
}
