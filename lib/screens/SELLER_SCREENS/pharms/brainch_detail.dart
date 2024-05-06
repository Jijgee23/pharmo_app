// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pharmo_app/widgets/snack_message.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher_string.dart';

// ignore: must_be_immutable
class BranchDetails extends StatefulWidget {
  final int customerId;
  final int branchId;
  final String branchName;
  const BranchDetails({
    super.key,
    required this.customerId,
    required this.branchId,
    required this.branchName,
  });

  @override
  State<BranchDetails> createState() => _BranchDetailsState();
}

class _BranchDetailsState extends State<BranchDetails> {
  Map<dynamic, dynamic> storeList = {};
  @override
  void initState() {
    getBranchDetail();
    super.initState();
  }

  getBranchDetail() async {
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
          body: jsonEncode(
              {'customerId': widget.customerId, 'branchId': widget.branchId}));
      if (response.statusCode == 200) {
        Map res = jsonDecode(utf8.decode(response.bodyBytes));
        print(res);
        storeList.clear();
        setState(() {
          storeList = res;
        });
        return res;
      } else {
        showFailedMessage(
            context: context, message: 'Салбарын мэдээлэл татаж чадсангүй');
      }
    } catch (e) {
      showFailedMessage(context: context, message: 'Алдаа гарлаа');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.branchName}-н дэлгэрэнгүй мэдээлэл',
          style: const TextStyle(fontSize: 14),
        ),
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 40),
        child: Center(
          child: storeList.isEmpty
              ? const Center(
                  child: Text(
                    'Салбарын мэдээлэл олдсонгүй',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.red,
                    ),
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Салбарын нэр: ${storeList['name']}',
                          style: const TextStyle(
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          'Салбарын утас: ${storeList['phone']}',
                          style: const TextStyle(
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          'Салбарын хаяг: ${storeList['address']}',
                          style: const TextStyle(
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          'Салбарын менежерийн нэр: ${storeList['manager']['name']}',
                          style: const TextStyle(
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          'Салбарын менежер имейл: ${storeList['manager']['email']}',
                          style: const TextStyle(
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          'Салбарын менежер утас: ${storeList['manager']['phone']}',
                          style: const TextStyle(
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.3,
                          child: OutlinedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStatePropertyAll(
                                  Colors.green.shade900),
                            ),
                            onPressed: () {
                              launchUrlString(
                                  'tel://+976${storeList['manager']['phone']}');
                            },
                            child: const Icon(Icons.call, color: Colors.white),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.3,
                          child: OutlinedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStatePropertyAll(
                                  Colors.green.shade900),
                            ),
                            onPressed: () async {},
                            child: const Icon(Icons.mail, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
