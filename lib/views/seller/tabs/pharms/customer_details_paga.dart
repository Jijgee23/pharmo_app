// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:pharmo_app/models/branch.dart';
import 'package:pharmo_app/utilities/constants.dart';
import 'package:pharmo_app/utilities/utils.dart';
import 'package:pharmo_app/views/seller/tabs/pharms/brainch_detail.dart';
import 'package:pharmo_app/widgets/ui_help/box.dart';
import 'package:pharmo_app/widgets/defaultBox.dart';
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
    final size = MediaQuery.of(context).size;
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: '${companyInfo['email']}',
      query: EmailHelper.encodeQueryParameters(<String, String>{
        'subject': 'Бичих зүйлээ оруулна уу!',
      }),
    );
    return Scaffold(
      body: DefaultBox(
        title: widget.custName,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Box(
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
                    color: Colors.blueGrey.shade800,
                  ),
                  TwoitemsRow(
                    title: 'Утас:',
                    text: '${companyInfo['phone'] ?? '-'}',
                    color: Colors.blueGrey.shade800,
                    onTapText: () =>
                        launchUrlString('tel://+976${companyInfo['phone']}'),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              child: const Text(
                'Салбарууд:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
            Expanded(
              child: Box(
                child: SingleChildScrollView(
                  child: Column(
                      children: _branchList
                          .map(
                            (branch) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              margin: const EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [Constants.defaultShadow]),
                              child: InkWell(
                                splashColor: Colors.grey.shade300,
                                onTap: () {
                                  goto(
                                      BranchDetails(
                                          customerId: widget.customerId,
                                          branchId: branch.id,
                                          branchName: branch.name),
                                      context);
                                },
                                child: Row(
                                  children: [
                                    const CustomIcon(name: 'drugstore1.png'),
                                    SizedBox(width: size.width * 0.03),
                                    Text(
                                      branch.name,
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                          .toList()),
                ),
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
        message(context: context, message: 'Хүсэлт амжилтгүй боллоо.');
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
        message(context: context, message: 'Салбарын мэдээлэл татаж чадсангүй');
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
