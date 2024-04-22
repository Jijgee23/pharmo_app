import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pharmo_app/models/partner.dart';
import 'package:pharmo_app/screens/SELLER_SCREENS/seller_customer/seller_customer_detail.dart';
import 'package:pharmo_app/utilities/colors.dart';
import 'package:pharmo_app/widgets/snack_message.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SellerCustomerPage extends StatefulWidget {
  const SellerCustomerPage({super.key});
  @override
  State<SellerCustomerPage> createState() => _SellerCustomerPageState();
}

class _SellerCustomerPageState extends State<SellerCustomerPage> {
  final List<Partner> _partnerList = <Partner>[];
  @override
  void initState() {
    getPartners();
    super.initState();
  }

  getPartners() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');
      final response = await http.get(
        Uri.parse('http://192.168.88.39:8000/api/v1/seller/customer_list/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        Map res = jsonDecode(utf8.decode(response.bodyBytes));
        List<dynamic> partners = res['partners'];
        _partnerList.clear();
        setState(() {
          for (int i = 0; i < partners.length; i++) {
            _partnerList.add(Partner.fromJson(partners[i]));
          }
        });
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      showFailedMessage(message: 'Дахин оролдоно уу.', context: context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Харилцагч эмийн сангууд'),
      ),
      body: _partnerList.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
              child: ListView.builder(
                itemCount: _partnerList.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PartnerDetail(
                              partner: _partnerList[index],
                            ),
                          ),
                        );
                      },
                      leading: const Icon(
                        Icons.medical_services,
                        color: AppColors.secondary,
                      ),
                      title: Text(
                          _partnerList[index].partnerDetails.name.toString()),
                      subtitle: Text(
                          _partnerList[index].partnerDetails.email.toString()),
                      trailing: Icon(Icons.chevron_right_rounded),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
