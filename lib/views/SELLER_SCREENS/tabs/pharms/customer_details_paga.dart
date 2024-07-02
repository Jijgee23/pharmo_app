// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:pharmo_app/models/branch.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/views/SELLER_SCREENS/tabs/pharms/brainch_detail.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  String? email;
  Map companyInfo = {};
  @override
  void initState() {
    getBranchList();
    getPharmaInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: '${companyInfo['email']}',
      query: EmailHelper.encodeQueryParameters(<String, String>{
        'subject': 'Бичих зүйлээ оруулна уу!',
      }),
    );
    return Scaffold(
      appBar: AppBar(
        leading: chevronBack(context),
        title: Text(
          widget.custName,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          children: [
            Row(
              children: [
                const Text('Имейл: ', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 10),
                InkWell(
                  child: Text('${companyInfo['email'] ?? '-'}',
                      style: const TextStyle(fontSize: 16)),
                  onTap: () async {
                    if (await canLaunchUrlString(emailLaunchUri.toString())) {
                      await launchUrlString(emailLaunchUri.toString());
                    } else {
                      showFailedMessage(
                        context: context,
                        message:
                            'Имейл илгээх боломжгүй байна. Таны төхөөрөмжид тохирох имейл апп байхгүй байна.',
                      );
                    }
                  },
                ),
              ],
            ),
            Row(
              children: [
                const Text('Утас: ', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 10),
                InkWell(
                  child: Text(
                    '${companyInfo['phone'] ?? '-'}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  onTap: () =>
                      launchUrlString('tel://+976${companyInfo['phone']}'),
                )
              ],
            ),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Салбарууд:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _branchList.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      onTap: () {
                        goto(
                            BranchDetails(
                                customerId: widget.customerId,
                                branchId: _branchList[index].id,
                                branchName: _branchList[index].name),
                            context);
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
          Uri.parse('${dotenv.env['SERVER_URL']}seller/get_pharmacy_info/'),
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
          Uri.parse('${dotenv.env['SERVER_URL']}seller/customer_branch/'),
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

class EmailHelper {
  static String encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((MapEntry<String, String> e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }
}
