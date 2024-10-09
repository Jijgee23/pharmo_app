// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:pharmo_app/models/branch.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/views/seller/tabs/pharms/brainch_detail.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:pharmo_app/widgets/icon/custom_icon.dart';
import 'package:pharmo_app/widgets/others/chevren_back.dart';
import 'package:pharmo_app/widgets/others/twoItemsRow.dart';
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
        leading: const ChevronBack(),
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
            TwoitemsRow(
              title: 'Имейл:',
              text: '${companyInfo['email'] ?? '-'}',
              onTapText: () async {
                if (await canLaunchUrlString(emailLaunchUri.toString())) {
                  await launchUrlString(emailLaunchUri.toString());
                } else {
                  message(
                    context: context,
                    message:
                        'Имейл илгээх боломжгүй байна. Таны төхөөрөмжид тохирох имейл апп байхгүй байна.',
                  );
                }
              },
              fontSize: 16,
              color: Colors.blueGrey.shade800,
            ),
            TwoitemsRow(
              title: 'Утас:',
              text: '${companyInfo['phone'] ?? '-'}',
              fontSize: 16,
              color: Colors.blueGrey.shade800,
              onTapText: () =>
                  launchUrlString('tel://+976${companyInfo['phone']}'),
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
                  return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade600)),
                      child: InkWell(
                        splashColor: Colors.grey.shade300,
                        onTap: () {
                          goto(
                              BranchDetails(
                                  customerId: widget.customerId,
                                  branchId: _branchList[index].id,
                                  branchName: _branchList[index].name),
                              context);
                        },
                        child: Row(
                          children: [
                            const CustomIcon(name: 'drugstore1.png'),
                            const SizedBox(width: 10),
                            Text(
                              _branchList[index].name,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ));
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
      String token = await getAccessToken();
      final response = await http.post(
          Uri.parse('${dotenv.env['SERVER_URL']}seller/get_pharmacy_info/'),
          headers: getHeader(token),
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
        message(
            context: context, message: 'Хүсэлт амжилтгүй боллоо.');
      }
    } catch (e) {
      message(context: context, message: 'Алдаа гарлаа');
    }
  }

  getBranchList() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String bearerToken = await getAccessToken();
      prefs.remove('branchId');
      final response = await http.post(
          Uri.parse('${dotenv.env['SERVER_URL']}seller/customer_branch/'),
          headers: getHeader(bearerToken),
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
        message(
            context: context, message: 'Салбарын мэдээлэл татаж чадсангүй');
      }
    } catch (e) {
      message(context: context, message: 'Алдаа гарлаа');
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
