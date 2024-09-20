// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:pharmo_app/views/seller/tabs/pharms/customer_details_paga.dart';
import 'package:pharmo_app/widgets/dialog_and_messages/snack_message.dart';
import 'package:pharmo_app/widgets/others/chevren_back.dart';
import 'package:pharmo_app/widgets/others/twoItemsRow.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
          Uri.parse('${dotenv.env['SERVER_URL']}seller/customer_branch/'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(
              {'customerId': widget.customerId, 'branchId': widget.branchId}));
      if (response.statusCode == 200) {
        Map res = jsonDecode(utf8.decode(response.bodyBytes));
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
        leading: const ChevronBack(),
        title: Text(
          widget.branchName,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Салбарын мэдээлэл',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TwoitemsRow(
                      title: 'Утас:',
                      text: '${storeList['phone'] ?? '-'}',
                      onTapText: () =>
                          launchUrlString('tel://+976${storeList['phone']}'),
                      fontSize: 16,
                    ),
                    TwoitemsRow(
                        title: 'Хаяг:', text: '${storeList['address'] ?? '-'}'),
                    const SizedBox(
                      height: 15,
                    ),
                    const Text(
                      'Салбарын менежерийн мэдээлэл',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TwoitemsRow(
                        title: 'Нэр:',
                        text: '${storeList['manager']['name'] ?? '-'}'),
                    TwoitemsRow(
                      title: 'Имейл:',
                      text: '${storeList['manager']['email'] ?? '-'}',
                      onTapText: () async {
                        final Uri emailLaunchUri = Uri(
                          scheme: 'mailto',
                          path: '${storeList['manager']['email'] ?? '-'}',
                          query: EmailHelper
                              .encodeQueryParameters(<String, String>{
                            'subject': 'Бичих зүйлээ оруулна уу!',
                          }),
                        );
                        if (await canLaunchUrlString(
                            emailLaunchUri.toString())) {
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
                    TwoitemsRow(
                      title: 'Утас:',
                      text: '${storeList['manager']['phone'] ?? '-'}',
                      onTapText: () => launchUrlString(
                          'tel://+976${storeList['manager']['phone']}'),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
