// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pharmo_app/models/branch.dart';
import 'package:pharmo_app/screens/SELLER_SCREENS/pharms/brainch_detail.dart';
import 'package:pharmo_app/widgets/snack_message.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class CustomerBranchList extends StatefulWidget {
  final int customerId;
  final String custName;
  const CustomerBranchList({
    super.key,
    required this.customerId,
    required this.custName,
  });

  @override
  State<CustomerBranchList> createState() => _CustomerBranchListState();
}

class _CustomerBranchListState extends State<CustomerBranchList> {
  final List<Branch> _branchList = <Branch>[];
  @override
  @override
  void initState() {
    getBranchList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.custName} -ийн салбарууд'),
        centerTitle: !false,
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        child: ListView.builder(
          itemCount: _branchList.length,
          itemBuilder: (context, index) {
            return Card(
              child: ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BranchDetails(
                        customerId: widget.customerId,
                        branchId: _branchList[index].id,
                        branchName: _branchList[index].name,
                      ),
                    ),
                  );
                },
                leading: const Icon(
                  Icons.house,
                  color: Colors.blue,
                ),
                title: Text(_branchList[index].name),
              ),
            );
          },
        ),
      ),
    );
  }

  getBranchList() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.remove('branchId');
      String? token = prefs.getString("access_token");
      final response = await http.post(
          Uri.parse('http://192.168.88.39:8000/api/v1/seller/customer_branch/'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'customerId': widget.customerId,
          }));
      if (response.statusCode == 200) {
        final res = jsonDecode(utf8.decode(response.bodyBytes));
        _branchList.clear();
        setState(() {
          for (int i = 0; i < res.length; i++) {
            _branchList.add(Branch.fromJson(res[i]));
          }
        });
      } else {
        showFailedMessage(
            context: context, message: 'Салбарын мэдээлэл татаж чадсангүй');
      }
    } catch (e) {
      showFailedMessage(context: context, message: 'Алдаа гарлаа');
    }
  }
}
