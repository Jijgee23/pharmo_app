import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pharmo_app/models/partner.dart';
import 'package:pharmo_app/screens/partners/partner_detail.dart';
import 'package:pharmo_app/widgets/snack_message.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PartnerPage extends StatefulWidget {
  const PartnerPage({super.key});
  @override
  State<PartnerPage> createState() => _PartnerPageState();
}

class _PartnerPageState extends State<PartnerPage> {
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
          for (var partnerData in partners) {
            var partnerInfo = PartnerInfo.fromJson(partnerData['partner']);
            var model = Partner(
              id: partnerData['id'],
              partner: partnerInfo,
              isBad: partnerData['isBad'],
              badCnt: partnerData['badCnt'],
              debt: partnerData['debt'],
              debtLimit: partnerData['debtLimit'],
            );
            _partnerList.add(model);
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
        title: const Text('Харилцагчид'),
        actions: [
          IconButton(
            onPressed: () {
              getPartners();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Container(
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
                        name: _partnerList[index].partner.name,
                        rd: _partnerList[index].partner.rd,
                        email: _partnerList[index].partner.email,
                        phone: _partnerList[index].partner.phone,
                        isbad: _partnerList[index].isBad,
                        basCount: _partnerList[index].badCnt,
                        debt: _partnerList[index].debt,
                        debtLimit: _partnerList[index].debtLimit,
                      ),
                    ),
                  );
                },
                leading: const Icon(Icons.person),
                title: Text(_partnerList[index].partner.name),
                subtitle: Text(_partnerList[index].partner.rd),
              ),
            );
          },
        ),
      ),
    );
  }
}
