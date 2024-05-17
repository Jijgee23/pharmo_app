import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class PharmProvider extends ChangeNotifier {
  String baseUrl = '${dotenv.env['SERVER_URL']}';
  List<PharmFullInfo> pharmList = <PharmFullInfo>[];
  List<PharmFullInfo> customeList = <PharmFullInfo>[];
  List<PharmFullInfo> fullList = <PharmFullInfo>[];
  List<PharmFullInfo> goodlist = <PharmFullInfo>[];
  List<PharmFullInfo> badlist = <PharmFullInfo>[];
  List<PharmFullInfo> limitedlist = <PharmFullInfo>[];

  getPharmacyList() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');
      final response = await http.get(
        Uri.parse('${baseUrl}seller/pharmacy_list/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        Map data = jsonDecode(utf8.decode(response.bodyBytes));
        List<dynamic> pharms = data['pharmacies'];
        fullList.clear();
        pharmList.clear();
        customeList.clear();
        badlist.clear();
        goodlist.clear();
        limitedlist.clear();
        for (int i = 0; i < pharms.length; i++) {
          fullList.add(PharmFullInfo.fromJson(pharms[i]));
          // if (pharms[i]['isCustomer'] == true) {
          //   customeList.add(PharmFullInfo.fromJson(pharms[i]));
          //   if (pharms[i]['isBad'] == true) {
          //     badlist.add(PharmFullInfo.fromJson(pharms[i]));
          //   } else {
          //     if (pharms[i]['debt'] != 0 &&
          //         pharms[i]['debtLimit'] != 0 &&
          //         pharms[i]['debt'] >= pharms[i]['debtLimit']) {
          //       limitedlist.add(PharmFullInfo.fromJson(pharms[i]));
          //     } else {
          //       goodlist.add(PharmFullInfo.fromJson(pharms[i]));
          //     }
          //   }
          // } else {
          //   pharmList.add(PharmFullInfo.fromJson(pharms[i]));
          // }
          notifyListeners();
        }
      }
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }
}

class PharmFullInfo {
  int id;
  String name;
  bool isCustomer;
  int badCnt;
  bool isBad;
  double debt;
  double debtLimit;
  PharmFullInfo(
    this.id,
    this.name,
    this.isCustomer,
    this.badCnt,
    this.isBad,
    this.debt,
    this.debtLimit,
  );
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'isCustomer': isCustomer,
      'badCnt': badCnt,
      'isBad': isBad,
      'debt': debt,
      'debtLimit': debtLimit,
    };
  }

  factory PharmFullInfo.fromJson(Map<String, dynamic> json) {
    return PharmFullInfo(
      json['id'],
      json['name'],
      json['isCustomer'],
      json['badCnt'],
      json['isBad'],
      json['debt'].toDouble(),
      json['debtLimit'].toDouble(),
    );
  }
}
