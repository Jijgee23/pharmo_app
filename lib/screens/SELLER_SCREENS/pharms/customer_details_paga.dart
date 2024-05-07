// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pharmo_app/models/branch.dart';
import 'package:pharmo_app/screens/SELLER_SCREENS/pharms/brainch_detail.dart';
import 'package:pharmo_app/widgets/snack_message.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher_string.dart';

class CustomerDetailsPage extends StatefulWidget {
  final int customerId;
  final String custName;
  const CustomerDetailsPage({
    super.key,
    required this.customerId,
    required this.custName,
  });
  @override
  State<CustomerDetailsPage> createState() => _CustomerDetailsPageState();
}

class _CustomerDetailsPageState extends State<CustomerDetailsPage> {
  final List<Branch> _branchList = <Branch>[];
  Map companyInfo = {};
  @override
  @override
  void initState() {
    getBranchList();
    getPharmaInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.custName} -ийн дэлгэрэнгүй',
          style: const TextStyle(fontSize: 18),
        ),
        centerTitle: !false,
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text('Эмийн сангийн нэр: ${companyInfo['name']}'),
                  Text('Регистрийн дугаар: ${companyInfo['rd']}'),
                  Text('Имейл хаяг: ${companyInfo['email']}'),
                  Text('Утасны дугаар: ${companyInfo['phone']}'),
                ],
              ),
            ),
            Expanded(
              flex: 5,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.3,
                  child: OutlinedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStatePropertyAll(Colors.green.shade900),
                    ),
                    onPressed: () {
                      launchUrlString('tel://+976${companyInfo['phone']}');
                    },
                    child: const Icon(Icons.call, color: Colors.white),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.3,
                  child: OutlinedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStatePropertyAll(Colors.green.shade900),
                    ),
                    onPressed: () async {},
                    child: const Icon(Icons.mail, color: Colors.white),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  getPharmaInfo() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("access_token");
      final response = await http.post(
          Uri.parse(
              'http://192.168.88.39:8000/api/v1/seller/get_pharmacy_info/'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'pharmaId': widget.customerId,
          }));
      if (response.statusCode == 200) {
        Map res = jsonDecode(utf8.decode(response.bodyBytes));
        Map company = res['company'];
        companyInfo.clear();
        setState(() {
          companyInfo = company;
        });
      } else {
        showFailedMessage(
            context: context, message: 'Хүсэлт амжилтгүй боллоо.');
      }
    } catch (e) {
      showFailedMessage(context: context, message: 'Алдаа гарлаа');
    }
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
