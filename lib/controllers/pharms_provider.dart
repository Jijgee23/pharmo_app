import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:pharmo_app/models/order_list.dart';
import 'package:pharmo_app/utilities/utils.dart';

class PharmProvider extends ChangeNotifier {
  String baseUrl = '${dotenv.env['SERVER_URL']}';
  List<PharmFullInfo> pharmList = <PharmFullInfo>[];
  List<PharmFullInfo> customeList = <PharmFullInfo>[];
  List<PharmFullInfo> fullList = <PharmFullInfo>[];
  List<PharmFullInfo> goodlist = <PharmFullInfo>[];
  List<PharmFullInfo> badlist = <PharmFullInfo>[];
  List<PharmFullInfo> limitedlist = <PharmFullInfo>[];
  List<OrderList> orderList = <OrderList>[];
  getPharmacyList() async {
    try {
      final beareToken = await getAccessToken();
      final response = await http.get(
        Uri.parse('${baseUrl}seller/pharmacy_list/'),
        headers: getHeader(beareToken),
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
          final bool isCustomer = pharms[i]['isCustomer'];
          final bool isBad = pharms[i]['isBad'];
          final bool isLimited = pharms[i]['debtLimit'] != 0 &&
              pharms[i]['debt'] != 0 &&
              pharms[i]['debt'] > pharms[i]['debtLimit'];
          if (isCustomer == true) {
            customeList.add(PharmFullInfo.fromJson(pharms[i]));
          } else {
            pharmList.add(PharmFullInfo.fromJson(pharms[i]));
          }
          if (isBad == true) {
            badlist.add(PharmFullInfo.fromJson(pharms[i]));
          }
          if(isBad == false && isCustomer == true && isLimited == false){
            goodlist.add(PharmFullInfo.fromJson(pharms[i]));
          }
          if (isLimited == true) {
            limitedlist.add(PharmFullInfo.fromJson(pharms[i]));
          }
          notifyListeners();
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  getOrderList(int customerId) async {
    try {
     final token = await getAccessToken();
      final response = await http.get(
        Uri.parse(
            '${dotenv.env['SERVER_URL']}seller/order_history/?pharmacyId=$customerId'),
        headers: getHeader(token),
      );
      notifyListeners();
      if (response.statusCode == 200) {
        List<dynamic> ordList = jsonDecode(utf8.decode(response.bodyBytes));
        for (int i = 0; i < ordList.length; i++) {
          orderList.add(OrderList.fromJson((ordList[i])));
        }
      }
      notifyListeners();
    } catch (e) {
      // showFailedMessage(message: 'Дахин оролдоно уу.', context: context);
      notifyListeners();
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
